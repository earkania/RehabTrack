import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('care_contacts_migration');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  File dbFile() => File('${tempDir.path}/migration.sqlite');

  Future<db.AppDatabase> openFileDb() async {
    return db.AppDatabase.forTesting(NativeDatabase(dbFile()));
  }

  test('schema version is 13', () {
    final database = db.AppDatabase.test();
    addTearDown(database.close);
    expect(database.schemaVersion, 13);
  });

  test('care_contacts table and indexes exist after fresh create', () async {
    final database = db.AppDatabase.test();
    addTearDown(database.close);

    final tables = await database
        .customSelect('SELECT name FROM sqlite_master WHERE type = \'table\'')
        .get();
    final tableNames = tables.map((r) => r.read<String>('name')).toSet();
    expect(tableNames, contains('care_contacts'));

    final indexes = await database
        .customSelect(
          'SELECT name FROM sqlite_master WHERE type = \'index\' '
          'AND tbl_name = \'care_contacts\'',
        )
        .get();
    final indexNames = indexes.map((r) => r.read<String>('name')).toSet();
    expect(indexNames, containsAll([
      'care_contacts_profile_idx',
      'care_contacts_type_idx',
      'care_contacts_archived_idx',
      'care_contacts_favorite_idx',
      'care_contacts_display_name_idx',
    ]));

    final columns = await database
        .customSelect('PRAGMA table_info(care_contacts)')
        .get();
    final columnNames = columns.map((r) => r.read<String>('name')).toList();
    expect(columnNames, containsAll([
      'id',
      'profile_id',
      'contact_type',
      'display_name',
      'first_name',
      'last_name',
      'specialty',
      'organization_name',
      'department',
      'contact_person',
      'primary_phone',
      'secondary_phone',
      'email',
      'website',
      'address',
      'working_hours',
      'policy_number',
      'member_number',
      'notes',
      'photo_path',
      'is_favorite',
      'is_archived',
      'created_at',
      'updated_at',
    ]));
  });

  test('upgrading from version 12 preserves existing data and creates '
      'care_contacts', () async {
    // 1. Open a fresh file DB at the current schema (13) and seed a profile.
    var database = await openFileDb();
    final profileId = await database.into(database.profiles).insert(
      db.ProfilesCompanion.insert(
        firstName: 'Existing',
        lastName: 'User',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
        isPrimary: const Value(true),
        isActive: const Value(true),
      ),
    );

    // 2. Simulate a v12 database: drop the care_contacts table and mark the
    //    user_version as 12 so reopening runs the real onUpgrade path.
    await database.customStatement('DROP TABLE care_contacts');
    await database.customStatement('PRAGMA user_version = 12');
    await database.close();

    // 3. Reopen — drift detects 12 < 13 and applies the migration.
    database = await openFileDb();
    addTearDown(database.close);

    // 4. Existing profile data is preserved.
    final profiles = await (database.select(database.profiles)
          ..where((t) => t.id.equals(profileId)))
        .get();
    expect(profiles, hasLength(1));
    expect(profiles.single.firstName, 'Existing');
    expect(profiles.single.lastName, 'User');

    // 5. The care_contacts table exists again after migration.
    final tables = await database
        .customSelect('SELECT name FROM sqlite_master WHERE type = \'table\'')
        .get();
    final tableNames = tables.map((r) => r.read<String>('name')).toSet();
    expect(tableNames, contains('care_contacts'));

    // 6. A contact can be written through the DAO after migration.
    final contactId = await database.careContactDao.insertContact(
      db.CareContactsCompanion.insert(
        profileId: profileId,
        contactType: 'doctor',
        displayName: 'Dr. Migrated',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      ),
    );
    expect(contactId, greaterThan(0));
    final saved = await database.careContactDao
        .getContactById(profileId, contactId);
    expect(saved!.displayName, 'Dr. Migrated');
  });

  test('all 12 pre-existing module tables survive the migration', () async {
    var database = await openFileDb();
    await database.customStatement('DROP TABLE care_contacts');
    await database.customStatement('PRAGMA user_version = 12');
    await database.close();

    database = await openFileDb();
    addTearDown(database.close);

    final tables = await database
        .customSelect('SELECT name FROM sqlite_master WHERE type = \'table\'')
        .get();
    final tableNames = tables.map((r) => r.read<String>('name')).toSet();

    final expectedTables = [
      'profiles',
      'medications',
      'medication_schedules',
      'medication_logs',
      'measurement_types',
      'measurement_records',
      'measurement_schedules',
      'exercise_types',
      'exercise_logs',
      'doctors',
      'app_settings',
      'profile_reference_ranges',
      'care_contacts',
    ];
    for (final table in expectedTables) {
      expect(tableNames, contains(table), reason: 'missing table $table');
    }
  });

  test('reopening at the current version runs no destructive migration', () async {
    final database = await openFileDb();
    await database.into(database.profiles).insert(
      db.ProfilesCompanion.insert(
        firstName: 'A',
        lastName: 'B',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      ),
    );
    await database.close();

    final reopened = await openFileDb();
    addTearDown(reopened.close);

    final count = await reopened.profileDao.getProfileCount();
    expect(count, greaterThanOrEqualTo(1));
  });
}
