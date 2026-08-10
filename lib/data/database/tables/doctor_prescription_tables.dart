import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/tables/profile_table.dart';
import 'package:rehab_track/data/database/tables/care_contact_table.dart';
import 'package:rehab_track/data/database/tables/doctor_visit_records_table.dart';

/// Doctor Prescriptions — document archive for prescribed medications with
/// attached PDFs, images, and photos of the prescription.
@TableIndex(name: 'doctor_prescriptions_profile_idx', columns: {#profileId})
@TableIndex(name: 'doctor_prescriptions_date_idx', columns: {#prescriptionDate})
@TableIndex(name: 'doctor_prescriptions_archived_idx', columns: {#isArchived})
@TableIndex(name: 'doctor_prescriptions_doctor_idx', columns: {#doctorContactId})
@TableIndex(name: 'doctor_prescriptions_clinic_idx', columns: {#clinicContactId})
@TableIndex(name: 'doctor_prescriptions_visit_idx', columns: {#relatedDoctorVisitId})
class DoctorPrescriptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  DateTimeColumn get prescriptionDate => dateTime()();
  IntColumn get doctorContactId =>
      integer().references(CareContacts, #id, onDelete: KeyAction.setNull).nullable()();
  IntColumn get clinicContactId =>
      integer().references(CareContacts, #id, onDelete: KeyAction.setNull).nullable()();
  IntColumn get relatedDoctorVisitId =>
      integer().references(DoctorVisitRecords, #id, onDelete: KeyAction.setNull).nullable()();
  TextColumn get reason => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// Attachments for Doctor Prescriptions (PDFs, images, etc.)
@TableIndex(name: 'doctor_prescription_attachments_prescription_idx', columns: {#prescriptionId})
@TableIndex(name: 'doctor_prescription_attachments_profile_idx', columns: {#profileId})
class DoctorPrescriptionAttachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get prescriptionId =>
      integer().references(DoctorPrescriptions, #id, onDelete: KeyAction.cascade)();
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

/// Structured medications belonging to a Doctor Prescription.
///
/// Holds free-searchable details (name, dose, frequency, timing, etc.) without
/// ever auto-creating entries in the active [Medications] module.
@TableIndex(name: 'doctor_prescription_medications_prescription_idx', columns: {#prescriptionId})
@TableIndex(name: 'doctor_prescription_medications_profile_idx', columns: {#profileId})
class DoctorPrescriptionMedications extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get prescriptionId =>
      integer().references(DoctorPrescriptions, #id, onDelete: KeyAction.cascade)();
  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get medicationName => text()();
  TextColumn get doseAmount => text().nullable()();
  TextColumn get doseUnit => text().nullable()();
  TextColumn get instructions => text().nullable()();
  TextColumn get frequency => text().nullable()();
  TextColumn get timing => text().nullable()();
  TextColumn get duration => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}