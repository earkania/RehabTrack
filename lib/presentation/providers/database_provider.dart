import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rehab_track/data/database/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => database.close());
  return database;
});
