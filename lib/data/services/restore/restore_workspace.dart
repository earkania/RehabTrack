import 'dart:io';

import 'package:path/path.dart' as p;

/// A private, unique temporary workspace for one restore-apply operation.
///
/// Layout (project convention):
///   `<base>/restore-workspace/<operationId>/`
///     selected-backup/     the validated backup selected for restore
///     prepared-database/   validated restored database
///     prepared-files/      validated restored managed files
///     prepared-preferences/validated restored preferences
///     safety-snapshot/     pre-restore safety snapshot (DB + prefs + files)
///     rollback-workspace/  live data moved aside during replacement
///
/// The safety snapshot is retained until restore verification succeeds, so it
/// is excluded from [cleanup] by default.
class RestoreWorkspace {
  final Directory root;

  RestoreWorkspace._(this.root);

  static Future<RestoreWorkspace> create({
    required Directory baseDir,
    required String operationId,
  }) async {
    final root = await Directory(
      p.join(baseDir.path, 'restore-workspace', operationId),
    ).create(recursive: true);
    return RestoreWorkspace._(root);
  }

  /// Reconstructs a workspace from an existing root directory, used when
  /// recovering an interrupted operation from its persisted workspace path.
  static RestoreWorkspace open(Directory root) => RestoreWorkspace._(root);

  Directory get selectedBackup =>
      Directory(p.join(root.path, 'selected-backup'));

  Directory get preparedDatabase =>
      Directory(p.join(root.path, 'prepared-database'));

  Directory get preparedFiles =>
      Directory(p.join(root.path, 'prepared-files'));

  Directory get preparedPreferences =>
      Directory(p.join(root.path, 'prepared-preferences'));

  Directory get safetySnapshot =>
      Directory(p.join(root.path, 'safety-snapshot'));

  Directory get rollbackWorkspace =>
      Directory(p.join(root.path, 'rollback-workspace'));

  /// Resolves all workspace subdirectories, creating them eagerly so later
  /// operations can write without repeating async scaffolding.
  Future<void> ensureSubdirectories() async {
    await Future.wait([
      _ensure(selectedBackup),
      _ensure(preparedDatabase),
      _ensure(preparedFiles),
      _ensure(preparedPreferences),
      _ensure(safetySnapshot),
      _ensure(rollbackWorkspace),
    ]);
  }

  Future<void> _ensure(Directory dir) async {
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  /// Removes the whole workspace, including the safety snapshot and any
  /// rollback data. Only call this once restoration succeeded and the snapshot
  /// is no longer needed.
  Future<void> deleteEntirely() async {
    await root.delete(recursive: true);
  }

  /// Whether the workspace (and thus any retained snapshot/rollback data)
  /// still exists on disk.
  Future<bool> exists() => root.exists();
}