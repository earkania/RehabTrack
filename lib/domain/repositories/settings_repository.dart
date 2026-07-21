abstract class SettingsRepository {
  Future<String?> getValue(String key);
  Future<void> setValue(String key, String value);
  Future<void> remove(String key);
  Stream<Map<String, String>> watchAll();
  Future<Map<String, String>> getAll();
}
