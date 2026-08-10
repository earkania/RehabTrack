import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/services/backup/backup_archive_reader.dart';
import 'package:rehab_track/data/services/backup/backup_archive_writer.dart';
import 'package:rehab_track/data/services/backup/backup_service.dart';
import 'package:rehab_track/data/services/backup/backup_storage_gateway.dart';
import 'package:rehab_track/data/services/backup/backup_validator.dart';
import 'package:rehab_track/data/services/backup/preferences_exporter.dart';
import 'package:rehab_track/data/services/restore/restore_recovery_metadata.dart';
import 'package:rehab_track/data/services/restore/restore_service.dart';
import 'package:rehab_track/domain/backup/backup_preview.dart';
import 'package:rehab_track/domain/backup/backup_result.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/domain/restore/restore_result.dart';

import 'helpers/restore_test_utils.dart';

class _FakeSettings implements SettingsRepository {
  final Map<String, String> store = {};

  @override
  Future<String?> getValue(String key) async => store[key];

  @override
  Future<void> setValue(String key, String value) async {
    store[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    store.remove(key);
  }

  @override
  Stream<Map<String, String>> watchAll() async* {
    yield Map.from(store);
  }

  @override
  Future<Map<String, String>> getAll() async => Map.from(store);
}

class _WriteToFileGateway extends BackupStorageGateway {
  final File target;

  _WriteToFileGateway(this.target);

  @override
  Future<BackupSaveResult> save({
    required Uint8List bytes,
    required String fileName,
  }) async {
    await target.writeAsBytes(bytes);
    return BackupSaveResult.success(target.path, displayName: fileName);
  }
}

void main() {
  late Directory tempBaseDir;
  late Directory docsDir;
  late AppDatabase database;
  late _FakeSettings settings;
  late RestoreRecoveryStore recoveryStore;

  setUp(() {
    tempBaseDir = Directory.systemTemp.createTempSync('e2e_');
    docsDir = Directory(p.join(tempBaseDir.path, 'docs'))..createSync();
    database = AppDatabase.forTesting(NativeDatabase.memory());
    settings = _FakeSettings();
    recoveryStore = RestoreRecoveryStore.inDirectory(
      Directory(p.join(tempBaseDir.path, 'recovery')),
    );
  });

  tearDown(() async {
    await database.close();
    tempBaseDir.deleteSync(recursive: true);
  });

  Future<File> createBackup() async {
    final target = File(p.join(tempBaseDir.path, 'backup.rtb'));
    final service = BackupService(
      database: database,
      archiveWriter: BackupArchiveWriter(),
      storageGateway: _WriteToFileGateway(target),
      preferencesExporter: PreferencesExporter(settings),
      documentsDirectory: () async => docsDir,
      tempBaseDir: tempBaseDir,
      platform: 'test',
    );
    final outcome = await service.createBackup();
    expect(outcome.result, BackupResult.success);
    return target;
  }

  Future<RestoreService> restoreService() async {
    return RestoreService(
      environment: FakeRestoreEnvironment(docsDir),
      archiveReader: const BackupArchiveReader(),
      validator: const BackupValidator(),
      recoveryStore: recoveryStore,
      tempBaseDir: tempBaseDir,
      currentDatabaseSchemaVersion: AppDatabase.currentSchemaVersion,
      currentAppVersion: '1.2.0',
    );
  }

  Future<BackupPreview> previewFor(File file) async {
    final read = await const BackupArchiveReader().read(file);
    expect(read.succeeded, isTrue);
    final outcome = await const BackupValidator().validate(
      handle: read.handle!,
      tempDir: tempBaseDir,
      currentDatabaseSchemaVersion: AppDatabase.currentSchemaVersion,
      currentAppVersion: '1.2.0',
    );
    return outcome.preview!;
  }

  Future<void> seedDatabase(String firstName) async {
    await database.delete(database.profiles).go();
    await database.into(database.profiles).insert(
          ProfilesCompanion.insert(
            firstName: firstName,
            lastName: 'Test',
            createdAt: DateTime(2025),
            updatedAt: DateTime(2025),
            isPrimary: const Value(true),
            isActive: const Value(true),
          ),
        );
  }

  String? firstProfileName(String dbPath) {
    final db = sqlite.sqlite3.open(dbPath, mode: sqlite.OpenMode.readOnly);
    final name = db
        .select('SELECT first_name FROM profiles ORDER BY id LIMIT 1')
        .rows
        .first
        .first as String?;
    db.close();
    return name;
  }

  test('backup then restore replaces live B with archived A', () async {
    await seedDatabase('Ana');

    final backup = await createBackup();
    final preview = await previewFor(backup);

    // Live device currently holds different data (B).
    await writeLiveDatabase(
      docsDir,
      buildRestorableSqliteBytes(schema: 16, profiles: 2),
    );

    final service = await restoreService();
    final failure = await service.run(
      selectedBackupFile: backup,
      expectedPreview: preview,
    );

    expect(failure.succeeded, isTrue);
    expect(readProfileCount(p.join(docsDir.path, 'rehabtrack.sqlite')), 1);
    expect(firstProfileName(p.join(docsDir.path, 'rehabtrack.sqlite')), 'Ana');
    expect(await recoveryStore.listAll(), isEmpty);
  });

  test('a second full cycle restores the newest backup', () async {
    // Cycle 1: backup A and restore it over live B.
    await seedDatabase('Ana');
    var backup = await createBackup();
    var preview = await previewFor(backup);
    await writeLiveDatabase(
      docsDir,
      buildRestorableSqliteBytes(schema: 16, profiles: 2),
    );
    var service = await restoreService();
    expect((await service.run(selectedBackupFile: backup, expectedPreview: preview)).succeeded,
        isTrue);
    expect(
      firstProfileName(p.join(docsDir.path, 'rehabtrack.sqlite')),
      'Ana',
    );

    // Cycle 2: user edits data to Bea and backs up again, then restores.
    await database.delete(database.profiles).go();
    await seedDatabase('Bea');
    backup = await createBackup();
    preview = await previewFor(backup);
    service = await restoreService();
    expect((await service.run(selectedBackupFile: backup, expectedPreview: preview)).succeeded,
        isTrue);
    expect(
      firstProfileName(p.join(docsDir.path, 'rehabtrack.sqlite')),
      'Bea',
    );
    expect(readProfileCount(p.join(docsDir.path, 'rehabtrack.sqlite')), 1);
    expect(await recoveryStore.listAll(), isEmpty);
  });

  test('restore finalizes the Last Restore source data, no recovery leftover',
      () async {
    await seedDatabase('Ana');
    final backup = await createBackup();
    final preview = await previewFor(backup);

    await writeLiveDatabase(
      docsDir,
      buildRestorableSqliteBytes(schema: 16, profiles: 2),
    );

    final service = await restoreService();
    final failure = await service.run(
      selectedBackupFile: backup,
      expectedPreview: preview,
    );

    expect(failure.succeeded, isTrue);
    expect(readProfileCount(p.join(docsDir.path, 'rehabtrack.sqlite')), 1);
    // Completed restores leave no recovery markers behind.
    expect(await recoveryStore.listAll(), isEmpty);
    // Nothing stale remains under the temp root.
    final leftovers = <String>[
      for (final e in tempBaseDir.listSync())
        if (p.basename(e.path).startsWith('rehabtrack_backup_'))
          e.path,
    ];
    expect(leftovers, isEmpty);
  });

  test('backup includes prescription attachments and restore places them back',
      () async {
    await seedDatabase('Ana');
    final profile = await database
        .select(database.profiles)
        .getSingle();
    final profileId = profile.id;

    // Write a prescription attachment to the managed documents directory and
    // reference it from the database.
    final attachmentsDir = Directory(
      p.join(docsDir.path, 'doctor_prescriptions', '$profileId', '1'),
    )..createSync(recursive: true);
    File(p.join(attachmentsDir.path, 'rx.pdf')).writeAsBytesSync([1, 2, 3]);
    await database.into(database.doctorPrescriptions).insert(
          DoctorPrescriptionsCompanion.insert(
            profileId: profileId,
            title: 'Amoxicillin',
            prescriptionDate: DateTime(2026, 8, 1),
            createdAt: DateTime(2025),
            updatedAt: DateTime(2025),
          ),
        );
    await database.into(database.doctorPrescriptionAttachments).insert(
          DoctorPrescriptionAttachmentsCompanion.insert(
            prescriptionId: 1,
            profileId: profileId,
            fileType: 'pdf',
            managedRelativePath:
                'doctor_prescriptions/$profileId/1/rx.pdf',
            originalFileName: 'rx.pdf',
            displayName: 'rx',
            mimeType: 'application/pdf',
            fileSize: const Value(3),
            sortOrder: const Value(0),
            createdAt: DateTime(2025),
            updatedAt: DateTime(2025),
          ),
        );

    final backup = await createBackup();
    final preview = await previewFor(backup);

    // Restore into a fresh docs dir so the file must come from the archive.
    final freshDocs =
        Directory(p.join(tempBaseDir.path, 'fresh_docs'))..createSync();
    await writeLiveDatabase(
      freshDocs,
      buildRestorableSqliteBytes(schema: 16, profiles: 2),
    );
    final env = FakeRestoreEnvironment(freshDocs);
    final service = RestoreService(
      environment: env,
      archiveReader: const BackupArchiveReader(),
      validator: const BackupValidator(),
      recoveryStore: RestoreRecoveryStore.inDirectory(
        Directory(p.join(tempBaseDir.path, 'recovery2')),
      ),
      tempBaseDir: tempBaseDir,
      currentDatabaseSchemaVersion: AppDatabase.currentSchemaVersion,
      currentAppVersion: '1.2.0',
    );

    final failure =
        await service.run(selectedBackupFile: backup, expectedPreview: preview);
    expect(failure.succeeded, isTrue,
        reason: 'Failed at ${failure.result}');
    expect(failure.result, RestoreResult.success);

    final restoredFile = File(
      p.join(freshDocs.path, 'doctor_prescriptions', '$profileId', '1',
          'rx.pdf'),
    );
    expect(restoredFile.existsSync(), isTrue);
    expect(restoredFile.readAsBytesSync(), [1, 2, 3]);
  });
}
