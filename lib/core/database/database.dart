import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'database.g.dart';

/// The Drift database for Bridge, hosting the devices, transfers, notifications, messages, and settings tables.
@DriftDatabase(tables: [Devices, Transfers, Notifications, Messages, Settings])
class BridgeDatabase extends _$BridgeDatabase {
  BridgeDatabase(super.e);

  @override
  int get schemaVersion => 1;

  static Future<BridgeDatabase> create() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'bridge.db'));
    return BridgeDatabase(NativeDatabase(file));
  }
}
