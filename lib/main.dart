import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/database.dart';
import 'core/database/providers.dart';
import 'core/providers/certificate_manager_provider.dart';
import 'core/security/certificate_manager.dart';
import 'core/services/app_settings.dart';
import 'core/services/app_settings_provider.dart';
import 'desktop/screens/pairing_screen.dart';
import 'mobile/screens/qr_scanner_screen.dart';
import 'shared/widgets/pending_offer_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final db = await BridgeDatabase.create();
    final settings = AppSettings(db);
    await settings.init();
    final certManager = CertificateManager(db);
    await certManager.init();

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
        child: const BridgeApp(),
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

class BridgeApp extends StatelessWidget {
  const BridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final home = (Platform.isLinux || Platform.isMacOS || Platform.isWindows)
        ? const PairingScreen()
        : const QrScannerScreen();

    return MaterialApp(
      title: 'Bridge',
      debugShowCheckedModeBanner: false,
      home: Stack(
        children: [
          home,
          const PendingOfferDialog(),
        ],
      ),
    );
  }
}
