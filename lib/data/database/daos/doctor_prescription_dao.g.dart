// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_prescription_dao.dart';

// ignore_for_file: type=lint
mixin _$DoctorPrescriptionDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $CareContactsTable get careContacts => attachedDatabase.careContacts;
  $DoctorVisitRecordsTable get doctorVisitRecords =>
      attachedDatabase.doctorVisitRecords;
  $DoctorPrescriptionsTable get doctorPrescriptions =>
      attachedDatabase.doctorPrescriptions;
  $DoctorPrescriptionAttachmentsTable get doctorPrescriptionAttachments =>
      attachedDatabase.doctorPrescriptionAttachments;
  $DoctorPrescriptionMedicationsTable get doctorPrescriptionMedications =>
      attachedDatabase.doctorPrescriptionMedications;
  DoctorPrescriptionDaoManager get managers =>
      DoctorPrescriptionDaoManager(this);
}

class DoctorPrescriptionDaoManager {
  final _$DoctorPrescriptionDaoMixin _db;
  DoctorPrescriptionDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$CareContactsTableTableManager get careContacts =>
      $$CareContactsTableTableManager(_db.attachedDatabase, _db.careContacts);
  $$DoctorVisitRecordsTableTableManager get doctorVisitRecords =>
      $$DoctorVisitRecordsTableTableManager(
        _db.attachedDatabase,
        _db.doctorVisitRecords,
      );
  $$DoctorPrescriptionsTableTableManager get doctorPrescriptions =>
      $$DoctorPrescriptionsTableTableManager(
        _db.attachedDatabase,
        _db.doctorPrescriptions,
      );
  $$DoctorPrescriptionAttachmentsTableTableManager
  get doctorPrescriptionAttachments =>
      $$DoctorPrescriptionAttachmentsTableTableManager(
        _db.attachedDatabase,
        _db.doctorPrescriptionAttachments,
      );
  $$DoctorPrescriptionMedicationsTableTableManager
  get doctorPrescriptionMedications =>
      $$DoctorPrescriptionMedicationsTableTableManager(
        _db.attachedDatabase,
        _db.doctorPrescriptionMedications,
      );
}
