import 'dart:io';

import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/services/restore/restore_database_manager.dart';

/// Thrown when an older-schema database cannot be migrated to the current
/// schema, or when the migrated result fails validation.
class DatabaseMigrationException implements Exception {
  const DatabaseMigrationException();
}

/// Outcome of a successful migration.
class MigratedDatabase {
  final int fromSchemaVersion;
  final int toSchemaVersion;

  const MigratedDatabase({
    required this.fromSchemaVersion,
    required this.toSchemaVersion,
  });
}

/// Migrates an older-schema restore database to the current schema by running
/// the app's own Drift migration strategy against a **temporary copy**.
///
/// The caller stages the raw backup bytes into the restore workspace first
/// ([RestoreDatabaseManager.prepare]); this service opens that copy with
/// [AppDatabase], which replays the cumulative `onUpgrade` migrations, and then
/// validates the migrated result. The live database is never touched here.
///
/// No personal data is ever logged or exposed by this service.
class RestoreSqliteMigrator {
  const RestoreSqliteMigrator();

  /// Migrates [file] in place (it must already be a private workspace copy)
  /// from [fromSchemaVersion] to the app's current schema and validates the
  /// result. Throws [DatabaseMigrationException] on any failure; the file is
  /// left unchanged from the caller's perspective because it is a temp copy.
  Future<MigratedDatabase> migrateToCurrent({
    required File file,
    required int fromSchemaVersion,
  }) async {
    final target = AppDatabase.currentSchemaVersion;
    if (fromSchemaVersion >= target) {
      return MigratedDatabase(
        fromSchemaVersion: fromSchemaVersion,
        toSchemaVersion: fromSchemaVersion,
      );
    }

    final AppDatabase db;
    try {
      db = AppDatabase.forTesting(NativeDatabase.createInBackground(file));
    } catch (_) {
      throw const DatabaseMigrationException();
    }

    try {
      // Opening the database applies the migration strategy (cumulative
      // `onUpgrade` blocks) because the file's user_version differs from the
      // schema version. The SELECT is what forces Drift to open the DB.
      await db.customSelect('SELECT 1').get();
    } catch (_) {
      try {
        await db.close();
      } catch (_) {}
      throw const DatabaseMigrationException();
    }

    try {
      await db.close();
    } catch (_) {
      throw const DatabaseMigrationException();
    }

    if (!await _validateMigrated(file: file, expectedSchemaVersion: target)) {
      throw const DatabaseMigrationException();
    }
    return MigratedDatabase(
      fromSchemaVersion: fromSchemaVersion,
      toSchemaVersion: target,
    );
  }

  /// Validates a migrated database read-only: schema version, core tables,
  /// sample queries, and foreign-key integrity. Returns whether it is safe to
  /// use as the restored live database.
  Future<bool> _validateMigrated({
    required File file,
    required int expectedSchemaVersion,
  }) async {
    final bytes = await file.readAsBytes();
    if (bytes.length < 16 ||
        String.fromCharCodes(bytes.sublist(0, 16)) !=
            'SQLite format 3\u0000') {
      return false;
    }

    sqlite.Database? db;
    try {
      db = sqlite.sqlite3.open(file.path, mode: sqlite.OpenMode.readOnly);
      if (db.userVersion != expectedSchemaVersion) return false;

      final tables = _tableNames(db);
      for (final core in RestoreDatabaseManager.coreTables) {
        if (!tables.contains(core)) return false;
      }

      // Read-only sample queries per core table.
      for (final core in RestoreDatabaseManager.coreTables) {
        try {
          db.select('SELECT COUNT(*) FROM $core');
        } catch (_) {
          return false;
        }
      }

      // Foreign-key integrity: any violating row means the migrated data is
      // not safe to surface.
      final violations = db.select('PRAGMA foreign_key_check').rows;
      if (violations.isNotEmpty) return false;

      return true;
    } catch (_) {
      return false;
    } finally {
      db?.close();
    }
  }

  static Set<String> _tableNames(sqlite.Database db) {
    final rows = db
        .select("SELECT name FROM sqlite_master WHERE type = 'table'")
        .rows;
    return rows
        .where((r) => r.isNotEmpty && r.first is String)
        .map((r) => r.first as String)
        .toSet();
  }
}
