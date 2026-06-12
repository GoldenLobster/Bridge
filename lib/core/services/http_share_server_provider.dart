import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'http_share_server.dart';

final httpShareServerProvider = Provider<HttpShareServer>((ref) {
  final server = HttpShareServer();
  ref.onDispose(() => server.stop());
  return server;
});
