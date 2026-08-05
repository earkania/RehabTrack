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
      schema: 14,
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
      schema: 14,
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
}