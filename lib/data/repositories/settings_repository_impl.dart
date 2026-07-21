import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final AppDatabase _database;

  SettingsRepositoryImpl(this._database);

  @override
  Future<String?> getValue(String key) async {
    return _database.appSettingDao.getValue(key);
  }

  @override
  Future<void> setValue(String key, String value) async {
    await _database.appSettingDao.setValue(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _database.appSettingDao.remove(key);
  }

  @override
  Stream<Map<String, String>> watchAll() {
    return _database.appSettingDao.watchAll();
  }

  @override
  Future<Map<String, String>> getAll() async {
    return _database.appSettingDao.getAll();
  }
}
