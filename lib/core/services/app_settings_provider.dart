import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/providers.dart';
import 'app_settings.dart';

final appSettingsProvider = FutureProvider<AppSettings>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return AppSettings(db);
});
