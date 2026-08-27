import 'package:rehab_track/domain/entities/doctor_visit_record.dart';
import 'package:rehab_track/domain/enums/enums.dart';

abstract class DoctorVisitRepository {
  /// Watches open (still scheduled, non-archived) visits for a profile,
  /// ordered by scheduled time ascending.
  Stream<List<DoctorVisitRecord>> watchUpcomingVisits(int profileId);

  /// Watches terminal visits (completed / cancelled / missed) for a profile,
  /// ordered by scheduled time descending.
  Stream<List<DoctorVisitRecord>> watchVisitHistory(int profileId);

  /// Watches a single visit scoped to a profile; emits null when absent.
  Stream<DoctorVisitRecord?> watchVisitById(int profileId, int visitId);

  /// One-shot fetch of a visit scoped to a profile.
  Future<DoctorVisitRecord?> getVisitById(int profileId, int visitId);

  /// One-shot fetch of open visits for reminder recovery.
  Future<List<DoctorVisitRecord>> getUpcomingVisits(int profileId);

  /// One-shot fetch of non-archived visits whose [DoctorVisitRecord.scheduledDateTime]
  /// falls within the half-open range `[startInclusive, endExclusive)` for a
  /// profile, newest first. Any visit status is included.
  Future<List<DoctorVisitRecord>> getVisitsBetween(
    int profileId,
    DateTime startInclusive,
    DateTime endExclusive,
  );

  Future<int> createVisit(DoctorVisitRecord visit);

  Future<void> updateVisit(DoctorVisitRecord visit);

  Future<void> setVisitStatus(
    int profileId,
    int visitId,
    DoctorVisitStatus status,
  );

  Future<void> archiveVisit(int profileId, int visitId);

  Future<void> deleteVisit(int profileId, int visitId);

  /// Whether a Care Contact is referenced by any visit (active or archived) —
  /// used by the Care Contacts module to refuse permanent deletion.
  Future<bool> isContactReferencedByVisits(int contactId);

  /// Number of open visits referencing a contact — used to warn before
  /// deleting/archiving a contact that has upcoming visits.
  Future<int> countOpenVisitsReferencingContact(int profileId, int contactId);
}
