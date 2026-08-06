import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'package:rehab_track/data/services/backup/preferences_exporter.dart';
import 'package:rehab_track/data/services/restore/app_settings_writer.dart';
import 'package:rehab_track/data/services/restore/restore_environment.dart';
import 'package:rehab_track/domain/restore/reminder_rebuild_report.dart';

import 'backup_test_utils.dart' show buildZip;

/// Builds a restorable SQLite database with the realistic column layout the
/// restore engine relies on (app_settings key/value, profiles.photoPath).
Uint8List buildRestorableSqliteBytes({
  required int schema,
  int profiles = 1,
  Map<String, String> settings = const {},
  String? profilePhotoPath,
  bool withCareContacts = true,
}) {
  final dir = Directory.systemTemp.createTempSync('rehabtest_rbb_');
  final path = p.join(dir.path, 'db.sqlite');
  try {
    final db = sqlite.sqlite3.open(path);
    try {
      db.execute('PRAGMA user_version = $schema');
      db.execute(
        'CREATE TABLE profiles (id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'firstName TEXT, photoPath TEXT)',
      );
      for (var i = 0; i < profiles; i++) {
        db.execute(
          'INSERT INTO profiles (firstName, photoPath) VALUES(?, ?)',
          ['Row${i + 1}', i == 0 ? profilePhotoPath : null],
        );
      }
      db.execute('CREATE TABLE medications (id INTEGER PRIMARY KEY)');
      db.execute(
        'CREATE TABLE measurement_types (id INTEGER PRIMARY KEY, name TEXT)',
      );
      db.execute('INSERT INTO measurement_types (name) VALUES(\'Weight\')');
      db.execute(
        'CREATE TABLE app_settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
      );
      for (final entry in settings.entries) {
        db.execute('INSERT INTO app_settings(key, value) VALUES(?, ?)',
            [entry.key, entry.value]);
      }
      if (withCareContacts) {
        db.execute(
          'CREATE TABLE care_contacts (id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'profileId INTEGER, photoPath TEXT)',
        );
      }
      db.execute(
        'CREATE TABLE measurement_records '
        '(id INTEGER PRIMARY KEY AUTOINCREMENT, profileId INTEGER, value REAL)',
      );
      db.execute(
        'CREATE TABLE doctor_visit_records '
        '(id INTEGER PRIMARY KEY AUTOINCREMENT, profileId INTEGER)',
      );
    } finally {
      db.close();
    }
    return File(path).readAsBytesSync();
  } finally {
    dir.deleteSync(recursive: true);
  }
}

/// Builds a complete, valid `.rtb` archive from the given parts.
Uint8List buildRestorableBackupZip({
  required int schema,
  required Uint8List database,
  required Map<String, Object?> preferences,
  Map<String, Uint8List> files = const {},
  String appVersion = '1.2.0',
  int formatVersion = 1,
}) {
  final prefsBytes = Uint8List.fromList(utf8.encode(jsonEncode(preferences)));
  final checksums = <String, String>{
    'database.sqlite': sha256.convert(database).toString(),
    'preferences.json': sha256.convert(prefsBytes).toString(),
    for (final e in files.entries)
      e.key: sha256.convert(e.value).toString(),
  };
  final manifest = {
    'backupFormatVersion': formatVersion,
    'appVersion': appVersion,
    'databaseSchemaVersion': schema,
    'createdAt': '2026-08-05T00:00:00.000Z',
    'platform': 'android',
    'fileCount': files.length,
    'totalUncompressedSize': database.length +
        prefsBytes.length +
        files.values.fold(0, (sum, b) => sum + b.length),
    'checksums': checksums,
  };
  return buildZip({
    'manifest.json': Uint8List.fromList(utf8.encode(jsonEncode(manifest))),
    'database.sqlite': database,
    'preferences.json': prefsBytes,
    ...files,
  });
}

/// Reads `app_settings` values present in the allowlist from a sqlite file.
Future<Map<String, String>> readAllowlistedSettings(String dbPath) async {
  final db = sqlite.sqlite3.open(dbPath, mode: sqlite.OpenMode.readOnly);
  try {
    final map = <String, String>{};
    for (final row in db.select('SELECT key, value FROM app_settings').rows) {
      final key = row[0] as String;
      if (PreferencesExporter.allowlist.contains(key)) {
        map[key] = row[1] as String;
      }
    }
    return map;
  } finally {
    db.close();
  }
}

/// Reads the profile count from a sqlite file.
int readProfileCount(String dbPath) {
  final db = sqlite.sqlite3.open(dbPath, mode: sqlite.OpenMode.readOnly);
  try {
    return db.select('SELECT COUNT(*) FROM profiles').rows.first[0] as int;
  } finally {
    db.close();
  }
}

/// A test double for [RestoreEnvironment] operating on [docsDir]: the live
/// database lives at `docsDir/rehabtrack.sqlite` and the managed roots at
/// `docsDir/profile_images` and `docsDir/care_contact_images`.
class FakeRestoreEnvironment implements RestoreEnvironment {
  final Directory docsDir;

  bool failSnapshot = false;
  bool failPause = false;
  bool failReopen = false;
  bool failReinit = false;

  /// When true, [reinitializeProviders] throws exactly once, then resets so a
  /// rollback's own reinitialization can proceed.
  bool failReinitOnce = false;
  bool verifyResult = true;
  bool failCancelNotifications = false;
  int cancelNotificationCalls = 0;
  bool failRebuildNotifications = false;
  int rebuildNotificationCalls = 0;
  final List<String> appliedPreferences = [];

  /// When true, [verifyScheduledNotificationsNoDuplicates] reports duplicates.
  bool hasDuplicateNotificationIds = false;
  int verifyNoDuplicateCalls = 0;
  int reopenDatabaseCalls = 0;

  FakeRestoreEnvironment(this.docsDir);

  Future<File> liveDb() async =>
      File(p.join(docsDir.path, 'rehabtrack.sqlite'));

  @override
  Future<Directory> documentsDirectory() async => docsDir;

  @override
  Future<Map<String, String>> captureSupportedPreferences() async {
    return readAllowlistedSettings((await liveDb()).path);
  }

  @override
  Future<void> snapshotLiveDatabase(File destinationPath) async {
    if (failSnapshot) throw const RestoreEnvironmentFailure();
    await (await liveDb()).copy(destinationPath.path);
  }

  @override
  Future<void> applyPreferences(Map<String, String> values) async {
    appliedPreferences.add(jsonEncode(values));
    AppSettingsWriter.write((await liveDb()).path, values);
  }

  @override
  Future<void> pauseLiveDatabase() async {
    if (failPause) throw const RestoreEnvironmentFailure();
  }

  @override
  Future<void> reopenDatabase() async {
    reopenDatabaseCalls++;
    if (failReopen) throw const RestoreEnvironmentFailure();
  }

  @override
  Future<void> reinitializeProviders() async {
    if (failReinitOnce) {
      failReinitOnce = false;
      throw const RestoreEnvironmentFailure();
    }
    if (failReinit) throw const RestoreEnvironmentFailure();
  }

  @override
  Future<bool> verifyRestoredState() async {
    if (!verifyResult) return false;
    final db = sqlite.sqlite3.open(
      (await liveDb()).path,
      mode: sqlite.OpenMode.readOnly,
    );
    final ok = db.userVersion > 0;
    db.close();
    return ok;
  }

  @override
  Future<void> cancelScheduledNotifications() async {
    if (failCancelNotifications) throw const RestoreEnvironmentFailure();
    cancelNotificationCalls++;
  }

  @override
  Future<ReminderRebuildReport> rebuildScheduledNotifications() async {
    if (failRebuildNotifications) {
      throw const RestoreEnvironmentFailure(reason: 'test');
    }
    rebuildNotificationCalls++;
    return const ReminderRebuildReport(
      medicationReminders: 1,
      measurementReminders: 1,
      doctorVisitReminders: 1,
    );
  }

  @override
  Future<bool> verifyScheduledNotificationsNoDuplicates() async {
    verifyNoDuplicateCalls++;
    return !hasDuplicateNotificationIds;
  }
}

/// Writes [bytes] as the live database of [docsDir].
Future<void> writeLiveDatabase(Directory docsDir, List<int> bytes) async {
  final file = File(p.join(docsDir.path, 'rehabtrack.sqlite'));
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes);
}

/// Writes a managed file into `docsDir/<root>/<name>`.
Future<void> writeManagedFile(
  Directory docsDir,
  String root,
  String name,
  List<int> bytes,
) async {
  final dir = Directory(p.join(docsDir.path, root));
  await dir.create(recursive: true);
  await File(p.join(dir.path, name)).writeAsBytes(bytes);
}

Future<bool> managedFileExists(
  Directory docsDir,
  String root,
  String name,
) async {
  return File(p.join(docsDir.path, root, name)).exists();
}

/// A convenience test backup source: a sqlite DB plus files/prefs such that
/// restoring a backup built from it will reproduce exactly this state.
class BackupSource {
  final Uint8List database;
  final Map<String, Object?> preferences;

  BackupSource(this.database, this.preferences);

  static Future<BackupSource> build({
    required int schema,
    int profiles = 1,
    Map<String, String> settings = const {},
    String? profilePhotoPath,
  }) async {
    return BackupSource(
      buildRestorableSqliteBytes(
        schema: schema,
        profiles: profiles,
        settings: settings,
        profilePhotoPath: profilePhotoPath,
      ),
      settings,
    );
  }
}