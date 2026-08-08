import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:rehab_track/data/services/restore/restore_environment.dart';
import 'package:rehab_track/data/services/restore/restore_file_manager.dart';

/// Thrown when the pre-restore safety snapshot cannot be created. The current
/// live state is left untouched; the restore must abort.
class SafetySnapshotException implements Exception {
  const SafetySnapshotException();
}

/// Captures the current live state (database, allowlisted preferences and
/// managed files) into the safety-snapshot area of the workspace so a
/// failed restore can roll the device back to exactly this state.
///
/// The snapshot directory is excluded from normal workspace cleanup and is
/// only removed once restore verification succeeds.
class RestoreSafetySnapshotService {
  final RestoreEnvironment _environment;

  RestoreSafetySnapshotService(this._environment);

  /// Snapshot layout:
  ///   `<snapshotDir>/database.sqlite`
  ///   `<snapshotDir>/preferences.json`
  ///   `<snapshotDir>/files/profile_images/...`
  ///   `<snapshotDir>/files/care_contact_images/...`
  ///   `<snapshotDir>/files/lab_analyses/<profileId>/<analysisId>/...`
  static const String databaseFileName = 'database.sqlite';
  static const String preferencesFileName = 'preferences.json';
  static const String filesDirectory = 'files';

  Future<void> create({required Directory snapshotDir}) async {
    await snapshotDir.create(recursive: true);

    final dbSnapshot = File(p.join(snapshotDir.path, databaseFileName));
    try {
      await _environment.snapshotLiveDatabase(dbSnapshot);
    } catch (_) {
      throw const SafetySnapshotException();
    }
    if (!await dbSnapshot.exists() || await dbSnapshot.length() == 0) {
      throw const SafetySnapshotException();
    }

    try {
      final prefs = await _environment.captureSupportedPreferences();
      await File(p.join(snapshotDir.path, preferencesFileName))
          .writeAsString(jsonEncode(prefs), flush: true);
    } catch (_) {
      throw const SafetySnapshotException();
    }

    try {
      await _copyManagedFiles(snapshotDir);
    } catch (_) {
      throw const SafetySnapshotException();
    }
  }

  Future<void> _copyManagedFiles(Directory snapshotDir) async {
    final docs = await _environment.documentsDirectory();
    final filesRoot = Directory(p.join(snapshotDir.path, filesDirectory));
    await filesRoot.create(recursive: true);

    for (final name in RestoreFileManager.managedRootNames) {
      final source = Directory(p.join(docs.path, name));
      if (!await source.exists()) continue;
      await copyDirectoryTree(
        source,
        Directory(p.join(filesRoot.path, name)),
      );
    }
  }
}

/// Reads the snapshot back for rollback use.
class SafetySnapshotContent {
  final Directory snapshotDir;

  SafetySnapshotContent(this.snapshotDir);

  File get databaseFile =>
      File(p.join(snapshotDir.path, RestoreSafetySnapshotService.databaseFileName));

  File get preferencesFile => File(
        p.join(snapshotDir.path, RestoreSafetySnapshotService.preferencesFileName),
      );

  Directory get filesRoot =>
      Directory(p.join(snapshotDir.path, RestoreSafetySnapshotService.filesDirectory));

  Future<Map<String, String>> readPreferences() async {
    try {
      final decoded = jsonDecode(await preferencesFile.readAsString());
      if (decoded is Map) {
        return decoded.cast<String, String>();
      }
    } catch (_) {}
    return const {};
  }
}