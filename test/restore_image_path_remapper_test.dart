import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'package:rehab_track/data/services/restore/restore_image_path_remapper.dart';

import 'helpers/restore_test_utils.dart';

void main() {
  late Directory dir;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('remapper_test_');
  });

  tearDown(() {
    dir.deleteSync(recursive: true);
  });

  test('remaps profile and care-contact photo paths to the managed root',
      () async {
    final bytes = buildRestorableSqliteBytes(
      schema: 15,
      profiles: 1,
      profilePhotoPath: '/data/user/0/com.app/files/docs/profile_images/a1.jpg',
      withCareContacts: true,
    );
    final dbPath = p.join(dir.path, 'restore.sqlite');
    await File(dbPath).writeAsBytes(bytes);

    // Add a care-contact photo path referencing the old device location.
    final db = sqlite.sqlite3.open(dbPath);
    db.execute(
      'INSERT INTO care_contacts (profileId, photoPath) VALUES(?, ?)',
      [1, '/old/device/care_contact_images/c9.jpg'],
    );
    db.close();

    const managedRoot = '/live/app/docs';
    RestoreImagePathRemapper.remap(
      databasePath: dbPath,
      managedFilesRoot: managedRoot,
    );

    final read = sqlite.sqlite3.open(dbPath, mode: sqlite.OpenMode.readOnly);
    final profilePath = read
        .select('SELECT photoPath FROM profiles WHERE id = 1').rows.first[0]
        as String;
    final contactPath = read
        .select('SELECT photoPath FROM care_contacts WHERE id = 1').rows.first[0]
        as String;
    read.close();

    expect(profilePath, '$managedRoot/profile_images/a1.jpg');
    expect(contactPath, '$managedRoot/care_contact_images/c9.jpg');
  });

  test('handles databases without the columns gracefully', () async {
    final bytes = buildRestorableSqliteBytes(
      schema: 15,
      profiles: 1,
      withCareContacts: false,
    );
    final dbPath = p.join(dir.path, 'restore.sqlite');
    await File(dbPath).writeAsBytes(bytes);

    expect(
      () => RestoreImagePathRemapper.remap(
        databasePath: dbPath,
        managedFilesRoot: '/live/docs',
      ),
      returnsNormally,
    );
  });

  test('content:// URIs are rewritten to canonical managed paths', () async {
    final bytes = buildRestorableSqliteBytes(
      schema: 15,
      profiles: 1,
      profilePhotoPath: 'content://media/external/images/media/42',
      withCareContacts: false,
    );
    final dbPath = p.join(dir.path, 'restore.sqlite');
    await File(dbPath).writeAsBytes(bytes);
    // The file exists in the restored archive, so it maps normally.
    final filesRoot = Directory(p.join(dir.path, 'files'));
    await Directory(p.join(filesRoot.path, 'profile_images'))
        .create(recursive: true);
    await File(p.join(filesRoot.path, 'profile_images', '42'))
        .writeAsBytes([1]);

    const managedRoot = '/live/app/docs';
    final report = RestoreImagePathRemapper.remap(
      databasePath: dbPath,
      managedFilesRoot: managedRoot,
      restoredFilesDir: filesRoot.path,
    );

    final read = sqlite.sqlite3.open(dbPath, mode: sqlite.OpenMode.readOnly);
    final photo = read
        .select('SELECT photoPath FROM profiles WHERE id = 1').rows.first[0]
        as String;
    read.close();
    expect(photo, '$managedRoot/profile_images/42');
    expect(report.repairedCount, 1);
    expect(report.missingManagedFileCount, 0);
  });

  test('missing referenced files are cleared and reported', () async {
    final bytes = buildRestorableSqliteBytes(
      schema: 15,
      profiles: 1,
      profilePhotoPath: 'content://media/external/images/media/99',
      withCareContacts: true,
    );
    final dbPath = p.join(dir.path, 'restore.sqlite');
    await File(dbPath).writeAsBytes(bytes);
    final db = sqlite.sqlite3.open(dbPath);
    db.execute(
      'INSERT INTO care_contacts (profileId, photoPath) VALUES(?, ?)',
      [1, '/old/device/care_contact_images/gone.jpg'],
    );
    db.close();

    // The restored archive contains no files, so both references are missing.
    const managedRoot = '/live/app/docs';
    final report = RestoreImagePathRemapper.remap(
      databasePath: dbPath,
      managedFilesRoot: managedRoot,
      restoredFilesDir: p.join(dir.path, 'files'),
    );

    final read = sqlite.sqlite3.open(dbPath, mode: sqlite.OpenMode.readOnly);
    final profilePhoto = read
        .select('SELECT photoPath FROM profiles WHERE id = 1').rows.first[0];
    final contactPhoto = read
        .select('SELECT photoPath FROM care_contacts WHERE id = 1')
        .rows
        .first[0];
    read.close();
    expect(profilePhoto, isNull);
    expect(contactPhoto, isNull);
    expect(report.missingManagedFileCount, 2);
    expect(report.hasMissingFiles, isTrue);
  });

  test('external website fields are never touched', () async {
    final bytes = buildRestorableSqliteBytes(
      schema: 15,
      profiles: 1,
      profilePhotoPath: '/old/profile_images/a1.jpg',
      withCareContacts: true,
    );
    final dbPath = p.join(dir.path, 'restore.sqlite');
    await File(dbPath).writeAsBytes(bytes);
    final db = sqlite.sqlite3.open(dbPath);
    db.execute(
      'INSERT INTO care_contacts (profileId, photoPath) VALUES(?, ?)',
      [1, null],
    );
    db.execute('ALTER TABLE care_contacts ADD COLUMN website TEXT');
    db.execute(
      'UPDATE care_contacts SET website = ? WHERE id = 1',
      ['https://clinic.example.org'],
    );
    db.close();

    RestoreImagePathRemapper.remap(
      databasePath: dbPath,
      managedFilesRoot: '/live/docs',
    );

    final read = sqlite.sqlite3.open(dbPath, mode: sqlite.OpenMode.readOnly);
    final website = read
        .select('SELECT website FROM care_contacts WHERE id = 1')
        .rows
        .first[0] as String;
    read.close();
    expect(website, 'https://clinic.example.org');
  });
}