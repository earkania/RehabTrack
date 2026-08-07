import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/data/services/backup/backup_archive_writer.dart';

void main() {
  late Directory tempDir;
  late BackupArchiveWriter writer;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('backup_writer_test_');
    writer = BackupArchiveWriter();
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  File writeTempFile(String name, String content) {
    final file = File('${tempDir.path}/$name');
    file.writeAsStringSync(content);
    return file;
  }

  Map<String, String> decodeZip(String zipPath) {
    final bytes = File(zipPath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    return {
      for (final entry in archive)
        if (entry.isFile)
          entry.name: utf8.decode(entry.content as List<int>),
    };
  }

  test('writes manifest, database, preferences and files in order', () async {
    final output = '${tempDir.path}/backup.rtb';
    final dbFile = writeTempFile('database.sqlite', 'sqlite-bytes');
    final files = [
      BackupSourceFile(
        archivePath: 'files/profile_images/profile_1.jpg',
        file: writeTempFile('profile_1.jpg', 'jpg1'),
      ),
      BackupSourceFile(
        archivePath: 'files/care_contact_images/contact_1.jpg',
        file: writeTempFile('contact_1.jpg', 'jpg2'),
      ),
    ];

    await writer.writeArchive(
      outputPath: output,
      manifestBytes: Uint8List.fromList(utf8.encode('{"format":1}')),
      databaseFile: dbFile,
      preferencesBytes: Uint8List.fromList(utf8.encode('{"lang":"en"}')),
      files: files,
    );

    expect(File(output).existsSync(), isTrue);
    final contents = decodeZip(output);
    expect(contents.keys.toList(), [
      'manifest.json',
      'database.sqlite',
      'preferences.json',
      'files/profile_images/profile_1.jpg',
      'files/care_contact_images/contact_1.jpg',
    ]);
    expect(contents['manifest.json'], '{"format":1}');
    expect(contents['database.sqlite'], 'sqlite-bytes');
    expect(contents['preferences.json'], '{"lang":"en"}');
    expect(contents['files/profile_images/profile_1.jpg'], 'jpg1');
    expect(contents['files/care_contact_images/contact_1.jpg'], 'jpg2');
  });

  test('writes an empty archive when there are no files', () async {
    final output = '${tempDir.path}/empty.rtb';
    await writer.writeArchive(
      outputPath: output,
      manifestBytes: Uint8List.fromList(utf8.encode('{}')),
      databaseFile: writeTempFile('database.sqlite', 'x'),
      preferencesBytes: Uint8List.fromList(utf8.encode('{}')),
      files: const [],
    );

    final contents = decodeZip(output);
    expect(contents.keys, ['manifest.json', 'database.sqlite', 'preferences.json']);
  });

  test('produces a valid ZIP readable with the archive package', () async {
    final output = '${tempDir.path}/valid.rtb';
    await writer.writeArchive(
      outputPath: output,
      manifestBytes: Uint8List.fromList(utf8.encode('{}')),
      databaseFile: writeTempFile('database.sqlite', 'x'),
      preferencesBytes: Uint8List.fromList(utf8.encode('{}')),
      files: [
        BackupSourceFile(
          archivePath: 'files/profile_images/a.jpg',
          file: writeTempFile('a.jpg', 'a'),
        ),
      ],
    );

    final archive = ZipDecoder().decodeBytes(File(output).readAsBytesSync());
    expect(archive.length, 4);
  });

  group('BackupArchivePath.validate', () {
    test('accepts valid root and files/ entries', () {
      for (final path in [
        'manifest.json',
        'database.sqlite',
        'preferences.json',
        'files/profile_images/profile_1.jpg',
        'files/care_contact_images/contact_1.jpg',
      ]) {
        expect(() => BackupArchivePath.validate(path), returnsNormally);
      }
    });

    test('rejects absolute paths', () {
      expect(
        () => BackupArchivePath.validate('/etc/passwd'),
        throwsFormatException,
      );
    });

    test('rejects parent traversal', () {
      expect(
        () => BackupArchivePath.validate('../outside.db'),
        throwsFormatException,
      );
      expect(
        () => BackupArchivePath.validate('files/../../etc/passwd'),
        throwsFormatException,
      );
    });

    test('rejects backslashes', () {
      expect(
        () => BackupArchivePath.validate(r'files\..\outside.db'),
        throwsFormatException,
      );
    });

    test('rejects unknown root-level entries', () {
      expect(
        () => BackupArchivePath.validate('notes.txt'),
        throwsFormatException,
      );
      expect(
        () => BackupArchivePath.validate('files'),
        throwsFormatException,
      );
    });

    test('rejects empty paths', () {
      expect(() => BackupArchivePath.validate(''), throwsFormatException);
    });
  });
}
