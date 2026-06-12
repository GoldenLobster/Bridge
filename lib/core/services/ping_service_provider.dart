import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/connection_providers.dart';
import 'ping_service.dart';

final pingServiceProvider = Provider<PingService>((ref) {
  final connectionManager = ref.watch(connectionManagerProvider);
  final router = ref.watch(messageRouterProvider);
  return PingService(connectionManager, router);
});
