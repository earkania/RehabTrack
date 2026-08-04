import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/database/tables/doctor_visit_records_table.dart';

part 'doctor_visit_dao.g.dart';

@DriftAccessor(tables: [DoctorVisitRecords])
class DoctorVisitDao extends DatabaseAccessor<AppDatabase>
    with _$DoctorVisitDaoMixin {
  DoctorVisitDao(super.db);

  static const _upcomingStatuses = {'scheduled'};
  static const _historyStatuses = {'completed', 'cancelled', 'missed'};

  /// Watches open (non-archived, still scheduled) visits ordered by scheduled
  /// time ascending. Past-scheduled rows are included so the UI can present
  /// them under an "attention" state until the user resolves them.
  Stream<List<DoctorVisitRecord>> watchUpcomingVisits(int profileId) {
    return (select(doctorVisitRecords)
          ..where((t) =>
              t.profileId.equals(profileId) &
              t.isArchived.equals(false) &
              t.status.isIn(_upcomingStatuses))
          ..orderBy([
            (t) => OrderingTerm(expression: t.scheduledDateTime),
          ])).watch();
  }

  /// Watches terminal visits (completed / cancelled / missed) ordered by
  /// scheduled time descending (most recent first).
  Stream<List<DoctorVisitRecord>> watchVisitHistory(int profileId) {
    return (select(doctorVisitRecords)
          ..where((t) =>
              t.profileId.equals(profileId) &
              t.isArchived.equals(false) &
              t.status.isIn(_historyStatuses))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.scheduledDateTime,
              mode: OrderingMode.desc,
            ),
          ])).watch();
  }

  Stream<DoctorVisitRecord?> watchVisitById(int profileId, int visitId) {
    return (select(doctorVisitRecords)
          ..where((t) =>
              t.id.equals(visitId) & t.profileId.equals(profileId))
          ..limit(1)).watchSingleOrNull();
  }

  Future<DoctorVisitRecord?> getVisitById(int profileId, int visitId) {
    return (select(doctorVisitRecords)
          ..where((t) =>
              t.id.equals(visitId) & t.profileId.equals(profileId))
          ..limit(1)).getSingleOrNull();
  }

  /// One-shot fetch of open visits for reminder recovery.
  Future<List<DoctorVisitRecord>> getUpcomingVisits(int profileId) {
    return (select(doctorVisitRecords)
          ..where((t) =>
              t.profileId.equals(profileId) &
              t.isArchived.equals(false) &
              t.status.isIn(_upcomingStatuses)))
        .get();
  }

  /// Counts non-archived open (still scheduled) visits referencing a contact,
  /// used to warn before deleting or archiving a contact that has upcoming
  /// visits.
  Future<int> countOpenVisitsReferencingContact(
    int profileId,
    int contactId,
  ) async {
    final rows = await (select(doctorVisitRecords)
          ..where((t) =>
              t.profileId.equals(profileId) &
              t.isArchived.equals(false) &
              t.status.isIn(_upcomingStatuses) &
              (t.doctorContactId.equals(contactId) |
                  t.organizationContactId.equals(contactId))))
        .get();
    return rows.length;
  }

  /// Counts all (including archived and terminal) visits referencing a contact
  /// — used by the Care Contacts "cannot delete referenced contact" guard.
  Future<int> countAllVisitsReferencingContact(int contactId) async {
    final rows = await (select(doctorVisitRecords)
          ..where((t) =>
              t.doctorContactId.equals(contactId) |
              t.organizationContactId.equals(contactId)))
        .get();
    return rows.length;
  }

  Future<int> insertVisit(DoctorVisitRecordsCompanion entry) {
    return into(doctorVisitRecords).insert(entry);
  }

  Future<void> updateVisit(DoctorVisitRecordsCompanion entry) {
    return update(doctorVisitRecords).replace(entry);
  }

  Future<void> setStatus(
    int profileId,
    int visitId,
    String status,
  ) async {
    await (update(doctorVisitRecords)
          ..where((t) =>
              t.id.equals(visitId) & t.profileId.equals(profileId)))
        .write(DoctorVisitRecordsCompanion(
      status: Value(status),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> setArchived(
    int profileId,
    int visitId,
    bool archived,
  ) async {
    await (update(doctorVisitRecords)
          ..where((t) =>
              t.id.equals(visitId) & t.profileId.equals(profileId)))
        .write(DoctorVisitRecordsCompanion(
      isArchived: Value(archived),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> deleteVisit(int profileId, int visitId) async {
    await (delete(doctorVisitRecords)
          ..where((t) =>
              t.id.equals(visitId) & t.profileId.equals(profileId)))
        .go();
  }
}
