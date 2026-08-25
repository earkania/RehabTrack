import 'dart:io';

import 'package:rehab_track/domain/entities/lab_analysis.dart';

/// Repository interface for Lab Analyses
abstract class LabAnalysisRepository {
  /// Watch active analyses for a profile
  Stream<List<LabAnalysis>> watchActiveAnalyses(int profileId);

  /// Watch archived analyses for a profile
  Stream<List<LabAnalysis>> watchArchivedAnalyses(int profileId);

  /// Get analysis by ID and profile ID
  Future<LabAnalysis?> getAnalysis(int id, int profileId);

  /// Create a new analysis with optional attachments
  Future<LabAnalysis> createAnalysis(LabAnalysis analysis, List<File> attachmentFiles);

  /// Update an analysis
  Future<LabAnalysis> updateAnalysis(LabAnalysis analysis);

  /// Archive an analysis
  Future<void> archiveAnalysis(int id, int profileId);

  /// Restore an archived analysis
  Future<void> restoreAnalysis(int id, int profileId);

  /// Permanently delete an analysis and its attachments
  Future<void> deleteAnalysis(int id, int profileId);

  /// Search analyses
  Stream<List<LabAnalysis>> searchAnalyses(
    int profileId, {
    bool includeArchived,
    String? query,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Add attachment to an analysis
  Future<LabAnalysisAttachment> addAttachment(
    int analysisId,
    int profileId,
    File file,
    String fileType,
    String displayName,
    String mimeType,
  );

  /// Remove attachment from an analysis
  Future<void> removeAttachment(int attachmentId);

  /// Update attachment metadata
  Future<void> updateAttachment(LabAnalysisAttachment attachment);

  /// One-shot fetch of an analysis' attachments (sort order preserved).
  Future<List<LabAnalysisAttachment>> getAttachments(int analysisId);
}