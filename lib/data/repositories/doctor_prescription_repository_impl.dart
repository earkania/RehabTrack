import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:rehab_track/data/database/app_database.dart'
    hide DoctorPrescription, DoctorPrescriptionAttachment, DoctorPrescriptionMedication;
import 'package:rehab_track/data/database/daos/doctor_prescription_dao.dart';
import 'package:rehab_track/domain/entities/doctor_prescription.dart';
import 'package:rehab_track/domain/repositories/doctor_prescription_repository.dart';

/// Drift implementation of [DoctorPrescriptionRepository]
class DoctorPrescriptionRepositoryImpl implements DoctorPrescriptionRepository {
  final AppDatabase _database;
  final Uuid _uuid = const Uuid();

  DoctorPrescriptionRepositoryImpl(this._database);

  DoctorPrescriptionDao get _dao => _database.doctorPrescriptionDao;

  @override
  Stream<List<DoctorPrescription>> watchActivePrescriptions(int profileId) {
    return _dao.watchActivePrescriptions(profileId).map(
      (list) => list
          .map((r) => DoctorPrescription.fromDb(
                r,
                doctorContactId: r.doctorContactId,
                clinicContactId: r.clinicContactId,
                relatedDoctorVisitId: r.relatedDoctorVisitId,
              ))
          .toList(),
    );
  }

  @override
  Stream<List<DoctorPrescription>> watchArchivedPrescriptions(int profileId) {
    return _dao.watchArchivedPrescriptions(profileId).map(
      (list) => list
          .map((r) => DoctorPrescription.fromDb(
                r,
                doctorContactId: r.doctorContactId,
                clinicContactId: r.clinicContactId,
                relatedDoctorVisitId: r.relatedDoctorVisitId,
              ))
          .toList(),
    );
  }

  @override
  Future<DoctorPrescription?> getPrescription(int id, int profileId) {
    return _dao.getPrescription(id, profileId).then((dbModel) {
      if (dbModel == null) return null;
      return DoctorPrescription.fromDb(
        dbModel,
        doctorContactId: dbModel.doctorContactId,
        clinicContactId: dbModel.clinicContactId,
        relatedDoctorVisitId: dbModel.relatedDoctorVisitId,
      );
    });
  }

  @override
  Future<DoctorPrescriptionWithMedications?> getPrescriptionWithMedications(
    int id,
    int profileId,
  ) async {
    final prescription = await getPrescription(id, profileId);
    if (prescription == null) return null;
    final medications = await _dao.getMedications(id);
    return DoctorPrescriptionWithMedications(
      prescription: prescription,
      medications: medications
          .map(DoctorPrescriptionMedication.fromDb)
          .toList(),
    );
  }

  @override
  Future<DoctorPrescription> createPrescription(
    DoctorPrescription prescription,
    List<File> attachmentFiles, {
    List<DoctorPrescriptionMedication> medications = const [],
  }) async {
    return _database.transaction(() async {
      // Insert the prescription
      final id = await _dao.insertPrescription(prescription.toCompanion());

      // Handle attachments
      if (attachmentFiles.isNotEmpty) {
        final attachmentsDir =
            await _getAttachmentsDir(prescription.profileId, id);
        for (var i = 0; i < attachmentFiles.length; i++) {
          final file = attachmentFiles[i];
          final fileType = _getFileType(file);
          final mimeType = _getMimeType(file);
          final originalName = p.basename(file.path);
          final displayName = _generateDisplayName(originalName, fileType);
          final ext = p.extension(originalName);
          final safeName = '${_uuid.v4()}$ext';
          final relativePath =
              'doctor_prescriptions/${prescription.profileId}/$id/$safeName';
          final destPath = p.join(attachmentsDir.path, safeName);

          // Copy file to managed storage
          await file.copy(destPath);

          // Get file size
          final fileSize = await file.length();

          // Insert attachment record
          await _dao.insertAttachment(
            DoctorPrescriptionAttachmentsCompanion(
              prescriptionId: Value(id),
              profileId: Value(prescription.profileId),
              fileType: Value(_getFileTypeCategory(fileType)),
              managedRelativePath: Value(relativePath),
              originalFileName: Value(originalName),
              displayName: Value(displayName),
              mimeType: Value(mimeType),
              fileSize: Value(fileSize),
              sortOrder: Value(attachmentFiles.indexOf(file)),
              createdAt: Value(DateTime.now()),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      }

      // Handle medications
      await _saveMedicationsForPrescription(id, prescription.profileId,
          medications);

      // Return the created prescription
      final created = await getPrescription(id, prescription.profileId);
      return created!;
    });
  }

  @override
  Future<DoctorPrescription> updatePrescription(
    DoctorPrescription prescription, {
    List<DoctorPrescriptionMedication> medications = const [],
  }) async {
    return _database.transaction(() async {
      await _dao.updatePrescription(prescription.toUpdateCompanion());
      await _saveMedicationsForPrescription(
          prescription.id!, prescription.profileId, medications);
      final updated = await getPrescription(prescription.id!, prescription.profileId);
      return updated!;
    });
  }

  /// Replaces the full medication list of a prescription with the provided
  /// set, preserving existing rows when the incoming entity carries an ID.
  Future<void> _saveMedicationsForPrescription(
    int prescriptionId,
    int profileId,
    List<DoctorPrescriptionMedication> medications,
  ) async {
    final existing = await _dao.getMedications(prescriptionId);
    final existingIds = existing.map((m) => m.id).toSet();
    final incomingIds =
        medications.where((m) => m.id != null).map((m) => m.id!).toSet();

    // Delete removed rows
    for (final id in existingIds) {
      if (!incomingIds.contains(id)) {
        await _dao.deleteMedication(id);
      }
    }

    final now = DateTime.now();
    var sortOrder = 0;
    for (final medication in medications) {
      if (medication.id != null && existingIds.contains(medication.id)) {
        await _dao.updateMedication(
          medication.copyWith(sortOrder: sortOrder).toUpdateCompanion(),
        );
      } else {
        await _dao.insertMedication(
          medication
              .copyWith(
                prescriptionId: prescriptionId,
                profileId: profileId,
                sortOrder: sortOrder,
                createdAt: now,
                updatedAt: now,
              )
              .toCompanion(),
        );
      }
      sortOrder++;
    }
  }

  @override
  Future<void> archivePrescription(int id, int profileId) async {
    await _dao.setArchived(id, profileId, true);
  }

  @override
  Future<void> restorePrescription(int id, int profileId) async {
    await _dao.setArchived(id, profileId, false);
  }

  @override
  Future<void> deletePrescription(int id, int profileId) async {
    // Get attachments first to delete files
    final attachments = await _dao.getAttachments(id);
    for (final attachment in attachments) {
      await _deleteManagedFile(attachment.managedRelativePath);
    }
    await _dao.deleteAllAttachments(id);
    await _dao.deleteAllMedications(id);
    await _dao.deletePrescription(id, profileId);
  }

  @override
  Stream<List<DoctorPrescription>> searchPrescriptions(
    int profileId, {
    bool includeArchived = false,
    String? query,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _dao.searchPrescriptions(
      profileId,
      includeArchived: includeArchived,
      query: query,
      startDate: startDate,
      endDate: endDate,
    ).map(
      (list) => list
          .map((r) => DoctorPrescription.fromDb(
                r,
                doctorContactId: r.doctorContactId,
                clinicContactId: r.clinicContactId,
                relatedDoctorVisitId: r.relatedDoctorVisitId,
              ))
          .toList(),
    );
  }

  @override
  Future<DoctorPrescriptionAttachment> addAttachment(
    int prescriptionId,
    int profileId,
    File file,
    String fileType,
    String displayName,
    String mimeType,
  ) async {
    final prescription = await getPrescription(prescriptionId, profileId);
    if (prescription == null) {
      throw ArgumentError('Prescription not found');
    }

    final attachmentsDir = await _getAttachmentsDir(profileId, prescriptionId);
    final originalName = p.basename(file.path);
    final ext = p.extension(originalName);
    final safeName = '${const Uuid().v4()}$ext';
    final relativePath = 'doctor_prescriptions/$profileId/$prescriptionId/$safeName';
    final destPath = p.join(attachmentsDir.path, safeName);

    // Copy file to managed storage
    await file.copy(destPath);

    // Get file size
    final fileSize = await file.length();

    // Determine sort order
    final existingAttachments = await _dao.getAttachments(prescriptionId);

    // Insert attachment record
    final id = await _dao.insertAttachment(
      DoctorPrescriptionAttachmentsCompanion(
        prescriptionId: Value(prescriptionId),
        profileId: Value(profileId),
        fileType: Value(fileType),
        managedRelativePath: Value(relativePath),
        originalFileName: Value(p.basename(file.path)),
        displayName: Value(displayName),
        mimeType: Value(mimeType),
        fileSize: Value(fileSize),
        sortOrder: Value(existingAttachments.length),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );

    return DoctorPrescriptionAttachment(
      id: id,
      prescriptionId: prescriptionId,
      profileId: profileId,
      fileType: _getFileTypeCategory(_getFileType(file)),
      managedRelativePath: relativePath,
      originalFileName: p.basename(file.path),
      displayName: displayName,
      mimeType: mimeType,
      fileSize: fileSize,
      sortOrder: existingAttachments.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> removeAttachment(int attachmentId) async {
    final attachment = await _dao.getAttachment(attachmentId);
    if (attachment != null) {
      await _deleteManagedFile(attachment.managedRelativePath);
      await _dao.deleteAttachment(attachmentId);
    }
  }

  @override
  Future<void> updateAttachment(
    DoctorPrescriptionAttachment attachment,
  ) async {
    await _dao.updateAttachment(attachment.toUpdateCompanion());
  }

  @override
  Future<List<DoctorPrescriptionAttachment>> getAttachments(
      int prescriptionId) async {
    final rows = await _dao.getAttachments(prescriptionId);
    return rows.map(DoctorPrescriptionAttachment.fromDb).toList();
  }

  @override
  Stream<List<DoctorPrescriptionMedication>> watchMedications(
      int prescriptionId) {
    return _dao.watchMedications(prescriptionId).map(
      (list) => list.map(DoctorPrescriptionMedication.fromDb).toList(),
    );
  }

  @override
  Future<List<DoctorPrescriptionMedication>> getMedications(
      int prescriptionId) async {
    final rows = await _dao.getMedications(prescriptionId);
    return rows.map(DoctorPrescriptionMedication.fromDb).toList();
  }

  @override
  Future<DoctorPrescriptionMedication> addMedication(
    int prescriptionId,
    DoctorPrescriptionMedication medication,
  ) async {
    final prescription = await getPrescription(medication.prescriptionId,
        medication.profileId);
    if (prescription == null) {
      throw ArgumentError('Prescription not found');
    }
    final existing = await _dao.getMedications(prescriptionId);
    final now = DateTime.now();
    final id = await _dao.insertMedication(
      medication
          .copyWith(
            prescriptionId: prescriptionId,
            sortOrder: existing.length,
            createdAt: now,
            updatedAt: now,
          )
          .toCompanion(),
    );
    final saved = await _dao.getMedication(id);
    return DoctorPrescriptionMedication.fromDb(saved!);
  }

  @override
  Future<DoctorPrescriptionMedication> updateMedication(
    DoctorPrescriptionMedication medication,
  ) async {
    await _dao.updateMedication(medication.toUpdateCompanion());
    final saved = await _dao.getMedication(medication.id!);
    return DoctorPrescriptionMedication.fromDb(saved!);
  }

  @override
  Future<void> removeMedication(int medicationId) async {
    await _dao.deleteMedication(medicationId);
  }

  @override
  Future<void> reorderMedications(
      int prescriptionId, List<int> medicationIds) async {
    await _database.transaction(() async {
      await _dao.updateMedicationOrder(prescriptionId, medicationIds);
    });
  }

  // Helper methods

  Future<Directory> _getAttachmentsDir(int profileId, int prescriptionId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(
      p.join(
        appDir.path,
        'doctor_prescriptions',
        profileId.toString(),
        prescriptionId.toString(),
      ),
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> _deleteManagedFile(String relativePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(appDir.path, relativePath));
    if (await file.exists()) {
      await file.delete();
    }
  }

  String _getFileType(File file) {
    final ext = p.extension(file.path).toLowerCase();
    if (ext == '.pdf') return 'pdf';
    if (ext == '.jpg' || ext == '.jpeg' || ext == '.png') return 'image';
    return 'other';
  }

  String _getFileTypeCategory(String fileType) {
    switch (fileType) {
      case 'pdf':
        return 'pdf';
      case 'image':
        return 'image';
      default:
        return 'other';
    }
  }

  String _getMimeType(File file) {
    final ext = p.extension(file.path).toLowerCase();
    switch (ext) {
      case '.pdf':
        return 'application/pdf';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  String _getFileTypeCategoryFromPath(String path) {
    final ext = p.extension(path).toLowerCase();
    if (ext == '.pdf') return 'pdf';
    if (ext == '.jpg' || ext == '.jpeg' || ext == '.png') return 'image';
    return 'other';
  }

  String _generateDisplayName(String originalName, String fileType) {
    final nameWithoutExt = p.basenameWithoutExtension(originalName);
    if (nameWithoutExt.isNotEmpty) {
      return nameWithoutExt;
    }
    switch (_getFileTypeCategoryFromPath(originalName)) {
      case 'pdf':
        return 'PDF Document';
      case 'image':
        return 'Image';
      default:
        return 'Attachment';
    }
  }
}