import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

/// Remaps image paths stored in a prepared restore database so they point at
/// the managed-file root of the device performing the restore.
///
/// Backups store absolute `photoPath` values from the source device. Keeping
/// them verbatim would break photos when the app is restored to a different
/// device or a relocated documents directory. Because the archive preserves
/// managed files under `profile_images/` and `care_contact_images/`, each path
/// can be rewritten to `<managedRoot>/<dir>/<basename>` safely.
///
/// Operates on the prepared temporary database **before** it is swapped into
/// the live location. Missing tables/columns (older schemas) are handled
/// gracefully.
class RestoreImagePathRemapper {
  static const _profileImagesDir = 'profile_images';
  static const _careContactImagesDir = 'care_contact_images';

  /// Rewrites `photoPath` in `profiles` and `care_contacts` to point at
  /// [managedFilesRoot]. Non-empty paths are normalized to
  /// `<managedFilesRoot>/<dir>/<basename>`.
  static void remap({required String databasePath, required String managedFilesRoot}) {
    final db = sqlite.sqlite3.open(databasePath);
    try {
      db.execute('BEGIN');
      _remapColumn(
        db,
        table: 'profiles',
        column: 'photoPath',
        dir: _profileImagesDir,
        managedFilesRoot: managedFilesRoot,
      );
      _remapColumn(
        db,
        table: 'care_contacts',
        column: 'photoPath',
        dir: _careContactImagesDir,
        managedFilesRoot: managedFilesRoot,
      );
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

  static void _remapColumn(
    sqlite.Database db, {
    required String table,
    required String column,
    required String dir,
    required String managedFilesRoot,
  }) {
    if (!_columnExists(db, table, column)) return;
    final rows = db.select('SELECT id, $column FROM $table').rows;
    for (final row in rows) {
      if (row.isEmpty) continue;
      final id = row[0];
      final raw = row.length > 1 ? row[1] : null;
      if (raw is! String || raw.trim().isEmpty) continue;
      final basename = p.posix.basename(raw.replaceAll('\\', '/'));
      if (basename.isEmpty || basename == '.' || basename == '/') continue;
      final newPath = '$managedFilesRoot/$dir/$basename';
      db.execute(
        'UPDATE $table SET $column = ? WHERE id = ?',
        [newPath, id],
      );
    }
  }

  static bool _columnExists(
    sqlite.Database db,
    String table,
    String column,
  ) {
    try {
      // PRAGMA table_info rows are [cid, name, type, notnull, dflt_value, pk].
      final columns = db
          .select('PRAGMA table_info($table)')
          .rows
          .map((r) => r.isNotEmpty ? r[1] : null)
          .toSet();
      return columns.contains(column);
    } catch (_) {
      return false;
    }
  }
}