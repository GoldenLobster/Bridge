import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:window_manager/window_manager.dart';

import 'core/database/database.dart';
import 'core/database/providers.dart';
import 'core/providers/certificate_manager_provider.dart';
import 'core/providers/connection_providers.dart';
import 'core/security/certificate_manager.dart';
import 'core/services/app_settings.dart';
import 'core/services/app_settings_provider.dart';
import 'core/services/background_service_manager.dart';
import 'core/services/notification_relay_service.dart';
import 'desktop/screens/pairing_screen.dart';
import 'desktop/services/desktop_notification_handler.dart';
import 'mobile/screens/qr_scanner_screen.dart';
import 'mobile/services/notification_permission_handler.dart';
import 'mobile/services/share_intent_handler.dart';
import 'shared/widgets/pending_offer_dialog.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

bool _needsBatteryDialog = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isDesktop =
      Platform.isLinux || Platform.isMacOS || Platform.isWindows;
  final isAndroid = Platform.isAndroid;

  if (isDesktop) {
    await windowManager.ensureInitialized();
    await localNotifier.setup(appName: 'Bridge');
  }

  try {
    final db = await BridgeDatabase.create();
    final settings = AppSettings(db);
    await settings.init();
    final certManager = CertificateManager(db);
    await certManager.init();

    final bgManager = BackgroundServiceManager();
    await bgManager.init(db: db, settings: settings);
    _needsBatteryDialog = bgManager.needsBatteryOptimizationDialog;

    runApp(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith((ref) {
            ref.onDispose(() => db.close());
            return Future.value(db);
          }),
          appSettingsProvider.overrideWith((ref) => Future.value(settings)),
          certificateManagerProvider.overrideWith((ref) => certManager),
        ],
        child: BridgeApp(
          db: db,
          settings: settings,
          isDesktop: isDesktop,
          isAndroid: isAndroid,
        ),
      ),
    );
  } catch (e) {
    runApp(
      ProviderScope(
        child: MaterialApp(
          title: 'Bridge',
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Failed to initialize: $e'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BridgeApp extends ConsumerStatefulWidget {
  final BridgeDatabase db;
  final AppSettings settings;
  final bool isDesktop;
  final bool isAndroid;

  const BridgeApp({
    super.key,
    required this.db,
    required this.settings,
    required this.isDesktop,
    required this.isAndroid,
  });

  @override
  ConsumerState<BridgeApp> createState() => _BridgeAppState();
}

class _BridgeAppState extends ConsumerState<BridgeApp> {
  ShareIntentHandler? _shareIntentHandler;
  NotificationRelayService? _notificationRelay;
  DesktopNotificationHandler? _desktopNotificationHandler;

  @override
  void initState() {
    super.initState();
    if (_needsBatteryDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showBatteryOptimizationDialog();
      });
    }
    if (widget.isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _initAndroidNotifications();
      });
    }
  }

  Future<void> _initAndroidNotifications() async {
    final permissionHandler = NotificationPermissionHandler(widget.settings);
    await permissionHandler.checkAndShowDialog(context);

    try {
      final connectionManager = ref.read(connectionManagerProvider);
      final router = ref.read(messageRouterProvider);
      final packageInfo = await PackageInfo.fromPlatform();
      _notificationRelay = NotificationRelayService(
        connectionManager,
        router,
        widget.settings,
        widget.db,
        packageInfo.packageName,
      );
      await _notificationRelay!.init();
    } catch (e) {
      // NotificationRelayService may fail if notification_listener_service is not available
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shareIntentHandler == null && widget.isAndroid) {
      _shareIntentHandler = ShareIntentHandler(navigatorKey: navigatorKey);
      _shareIntentHandler!.init();
    }
    if (_desktopNotificationHandler == null && widget.isDesktop) {
      try {
        final connectionManager = ref.read(connectionManagerProvider);
        final router = ref.read(messageRouterProvider);
        _desktopNotificationHandler = DesktopNotificationHandler(
          connectionManager,
          router,
          widget.db,
        );
        _desktopNotificationHandler!.init();
      } catch (e) {
        // DesktopNotificationHandler may fail if providers are not ready
      }
    }
  }

  @override
  void dispose() {
    _shareIntentHandler?.dispose();
    _notificationRelay?.dispose();
    _desktopNotificationHandler?.dispose();
    super.dispose();
  }

  void _showBatteryOptimizationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Bridge'),
        content: const Text(
          'Without permission to ignore battery optimizations, Android may '
          'kill Bridge in the background, stopping file transfers and '
          'notifications from working.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Maybe Later'),
          ),
          FilledButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(ctx);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final home = widget.isDesktop
        ? const PairingScreen()
        : const QrScannerScreen();

    return MaterialApp(
      title: 'Bridge',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: Stack(
        children: [
          home,
          const PendingOfferDialog(),
        ],
      ),
    );
  }
}
