import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:rehab_track/data/database/app_database.dart'
    hide LabAnalysisAttachment, LabAnalyse;
import 'package:rehab_track/data/database/daos/lab_analysis_dao.dart';
import 'package:rehab_track/domain/entities/lab_analysis.dart';
import 'package:rehab_track/domain/repositories/lab_analysis_repository.dart';

/// Drift implementation of [LabAnalysisRepository]
class LabAnalysisRepositoryImpl implements LabAnalysisRepository {
  final AppDatabase _database;
  final Uuid _uuid = const Uuid();

  LabAnalysisRepositoryImpl(this._database);

  LabAnalysisDao get _dao => _database.labAnalysisDao;

  @override
  Stream<List<LabAnalysis>> watchActiveAnalyses(int profileId) {
    return _dao.watchActiveAnalyses(profileId).map(
      (list) => list
          .map((a) => LabAnalysis.fromDb(
                a,
                laboratoryContactId: a.laboratoryContactId,
                orderingDoctorContactId: a.orderingDoctorContactId,
                relatedDoctorVisitId: a.relatedDoctorVisitId,
              ))
          .toList(),
    );
  }

  @override
  Stream<List<LabAnalysis>> watchArchivedAnalyses(int profileId) {
    return _dao.watchArchivedAnalyses(profileId).map(
      (list) => list
          .map((a) => LabAnalysis.fromDb(
                a,
                laboratoryContactId: a.laboratoryContactId,
                orderingDoctorContactId: a.orderingDoctorContactId,
                relatedDoctorVisitId: a.relatedDoctorVisitId,
              ))
          .toList(),
    );
  }

  @override
  Future<LabAnalysis?> getAnalysis(int id, int profileId) {
    return _dao.getAnalysis(id, profileId).then((dbModel) {
      if (dbModel == null) return null;
      return LabAnalysis.fromDb(
        dbModel,
        laboratoryContactId: dbModel.laboratoryContactId,
        orderingDoctorContactId: dbModel.orderingDoctorContactId,
        relatedDoctorVisitId: dbModel.relatedDoctorVisitId,
      );
    });
  }

  @override
  Future<LabAnalysis> createAnalysis(
    LabAnalysis analysis,
    List<File> attachmentFiles,
  ) async {
    return _database.transaction(() async {
      // Insert the analysis
      final id = await _dao.insertAnalysis(analysis.toCompanion());

      // Handle attachments
      if (attachmentFiles.isNotEmpty) {
        final attachmentsDir = await _getAttachmentsDir(analysis.profileId, id);
        for (var i = 0; i < attachmentFiles.length; i++) {
          final file = attachmentFiles[i];
          final fileType = _getFileType(file);
          final mimeType = _getMimeType(file);
          final originalName = p.basename(file.path);
          final displayName = _generateDisplayName(originalName, fileType);
          final ext = p.extension(originalName);
          final safeName = '${_uuid.v4()}$ext';
          final relativePath = 'lab_analyses/${analysis.profileId}/$id/$safeName';
          final destPath = p.join(attachmentsDir.path, safeName);

          // Copy file to managed storage
          await file.copy(destPath);

          // Get file size
          final fileSize = await file.length();

          // Insert attachment record
          await _dao.insertAttachment(
            LabAnalysisAttachmentsCompanion(
              analysisId: Value(id),
              profileId: Value(analysis.profileId),
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

      // Return the created analysis
      final created = await getAnalysis(id, analysis.profileId);
      return created!;
    });
  }

  @override
  Future<LabAnalysis> updateAnalysis(LabAnalysis analysis) async {
    return _database.transaction(() async {
      await _dao.updateAnalysis(analysis.toUpdateCompanion());
      final updated = await getAnalysis(analysis.id!, analysis.profileId);
      return updated!;
    });
  }

  @override
  Future<void> archiveAnalysis(int id, int profileId) async {
    await _dao.setArchived(id, profileId, true);
  }

  @override
  Future<void> restoreAnalysis(int id, int profileId) async {
    await _dao.setArchived(id, profileId, false);
  }

  @override
  Future<void> deleteAnalysis(int id, int profileId) async {
    // Get attachments first to delete files
    final attachments = await _dao.getAttachments(id);
    for (final attachment in attachments) {
      await _deleteManagedFile(attachment.managedRelativePath);
    }
    await _dao.deleteAllAttachments(id);
    await _dao.deleteAnalysis(id, profileId);
  }

  @override
  Stream<List<LabAnalysis>> searchAnalyses(
    int profileId, {
    bool includeArchived = false,
    String? query,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _dao.searchAnalyses(
      profileId,
      includeArchived: includeArchived,
      query: query,
      category: category,
      startDate: startDate,
      endDate: endDate,
    ).map(
      (list) => list
          .map((a) => LabAnalysis.fromDb(
                a,
                laboratoryContactId: a.laboratoryContactId,
                orderingDoctorContactId: a.orderingDoctorContactId,
                relatedDoctorVisitId: a.relatedDoctorVisitId,
              ))
          .toList(),
    );
  }

  @override
  Future<LabAnalysisAttachment> addAttachment(
    int analysisId,
    int profileId,
    File file,
    String fileType,
    String displayName,
    String mimeType,
  ) async {
    final analysis = await getAnalysis(analysisId, profileId);
    if (analysis == null) {
      throw ArgumentError('Analysis not found');
    }

    final attachmentsDir = await _getAttachmentsDir(profileId, analysisId);
    final originalName = p.basename(file.path);
    final ext = p.extension(originalName);
    final safeName = '${const Uuid().v4()}$ext';
    final relativePath = 'lab_analyses/$profileId/$analysisId/$safeName';
    final destPath = p.join(attachmentsDir.path, safeName);

    // Copy file to managed storage
    await file.copy(destPath);

    // Get file size
    final fileSize = await file.length();

    // Determine sort order
    final existingAttachments = await _dao.getAttachments(analysisId);

    // Insert attachment record
    final id = await _dao.insertAttachment(
      LabAnalysisAttachmentsCompanion(
        analysisId: Value(analysisId),
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

    return LabAnalysisAttachment(
      id: id,
      analysisId: analysisId,
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
  Future<void> updateAttachment(LabAnalysisAttachment attachment) async {
    await _dao.updateAttachment(attachment.toUpdateCompanion());
  }

  // Helper methods

  Future<Directory> _getAttachmentsDir(int profileId, int analysisId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(
      p.join(
        appDir.path,
        'files',
        'lab_analyses',
        profileId.toString(),
        analysisId.toString(),
      ),
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> _deleteManagedFile(String relativePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(appDir.path, 'files', relativePath));
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