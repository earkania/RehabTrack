import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'package:rehab_track/data/services/backup/preferences_exporter.dart';

/// Writes allowlisted preference values directly into a backed database file.
///
/// User preferences are stored in the `app_settings` table of the database.
/// Applying them must not depend on a Drift connection lifecycle, so this
/// helper writes with a standalone read-write SQLite connection.
///
/// Policy: every allowlisted key present in [values] is upserted; every
/// allowlisted key absent from [values] is deleted, so the restored user
/// settings match the backup exactly. Operational keys not in the allowlist
/// (e.g. the last-backup timestamp) are left untouched.
class AppSettingsWriter {
  const AppSettingsWriter();

  /// Writes [values] into `app_settings` of the database at [databasePath].
  /// Throws on any I/O or SQL error.
  static void write(String databasePath, Map<String, String> values) {
    final db = sqlite.sqlite3.open(databasePath);
    try {
      db.execute('BEGIN');
      final existingAllowlisted =
          db.select('SELECT key FROM app_settings').rows
              .map((r) => r.isNotEmpty ? r.first as String : '')
              .where(PreferencesExporter.allowlist.contains)
              .toSet();
      for (final key in PreferencesExporter.allowlist) {
        if (existingAllowlisted.contains(key)) {
          db.execute('DELETE FROM app_settings WHERE key = ?', [key]);
        }
      }
      for (final entry in values.entries) {
        db.execute(
          'INSERT INTO app_settings(key, value) VALUES(?, ?) '
          'ON CONFLICT(key) DO UPDATE SET value = excluded.value',
          [entry.key, entry.value],
        );
      }
      db.execute('COMMIT');
    } catch (_) {
      try {
        db.execute('ROLLBACK');
      } catch (_) {}
      rethrow;
    } finally {
      db.close();
    }
  }
}