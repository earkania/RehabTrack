import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

/// Verifies a restored database beyond "it opens": schema version, core tables
/// and read-only sample queries across the record types the app relies on,
/// plus the managed-files root.
///
/// The verifier never inspects, logs or returns row values — it only checks
/// that the database is structurally sound and queryable.
class RestoreStateVerifier {
  const RestoreStateVerifier();

  /// Tables that must exist and be queryable in every restorable schema.
  static const Set<String> coreTables = {
    'profiles',
    'medications',
    'measurement_types',
    'measurement_records',
    'care_contacts',
    'doctor_visit_records',
    'app_settings',
  };

  /// Verifies [databasePath] is a readable SQLite database at
  /// [expectedSchemaVersion] with all [coreTables] present and each core table
  /// answering a `COUNT(*)`. Also checks that [managedFilesRoot] exists when
  /// provided. Returns false on any structural problem.
  Future<bool> verify({
    required String databasePath,
    required int expectedSchemaVersion,
    String? managedFilesRoot,
  }) async {
    final file = File(databasePath);
    if (!await file.exists()) return false;
    final bytes = await _safeRead(file);
    if (bytes == null) return false;

    // SQLite header magic: "SQLite format 3\0" (16 bytes).
    if (bytes.length < 16) return false;
    const magic = 'SQLite format 3\u0000';
    if (String.fromCharCodes(bytes.sublist(0, 16)) != magic) return false;

    sqlite.Database? db;
    try {
      db = sqlite.sqlite3.open(databasePath, mode: sqlite.OpenMode.readOnly);
      if (db.userVersion != expectedSchemaVersion) return false;

      final tableRows = db
          .select("SELECT name FROM sqlite_master WHERE type = 'table'")
          .rows;
      final tables = tableRows
          .where((r) => r.isNotEmpty && r.first is String)
          .map((r) => r.first as String)
          .toSet();
      for (final table in coreTables) {
        if (!tables.contains(table)) return false;
      }

      // Read-only sample queries: a database that cannot answer these is not
      // usable by the app. Values are deliberately discarded.
      for (final table in coreTables) {
        try {
          db.select('SELECT COUNT(*) FROM "$table"');
        } catch (_) {
          return false;
        }
      }
    } catch (_) {
      return false;
    } finally {
      db?.close();
    }

    if (managedFilesRoot != null) {
      if (!await Directory(managedFilesRoot).exists()) return false;
    }
    return true;
  }

  Future<Uint8List?> _safeRead(File file) async {
    try {
      return await file.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  /// Whether [path] is a plausible canonical managed-file path rooted at
  /// [managedFilesRoot] (no absolute path, no traversal, no backslashes).
  static bool isSafeManagedPath(String managedFilesRoot, String path) {
    if (path.isEmpty) return false;
    if (p.isAbsolute(path)) return false;
    if (path.contains('..') || path.contains('\\')) return false;
    final root = p.normalize(managedFilesRoot);
    final candidate = p.normalize(path);
    return candidate == root || candidate.startsWith('$root${p.separator}');
  }
}
