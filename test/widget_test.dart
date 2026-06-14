import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bridge/core/database/database.dart';
import 'package:bridge/core/database/providers.dart';
import 'package:bridge/core/providers/certificate_manager_provider.dart';
import 'package:bridge/core/security/certificate_manager.dart';
import 'package:bridge/core/services/app_settings.dart';
import 'package:bridge/core/services/app_settings_provider.dart';
import 'package:bridge/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    final db = BridgeDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final settings = AppSettings(db);
    await settings.init();
    final certManager = CertificateManager(db);
    await certManager.init();

    await tester.pumpWidget(
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
          isDesktop: false,
          isAndroid: false,
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(BridgeApp), findsOneWidget);
  });
}
