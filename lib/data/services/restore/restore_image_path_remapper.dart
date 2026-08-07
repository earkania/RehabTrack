import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

/// Non-sensitive report of a path-repair pass.
class RestorePathRepairReport {
  /// Number of rows whose photo path was rewritten to the canonical managed
  /// location.
  final int repairedCount;

  /// Number of rows cleared to null because the referenced file is not present
  /// in the restored archive and no safe fallback exists.
  final int missingManagedFileCount;

  const RestorePathRepairReport({
    this.repairedCount = 0,
    this.missingManagedFileCount = 0,
  });

  bool get hasMissingFiles => missingManagedFileCount > 0;
}

/// Repairs photo paths stored in a prepared restore database so they point at
/// the managed-file root of the device performing the restore.
///
/// Backups store `photoPath` values verbatim from the source device, which may
/// be absolute legacy sandbox paths, `content://` URIs, or already-canonical
/// app-managed paths. Because the archive preserves managed files under
/// `profile_images/` and `care_contact_images/`, each path is normalised to the
/// canonical form `<managedRoot>/<dir>/<basename>`.
///
/// Rules:
/// - Only the `photoPath` columns of `profiles` and `care_contacts` are touched.
/// - External URLs (`website`) and other free-text fields are never rewritten.
/// - When the referenced file is not part of the restored archive, the path is
///   cleared to `null` so callers fall back to initials/avatars instead of
///   crashing on a dangling path; that file is reported as missing.
///
/// Operates on the prepared temporary database **before** it is swapped into
/// the live location. Missing tables/columns (older schemas) are handled
/// gracefully.
class RestoreImagePathRemapper {
  static const _profileImagesDir = 'profile_images';
  static const _careContactImagesDir = 'care_contact_images';

  /// Rewrites `photoPath` in `profiles` and `care_contacts` to canonical
  /// `<managedFilesRoot>/<dir>/<basename>` form.
  ///
  /// When [restoredFilesDir] is provided (the extracted `files/` of the
  /// archive), photos whose managed file is absent from that directory are
  /// cleared and counted as missing so the caller can surface a
  /// "some optional files are missing" warning.
  static RestorePathRepairReport remap({
    required String databasePath,
    required String managedFilesRoot,
    String? restoredFilesDir,
  }) {
    final db = sqlite.sqlite3.open(databasePath);
    var repaired = 0;
    var missingManaged = 0;
    try {
      db.execute('BEGIN');
      final profileRepair = _remapColumn(
        db,
        table: 'profiles',
        column: 'photoPath',
        dir: _profileImagesDir,
        managedFilesRoot: managedFilesRoot,
        restoredFilesDir: restoredFilesDir,
      );
      final contactRepair = _remapColumn(
        db,
        table: 'care_contacts',
        column: 'photoPath',
        dir: _careContactImagesDir,
        managedFilesRoot: managedFilesRoot,
        restoredFilesDir: restoredFilesDir,
      );
      repaired += profileRepair.$1;
      missingManaged += profileRepair.$2;
      repaired += contactRepair.$1;
      missingManaged += contactRepair.$2;
      db.execute('COMMIT');
    } catch (_) {
      try {
        db.execute('ROLLBACK');
      } catch (_) {}
      rethrow;
    } finally {
      db.close();
    }
    return RestorePathRepairReport(
      repairedCount: repaired,
      missingManagedFileCount: missingManaged,
    );
  }

  static (int, int) _remapColumn(
    sqlite.Database db, {
    required String table,
    required String column,
    required String dir,
    required String managedFilesRoot,
    String? restoredFilesDir,
  }) {
    if (!_columnExists(db, table, column)) return (0, 0);
    var repaired = 0;
    var missingManaged = 0;
    final rows = db.select('SELECT id, $column FROM $table').rows;
    for (final row in rows) {
      if (row.isEmpty) continue;
      final id = row[0];
      final raw = row.length > 1 ? row[1] : null;
      if (raw is! String || raw.trim().isEmpty) continue;

      final basename = _safeBasename(raw);
      if (basename == null) continue;

      final canonical = '$managedFilesRoot/$dir/$basename';
      if (restoredFilesDir != null) {
        final managedFile = File(
          p.join(restoredFilesDir, dir, basename),
        );
        if (!managedFile.existsSync()) {
          // The referenced photo is not part of the restored archive. Clear it
          // so the UI falls back to initials rather than crashing.
          db.execute('UPDATE $table SET $column = NULL WHERE id = ?', [id]);
          missingManaged++;
          continue;
        }
      }

      final current = row.length > 1 ? row[1] : null;
      if (current is String && current == canonical) continue;
      db.execute('UPDATE $table SET $column = ? WHERE id = ?', [canonical, id]);
      repaired++;
    }
    return (repaired, missingManaged);
  }

  /// Extracts a usable, safe basename from a stored path or URI, or returns
  /// `null` for values that carry no usable file name (e.g. plain roots).
  static String? _safeBasename(String raw) {
    final normalized = raw.replaceAll('\\', '/');
    var candidate = p.posix.basename(normalized);
    if (candidate.isEmpty) return null;
    // Strip any query/fragment from URI-style values.
    for (final sep in ['?', '#']) {
      final cut = candidate.indexOf(sep);
      if (cut >= 0) candidate = candidate.substring(0, cut);
    }
    candidate = Uri.decodeComponent(candidate);
    if (candidate.isEmpty || candidate == '.' || candidate == '/') return null;
    return candidate;
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