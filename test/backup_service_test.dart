import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/services/backup/backup_archive_reader.dart';
import 'package:rehab_track/data/services/backup/backup_archive_writer.dart';
import 'package:rehab_track/data/services/backup/backup_service.dart';
import 'package:rehab_track/data/services/backup/backup_storage_gateway.dart';
import 'package:rehab_track/data/services/backup/preferences_exporter.dart';
import 'package:rehab_track/data/services/storage/storage_inspector.dart';
import 'package:rehab_track/domain/backup/backup_manifest.dart';
import 'package:rehab_track/domain/backup/backup_phase.dart';
import 'package:rehab_track/domain/backup/backup_result.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';

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

class FakeStorageGateway extends BackupStorageGateway {
  BackupSaveResult Function(Uint8List bytes, String fileName) handler;

  Uint8List? lastBytes;
  String? lastFileName;
  bool saved = false;

  FakeStorageGateway({required this.handler});

  @override
  Future<BackupSaveResult> save({
    required Uint8List bytes,
    required String fileName,
  }) async {
    lastBytes = bytes;
    lastFileName = fileName;
    saved = true;
    return handler(bytes, fileName);
  }
}

class ThrowingArchiveWriter extends BackupArchiveWriter {
  @override
  Future<void> writeArchive({
    required String outputPath,
    required Uint8List manifestBytes,
    required File databaseFile,
    required Uint8List preferencesBytes,
    required List<BackupSourceFile> files,
  }) async {
    throw StateError('zip boom');
  }
}

class FailingArchiveReader extends BackupArchiveReader {
  const FailingArchiveReader(this.status);

  final BackupArchiveReadStatus status;

  @override
  Future<BackupArchiveReadResult> read(File archiveFile) async {
    return BackupArchiveReadResult.failure(status);
  }
}

class FixedStorageInspector extends StorageInspector {
  const FixedStorageInspector(this.bytes);

  final int? bytes;

  @override
  Future<int?> freeBytes(String path) async => bytes;
}

void main() {
  late Directory tempDir;
  late Directory docsDir;
  late AppDatabase database;
  late FakeSettingsRepository settings;
  late FakeStorageGateway gateway;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('backup_service_test_');
    docsDir = Directory(p.join(tempDir.path, 'docs'))..createSync(recursive: true);
    database = AppDatabase.forTesting(NativeDatabase.memory());
    settings = FakeSettingsRepository();
    gateway = FakeStorageGateway(
      handler: (bytes, fileName) =>
          BackupSaveResult.success('/tmp/destination.rtb'),
    );
  });

  tearDown(() async {
    await database.close();
    tempDir.deleteSync(recursive: true);
  });

  BackupService buildService({
    DateTime Function()? clock,
    BackupArchiveReader? archiveReader,
    StorageInspector? storageInspector,
  }) {
    return BackupService(
      database: database,
      archiveWriter: BackupArchiveWriter(),
      storageGateway: gateway,
      preferencesExporter: PreferencesExporter(settings),
      documentsDirectory: () async => docsDir,
      tempBaseDir: tempDir,
      platform: 'test',
      clock: clock ?? () => DateTime.utc(2026, 8, 4, 12, 30),
      archiveReader: archiveReader ?? const BackupArchiveReader(),
      storageInspector: storageInspector ?? const StorageInspector(),
    );
  }

  Archive decodeArchive() {
    return ZipDecoder().decodeBytes(gateway.lastBytes!);
  }

  String entryContent(Archive archive, String name) {
    return utf8.decode(archive.findFile(name)!.content as List<int>);
  }

  File photo(String relativePath, {required String content}) {
    final file = File(p.join(docsDir.path, relativePath));
    file.createSync(recursive: true);
    file.writeAsStringSync(content);
    return file;
  }

  group('BackupService', () {
    test('creates a valid archive with manifest, database and preferences',
        () async {
      photo(p.join('profile_images', 'profile_1_1.jpg'), content: 'photo-a');
      photo(
        p.join('care_contact_images', 'contact_1_1.jpg'),
        content: 'photo-b',
      );
      settings.store['app_language'] = 'ka';
      await database.into(database.profiles).insert(
            ProfilesCompanion.insert(
              firstName: 'Ana',
              lastName: 'Test',
              createdAt: DateTime(2025),
              updatedAt: DateTime(2025),
              isPrimary: const Value(true),
              isActive: const Value(true),
            ),
          );

      final phases = <BackupPhase>[];
      final outcome = await buildService().createBackup(
        onPhase: phases.add,
      );

      expect(outcome.result, BackupResult.success);
      expect(outcome.warnings, isEmpty);
      expect(phases, [
        BackupPhase.collecting,
        BackupPhase.snapshotting,
        BackupPhase.collecting,
        BackupPhase.archiving,
        BackupPhase.writing,
        BackupPhase.done,
      ]);
      expect(gateway.lastFileName, 'RehabTrack-Backup-2026-08-04_12-30.rtb');
      expect(gateway.lastBytes, isNotNull);

      final archive = decodeArchive();
      expect(archive.findFile('manifest.json'), isNotNull);
      expect(archive.findFile('database.sqlite'), isNotNull);
      expect(archive.findFile('preferences.json'), isNotNull);
      expect(archive.findFile('files/profile_images/profile_1_1.jpg'), isNotNull);
      expect(
        archive.findFile('files/care_contact_images/contact_1_1.jpg'),
        isNotNull,
      );
    });

    test('manifest reports correct metadata and checksums', () async {
      photo(p.join('profile_images', 'profile_1_1.jpg'), content: 'photo-a');
      final outcome = await buildService().createBackup();
      expect(outcome.result, BackupResult.success);

      final manifest = BackupManifest.fromJsonString(
        entryContent(decodeArchive(), 'manifest.json'),
      );

      expect(manifest.backupFormatVersion, BackupManifest.currentFormatVersion);
      expect(manifest.appVersion, '1.0.0');
      expect(manifest.databaseSchemaVersion, 14);
      expect(manifest.createdAt, DateTime.utc(2026, 8, 4, 12, 30));
      expect(manifest.platform, 'test');
      expect(manifest.fileCount, 1);
      expect(BackupManifest.databaseFileName, 'database.sqlite');
      expect(BackupManifest.preferencesFileName, 'preferences.json');

      final archive = decodeArchive();
      final dbDigest = sha256.convert(
        (archive.findFile('database.sqlite')!.content as List<int>),
      ).toString();
      expect(manifest.checksums['database.sqlite'], dbDigest);

      final prefsDigest = sha256.convert(
        (archive.findFile('preferences.json')!.content as List<int>),
      ).toString();
      expect(manifest.checksums['preferences.json'], prefsDigest);

      final photoDigest = sha256.convert(utf8.encode('photo-a')).toString();
      expect(
        manifest.checksums['files/profile_images/profile_1_1.jpg'],
        photoDigest,
      );
      expect(manifestChecksumsComplete(manifest, 1), isTrue);
    });

    test('database snapshot contains the inserted data', () async {
      await database.into(database.profiles).insert(
            ProfilesCompanion.insert(
              firstName: 'Ana',
              lastName: 'Test',
              createdAt: DateTime(2025),
              updatedAt: DateTime(2025),
              isPrimary: const Value(true),
              isActive: const Value(true),
            ),
          );
      await buildService().createBackup();

      final archive = decodeArchive();
      final snapshotBytes = archive.findFile('database.sqlite')!.content as List<int>;
      final snapshotFile = File(p.join(tempDir.path, 'restored.sqlite'));
      snapshotFile.writeAsBytesSync(snapshotBytes);

      final restored = AppDatabase.forTesting(NativeDatabase(snapshotFile));
      addTearDown(restored.close);
      final profiles = await restored.select(restored.profiles).get();
      expect(profiles.map((pr) => pr.firstName), contains('Ana'));
    });

    test('exports only allowlisted preferences', () async {
      settings.store['app_language'] = 'ka';
      settings.store['last_backup_at'] = '2026-08-04T12:00:00.000';
      await buildService().createBackup();

      final json = jsonDecode(
        entryContent(decodeArchive(), 'preferences.json'),
      );
      expect(json, {'app_language': 'ka'});
    });

    test('tolerates missing referenced photos with a non-sensitive warning',
        () async {
      final missing = p.join(docsDir.path, 'profile_images', 'gone_1.jpg');
      await database.into(database.profiles).insert(
            ProfilesCompanion.insert(
              firstName: 'Ana',
              lastName: 'Test',
              createdAt: DateTime(2025),
              updatedAt: DateTime(2025),
              isPrimary: const Value(true),
              isActive: const Value(true),
              photoPath: Value(missing),
            ),
          );

      final outcome = await buildService().createBackup();

      expect(outcome.result, BackupResult.success);
      expect(outcome.warnings, hasLength(1));
    });

    test('returns cancelled when the user cancels the picker', () async {
      gateway.handler = (b, f) => BackupSaveResult.cancelled();
      final outcome = await buildService().createBackup();
      expect(outcome.result, BackupResult.cancelled);
    });

    test('propagates storage failures from the gateway', () async {
      gateway.handler = (b, f) =>
          BackupSaveResult.failed(BackupResult.storageFailure);
      final outcome = await buildService().createBackup();
      expect(outcome.result, BackupResult.storageFailure);
    });

    test('maps archive encoding failures to archiveFailure', () async {
      final service = BackupService(
        database: database,
        archiveWriter: ThrowingArchiveWriter(),
        storageGateway: gateway,
        preferencesExporter: PreferencesExporter(settings),
        documentsDirectory: () async => docsDir,
        tempBaseDir: tempDir,
        platform: 'test',
      );
      final outcome = await service.createBackup();
      expect(outcome.result, BackupResult.archiveFailure);
    });

    test('maps unexpected errors to unexpectedFailure', () async {
      final service = BackupService(
        database: database,
        archiveWriter: BackupArchiveWriter(),
        storageGateway: gateway,
        preferencesExporter: PreferencesExporter(settings),
        documentsDirectory: () async => throw StateError('boom'),
        tempBaseDir: tempDir,
        platform: 'test',
      );
      final outcome = await service.createBackup();
      expect(outcome.result, BackupResult.unexpectedFailure);
    });

    test('formats the suggested file name with the injected clock', () async {
      final fixed = DateTime.utc(2026, 1, 2, 3, 4);
      final service = buildService(clock: () => fixed);
      await service.createBackup();
      expect(gateway.lastFileName, 'RehabTrack-Backup-2026-01-02_03-04.rtb');
    });

    test('sanitizes illegal filename characters from the suggested name',
        () async {
      final service = buildService(
        clock: () => DateTime.utc(2026, 1, 2, 3, 4),
      );
      await service.createBackup();
      expect(gateway.lastFileName, contains('_'));
      expect(gateway.lastFileName, isNot(contains(':')));
      expect(gateway.lastFileName, endsWith('.rtb'));
    });

    test('reports notEnoughStorage before saving when free space is low',
        () async {
      final outcome = await buildService(
        storageInspector: const FixedStorageInspector(10),
      ).createBackup();
      expect(outcome.result, BackupResult.notEnoughStorage);
      expect(gateway.saved, isFalse);
    });

    test('reports archiveFailure when the post-write self-check fails',
        () async {
      final outcome = await buildService(
        archiveReader: const FailingArchiveReader(
          BackupArchiveReadStatus.corruptedArchive,
        ),
      ).createBackup();
      expect(outcome.result, BackupResult.archiveFailure);
      expect(gateway.saved, isFalse);
    });

    test('exposes the provider-renamed display name after saving', () async {
      gateway.handler = (b, f) =>
          BackupSaveResult.success('/tmp/custom.rtb', displayName: 'My Rehab');
      final outcome = await buildService().createBackup();
      expect(outcome.result, BackupResult.success);
      expect(outcome.savedFileName, 'My Rehab');
    });
  });
}
