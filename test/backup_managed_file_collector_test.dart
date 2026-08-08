import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/services/backup/managed_file_collector.dart';

void main() {
  late Directory tempDir;
  late Directory docsDir;
  late AppDatabase database;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('collector_test_');
    docsDir = Directory(p.join(tempDir.path, 'docs'))..createSync(recursive: true);
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
    tempDir.deleteSync(recursive: true);
  });

  Directory imagesDir(String name) {
    final dir = Directory(p.join(docsDir.path, name));
    dir.createSync(recursive: true);
    return dir;
  }

  /// Creates a nested lab attachment file at `lab_analyses/<pid>/<aid>/...`.
  File labAttachment(String relative, {required String content}) {
    final file = File(p.join(docsDir.path, relative));
    file.createSync(recursive: true);
    file.writeAsStringSync(content);
    return file;
  }

  File photo(String name, {required String content}) {
    final file = File(p.join(docsDir.path, name));
    file.createSync(recursive: true);
    file.writeAsStringSync(content);
    return file;
  }

  test('collects files from both image directories', () async {
    final profileDir = imagesDir(ManagedFileCollector.profileImagesDirName);
    final contactDir = imagesDir(ManagedFileCollector.careContactImagesDirName);

    final profilePhoto = File(p.join(profileDir.path, 'profile_1_1.jpg'))
      ..writeAsStringSync('p');
    final contactPhoto = File(p.join(contactDir.path, 'contact_1_1.jpg'))
      ..writeAsStringSync('c');

    final collection = await ManagedFileCollector(database, docsDir).collect();

    expect(collection.files, hasLength(2));
    expect(collection.files.map((f) => f.archivePath), containsAll([
      'files/profile_images/profile_1_1.jpg',
      'files/care_contact_images/contact_1_1.jpg',
    ]));
    expect(
      collection.files.map((f) => f.file.path),
      containsAll([profilePhoto.path, contactPhoto.path]),
    );
    expect(collection.warnings, isEmpty);
  });

  test('collects nested lab attachments preserving their layout', () async {
    final attachment = labAttachment(
      '${ManagedFileCollector.labAnalysesDirName}/1/2/report.pdf',
      content: 'lab',
    );

    final collection = await ManagedFileCollector(database, docsDir).collect();

    expect(collection.files, hasLength(1));
    expect(collection.files.single.archivePath,
        'files/lab_analyses/1/2/report.pdf');
    expect(collection.files.single.file.path, attachment.path);
    expect(collection.warnings, isEmpty);
  });

  test('warns about DB-referenced lab attachments missing on disk', () async {
    await database.into(database.labAnalysisAttachments).insert(
          LabAnalysisAttachmentsCompanion.insert(
            analysisId: 7,
            profileId: 3,
            fileType: 'image',
            managedRelativePath: 'lab_analyses/3/9/missing.jpg',
            originalFileName: 'missing.jpg',
            displayName: 'missing',
            mimeType: 'image/jpeg',
            fileSize: const Value(1),
            sortOrder: const Value(0),
            createdAt: DateTime(2025),
            updatedAt: DateTime(2025),
          ),
        );

    final collection = await ManagedFileCollector(database, docsDir).collect();

    expect(collection.warnings, hasLength(1));
    expect(collection.warnings.single, contains('1'));
  });

  test('returns no files and no warnings when directories are absent', () async {
    final collection = await ManagedFileCollector(database, docsDir).collect();
    expect(collection.files, isEmpty);
    expect(collection.warnings, isEmpty);
  });

  test('warns about DB-referenced photos missing on disk', () async {
    final missingPath = p.join(docsDir.path, 'profile_images', 'profile_9_1.jpg');
    await database.into(database.profiles).insert(
          ProfilesCompanion.insert(
            firstName: 'Test',
            lastName: 'User',
            createdAt: DateTime(2025),
            updatedAt: DateTime(2025),
            isPrimary: const Value(true),
            isActive: const Value(true),
            photoPath: Value(missingPath),
          ),
        );

    final collection = await ManagedFileCollector(database, docsDir).collect();

    expect(collection.files, isEmpty);
    expect(collection.warnings, hasLength(1));
    expect(collection.warnings.single, contains('1'));
  });

  test('includes files on disk that are not referenced in the database',
      () async {
    imagesDir(ManagedFileCollector.profileImagesDirName);
    photo(
      p.join(
        ManagedFileCollector.profileImagesDirName,
        'orphan.jpg',
      ),
      content: 'x',
    );

    final collection = await ManagedFileCollector(database, docsDir).collect();

    expect(collection.files, hasLength(1));
    expect(collection.files.single.archivePath, 'files/profile_images/orphan.jpg');
    expect(collection.warnings, isEmpty);
  });
}
