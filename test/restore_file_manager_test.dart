import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:rehab_track/data/services/backup/backup_archive_reader.dart';
import 'package:rehab_track/data/services/restore/restore_file_manager.dart';

import 'helpers/restore_test_utils.dart';

void main() {
  late Directory dir;
  const fileManager = RestoreFileManager();

  setUp(() {
    dir = Directory.systemTemp.createTempSync('filemanager_test_');
  });

  tearDown(() {
    dir.deleteSync(recursive: true);
  });

  Future<BackupArchiveHandle> handleOf(Uint8List bytes) async {
    final file = File(p.join(dir.path, 'backup.rtb'));
    await file.writeAsBytes(bytes);
    final result = await const BackupArchiveReader().read(file);
    expect(result.succeeded, isTrue);
    return result.handle!;
  }

  Map<String, String> matches(BackupArchiveHandle handle) {
    final map = <String, String>{};
    for (final entry in handle.info.entries) {
      final content = handle.content(entry.name);
      if (content != null) map[entry.name] = sha256.convert(content).toString();
    }
    return map;
  }

  test('extract writes archive files preserving their relative layout', () async {
    final files = {
      'files/profile_images/p1.jpg': Uint8List.fromList([1, 2, 3]),
      'files/care_contact_images/c1.jpg': Uint8List.fromList([9, 9]),
      'files/lab_analyses/1/2/report.pdf': Uint8List.fromList([4, 5]),
    };
    final db = buildRestorableSqliteBytes(schema: 16, profiles: 1);
    final archive = buildRestorableBackupZip(
      schema: 16,
      database: db,
      preferences: const {'app_language': 'en'},
      files: files,
    );
    final handle = await handleOf(archive);

    final prepared = Directory(p.join(dir.path, 'prepared-files'));
    final count = await fileManager.extract(
      handle: handle,
      checksums: matches(handle),
      preparedFilesDir: prepared,
    );
    expect(count, 3);
    expect(
      File(p.join(prepared.path, 'profile_images', 'p1.jpg')).existsSync(),
      isTrue,
    );
    expect(
      File(p.join(prepared.path, 'care_contact_images', 'c1.jpg')).existsSync(),
      isTrue,
    );
    expect(
      File(p.join(prepared.path, 'lab_analyses', '1', '2', 'report.pdf'))
          .existsSync(),
      isTrue,
    );
  });

  test('managedRootNames includes lab_analyses', () {
    expect(
      RestoreFileManager.managedRootNames,
      containsAll(['profile_images', 'care_contact_images', 'lab_analyses']),
    );
  });

  test('extract rejects a file whose checksum does not match the manifest',
      () async {
    final files = {'files/profile_images/p1.jpg': Uint8List.fromList([1, 2, 3])};
    final db = buildRestorableSqliteBytes(schema: 16, profiles: 1);
    final archive = buildRestorableBackupZip(
      schema: 16,
      database: db,
      preferences: const {'app_language': 'en'},
      files: files,
    );
    final handle = await handleOf(archive);

    // Corrupt the expected checksum for the photo file.
    final tampered = Map<String, String>.from(matches(handle))
      ..['files/profile_images/p1.jpg'] = '0' * 64;

    expect(
      fileManager.extract(
        handle: handle,
        checksums: tampered,
        preparedFilesDir: Directory(p.join(dir.path, 'prepared-files')),
      ),
      throwsA(isA<ManagedFileRestoreException>()),
    );
  });

  test('replace moves live aside and places prepared; restore reverses', () async {
    final docs = Directory(p.join(dir.path, 'documents'));
    await docs.create(recursive: true);
    final liveImage = File(p.join(docs.path, 'profile_images', 'a.jpg'));
    await liveImage.parent.create(recursive: true);
    await liveImage.writeAsBytes([1]);

    final prepared = Directory(p.join(dir.path, 'prepared-files'));
    final newImage = File(p.join(prepared.path, 'profile_images', 'b.jpg'));
    await newImage.parent.create(recursive: true);
    await newImage.writeAsBytes([2]);

    final rollback = Directory(p.join(dir.path, 'rollback'));

    final handle = await fileManager.replace(
      documentsDir: docs,
      preparedFilesDir: prepared,
      rollbackDir: rollback,
    );
    expect(handle.movedRootNames, contains('profile_images'));
    expect(File(p.join(docs.path, 'profile_images', 'b.jpg')).existsSync(), isTrue);
    expect(File(p.join(docs.path, 'profile_images', 'a.jpg')).existsSync(), isFalse);

    await fileManager.restore(
      documentsDir: docs,
      rollbackDir: rollback,
      handle: handle,
    );
    expect(File(p.join(docs.path, 'profile_images', 'a.jpg')).existsSync(), isTrue);
    expect(File(p.join(docs.path, 'profile_images', 'b.jpg')).existsSync(), isFalse);
  });
}