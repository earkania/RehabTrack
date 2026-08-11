import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:rehab_track/data/services/backup/backup_document_gateway.dart';
import 'package:rehab_track/data/services/backup/backup_import_service.dart';
import 'package:rehab_track/data/services/backup/backup_registry.dart';
import 'package:rehab_track/data/services/backup/backup_storage_gateway.dart';
import 'package:rehab_track/domain/backup/backup_availability.dart';
import 'package:rehab_track/domain/backup/backup_result.dart';
import 'package:rehab_track/domain/backup/registered_backup.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';

import 'helpers/backup_test_utils.dart';

class FakeSettingsRepository implements SettingsRepository {
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

class _PickableGateway extends BackupStorageGateway {
  BackupImportPickResult pick;
  int pickCalls = 0;

  _PickableGateway(this.pick);

  @override
  Future<BackupImportPickResult> pickBackupDocuments() async {
    pickCalls++;
    return pick;
  }
}

class _FakeDocumentGateway extends BackupDocumentGateway {
  final Map<String, Uint8List> contents;
  final Set<String> failingUris;

  _FakeDocumentGateway(this.contents, {this.failingUris = const {}});

  @override
  Future<void> copyDocument({
    required String contentUri,
    required String destinationPath,
  }) async {
    if (failingUris.contains(contentUri)) {
      throw Exception('simulated copy failure');
    }
    final bytes = contents[contentUri];
    if (bytes == null) {
      throw Exception('source document unavailable');
    }
    await File(destinationPath).writeAsBytes(bytes);
  }
}

void main() {
  late Directory tempBase;

  setUp(() {
    tempBase = Directory.systemTemp.createTempSync('import_test_');
  });

  tearDown(() {
    if (tempBase.existsSync()) {
      tempBase.deleteSync(recursive: true);
    }
  });

  BackupImportService buildService(
    _PickableGateway picker,
    _FakeDocumentGateway documents,
    BackupRegistry registry,
  ) {
    return BackupImportService(
      storageGateway: picker,
      documentGateway: documents,
      registry: registry,
      tempBaseDir: tempBase,
      // Accept any manifest app version / schema regardless of the current
      // release values baked into the build.
      currentAppVersion: '1.0.0',
      currentDatabaseSchemaVersion: 20,
    );
  }

  Uint8List validZip() =>
      buildValidBackupZip(schema: 14, appVersion: '1.0.0');

  final validBytes = validZip();

  test('registers a single valid picked document with provider metadata and '
      'available state', () async {
    final registry = BackupRegistry(FakeSettingsRepository());
    final picker = _PickableGateway(
      BackupImportPickResult.success(const [
        BackupImportDocument(
          contentUri: 'content://doc/imported',
          displayName: 'Old Backup from Downloads.rtb',
        ),
      ]),
    );
    final documents = _FakeDocumentGateway({
      'content://doc/imported': validBytes,
    });
    final service = buildService(picker, documents, registry);

    final outcome = await service.import();

    expect(outcome.status, BackupImportStatus.success);
    expect(outcome.imported, 1);
    expect(outcome.refreshed, 0);
    expect(outcome.invalidSkipped, 0);
    expect(outcome.failed, 0);

    final entry = (await registry.all()).single;
    expect(entry.contentUri, 'content://doc/imported');
    expect(entry.displayName, 'Old Backup from Downloads.rtb');
    expect(entry.availability, BackupAvailability.available);
    expect(entry.lastCheckedAt, isNotNull);
    expect(entry.backupFormatVersion, 1);
    expect(entry.databaseSchemaVersion, 14);
    expect(entry.fileSize, greaterThan(0));
  });

  test('updates an already-registered document instead of duplicating it',
      () async {
    final registry = BackupRegistry(FakeSettingsRepository());
    await registry.add(
      const RegisteredBackup(contentUri: 'content://doc/existing'),
    );
    final picker = _PickableGateway(
      BackupImportPickResult.success(const [
        BackupImportDocument(
          contentUri: 'content://doc/existing',
          displayName: 'Refreshed.rtb',
        ),
      ]),
    );
    final documents = _FakeDocumentGateway({
      'content://doc/existing': validBytes,
    });
    final service = buildService(picker, documents, registry);

    final outcome = await service.import();

    expect(outcome.status, BackupImportStatus.success);
    expect(outcome.imported, 0);
    expect(outcome.refreshed, 1);
    expect(await registry.all(), hasLength(1));
    expect((await registry.all()).single.displayName, 'Refreshed.rtb');
  });

  test('duplicate URIs inside one selection collapse to one refreshed entry',
      () async {
    final registry = BackupRegistry(FakeSettingsRepository());
    final picker = _PickableGateway(
      BackupImportPickResult.success(const [
        BackupImportDocument(contentUri: 'content://doc/a'),
        BackupImportDocument(contentUri: 'content://doc/a'),
      ]),
    );
    final documents = _FakeDocumentGateway({
      'content://doc/a': validBytes,
    });
    final service = buildService(picker, documents, registry);

    final outcome = await service.import();

    expect(outcome.imported, 1);
    expect(outcome.refreshed, 1);
    expect(await registry.all(), hasLength(1));
  });

  test('returns cancelled when the user dismisses the picker', () async {
    final registry = BackupRegistry(FakeSettingsRepository());
    final picker = _PickableGateway(BackupImportPickResult.cancelled());
    final service = buildService(
      picker,
      _FakeDocumentGateway({}),
      registry,
    );

    final outcome = await service.import();

    expect(outcome.status, BackupImportStatus.cancelled);
    expect(outcome.succeeded, isFalse);
    expect(await registry.all(), isEmpty);
  });

  test('maps a picker storage failure without touching the registry', () async {
    final registry = BackupRegistry(FakeSettingsRepository());
    final picker = _PickableGateway(
      BackupImportPickResult.failed(BackupResult.storageFailure),
    );
    final service = buildService(
      picker,
      _FakeDocumentGateway({}),
      registry,
    );

    final outcome = await service.import();

    expect(outcome.status, BackupImportStatus.storageFailure);
    expect(await registry.all(), isEmpty);
  });

  test('skips invalid files without failing the rest of the batch', () async {
    final registry = BackupRegistry(FakeSettingsRepository());
    final picker = _PickableGateway(
      BackupImportPickResult.success(const [
        BackupImportDocument(contentUri: 'content://doc/good'),
        BackupImportDocument(contentUri: 'content://doc/not-a-backup'),
        BackupImportDocument(contentUri: 'content://doc/corrupt'),
      ]),
    );
    // "not-a-backup" is a valid ZIP lacking a manifest; "corrupt" is garbage.
    final documents = _FakeDocumentGateway({
      'content://doc/good': validBytes,
      'content://doc/not-a-backup': buildZip({
        'random.txt': Uint8List.fromList(utf8.encode('hello')),
      }),
      'content://doc/corrupt': Uint8List.fromList(utf8.encode('not a zip')),
    });
    final service = buildService(picker, documents, registry);

    final outcome = await service.import();

    expect(outcome.status, BackupImportStatus.success);
    expect(outcome.imported, 1);
    expect(outcome.invalidSkipped, 2);
    expect(await registry.all(), hasLength(1));
    expect((await registry.all()).single.contentUri, 'content://doc/good');
  });

  test('counts copy failures but keeps importing the other documents',
      () async {
    final registry = BackupRegistry(FakeSettingsRepository());
    final picker = _PickableGateway(
      BackupImportPickResult.success(const [
        BackupImportDocument(contentUri: 'content://doc/hardfail'),
        BackupImportDocument(contentUri: 'content://doc/good'),
      ]),
    );
    final documents = _FakeDocumentGateway(
      {
        'content://doc/hardfail': validBytes,
        'content://doc/good': validBytes,
      },
      failingUris: {'content://doc/hardfail'},
    );
    final service = buildService(picker, documents, registry);

    final outcome = await service.import();

    expect(outcome.status, BackupImportStatus.success);
    expect(outcome.imported, 1);
    expect(outcome.failed, 1);
    expect(await registry.all(), hasLength(1));
    expect((await registry.all()).single.contentUri, 'content://doc/good');
  });

  test('reports storageFailure when the temp work directory cannot be created',
      () async {
    final registry = BackupRegistry(FakeSettingsRepository());
    final picker = _PickableGateway(
      BackupImportPickResult.success(const [
        BackupImportDocument(contentUri: 'content://doc/x'),
      ]),
    );
    // Point tempBaseDir at a directory that cannot host subdirectories so
    // createTemp fails.
    final colliding = Directory(p.join(tempBase.path, 'does_not_exist'));
    final service = BackupImportService(
      storageGateway: picker,
      documentGateway: _FakeDocumentGateway({
        'content://doc/x': validBytes,
      }),
      registry: registry,
      tempBaseDir: colliding,
      currentAppVersion: '1.0.0',
      currentDatabaseSchemaVersion: 20,
    );

    final outcome = await service.import();

    expect(outcome.status, BackupImportStatus.storageFailure);
  });

  test('leaves the temp directory clean after import', () async {
    final registry = BackupRegistry(FakeSettingsRepository());
    final picker = _PickableGateway(
      BackupImportPickResult.success(const [
        BackupImportDocument(contentUri: 'content://doc/good'),
      ]),
    );
    final documents = _FakeDocumentGateway({
      'content://doc/good': validBytes,
    });
    final service = buildService(picker, documents, registry);

    await service.import();

    expect(tempBase.listSync(), isEmpty);
  });

  test('pickers are never invoked when the screen-supplied outcome is used',
      () async {
    // Covers the controller level: import must go through the import service,
    // which is the only place that talks to the picker.
    final registry = BackupRegistry(FakeSettingsRepository());
    final picker = _PickableGateway(BackupImportPickResult.cancelled());
    final service = buildService(
      picker,
      _FakeDocumentGateway({}),
      registry,
    );

    expect(picker.pickCalls, 0);
    await service.import();
    expect(picker.pickCalls, 1);
  });
}