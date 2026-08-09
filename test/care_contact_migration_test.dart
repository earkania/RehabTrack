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

  test('schema version is 17', () {
    final database = db.AppDatabase.test();
    addTearDown(database.close);
    expect(database.schemaVersion, 17);
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

  test('doctor_visit_records table and indexes exist after fresh create',
      () async {
    final database = db.AppDatabase.test();
    addTearDown(database.close);

    final tables = await database
        .customSelect('SELECT name FROM sqlite_master WHERE type = \'table\'')
        .get();
    final tableNames = tables.map((r) => r.read<String>('name')).toSet();
    expect(tableNames, contains('doctor_visit_records'));

    final indexes = await database
        .customSelect(
          'SELECT name FROM sqlite_master WHERE type = \'index\' '
          'AND tbl_name = \'doctor_visit_records\'',
        )
        .get();
    final indexNames = indexes.map((r) => r.read<String>('name')).toSet();
    expect(indexNames, containsAll([
      'doctor_visit_records_profile_idx',
      'doctor_visit_records_scheduled_idx',
      'doctor_visit_records_status_idx',
      'doctor_visit_records_doctor_idx',
      'doctor_visit_records_org_idx',
      'doctor_visit_records_archived_idx',
    ]));

    final columns = await database
        .customSelect('PRAGMA table_info(doctor_visit_records)')
        .get();
    final columnNames = columns.map((r) => r.read<String>('name')).toList();
    expect(columnNames, containsAll([
      'id',
      'profile_id',
      'doctor_contact_id',
      'organization_contact_id',
      'visit_type',
      'status',
      'scheduled_date_time',
      'reason',
      'notes',
      'reminder_enabled',
      'reminder_minutes_before',
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
      'doctor_visit_records',
    ];
    for (final table in expectedTables) {
      expect(tableNames, contains(table), reason: 'missing table $table');
    }
  });

  test('upgrading from version 13 creates doctor_visit_records and preserves '
      'data', () async {
    // 1. Open a fresh file DB at the current schema (14) and seed data.
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
    final contactId = await database.careContactDao.insertContact(
      db.CareContactsCompanion.insert(
        profileId: profileId,
        contactType: 'doctor',
        displayName: 'Dr. Migrated',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      ),
    );

    // 2. Simulate a v13 database: drop the doctor_visit_records table and mark
    //    user_version as 13 so reopening runs the real onUpgrade path.
    await database.customStatement('DROP TABLE doctor_visit_records');
    await database.customStatement('PRAGMA user_version = 13');
    await database.close();

    // 3. Reopen — drift detects 13 < 14 and applies the migration.
    database = await openFileDb();
    addTearDown(database.close);

    // 4. Existing data is preserved.
    final profiles = await (database.select(database.profiles)
          ..where((t) => t.id.equals(profileId)))
        .get();
    expect(profiles, hasLength(1));
    expect(profiles.single.firstName, 'Existing');
    final contact = await database.careContactDao
        .getContactById(profileId, contactId);
    expect(contact!.displayName, 'Dr. Migrated');

    // 5. The doctor_visit_records table exists again after migration.
    final tables = await database
        .customSelect('SELECT name FROM sqlite_master WHERE type = \'table\'')
        .get();
    final tableNames = tables.map((r) => r.read<String>('name')).toSet();
    expect(tableNames, contains('doctor_visit_records'));

    // 6. A visit can be written through the DAO after migration.
    final visitId = await database.doctorVisitDao.insertVisit(
      db.DoctorVisitRecordsCompanion.insert(
        profileId: profileId,
        doctorContactId: Value(contactId),
        visitType: 'planned',
        status: 'scheduled',
        scheduledDateTime: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      ),
    );
    expect(visitId, greaterThan(0));
    final saved = await database.doctorVisitDao.getVisitById(profileId, visitId);
    expect(saved!.doctorContactId, contactId);
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

  test('upgrading from version 15 creates doctor prescription tables and '
      'preserves data', () async {
    // 1. Open a fresh file DB at the current schema and seed a profile.
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

    // 2. Simulate a v15 database: drop the doctor prescription tables and mark
    //    user_version as 15 so reopening runs the real onUpgrade path.
    await database.customStatement('DROP TABLE doctor_prescription_attachments');
    await database.customStatement('DROP TABLE doctor_prescriptions');
    await database.customStatement('PRAGMA user_version = 15');
    await database.close();

    // 3. Reopen — drift detects 15 < 16 and applies the migration.
    database = await openFileDb();
    addTearDown(database.close);

    // 4. Existing profile data is preserved.
    final profiles = await (database.select(database.profiles)
          ..where((t) => t.id.equals(profileId)))
        .get();
    expect(profiles, hasLength(1));
    expect(profiles.single.firstName, 'Existing');

    // 5. Both prescription tables exist again after migration.
    final tables = await database
        .customSelect('SELECT name FROM sqlite_master WHERE type = \'table\'')
        .get();
    final tableNames = tables.map((r) => r.read<String>('name')).toSet();
    expect(tableNames, contains('doctor_prescriptions'));
    expect(tableNames, contains('doctor_prescription_attachments'));

    // 6. A prescription can be written through the DAO after migration.
    final prescriptionId = await database.doctorPrescriptionDao
        .insertPrescription(
      db.DoctorPrescriptionsCompanion.insert(
        profileId: profileId,
        title: 'Amoxicillin 500mg',
        prescriptionDate: DateTime(2026, 8, 1),
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      ),
    );
    expect(prescriptionId, greaterThan(0));

    // 7. An attachment row can also be written.
    final attachmentId = await database.doctorPrescriptionDao
        .insertAttachment(
      db.DoctorPrescriptionAttachmentsCompanion.insert(
        prescriptionId: prescriptionId,
        profileId: profileId,
        fileType: 'pdf',
        managedRelativePath: 'doctor_prescriptions/$profileId/$prescriptionId/a.pdf',
        originalFileName: 'a.pdf',
        displayName: 'a',
        mimeType: 'application/pdf',
        fileSize: const Value(1),
        sortOrder: const Value(0),
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      ),
    );
    expect(attachmentId, greaterThan(0));
  });

  test('upgrading from version 16 creates the prescription medications table '
      'and preserves data', () async {
    // 1. Open a fresh file DB at the current schema and seed a profile.
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

    // 2. Simulate a v16 database: drop the prescription medications table and
    //    mark user_version as 16 so reopening runs the real onUpgrade path.
    await database.customStatement('DROP TABLE doctor_prescription_medications');
    await database.customStatement('PRAGMA user_version = 16');
    await database.close();

    // 3. Reopen — drift detects 16 < 17 and applies the migration.
    database = await openFileDb();
    addTearDown(database.close);

    // 4. The medications table exists again after migration.
    final tables = await database
        .customSelect('SELECT name FROM sqlite_master WHERE type = \'table\'')
        .get();
    final tableNames = tables.map((r) => r.read<String>('name')).toSet();
    expect(tableNames, contains('doctor_prescription_medications'));

    // 5. A medication row can be written through the DAO after migration.
    final prescriptionId = await database.doctorPrescriptionDao
        .insertPrescription(
      db.DoctorPrescriptionsCompanion.insert(
        profileId: profileId,
        title: 'Cardiology follow-up',
        prescriptionDate: DateTime(2026, 8, 1),
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      ),
    );
    final medicationId = await database.doctorPrescriptionDao
        .insertMedication(
      db.DoctorPrescriptionMedicationsCompanion.insert(
        prescriptionId: prescriptionId,
        profileId: profileId,
        medicationName: 'Clopidogrel 75 mg',
        doseAmount: const Value('75'),
        doseUnit: const Value('mg'),
        sortOrder: const Value(0),
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      ),
    );
    expect(medicationId, greaterThan(0));
  });
}
