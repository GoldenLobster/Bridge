import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../networking/connection_manager.dart';
import '../networking/message_router.dart';
import '../services/app_settings_provider.dart';
import 'certificate_manager_provider.dart';

final messageRouterProvider = Provider<MessageRouter>((ref) {
  return MessageRouter();
});

final connectionManagerProvider = Provider<ConnectionManager>((ref) {
  final router = ref.watch(messageRouterProvider);
  final certManager = ref.watch(certificateManagerProvider);
  final manager = ConnectionManager(
    port: 9876,
    router: router,
    certManager: certManager,
  );
  unawaited(() async {
    try {
      await manager.start();
      final settings = await ref.read(appSettingsProvider.future);
      await settings.set('serverPort', manager.actualPort.toString());
    } catch (e) {
      log('connectionManagerProvider: failed to start: $e');
    }
  }());
  ref.onDispose(() => manager.stop());
  return manager;
});


