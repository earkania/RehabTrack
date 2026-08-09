import 'dart:io';

import 'package:rehab_track/domain/entities/doctor_prescription.dart';

/// Repository interface for Doctor Prescriptions
abstract class DoctorPrescriptionRepository {
  /// Watch active prescriptions for a profile
  Stream<List<DoctorPrescription>> watchActivePrescriptions(int profileId);

  /// Watch archived prescriptions for a profile
  Stream<List<DoctorPrescription>> watchArchivedPrescriptions(int profileId);

  /// Get prescription by ID and profile ID
  Future<DoctorPrescription?> getPrescription(int id, int profileId);

  /// Get a prescription together with its structured medications
  Future<DoctorPrescriptionWithMedications?> getPrescriptionWithMedications(
    int id,
    int profileId,
  );

  /// Create a new prescription with optional attachments and medications
  Future<DoctorPrescription> createPrescription(
    DoctorPrescription prescription,
    List<File> attachmentFiles, {
    List<DoctorPrescriptionMedication> medications = const [],
  });

  /// Update a prescription, optionally persisting its medications
  Future<DoctorPrescription> updatePrescription(
    DoctorPrescription prescription, {
    List<DoctorPrescriptionMedication> medications = const [],
  });

  /// Archive a prescription
  Future<void> archivePrescription(int id, int profileId);

  /// Restore an archived prescription
  Future<void> restorePrescription(int id, int profileId);

  /// Permanently delete a prescription and its attachments
  Future<void> deletePrescription(int id, int profileId);

  /// Search prescriptions
  Stream<List<DoctorPrescription>> searchPrescriptions(
    int profileId, {
    bool includeArchived,
    String? query,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Add attachment to a prescription
  Future<DoctorPrescriptionAttachment> addAttachment(
    int prescriptionId,
    int profileId,
    File file,
    String fileType,
    String displayName,
    String mimeType,
  );

  /// Remove attachment from a prescription
  Future<void> removeAttachment(int attachmentId);

  /// Update attachment metadata
  Future<void> updateAttachment(DoctorPrescriptionAttachment attachment);

  /// Watch medications for a prescription
  Stream<List<DoctorPrescriptionMedication>> watchMedications(
      int prescriptionId);

  /// Get medications for a prescription
  Future<List<DoctorPrescriptionMedication>> getMedications(
      int prescriptionId);

  /// Add a medication to a prescription
  Future<DoctorPrescriptionMedication> addMedication(
    int prescriptionId,
    DoctorPrescriptionMedication medication,
  );

  /// Update a medication
  Future<DoctorPrescriptionMedication> updateMedication(
    DoctorPrescriptionMedication medication,
  );

  /// Remove a medication from a prescription
  Future<void> removeMedication(int medicationId);

  /// Reorder medications within a prescription
  Future<void> reorderMedications(int prescriptionId, List<int> medicationIds);
}

/// A doctor prescription bundled with its structured medications.
class DoctorPrescriptionWithMedications {
  final DoctorPrescription prescription;
  final List<DoctorPrescriptionMedication> medications;

  const DoctorPrescriptionWithMedications({
    required this.prescription,
    required this.medications,
  });
}