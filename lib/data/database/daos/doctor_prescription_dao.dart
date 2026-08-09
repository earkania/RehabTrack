import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/database/tables/doctor_prescription_tables.dart';

part 'doctor_prescription_dao.g.dart';

@DriftAccessor(
    tables: [DoctorPrescriptions, DoctorPrescriptionAttachments, DoctorPrescriptionMedications])
class DoctorPrescriptionDao extends DatabaseAccessor<AppDatabase>
    with _$DoctorPrescriptionDaoMixin {
  DoctorPrescriptionDao(super.db);

  /// Watch all active prescriptions for a profile
  Stream<List<DoctorPrescription>> watchActivePrescriptions(int profileId) {
    final query = select(doctorPrescriptions)
      ..where((t) => t.profileId.equals(profileId) & t.isArchived.equals(false))
      ..orderBy([
        (t) => OrderingTerm.desc(t.prescriptionDate),
        (t) => OrderingTerm.desc(t.createdAt),
      ]);
    return query.watch();
  }

  /// Watch all archived prescriptions for a profile
  Stream<List<DoctorPrescription>> watchArchivedPrescriptions(int profileId) {
    final query = select(doctorPrescriptions)
      ..where((t) => t.profileId.equals(profileId) & t.isArchived.equals(true))
      ..orderBy([
        (t) => OrderingTerm.desc(t.prescriptionDate),
        (t) => OrderingTerm.desc(t.createdAt),
      ]);
    return query.watch();
  }

  /// Get prescription by ID and profile ID
  Future<DoctorPrescription?> getPrescription(int id, int profileId) {
    return (select(doctorPrescriptions)
          ..where((t) => t.id.equals(id) & t.profileId.equals(profileId)))
        .getSingleOrNull();
  }

  /// Watch prescription by ID
  Stream<DoctorPrescription?> watchPrescription(int id, int profileId) {
    return (select(doctorPrescriptions)
          ..where((t) => t.id.equals(id) & t.profileId.equals(profileId)))
        .watchSingleOrNull();
  }

  /// Insert a new prescription
  Future<int> insertPrescription(DoctorPrescriptionsCompanion entry) {
    return into(doctorPrescriptions).insert(entry);
  }

  /// Update an existing prescription
  Future<bool> updatePrescription(DoctorPrescriptionsCompanion entry) {
    return update(doctorPrescriptions).replace(entry);
  }

  /// Archive or restore a prescription
  Future<int> setArchived(int id, int profileId, bool archived) {
    return (update(doctorPrescriptions)
          ..where((t) => t.id.equals(id) & t.profileId.equals(profileId)))
        .write(DoctorPrescriptionsCompanion(
          isArchived: Value(archived),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Permanently delete a prescription (attachments handled separately)
  Future<int> deletePrescription(int id, int profileId) {
    return (delete(doctorPrescriptions)
          ..where((t) => t.id.equals(id) & t.profileId.equals(profileId)))
        .go();
  }

  /// Search prescriptions by title, doctor, clinic, reason, notes, etc.
  Stream<List<DoctorPrescription>> searchPrescriptions(
    int profileId, {
    bool includeArchived = false,
    String? query,
    DateTime? startDate,
    DateTime? endDate,
  }) async* {
    // Prescriptions matching by medication name.
    List<int> medicationIds = [];
    if (query != null && query.isNotEmpty) {
      final searchTerm = '%$query%';
      final matching = await (select(doctorPrescriptionMedications)
            ..where((m) => m.medicationName.like(searchTerm)))
          .get();
      medicationIds = matching.map((m) => m.prescriptionId).toSet().toList();
    }

    var statement = select(doctorPrescriptions)
      ..where((t) => t.profileId.equals(profileId));

    if (!includeArchived) {
      statement.where((t) => t.isArchived.equals(false));
    }

    if (query != null && query.isNotEmpty) {
      final searchTerm = '%$query%';
      statement.where((t) =>
          t.title.like(searchTerm) |
          t.reason.like(searchTerm) |
          t.notes.like(searchTerm) |
          (medicationIds.isNotEmpty
              ? t.id.isIn(medicationIds)
              : const Constant(false)));
    }

    if (startDate != null) {
      statement.where((t) => t.prescriptionDate.isBiggerOrEqualValue(startDate));
    }

    if (endDate != null) {
      statement.where((t) => t.prescriptionDate.isSmallerOrEqualValue(endDate));
    }

    statement.orderBy([
      (t) => OrderingTerm.desc(t.prescriptionDate),
      (t) => OrderingTerm.desc(t.createdAt),
    ]);

    yield* statement.watch();
  }

  // Attachments

  /// Watch attachments for a prescription
  Stream<List<DoctorPrescriptionAttachment>> watchAttachments(
      int prescriptionId) {
    final query = select(doctorPrescriptionAttachments)
      ..where((t) => t.prescriptionId.equals(prescriptionId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.createdAt),
      ]);
    return query.watch();
  }

  /// Get attachments for a prescription
  Future<List<DoctorPrescriptionAttachment>> getAttachments(
      int prescriptionId) {
    final query = select(doctorPrescriptionAttachments)
      ..where((t) => t.prescriptionId.equals(prescriptionId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.createdAt),
      ]);
    return query.get();
  }

  /// Get attachment by ID
  Future<DoctorPrescriptionAttachment?> getAttachment(int id) {
    return (select(doctorPrescriptionAttachments)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Insert an attachment
  Future<int> insertAttachment(DoctorPrescriptionAttachmentsCompanion entry) {
    return into(doctorPrescriptionAttachments).insert(entry);
  }

  /// Update an attachment
  Future<int> updateAttachment(DoctorPrescriptionAttachmentsCompanion entry) {
    final query = update(doctorPrescriptionAttachments)
      ..where((t) => t.id.equals(entry.id.value));
    return query.write(entry);
  }

  /// Delete an attachment
  Future<int> deleteAttachment(int id) {
    return (delete(doctorPrescriptionAttachments)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  /// Delete all attachments for a prescription
  Future<int> deleteAllAttachments(int prescriptionId) {
    return (delete(doctorPrescriptionAttachments)
          ..where((t) => t.prescriptionId.equals(prescriptionId)))
        .go();
  }

/// Update attachment sort order
  Future<void> updateAttachmentOrder(List<int> attachmentIds) async {
    for (var i = 0; i < attachmentIds.length; i++) {
      await (update(doctorPrescriptionAttachments)
            ..where((t) => t.id.equals(attachmentIds[i])))
          .write(DoctorPrescriptionAttachmentsCompanion(
        sortOrder: Value(i),
        updatedAt: Value(DateTime.now()),
      ));
    }
  }

  // Medications

  /// Watch medications for a prescription
  Stream<List<DoctorPrescriptionMedication>> watchMedications(
      int prescriptionId) {
    final query = select(doctorPrescriptionMedications)
      ..where((t) => t.prescriptionId.equals(prescriptionId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.createdAt),
      ]);
    return query.watch();
  }

  /// Get medications for a prescription
  Future<List<DoctorPrescriptionMedication>> getMedications(
      int prescriptionId) {
    final query = select(doctorPrescriptionMedications)
      ..where((t) => t.prescriptionId.equals(prescriptionId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.createdAt),
      ]);
    return query.get();
  }

  /// Get medication by ID
  Future<DoctorPrescriptionMedication?> getMedication(int id) {
    return (select(doctorPrescriptionMedications)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Insert a medication
  Future<int> insertMedication(
      DoctorPrescriptionMedicationsCompanion entry) {
    return into(doctorPrescriptionMedications).insert(entry);
  }

  /// Update a medication
  Future<int> updateMedication(DoctorPrescriptionMedicationsCompanion entry) {
    final query = update(doctorPrescriptionMedications)
      ..where((t) => t.id.equals(entry.id.value));
    return query.write(entry);
  }

  /// Delete a medication
  Future<int> deleteMedication(int id) {
    return (delete(doctorPrescriptionMedications)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  /// Delete all medications for a prescription
  Future<int> deleteAllMedications(int prescriptionId) {
    return (delete(doctorPrescriptionMedications)
          ..where((t) => t.prescriptionId.equals(prescriptionId)))
        .go();
  }

  /// Update medication sort order within a prescription
  Future<void> updateMedicationOrder(
      int prescriptionId, List<int> medicationIds) async {
    for (var i = 0; i < medicationIds.length; i++) {
      await (update(doctorPrescriptionMedications)
            ..where((t) =>
                t.id.equals(medicationIds[i]) &
                t.prescriptionId.equals(prescriptionId)))
          .write(DoctorPrescriptionMedicationsCompanion(
        sortOrder: Value(i),
        updatedAt: Value(DateTime.now()),
      ));
    }
  }
}