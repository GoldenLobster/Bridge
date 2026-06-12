import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';

final databaseProvider = FutureProvider<BridgeDatabase>((ref) async {
  final db = await BridgeDatabase.create();
  ref.onDispose(() => db.close());
  return db;
});
