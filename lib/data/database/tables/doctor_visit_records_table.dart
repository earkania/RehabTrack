import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/tables/profile_table.dart';
import 'package:rehab_track/data/database/tables/care_contact_table.dart';

/// Doctor Visits — Records → Doctor Visits module.
///
/// Deliberately named `DoctorVisitRecords` (table `doctor_visit_records`) to
/// avoid clashing with the legacy placeholder `DoctorVisits` table that
/// belongs to the old Doctor module. Each row references optional Care
/// Contacts for the doctor and the clinic/hospital; both are nullable because
/// a visit may reference only a doctor, only an organization, both, or
/// neither.
@TableIndex(name: 'doctor_visit_records_profile_idx', columns: {#profileId})
@TableIndex(name: 'doctor_visit_records_scheduled_idx', columns: {#scheduledDateTime})
@TableIndex(name: 'doctor_visit_records_status_idx', columns: {#status})
@TableIndex(name: 'doctor_visit_records_doctor_idx', columns: {#doctorContactId})
@TableIndex(name: 'doctor_visit_records_org_idx', columns: {#organizationContactId})
@TableIndex(name: 'doctor_visit_records_archived_idx', columns: {#isArchived})
class DoctorVisitRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id)();
  @ReferenceName('doctor')
  IntColumn get doctorContactId =>
      integer().references(CareContacts, #id).nullable()();
  @ReferenceName('organization')
  IntColumn get organizationContactId =>
      integer().references(CareContacts, #id).nullable()();
  TextColumn get visitType => text()();
  TextColumn get status => text()();
  DateTimeColumn get scheduledDateTime => dateTime()();
  TextColumn get reason => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(false))();
  IntColumn get reminderMinutesBefore =>
      integer().withDefault(const Constant(1440))();
  BoolColumn get isArchived =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
