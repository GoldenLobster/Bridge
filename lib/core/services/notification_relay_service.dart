import 'dart:async';
import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import '../database/database.dart' hide Message;
import '../models/message.dart';
import '../networking/connection_manager.dart';
import '../networking/message_router.dart';
import 'app_settings.dart';

/// Listens for system notifications on Android via notification_listener_service, relays them to paired desktop devices over TCP, and handles dismiss sync bidirectionally.
class NotificationRelayService {
  final ConnectionManager _connectionManager;
  final MessageRouter _router;
  final AppSettings _settings;
  final BridgeDatabase _db;
  final String _ownPackageName;
  StreamSubscription<ServiceNotificationEvent>? _subscription;
  final Map<String, String> _appNameCache = {};
  bool _disposed = false;

  static const _cancelChannel = MethodChannel('bridge/notification_cancel');

  NotificationRelayService(
    this._connectionManager,
    this._router,
    this._settings,
    this._db,
    this._ownPackageName,
  ) {
    _router.register('notification_dismiss', _onDismiss);
  }

  Future<void> init() async {
    _subscription =
        NotificationListenerService.notificationsStream.listen((event) {
      if (_disposed) return;
      _onNotificationEvent(event);
    });
  }

  Future<void> _onNotificationEvent(ServiceNotificationEvent event) async {
    try {
      if (event.hasRemoved == true) return;

      final packageName = event.packageName ?? '';
      if (packageName.isEmpty || packageName == _ownPackageName) return;

      final appName = await _resolveAppName(packageName);
      final notificationId = '${packageName}_${event.id ?? 0}';
      final now = DateTime.now();

      await _db.into(_db.notifications).insert(
            NotificationsCompanion.insert(
              id: notificationId,
              deviceId: _settings.deviceId,
              app: appName,
              title: event.title ?? '',
              body: event.content ?? '',
              timestamp: now,
              dismissed: false,
            ),
            mode: InsertMode.insertOrReplace,
          );

      final message = Message(
        type: 'notification',
        deviceId: _settings.deviceId,
        payload: {
          'notificationId': notificationId,
          'packageName': packageName,
          'appName': appName,
          'title': event.title ?? '',
          'body': event.content ?? '',
          'dismissable': true,
          'timestamp': now.toIso8601String(),
        },
      );

      _connectionManager.broadcast(message);
    } catch (e) {
      log('NotificationRelayService: failed to process notification: $e');
    }
  }

  Future<String> _resolveAppName(String packageName) async {
    if (_appNameCache.containsKey(packageName)) {
      return _appNameCache[packageName]!;
    }
    try {
      final info = await InstalledApps.getAppInfo(packageName);
      final name = info?.name ?? packageName;
      _appNameCache[packageName] = name;
      return name;
    } catch (_) {
      _appNameCache[packageName] = packageName;
      return packageName;
    }
  }

  void _onDismiss(Message message, String sourceDeviceId) {
    final notificationId = message.payload['notificationId'] as String?;
    if (notificationId == null) return;

    final parts = notificationId.split('_');
    if (parts.length < 2) return;
    final androidId = int.tryParse(parts.last);
    if (androidId == null) return;

    try {
      _cancelChannel.invokeMethod('cancel', androidId);
    } catch (e) {
      log('NotificationRelayService: cancelNotification not available on this platform: $e');
    }

    unawaited(_markDismissed(notificationId));
  }

  Future<void> _markDismissed(String notificationId) async {
    try {
      await (_db.update(_db.notifications)
            ..where((n) => n.id.equals(notificationId)))
          .write(const NotificationsCompanion(dismissed: Value(true)));
    } catch (e) {
      log('NotificationRelayService: failed to mark dismissed: $e');
    }
  }

  void dispose() {
    _disposed = true;
    _subscription?.cancel();
  }
}
