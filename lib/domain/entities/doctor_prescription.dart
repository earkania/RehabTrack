import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart'
    hide DoctorPrescription, DoctorPrescriptionAttachment, DoctorPrescriptionMedication;

/// Doctor Prescription domain entity
class DoctorPrescription {
  final int? id;
  final int profileId;
  final String title;
  final DateTime prescriptionDate;
  final int? doctorContactId;
  final int? clinicContactId;
  final int? relatedDoctorVisitId;
  final String? reason;
  final String? notes;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DoctorPrescription({
    this.id,
    required this.profileId,
    required this.title,
    required this.prescriptionDate,
    this.doctorContactId,
    this.clinicContactId,
    this.relatedDoctorVisitId,
    this.reason,
    this.notes,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  DoctorPrescription copyWith({
    int? id,
    int? profileId,
    String? title,
    DateTime? prescriptionDate,
    int? doctorContactId,
    int? clinicContactId,
    int? relatedDoctorVisitId,
    String? reason,
    String? notes,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DoctorPrescription(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      title: title ?? this.title,
      prescriptionDate: prescriptionDate ?? this.prescriptionDate,
      doctorContactId: doctorContactId ?? this.doctorContactId,
      clinicContactId: clinicContactId ?? this.clinicContactId,
      relatedDoctorVisitId: relatedDoctorVisitId ?? this.relatedDoctorVisitId,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert from database model
  static DoctorPrescription fromDb(
    dynamic dbModel, {
    int? doctorContactId,
    int? clinicContactId,
    int? relatedDoctorVisitId,
  }) {
    return DoctorPrescription(
      id: dbModel.id,
      profileId: dbModel.profileId,
      title: dbModel.title,
      prescriptionDate: dbModel.prescriptionDate,
      doctorContactId: doctorContactId ?? dbModel.doctorContactId,
      clinicContactId: clinicContactId ?? dbModel.clinicContactId,
      relatedDoctorVisitId:
          relatedDoctorVisitId ?? dbModel.relatedDoctorVisitId,
      reason: dbModel.reason,
      notes: dbModel.notes,
      isArchived: dbModel.isArchived,
      createdAt: dbModel.createdAt,
      updatedAt: dbModel.updatedAt,
    );
  }

  /// Convert to database companion for insertion
  DoctorPrescriptionsCompanion toCompanion({bool includeId = false}) {
    return DoctorPrescriptionsCompanion(
      id: includeId && id != null ? Value(id!) : const Value.absent(),
      profileId: Value(profileId),
      title: Value(title),
      prescriptionDate: Value(prescriptionDate),
      doctorContactId: Value(doctorContactId),
      clinicContactId: Value(clinicContactId),
      relatedDoctorVisitId: Value(relatedDoctorVisitId),
      reason: Value(reason),
      notes: Value(notes),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  /// Convert to database companion for update
  DoctorPrescriptionsCompanion toUpdateCompanion() {
    return DoctorPrescriptionsCompanion(
      id: Value(id!),
      profileId: Value(profileId),
      title: Value(title),
      prescriptionDate: Value(prescriptionDate),
      doctorContactId: Value(doctorContactId),
      clinicContactId: Value(clinicContactId),
      relatedDoctorVisitId: Value(relatedDoctorVisitId),
      reason: Value(reason),
      notes: Value(notes),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(DateTime.now()),
    );
  }
}

/// Doctor Prescription Attachment domain entity
class DoctorPrescriptionAttachment {
  final int? id;
  final int prescriptionId;
  final int profileId;
  final String fileType; // pdf, image, other
  final String managedRelativePath;
  final String originalFileName;
  final String displayName;
  final String mimeType;
  final int? fileSize;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DoctorPrescriptionAttachment({
    this.id,
    required this.prescriptionId,
    required this.profileId,
    required this.fileType,
    required this.managedRelativePath,
    required this.originalFileName,
    required this.displayName,
    required this.mimeType,
    this.fileSize,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  DoctorPrescriptionAttachment copyWith({
    int? id,
    int? prescriptionId,
    int? profileId,
    String? fileType,
    String? managedRelativePath,
    String? originalFileName,
    String? displayName,
    String? mimeType,
    int? fileSize,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DoctorPrescriptionAttachment(
      id: id ?? this.id,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      profileId: profileId ?? this.profileId,
      fileType: fileType ?? this.fileType,
      managedRelativePath: managedRelativePath ?? this.managedRelativePath,
      originalFileName: originalFileName ?? this.originalFileName,
      displayName: displayName ?? this.displayName,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert from database model
  static DoctorPrescriptionAttachment fromDb(dynamic dbModel) {
    return DoctorPrescriptionAttachment(
      id: dbModel.id,
      prescriptionId: dbModel.prescriptionId,
      profileId: dbModel.profileId,
      fileType: dbModel.fileType,
      managedRelativePath: dbModel.managedRelativePath,
      originalFileName: dbModel.originalFileName,
      displayName: dbModel.displayName,
      mimeType: dbModel.mimeType,
      fileSize: dbModel.fileSize,
      sortOrder: dbModel.sortOrder,
      createdAt: dbModel.createdAt,
      updatedAt: dbModel.updatedAt,
    );
  }

  /// Convert to database companion for insertion
  DoctorPrescriptionAttachmentsCompanion toCompanion({
    bool includeId = false,
  }) {
    return DoctorPrescriptionAttachmentsCompanion(
      id: includeId && id != null ? Value(id!) : const Value.absent(),
      prescriptionId: Value(prescriptionId),
      profileId: Value(profileId),
      fileType: Value(fileType),
      managedRelativePath: Value(managedRelativePath),
      originalFileName: Value(originalFileName),
      displayName: Value(displayName),
      mimeType: Value(mimeType),
      fileSize: Value(fileSize),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  /// Convert to database companion for update
  DoctorPrescriptionAttachmentsCompanion toUpdateCompanion() {
    return DoctorPrescriptionAttachmentsCompanion(
      id: Value(id!),
      displayName: Value(displayName),
      sortOrder: Value(sortOrder),
      updatedAt: Value(DateTime.now()),
    );
  }
}

/// Structured medication belonging to a Doctor Prescription.
///
/// Intentionally not linked to the active [Medication] domain/module: values are
/// free-searchable text captured inline on the prescription.
class DoctorPrescriptionMedication {
  final int? id;
  final int prescriptionId;
  final int profileId;
  final String medicationName;
  final String? doseAmount;
  final String? doseUnit;
  final String? instructions;
  final String? frequency;
  final String? timing;
  final String? duration;
  final String? notes;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DoctorPrescriptionMedication({
    this.id,
    required this.prescriptionId,
    required this.profileId,
    required this.medicationName,
    this.doseAmount,
    this.doseUnit,
    this.instructions,
    this.frequency,
    this.timing,
    this.duration,
    this.notes,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  DoctorPrescriptionMedication copyWith({
    int? id,
    int? prescriptionId,
    int? profileId,
    String? medicationName,
    String? doseAmount,
    String? doseUnit,
    String? instructions,
    String? frequency,
    String? timing,
    String? duration,
    String? notes,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DoctorPrescriptionMedication(
      id: id ?? this.id,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      profileId: profileId ?? this.profileId,
      medicationName: medicationName ?? this.medicationName,
      doseAmount: doseAmount ?? this.doseAmount,
      doseUnit: doseUnit ?? this.doseUnit,
      instructions: instructions ?? this.instructions,
      frequency: frequency ?? this.frequency,
      timing: timing ?? this.timing,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert from database model
  static DoctorPrescriptionMedication fromDb(dynamic dbModel) {
    return DoctorPrescriptionMedication(
      id: dbModel.id,
      prescriptionId: dbModel.prescriptionId,
      profileId: dbModel.profileId,
      medicationName: dbModel.medicationName,
      doseAmount: dbModel.doseAmount,
      doseUnit: dbModel.doseUnit,
      instructions: dbModel.instructions,
      frequency: dbModel.frequency,
      timing: dbModel.timing,
      duration: dbModel.duration,
      notes: dbModel.notes,
      sortOrder: dbModel.sortOrder,
      createdAt: dbModel.createdAt,
      updatedAt: dbModel.updatedAt,
    );
  }

  /// Convert to database companion for insertion
  DoctorPrescriptionMedicationsCompanion toCompanion({
    bool includeId = false,
  }) {
    return DoctorPrescriptionMedicationsCompanion(
      id: includeId && id != null ? Value(id!) : const Value.absent(),
      prescriptionId: Value(prescriptionId),
      profileId: Value(profileId),
      medicationName: Value(medicationName),
      doseAmount: Value(doseAmount),
      doseUnit: Value(doseUnit),
      instructions: Value(instructions),
      frequency: Value(frequency),
      timing: Value(timing),
      duration: Value(duration),
      notes: Value(notes),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  /// Convert to database companion for update
  DoctorPrescriptionMedicationsCompanion toUpdateCompanion() {
    return DoctorPrescriptionMedicationsCompanion(
      id: Value(id!),
      prescriptionId: Value(prescriptionId),
      profileId: Value(profileId),
      medicationName: Value(medicationName),
      doseAmount: Value(doseAmount),
      doseUnit: Value(doseUnit),
      instructions: Value(instructions),
      frequency: Value(frequency),
      timing: Value(timing),
      duration: Value(duration),
      notes: Value(notes),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(DateTime.now()),
    );
  }
}