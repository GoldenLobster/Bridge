import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/providers.dart';
import '../providers/connection_providers.dart';
import '../providers/pending_offers_provider.dart';
import 'app_settings_provider.dart';
import 'file_transfer_service.dart';

final fileTransferServiceProvider = FutureProvider<FileTransferService>((ref) async {
  final connectionManager = ref.watch(connectionManagerProvider);
  final router = ref.watch(messageRouterProvider);
  final settings = await ref.watch(appSettingsProvider.future);
  final db = await ref.watch(databaseProvider.future);
  final pendingOffersNotifier = ref.watch(pendingOffersProvider.notifier);
  final service = FileTransferService(
    connectionManager,
    router,
    settings,
    db,
    pendingOffersNotifier,
  );
  ref.onDispose(() => service.dispose());
  return service;
});
