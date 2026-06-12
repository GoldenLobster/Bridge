import 'dart:io' show Platform;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';

/// Reads and writes key-value settings to the Drift settings table, with first-launch defaults for device ID, name, and platform.
class AppSettings {
  final BridgeDatabase _db;

  late final String deviceId;
  late final String deviceName;
  late final String platform;

  AppSettings(this._db);

  String _buildFriendlyDeviceName() {
    String username = '';
    if (Platform.isWindows) {
      username = Platform.environment['USERNAME'] ?? '';
    } else {
      username = Platform.environment['USER'] ?? '';
    }
    if (username.isNotEmpty) {
      username = username[0].toUpperCase() + username.substring(1);
    }
    if (Platform.isLinux) return '${username}s Linux PC'.trim();
    if (Platform.isWindows) return '${username}s Windows PC'.trim();
    if (Platform.isMacOS) return '${username}s MacBook'.trim();
    if (Platform.isIOS) return '${username}s iPhone'.trim();
    if (Platform.isAndroid) return '${username}s Android Phone'.trim();
    return 'Bridge Device';
  }

  Future<void> init() async {
    try {
      deviceId = await _getOrCreate('deviceId', () => const Uuid().v4());
      deviceName = await _getOrCreate('deviceName', _buildFriendlyDeviceName);
      platform =
          await _getOrCreate('platform', () => Platform.operatingSystem);

      if (deviceName == 'Desktop' || deviceName.contains('.')) {
        final friendly = _buildFriendlyDeviceName();
        await set('deviceName', friendly);
        deviceName = friendly;
      }
    } catch (e) {
      throw StateError('AppSettings initialization failed: $e');
    }
  }

  Future<String> _getOrCreate(String key, String Function() create) async {
    final rows =
        await (_db.select(_db.settings)..where((s) => s.key.equals(key))).get();
    if (rows.isNotEmpty) {
      return rows.first.value;
    }
    final value = create();
    await _db.into(_db.settings).insert(
          SettingsCompanion.insert(key: key, value: value),
        );
    return value;
  }

  Future<String?> get(String key) async {
    final rows =
        await (_db.select(_db.settings)..where((s) => s.key.equals(key))).get();
    return rows.isEmpty ? null : rows.first.value;
  }

  Future<void> set(String key, String value) async {
    await _db.into(_db.settings).insert(
          SettingsCompanion.insert(key: key, value: value),
          mode: InsertMode.insertOrReplace,
        );
  }
}
