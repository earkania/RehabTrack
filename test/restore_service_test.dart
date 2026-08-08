import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'package:rehab_track/data/services/backup/backup_archive_reader.dart';
import 'package:rehab_track/data/services/backup/backup_validator.dart';
import 'package:rehab_track/data/services/restore/restore_recovery_metadata.dart';
import 'package:rehab_track/data/services/restore/restore_service.dart';
import 'package:rehab_track/data/services/storage/storage_inspector.dart';
import 'package:rehab_track/domain/backup/backup_preview.dart';
import 'package:rehab_track/domain/restore/restore_apply_phase.dart';
import 'package:rehab_track/domain/restore/restore_result.dart';
import 'package:rehab_track/domain/restore/restore_rollback_result.dart';

import 'helpers/restore_test_utils.dart';

void main() {
  late _Fixture fix;

  setUp(() async {
    fix = await _Fixture.create();
  });

  tearDown(() {
    fix.tempBaseDir.deleteSync(recursive: true);
  });

  test('successful restore replaces the live state with the backup', () async {
    final phases = <RestoreApplyPhase>[];
    final failure = await fix.service.run(
      selectedBackupFile: fix.selectedFile,
      expectedPreview: fix.preview,
      onPhase: phases.add,
    );

    expect(failure.succeeded, isTrue);
    expect(fix.env.cancelNotificationCalls, 1);
    expect(await fix.recoveryStore.listAll(), isEmpty);

    final liveDb = (await fix.env.liveDb()).path;
    expect(readProfileCount(liveDb), 1);
    expect(
      await readAllowlistedSettings(liveDb),
      {'app_language': 'en'},
    );
    // Photo path was remapped to the live managed root, not the backup device.
    final reader = sqlite.sqlite3.open(liveDb, mode: sqlite.OpenMode.readOnly);
    final photo = reader
        .select('SELECT photoPath FROM profiles WHERE id = 1').rows.first[0]
        as String;
    reader.close();
    expect(photo, p.join(fix.docsDir.path, 'profile_images', 'photoB.jpg'));
    expect(await managedFileExists(fix.docsDir, 'profile_images', 'photoB.jpg'),
        isTrue);
    expect(await managedFileExists(fix.docsDir, 'profile_images', 'photoA.jpg'),
        isFalse);
    expect(await managedFileExists(
          fix.docsDir,
          'lab_analyses',
          p.join('1', '2', 'report.pdf'),
        ),
        isTrue);

    expect(phases.last, RestoreApplyPhase.finalizing);
  });

  test('older-schema backups are migrated and restored', () async {
    // A schema-13 backup now runs through the app's migrations, not gated off.
    final oldDb = buildRestorableSqliteBytes(
      schema: 13,
      profiles: 1,
      settings: const {},
    );
    final oldArchive = buildRestorableBackupZip(
      schema: 13,
      database: oldDb,
      preferences: const {'app_language': 'en'},
    );
    final oldFile = File(p.join(fix.tempBaseDir.path, 'old.rtb'));
    await oldFile.writeAsBytes(oldArchive);
    final oldPreview = await fix.previewFor(oldFile);
    expect(oldPreview.migrationRequired, isTrue);

    final failure = await fix.service.run(
      selectedBackupFile: oldFile,
      expectedPreview: oldPreview,
    );
    expect(failure.succeeded, isTrue);

    final liveDb = (await fix.env.liveDb()).path;
    expect(readProfileCount(liveDb), 1);
    final db = sqlite.sqlite3.open(liveDb, mode: sqlite.OpenMode.readOnly);
    final version = db.userVersion;
    final hasVisitRecords = db
        .select(
          "SELECT name FROM sqlite_master "
          "WHERE type='table' AND name='doctor_visit_records'",
        )
        .isNotEmpty;
    db.close();
    expect(version, 15);
    expect(hasVisitRecords, isTrue);
  });

  test('a failed reminder rebuild still restores the data', () async {
    fix.env.failRebuildNotifications = true;
    final failure = await fix.service.run(
      selectedBackupFile: fix.selectedFile,
      expectedPreview: fix.preview,
    );
    expect(failure.result, RestoreResult.successWithReminderWarning);
    expect(failure.succeeded, isTrue);
    // The data restore completed and the recovery store is cleared.
    expect(readProfileCount((await fix.env.liveDb()).path), 1);
    expect(await fix.recoveryStore.listAll(), isEmpty);
  });

  test('cancellation requested before the swap leaves the live state intact',
      () async {
    final failure = await fix.service.run(
      selectedBackupFile: fix.selectedFile,
      expectedPreview: fix.preview,
      isCancellationRequested: () async => true,
    );
    expect(failure.result, RestoreResult.cancelled);
    expect(readProfileCount((await fix.env.liveDb()).path), 2);
    expect(await managedFileExists(fix.docsDir, 'profile_images', 'photoA.jpg'),
        isTrue);
  });

  test('a preview that no longer matches the archive fails validation', () async {
    final mismatched = BackupPreview(
      backupCreatedAt: fix.preview.backupCreatedAt,
      appVersion: fix.preview.appVersion,
      backupFormatVersion: fix.preview.backupFormatVersion,
      databaseSchemaVersion: 13,
      currentDatabaseSchemaVersion: fix.preview.currentDatabaseSchemaVersion,
      compatibility: fix.preview.compatibility,
      migrationRequired: fix.preview.migrationRequired,
      managedFileCount: fix.preview.managedFileCount,
      backupFileSize: fix.preview.backupFileSize,
    );
    final failure = await fix.service.run(
      selectedBackupFile: fix.selectedFile,
      expectedPreview: mismatched,
    );
    expect(failure.result, RestoreResult.validationFailure);
    expect(readProfileCount((await fix.env.liveDb()).path), 2);
  });

  test('a corrupted archive fails validation', () async {
    final garbage = File(p.join(fix.tempBaseDir.path, 'garbage.rtb'));
    await garbage.writeAsBytes([1, 2, 3, 4, 5]);
    final failure = await fix.service.run(
      selectedBackupFile: garbage,
      expectedPreview: fix.preview,
    );
    expect(failure.result, RestoreResult.validationFailure);
  });

  test('a safety-snapshot failure aborts without changing the live state',
      () async {
    fix.env.failSnapshot = true;
    final failure = await fix.service.run(
      selectedBackupFile: fix.selectedFile,
      expectedPreview: fix.preview,
    );
    expect(failure.result, RestoreResult.safetySnapshotFailure);
    expect(failure.rollback, RestoreRollbackResult.rollbackSucceeded);
    expect(readProfileCount((await fix.env.liveDb()).path), 2);
    expect(await fix.recoveryStore.listAll(), isEmpty);
  });

  test('a pause failure is reported as unexpected without live changes',
      () async {
    fix.env.failPause = true;
    final failure = await fix.service.run(
      selectedBackupFile: fix.selectedFile,
      expectedPreview: fix.preview,
    );
    expect(failure.result, RestoreResult.unexpectedFailure);
    expect(failure.originalDataRecovered, isTrue);
    expect(readProfileCount((await fix.env.liveDb()).path), 2);
  });

  test('a failed reinitialization rolls back to the original data',
      () async {
    fix.env.failReinitOnce = true;
    final failure = await fix.service.run(
      selectedBackupFile: fix.selectedFile,
      expectedPreview: fix.preview,
    );
    expect(failure.result, RestoreResult.reinitializationFailure);
    expect(failure.rollback, RestoreRollbackResult.rollbackSucceeded);
    expect(failure.originalDataRecovered, isTrue);
    expect(await fix.recoveryStore.listAll(), isEmpty);

    final liveDb = (await fix.env.liveDb()).path;
    expect(readProfileCount(liveDb), 2);
    expect(await readAllowlistedSettings(liveDb), {'app_language': 'ka'});
    expect(await managedFileExists(fix.docsDir, 'profile_images', 'photoA.jpg'),
        isTrue);
    expect(await managedFileExists(fix.docsDir, 'profile_images', 'photoB.jpg'),
        isFalse);
  });

  test('a failed verification rolls back but retains recovery data',
      () async {
    fix.env.verifyResult = false;
    final failure = await fix.service.run(
      selectedBackupFile: fix.selectedFile,
      expectedPreview: fix.preview,
    );
    expect(failure.result, RestoreResult.verificationFailure);
    expect(failure.rollback, RestoreRollbackResult.rollbackFailed);

    // The safety snapshot and rollback data must be retained for recovery.
    expect(await fix.recoveryStore.listAll(), isNotEmpty);
    final liveDb = (await fix.env.liveDb()).path;
    // Data was still restored to the original; only the final verification
    // could not run.
    expect(readProfileCount(liveDb), 2);
    expect(await readAllowlistedSettings(liveDb), {'app_language': 'ka'});
  });

  test('low free space aborts with insufficientStorage before any swap',
      () async {
    final guarded = await _Fixture.create(
      storageInspector: const _FixedStorageInspector(0),
    );
    final failure = await guarded.service.run(
      selectedBackupFile: guarded.selectedFile,
      expectedPreview: guarded.preview,
    );
    expect(failure.result, RestoreResult.insufficientStorage);
    // Nothing was applied, no recovery data remains.
    expect(await guarded.recoveryStore.listAll(), isEmpty);
    expect(readProfileCount((await guarded.env.liveDb()).path), 2);
    expect(guarded.env.cancelNotificationCalls, 0);
  });

  test('duplicate notification ids yield successWithReminderWarning',
      () async {
    fix.env.hasDuplicateNotificationIds = true;
    final failure = await fix.service.run(
      selectedBackupFile: fix.selectedFile,
      expectedPreview: fix.preview,
    );
    expect(failure.result, RestoreResult.successWithReminderWarning);
    expect(failure.succeeded, isTrue);
    expect(readProfileCount((await fix.env.liveDb()).path), 1);
    expect(await fix.recoveryStore.listAll(), isEmpty);
  });
}

class _FixedStorageInspector extends StorageInspector {
  const _FixedStorageInspector(this.bytes);

  final int? bytes;

  @override
  Future<int?> freeBytes(String path) async => bytes;
}

class _Fixture {
  final Directory tempBaseDir;
  final Directory docsDir;
  final FakeRestoreEnvironment env;
  final RestoreRecoveryStore recoveryStore;
  final RestoreService service;
  final File selectedFile;
  final BackupPreview preview;

  _Fixture(this.tempBaseDir, this.docsDir, this.env, this.recoveryStore,
      this.service, this.selectedFile, this.preview);

  static Future<_Fixture> create({
    StorageInspector? storageInspector,
  }) async {
    final tempBaseDir = Directory.systemTemp.createTempSync('restore_svc_');
    final docsDir = Directory(p.join(tempBaseDir.path, 'documents'));
    final env = FakeRestoreEnvironment(docsDir);
    final recoveryStore = RestoreRecoveryStore.inDirectory(
      Directory(p.join(tempBaseDir.path, 'recovery')),
    );
    final service = RestoreService(
      environment: env,
      archiveReader: const BackupArchiveReader(),
      validator: const BackupValidator(),
      recoveryStore: recoveryStore,
      tempBaseDir: tempBaseDir,
      currentDatabaseSchemaVersion: 15,
      currentAppVersion: '1.2.0',
      storageInspector: storageInspector ?? const StorageInspector(),
      random: Random(7),
    );

    // Live state A: 2 profiles, ka locale, one photo.
    final aDb = buildRestorableSqliteBytes(
      schema: 15,
      profiles: 2,
      settings: const {'app_language': 'ka'},
      profilePhotoPath: '/device/docs/profile_images/photoA.jpg',
    );
    await writeLiveDatabase(docsDir, aDb);
    await writeManagedFile(docsDir, 'profile_images', 'photoA.jpg', [1]);

    // Backup B: 1 profile, en locale, a different photo.
    final bDb = buildRestorableSqliteBytes(
      schema: 15,
      profiles: 1,
      settings: const {'app_language': 'en'},
      profilePhotoPath: '/other/device/profile_images/photoB.jpg',
    );
    final archive = buildRestorableBackupZip(
      schema: 15,
      database: bDb,
      preferences: const {'app_language': 'en'},
      files: {
        'files/profile_images/photoB.jpg': Uint8List.fromList([2, 2, 2]),
        'files/lab_analyses/1/2/report.pdf': Uint8List.fromList([7, 8, 9]),
      },
    );
    final selectedFile = File(p.join(tempBaseDir.path, 'selected.rtb'));
    await selectedFile.writeAsBytes(archive);
    final preview = await _previewFor(tempBaseDir, selectedFile);

    return _Fixture(tempBaseDir, docsDir, env, recoveryStore, service,
        selectedFile, preview);
  }

  Future<BackupPreview> previewFor(File file) => _previewFor(tempBaseDir, file);

  static Future<BackupPreview> _previewFor(
    Directory tempBaseDir,
    File file,
  ) async {
    final read = await const BackupArchiveReader().read(file);
    expect(read.succeeded, isTrue);
    final outcome = await const BackupValidator().validate(
      handle: read.handle!,
      tempDir: tempBaseDir,
      currentDatabaseSchemaVersion: 15,
      currentAppVersion: '1.2.0',
    );
    expect(outcome.preview, isNotNull);
    return outcome.preview!;
  }
}