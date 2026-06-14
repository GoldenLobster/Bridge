import 'dart:async';
import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/database/database.dart' hide Message;
import '../../core/models/message.dart';
import '../../core/networking/connection_manager.dart';
import '../../core/networking/message_router.dart';

/// Receives notification relay messages from Android via MessageRouter, displays them as native desktop notifications via local_notifier, syncs dismissal back to the phone, and brings the window to front on click.
class DesktopNotificationHandler {
  final ConnectionManager _connectionManager;
  final MessageRouter _router;
  final BridgeDatabase _db;
  bool _disposed = false;

  DesktopNotificationHandler(
    this._connectionManager,
    this._router,
    this._db,
  );

  void init() {
    _router.register('notification', _onNotification);
  }

  void dispose() {
    _disposed = true;
  }

  void _onNotification(Message message, String sourceDeviceId) {
    if (_disposed) return;

    final notificationId =
        message.payload['notificationId'] as String? ?? '';
    final appName = message.payload['appName'] as String? ?? '';
    final title = message.payload['title'] as String? ?? '';
    final body = message.payload['body'] as String? ?? '';
    final timestamp = message.payload['timestamp'] as String? ?? '';

    unawaited(
      _db.into(_db.notifications).insert(
            NotificationsCompanion.insert(
              id: notificationId,
              deviceId: sourceDeviceId,
              app: appName,
              title: title,
              body: body,
              timestamp: DateTime.tryParse(timestamp) ?? DateTime.now(),
              dismissed: false,
            ),
            mode: InsertMode.insertOrReplace,
          ),
    );

    final displayTitle =
        appName.isNotEmpty ? '$appName: $title' : title;

    final notification = LocalNotification(
      identifier: notificationId,
      title: displayTitle,
      body: body,
    );

    notification.onClick = () async {
      try {
        await windowManager.show();
        await windowManager.focus();
      } catch (e) {
        log('DesktopNotificationHandler: failed to focus window: $e');
      }
    };

    notification.onClose = (closeReason) {
      if (_disposed) return;
      if (closeReason == LocalNotificationCloseReason.userCanceled) {
        _sendDismiss(sourceDeviceId, notificationId);
      }
    };

    notification.show();
  }

  void _sendDismiss(String deviceId, String notificationId) {
    try {
      _connectionManager.sendToDevice(
        deviceId,
        Message(
          type: 'notification_dismiss',
          deviceId: '',
          payload: {'notificationId': notificationId},
        ),
      );
    } catch (e) {
      log('DesktopNotificationHandler: failed to send dismiss: $e');
    }
  }
}
