import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

/// Thrown when the restored database cannot be staged or validated.
class DatabasePreparationException implements Exception {
  const DatabasePreparationException();
}

/// Thrown when the prepared database cannot be placed into the live location.
class DatabaseReplacementException implements Exception {
  const DatabaseReplacementException();
}

/// Result of a database preparation.
class PreparedDatabase {
  final File file;
  final int entryCount;

  const PreparedDatabase({required this.file, required this.entryCount});
}

/// Core tables that must exist in every supported schema version.
const Set<String> _coreTables = {
  'profiles',
  'medications',
  'measurement_types',
  'app_settings',
};

/// Stages, validates and swaps the restored database.
///
/// Validation is a re-check of critical integrity immediately before the swap
/// (header, declared schema version, core tables and read-only queries) and is
/// deliberately independent of the earlier preview validation.
class RestoreDatabaseManager {
  const RestoreDatabaseManager();

  /// Writes [dbBytes] into [preparedDir]/database.sqlite and validates it.
  /// Returns the validated prepared file.
  Future<PreparedDatabase> prepare({
    required Uint8List dbBytes,
    required Directory preparedDir,
    required int expectedSchemaVersion,
  }) async {
    final file = File(p.join(preparedDir.path, 'database.sqlite'));
    try {
      await file.writeAsBytes(dbBytes, flush: true);
    } catch (_) {
      throw const DatabasePreparationException();
    }
    if (!await validatePrepared(
      file: file,
      expectedSchemaVersion: expectedSchemaVersion,
    )) {
      throw const DatabasePreparationException();
    }
    return PreparedDatabase(file: file, entryCount: dbBytes.length);
  }

  /// Validates an on-disk prepared database: SQLite header, schema version,
  /// core tables and read-only queries.
  Future<bool> validatePrepared({
    required File file,
    required int expectedSchemaVersion,
  }) async {
    final bytes = await file.readAsBytes();
    if (bytes.length < 16 ||
        utf8.decode(bytes.sublist(0, 16)) != 'SQLite format 3\u0000') {
      return false;
    }

    sqlite.Database? db;
    try {
      db = sqlite.sqlite3.open(file.path, mode: sqlite.OpenMode.readOnly);
      if (db.userVersion != expectedSchemaVersion) return false;
      final tableRows = db
          .select("SELECT name FROM sqlite_master WHERE type = 'table'")
          .rows;
      final tables = tableRows
          .where((r) => r.isNotEmpty && r.first is String)
          .map((r) => r.first as String)
          .toSet();
      for (final core in _coreTables) {
        if (!tables.contains(core)) return false;
      }
      try {
        db.select('SELECT COUNT(*) FROM profiles');
      } catch (_) {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    } finally {
      db?.close();
    }
  }
}

/// Holds the live database files moved aside during replacement so the swap
/// can be reversed atomically by rename.
class DatabaseSwapHandle {
  final Directory rollbackDir;
  final File liveFile;

  /// Files moved out of the live location, in the order they must be restored.
  final List<File> movedFiles;

  DatabaseSwapHandle({
    required this.rollbackDir,
    required this.liveFile,
    required this.movedFiles,
  });

  bool get movedAnything => movedFiles.isNotEmpty;
}

/// File-level swap primitives for the live database. Renames are used so the
/// swap is effectively atomic on the same filesystem.
class RestoreDatabaseSwap {
  const RestoreDatabaseSwap();

  static const String _databaseDir = 'database';

  static List<String> _sidecarNames(String path) =>
      ['$path-wal', '$path-shm', '$path-journal'];

  /// The sidecar file names (WAL/SHM/journal) associated with a database path.
  static List<String> sidecarNamesFor(String path) => _sidecarNames(path);

  /// Moves the live database and its sidecar files (WAL/SHM/journal) into
  /// [rollbackDir] so the prepared file can take its place. On a partial
  /// failure any files already moved are moved back before rethrowing.
  Future<DatabaseSwapHandle> moveAside({
    required File liveFile,
    required Directory rollbackDir,
  }) async {
    final targetDir = Directory(p.join(rollbackDir.path, _databaseDir));
    await targetDir.create(recursive: true);
    final moved = <File>[];
    try {
      final names = [liveFile.path, ..._sidecarNames(liveFile.path)];
      for (final name in names) {
        final source = File(name);
        if (!await source.exists()) continue;
        final target = File(p.join(targetDir.path, p.basename(name)));
        await source.rename(target.path);
        moved.add(target);
      }
    } catch (_) {
      for (final movedFile in moved.reversed) {
        try {
          if (!await movedFile.exists()) continue;
          await movedFile.rename(
            p.join(liveFile.parent.path, p.basename(movedFile.path)),
          );
        } catch (_) {}
      }
      throw const DatabaseReplacementException();
    }
    return DatabaseSwapHandle(
      rollbackDir: rollbackDir,
      liveFile: liveFile,
      movedFiles: moved,
    );
  }

  /// Places the prepared database at the live location.
  Future<void> placePrepared({required File preparedFile, required File liveFile}) async {
    try {
      if (await liveFile.exists()) {
        await liveFile.delete();
      }
      await preparedFile.rename(liveFile.path);
    } catch (_) {
      throw const DatabaseReplacementException();
    }
  }

  /// Reverses a swap: deletes whatever currently sits at the live location and
  /// moves the aside files back.
  Future<void> restoreLive({required DatabaseSwapHandle handle}) async {
    try {
      if (await handle.liveFile.exists()) {
        await handle.liveFile.delete();
      }
      for (final sidecar in _sidecarNames(handle.liveFile.path)) {
        final f = File(sidecar);
        if (await f.exists()) {
          await f.delete();
        }
      }
      for (final moved in handle.movedFiles.reversed) {
        if (!await moved.exists()) continue;
        await moved.rename(p.join(handle.liveFile.parent.path, p.basename(moved.path)));
      }
    } catch (_) {
      throw const DatabaseReplacementException();
    }
  }
}