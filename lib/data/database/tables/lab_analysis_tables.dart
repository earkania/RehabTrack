import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/tables/profile_table.dart';
import 'package:rehab_track/data/database/tables/care_contact_table.dart';
import 'package:rehab_track/data/database/tables/doctor_visit_records_table.dart';

/// Lab Analyses — document archive for lab results, imaging reports, etc.
@TableIndex(name: 'lab_analyses_profile_idx', columns: {#profileId})
@TableIndex(name: 'lab_analyses_date_idx', columns: {#analysisDate})
@TableIndex(name: 'lab_analyses_category_idx', columns: {#category})
@TableIndex(name: 'lab_analyses_archived_idx', columns: {#isArchived})
@TableIndex(name: 'lab_analyses_laboratory_idx', columns: {#laboratoryContactId})
@TableIndex(name: 'lab_analyses_ordering_doctor_idx', columns: {#orderingDoctorContactId})
@TableIndex(name: 'lab_analyses_visit_idx', columns: {#relatedDoctorVisitId})
class LabAnalyses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get category => text()();
  DateTimeColumn get analysisDate => dateTime()();
  DateTimeColumn get resultReceivedDate => dateTime().nullable()();
  IntColumn get laboratoryContactId =>
      integer().references(CareContacts, #id, onDelete: KeyAction.setNull).nullable()();
  IntColumn get orderingDoctorContactId =>
      integer().references(CareContacts, #id, onDelete: KeyAction.setNull).nullable()();
  IntColumn get relatedDoctorVisitId =>
      integer().references(DoctorVisitRecords, #id, onDelete: KeyAction.setNull).nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// Attachments for Lab Analyses (PDFs, images, etc.)
@TableIndex(name: 'lab_analysis_attachments_analysis_idx', columns: {#analysisId})
@TableIndex(name: 'lab_analysis_attachments_profile_idx', columns: {#profileId})
class LabAnalysisAttachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get analysisId =>
      integer().references(LabAnalyses, #id, onDelete: KeyAction.cascade)();
  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get fileType => text()(); // pdf, image, other
  TextColumn get managedRelativePath => text()();
  TextColumn get originalFileName => text()();
  TextColumn get displayName => text()();
  TextColumn get mimeType => text()();
  IntColumn get fileSize => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}