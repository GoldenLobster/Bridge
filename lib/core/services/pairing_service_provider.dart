import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/providers.dart';
import '../providers/certificate_manager_provider.dart';
import '../providers/connection_providers.dart';
import 'app_settings_provider.dart';
import 'pairing_service.dart';

final pairingServiceProvider = FutureProvider<PairingService>((ref) async {
  final connectionManager = ref.watch(connectionManagerProvider);
  final router = ref.watch(messageRouterProvider);
  final settings = await ref.watch(appSettingsProvider.future);
  final db = await ref.watch(databaseProvider.future);
  final certManager = ref.watch(certificateManagerProvider);
  return PairingService(
    connectionManager,
    router,
    settings,
    db,
    certManager,
  );
});
