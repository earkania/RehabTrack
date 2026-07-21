import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/database/tables/app_setting_table.dart';

part 'app_setting_dao.g.dart';

@DriftAccessor(tables: [AppSettings])
class AppSettingDao extends DatabaseAccessor<AppDatabase>
    with _$AppSettingDaoMixin {
  AppSettingDao(super.db);

  Future<String?> getValue(String key) async {
    final result = await (select(appSettings)
      ..where((t) => t.key.equals(key))).getSingleOrNull();
    return result?.value;
  }

  Future<void> setValue(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: value),
    );
  }

  Future<void> remove(String key) async {
    await (delete(appSettings)
      ..where((t) => t.key.equals(key))).go();
  }

  Stream<Map<String, String>> watchAll() {
    return (select(appSettings)).watch().map((rows) {
      return {
        for (final row in rows) row.key: row.value,
      };
    });
  }

  Future<Map<String, String>> getAll() async {
    final rows = await select(appSettings).get();
    return {
      for (final row in rows) row.key: row.value,
    };
  }
}
