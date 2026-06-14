import 'dart:developer';
import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../database/database.dart';
import '../networking/connection_manager.dart';
import '../networking/message_router.dart';
import '../providers/pending_offers_provider.dart';
import '../security/certificate_manager.dart';
import 'app_settings.dart';
import 'file_transfer_service.dart';
import 'mdns_discovery_service.dart';
import 'notification_relay_service.dart';

/// Configures and manages the Android foreground service that keeps Bridge alive
/// in the background so discovery, connections, and file transfers continue when
/// the app is not visible. On non-Android platforms this class is a no-op.
class BackgroundServiceManager {
  bool _initialized = false;
  bool _needsBatteryOptimizationDialog = false;

  static bool _backgroundInitialized = false;

  bool get needsBatteryOptimizationDialog => _needsBatteryOptimizationDialog;

  Future<void> init({
    required BridgeDatabase db,
    required AppSettings settings,
  }) async {
    if (_initialized) return;
    _initialized = true;

    if (!Platform.isAndroid) return;

    await _configureService();

    await _checkBatteryOptimization(settings);

    await FlutterBackgroundService().startService();
    _backgroundInitialized = true;
  }

  Future<void> stop() async {
    if (!_initialized) return;
    _initialized = false;
    if (!Platform.isAndroid) return;
    try {
      final service = FlutterBackgroundService();
      if (await service.isRunning()) {
        service.invoke('stop');
      }
    } catch (_) {}
  }

  Future<void> _configureService() async {
    await FlutterBackgroundService().configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'bridge_background',
        initialNotificationTitle: 'Bridge',
        initialNotificationContent: 'Running in the background',
        foregroundServiceNotificationId: 888,
      ),
    );
  }

  Future<void> _onStart(ServiceInstance service) async {
    if (!_backgroundInitialized) {
      _backgroundInitialized = true;
      try {
        WidgetsFlutterBinding.ensureInitialized();

        final db = await BridgeDatabase.create();
        final settings = AppSettings(db);
        await settings.init();
        final certManager = CertificateManager(db);
        await certManager.init();

        final router = MessageRouter();
        final connectionManager = ConnectionManager(
          port: 9876,
          router: router,
          certManager: certManager,
        );
        await connectionManager.start();
        await settings.set('serverPort', connectionManager.actualPort.toString());

        final discoveryService = MdnsDiscoveryService(
          serverPort: connectionManager.actualPort,
          deviceId: settings.deviceId,
          deviceName: settings.deviceName,
          platform: settings.platform,
        );
        await discoveryService.start();

        final notifier = PendingOffersNotifier();
        FileTransferService(
          connectionManager,
          router,
          settings,
          db,
          notifier,
        );

        final packageInfo = await PackageInfo.fromPlatform();
        final notificationRelay = NotificationRelayService(
          connectionManager,
          router,
          settings,
          db,
          packageInfo.packageName,
        );
        await notificationRelay.init();
      } catch (e) {
        log('BackgroundServiceManager._onStart: initialization failed: $e');
      }
    }

    service.on('stop').listen((_) {
      service.stopSelf();
    });
  }

  Future<void> _checkBatteryOptimization(AppSettings settings) async {
    try {
      final alreadyShown = await settings.get('shownBatteryOptimizationPrompt');
      if (alreadyShown == 'true') return;

      final status = await Permission.ignoreBatteryOptimizations.status;
      if (!status.isGranted) {
        _needsBatteryOptimizationDialog = true;
      }

      await settings.set('shownBatteryOptimizationPrompt', 'true');
    } catch (e) {
      log('BackgroundServiceManager: failed to check battery optimization: $e');
    }
  }
}
