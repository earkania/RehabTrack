import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/data/repositories/doctor_visit_repository_impl.dart';
import 'package:rehab_track/domain/entities/doctor_visit_record.dart';
import 'package:rehab_track/domain/enums/enums.dart';

void main() {
  late db.AppDatabase database;
  late DoctorVisitRepositoryImpl repository;

  setUp(() {
    database = db.AppDatabase.test();
    repository = DoctorVisitRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<int> insertProfile() {
    return database.into(database.profiles).insert(
      db.ProfilesCompanion.insert(
        firstName: 'John',
        lastName: 'Doe',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        isPrimary: const Value(true),
        isActive: const Value(true),
      ),
    );
  }

  Future<int> insertContact({
    required int profileId,
    String type = 'doctor',
    String displayName = 'Dr. Smith',
  }) {
    return database.careContactDao.insertContact(
      db.CareContactsCompanion.insert(
        profileId: profileId,
        contactType: type,
        displayName: displayName,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    );
  }

  DoctorVisitRecord makeVisit({
    int? id,
    required int profileId,
    int? doctorContactId,
    int? organizationContactId,
    DoctorVisitType visitType = DoctorVisitType.planned,
    DoctorVisitStatus status = DoctorVisitStatus.scheduled,
    DateTime? scheduledDateTime,
    String? reason,
    String? notes,
    bool reminderEnabled = false,
    int reminderMinutesBefore = 1440,
    bool isArchived = false,
  }) {
    return DoctorVisitRecord(
      id: id,
      profileId: profileId,
      doctorContactId: doctorContactId,
      organizationContactId: organizationContactId,
      visitType: visitType,
      status: status,
      scheduledDateTime: scheduledDateTime ?? DateTime(2026, 8, 1, 10, 0),
      reason: reason,
      notes: notes,
      reminderEnabled: reminderEnabled,
      reminderMinutesBefore: reminderMinutesBefore,
      isArchived: isArchived,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
  }

  group('createVisit / getVisitById', () {
    test('persists a visit and returns its id', () async {
      final profileId = await insertProfile();
      final doctorId = await insertContact(profileId: profileId);
      final clinicId =
          await insertContact(profileId: profileId, type: 'clinic', displayName: 'City Clinic');

      final id = await repository.createVisit(makeVisit(
        profileId: profileId,
        doctorContactId: doctorId,
        organizationContactId: clinicId,
        reason: 'Follow-up',
      ));

      expect(id, greaterThan(0));
      final saved = await repository.getVisitById(profileId, id);
      expect(saved, isNotNull);
      expect(saved!.doctorContactId, doctorId);
      expect(saved.organizationContactId, clinicId);
      expect(saved.visitType, DoctorVisitType.planned);
      expect(saved.status, DoctorVisitStatus.scheduled);
      expect(saved.reason, 'Follow-up');
      expect(saved.reminderEnabled, isFalse);
      expect(saved.reminderMinutesBefore, 1440);
      expect(saved.isArchived, isFalse);
    });

    test('supports visits with no contacts', () async {
      final profileId = await insertProfile();
      final id = await repository.createVisit(makeVisit(profileId: profileId));

      final saved = await repository.getVisitById(profileId, id);
      expect(saved!.doctorContactId, isNull);
      expect(saved.organizationContactId, isNull);
    });

    test('persists reminder settings and on-demand type', () async {
      final profileId = await insertProfile();
      final id = await repository.createVisit(makeVisit(
        profileId: profileId,
        visitType: DoctorVisitType.onDemand,
        status: DoctorVisitStatus.completed,
        reminderEnabled: true,
        reminderMinutesBefore: 60,
      ));

      final saved = await repository.getVisitById(profileId, id);
      expect(saved!.visitType, DoctorVisitType.onDemand);
      expect(saved.status, DoctorVisitStatus.completed);
      expect(saved.reminderEnabled, isTrue);
      expect(saved.reminderMinutesBefore, 60);
    });
  });

  group('updateVisit', () {
    test('updates fields in place without duplicating the row', () async {
      final profileId = await insertProfile();
      final id = await repository.createVisit(makeVisit(
        profileId: profileId,
        reason: 'Original',
      ));

      final existing = await repository.getVisitById(profileId, id);
      final updated = existing!.copyWith(
        status: DoctorVisitStatus.completed,
        reason: 'Updated',
        reminderEnabled: false,
      );
      await repository.updateVisit(updated);

      final saved = await repository.getVisitById(profileId, id);
      expect(saved!.status, DoctorVisitStatus.completed);
      expect(saved.reason, 'Updated');
      expect(saved.reminderEnabled, isFalse);

      final all = await database.doctorVisitDao
          .customSelect('SELECT COUNT(*) FROM doctor_visit_records')
          .get();
      expect(all.single.read<int>('COUNT(*)'), 1);
    });

    test('can clear a contact reference', () async {
      final profileId = await insertProfile();
      final doctorId = await insertContact(profileId: profileId);
      final id = await repository.createVisit(makeVisit(
        profileId: profileId,
        doctorContactId: doctorId,
      ));

      final existing = await repository.getVisitById(profileId, id);
      await repository.updateVisit(
        existing!.copyWith(clearDoctorContactId: true),
      );

      final saved = await repository.getVisitById(profileId, id);
      expect(saved!.doctorContactId, isNull);
    });
  });

  group('setVisitStatus / archiveVisit / deleteVisit', () {
    test('setVisitStatus transitions status', () async {
      final profileId = await insertProfile();
      final id = await repository.createVisit(makeVisit(profileId: profileId));

      await repository.setVisitStatus(
        profileId,
        id,
        DoctorVisitStatus.completed,
      );

      final saved = await repository.getVisitById(profileId, id);
      expect(saved!.status, DoctorVisitStatus.completed);
    });

    test('archived visit is hidden from upcoming watch', () async {
      final profileId = await insertProfile();
      final id = await repository.createVisit(makeVisit(profileId: profileId));

      final before = await repository.watchUpcomingVisits(profileId).first;
      expect(before, hasLength(1));

      await repository.archiveVisit(profileId, id);
      final after = await repository.watchUpcomingVisits(profileId).first;
      expect(after, isEmpty);
    });

    test('deleteVisit removes the row', () async {
      final profileId = await insertProfile();
      final id = await repository.createVisit(makeVisit(profileId: profileId));

      await repository.deleteVisit(profileId, id);
      final saved = await repository.getVisitById(profileId, id);
      expect(saved, isNull);
    });
  });

  group('watchUpcomingVisits / watchVisitHistory', () {
    test('upcoming only includes scheduled, sorted ascending', () async {
      final profileId = await insertProfile();
      final early = await repository.createVisit(makeVisit(
        profileId: profileId,
        scheduledDateTime: DateTime(2026, 8, 1, 10),
      ));
      final late = await repository.createVisit(makeVisit(
        profileId: profileId,
        scheduledDateTime: DateTime(2026, 8, 3, 10),
      ));
      await repository.createVisit(makeVisit(
        profileId: profileId,
        status: DoctorVisitStatus.completed,
      ));

      final upcoming = await repository.watchUpcomingVisits(profileId).first;
      expect(upcoming.map((v) => v.id), [early, late]);
    });

    test('history includes terminal statuses, sorted descending', () async {
      final profileId = await insertProfile();
      final old = await repository.createVisit(makeVisit(
        profileId: profileId,
        scheduledDateTime: DateTime(2026, 7, 1, 10),
      ));
      final recent = await repository.createVisit(makeVisit(
        profileId: profileId,
        scheduledDateTime: DateTime(2026, 7, 5, 10),
      ));
      await repository.setVisitStatus(profileId, old, DoctorVisitStatus.missed);
      await repository.setVisitStatus(
        profileId,
        recent,
        DoctorVisitStatus.cancelled,
      );
      await repository.createVisit(makeVisit(profileId: profileId));

      final history = await repository.watchVisitHistory(profileId).first;
      expect(history.map((v) => v.id), [recent, old]);
      expect(history.map((v) => v.status).toSet(),
          {DoctorVisitStatus.missed, DoctorVisitStatus.cancelled});
    });

    test('past scheduled visits stay in upcoming until resolved', () async {
      final profileId = await insertProfile();
      final id = await repository.createVisit(makeVisit(
        profileId: profileId,
        scheduledDateTime: DateTime(2026, 1, 1, 10),
      ));

      final upcoming = await repository.watchUpcomingVisits(profileId).first;
      expect(upcoming.map((v) => v.id), [id]);
    });
  });

  group('contact reference guards', () {
    test('isContactReferencedByVisits true when a visit references it',
        () async {
      final profileId = await insertProfile();
      final doctorId = await insertContact(profileId: profileId);
      await repository.createVisit(makeVisit(
        profileId: profileId,
        doctorContactId: doctorId,
      ));

      expect(await repository.isContactReferencedByVisits(doctorId), isTrue);
    });

    test('isContactReferencedByVisits false when unreferenced', () async {
      final profileId = await insertProfile();
      final doctorId = await insertContact(profileId: profileId);

      expect(await repository.isContactReferencedByVisits(doctorId), isFalse);
    });

    test('countOpenVisitsReferencingContact counts only open visits', () async {
      final profileId = await insertProfile();
      final doctorId = await insertContact(profileId: profileId);
      final openId = await repository.createVisit(makeVisit(
        profileId: profileId,
        doctorContactId: doctorId,
        scheduledDateTime: DateTime(2026, 8, 10, 10),
      ));
      final terminalId = await repository.createVisit(makeVisit(
        profileId: profileId,
        doctorContactId: doctorId,
        scheduledDateTime: DateTime(2026, 7, 10, 10),
      ));
      await repository.setVisitStatus(
        profileId,
        terminalId,
        DoctorVisitStatus.completed,
      );

      // One open (scheduled) and one terminal visit both reference the contact.
      expect(
        await repository.countOpenVisitsReferencingContact(
          profileId,
          doctorId,
        ),
        1,
      );

      // Closing the open visit drops the count to zero.
      await repository.setVisitStatus(
        profileId,
        openId,
        DoctorVisitStatus.cancelled,
      );
      expect(
        await repository.countOpenVisitsReferencingContact(
          profileId,
          doctorId,
        ),
        0,
      );
    });

    test('reference counts include archived visits', () async {
      final profileId = await insertProfile();
      final doctorId = await insertContact(profileId: profileId);
      final id = await repository.createVisit(makeVisit(
        profileId: profileId,
        doctorContactId: doctorId,
      ));

      await repository.archiveVisit(profileId, id);
      expect(await repository.isContactReferencedByVisits(doctorId), isTrue);
    });
  });
}
