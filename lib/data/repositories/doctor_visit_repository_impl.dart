import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/domain/entities/doctor_visit_record.dart';
import 'package:rehab_track/domain/enums/enums.dart';
import 'package:rehab_track/domain/repositories/doctor_visit_repository.dart';

class DoctorVisitRepositoryImpl implements DoctorVisitRepository {
  final db.AppDatabase _database;

  DoctorVisitRepositoryImpl(this._database);

  @override
  Stream<List<DoctorVisitRecord>> watchUpcomingVisits(int profileId) {
    return _database.doctorVisitDao
        .watchUpcomingVisits(profileId)
        .map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<List<DoctorVisitRecord>> watchVisitHistory(int profileId) {
    return _database.doctorVisitDao
        .watchVisitHistory(profileId)
        .map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<DoctorVisitRecord?> watchVisitById(int profileId, int visitId) {
    return _database.doctorVisitDao
        .watchVisitById(profileId, visitId)
        .map((row) => row != null ? _toDomain(row) : null);
  }

  @override
  Future<DoctorVisitRecord?> getVisitById(int profileId, int visitId) async {
    final row =
        await _database.doctorVisitDao.getVisitById(profileId, visitId);
    return row != null ? _toDomain(row) : null;
  }

  @override
  Future<List<DoctorVisitRecord>> getUpcomingVisits(int profileId) async {
    final rows = await _database.doctorVisitDao.getUpcomingVisits(profileId);
    return rows.map(_toDomain).toList();
  }

  @override
  Future<List<DoctorVisitRecord>> getVisitsBetween(
    int profileId,
    DateTime startInclusive,
    DateTime endExclusive,
  ) async {
    final rows = await _database.doctorVisitDao.getVisitsBetween(
      profileId,
      startInclusive,
      endExclusive,
    );
    return rows.map(_toDomain).toList();
  }

  @override
  Future<int> createVisit(DoctorVisitRecord visit) async {
    final now = visit.createdAt;
    return _database.doctorVisitDao.insertVisit(
      db.DoctorVisitRecordsCompanion.insert(
        profileId: visit.profileId,
        doctorContactId: Value(visit.doctorContactId),
        organizationContactId: Value(visit.organizationContactId),
        visitType: visit.visitType.name,
        status: visit.status.name,
        scheduledDateTime: visit.scheduledDateTime,
        reason: Value(visit.reason),
        notes: Value(visit.notes),
        reminderEnabled: Value(visit.reminderEnabled),
        reminderMinutesBefore: Value(visit.reminderMinutesBefore),
        isArchived: Value(visit.isArchived),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  Future<void> updateVisit(DoctorVisitRecord visit) async {
    await _database.doctorVisitDao.updateVisit(
      db.DoctorVisitRecordsCompanion(
        id: Value(visit.id!),
        profileId: Value(visit.profileId),
        doctorContactId: Value(visit.doctorContactId),
        organizationContactId: Value(visit.organizationContactId),
        visitType: Value(visit.visitType.name),
        status: Value(visit.status.name),
        scheduledDateTime: Value(visit.scheduledDateTime),
        reason: Value(visit.reason),
        notes: Value(visit.notes),
        reminderEnabled: Value(visit.reminderEnabled),
        reminderMinutesBefore: Value(visit.reminderMinutesBefore),
        isArchived: Value(visit.isArchived),
        createdAt: Value(visit.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> setVisitStatus(
    int profileId,
    int visitId,
    DoctorVisitStatus status,
  ) async {
    await _database.doctorVisitDao.setStatus(profileId, visitId, status.name);
  }

  @override
  Future<void> archiveVisit(int profileId, int visitId) {
    return _database.doctorVisitDao.setArchived(profileId, visitId, true);
  }

  @override
  Future<void> deleteVisit(int profileId, int visitId) {
    return _database.doctorVisitDao.deleteVisit(profileId, visitId);
  }

  @override
  Future<bool> isContactReferencedByVisits(int contactId) async {
    final count =
        await _database.doctorVisitDao.countAllVisitsReferencingContact(
      contactId,
    );
    return count > 0;
  }

  @override
  Future<int> countOpenVisitsReferencingContact(
    int profileId,
    int contactId,
  ) async {
    return _database.doctorVisitDao.countOpenVisitsReferencingContact(
      profileId,
      contactId,
    );
  }

  DoctorVisitRecord _toDomain(db.DoctorVisitRecord row) {
    return DoctorVisitRecord(
      id: row.id,
      profileId: row.profileId,
      doctorContactId: row.doctorContactId,
      organizationContactId: row.organizationContactId,
      visitType: DoctorVisitType.fromString(row.visitType),
      status: DoctorVisitStatus.fromString(row.status),
      scheduledDateTime: row.scheduledDateTime,
      reason: row.reason,
      notes: row.notes,
      reminderEnabled: row.reminderEnabled,
      reminderMinutesBefore: row.reminderMinutesBefore,
      isArchived: row.isArchived,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
