import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/database/tables/lab_analysis_tables.dart';

part 'lab_analysis_dao.g.dart';

@DriftAccessor(tables: [LabAnalyses, LabAnalysisAttachments])
class LabAnalysisDao extends DatabaseAccessor<AppDatabase>
    with _$LabAnalysisDaoMixin {
  LabAnalysisDao(super.db);

  /// Watch all active analyses for a profile
  Stream<List<LabAnalyse>> watchActiveAnalyses(int profileId) {
    final query = select(labAnalyses)
      ..where((t) => t.profileId.equals(profileId) & t.isArchived.equals(false))
      ..orderBy([
        (t) => OrderingTerm.desc(t.analysisDate),
        (t) => OrderingTerm.desc(t.createdAt),
      ]);
    return query.watch();
  }

  /// Watch all archived analyses for a profile
  Stream<List<LabAnalyse>> watchArchivedAnalyses(int profileId) {
    final query = select(labAnalyses)
      ..where((t) => t.profileId.equals(profileId) & t.isArchived.equals(true))
      ..orderBy([
        (t) => OrderingTerm.desc(t.analysisDate),
        (t) => OrderingTerm.desc(t.createdAt),
      ]);
    return query.watch();
  }

  /// Get analysis by ID and profile ID
  Future<LabAnalyse?> getAnalysis(int id, int profileId) {
    return (select(labAnalyses)
          ..where((t) => t.id.equals(id) & t.profileId.equals(profileId)))
        .getSingleOrNull();
  }

  /// Watch analysis by ID
  Stream<LabAnalyse?> watchAnalysis(int id, int profileId) {
    return (select(labAnalyses)
          ..where((t) => t.id.equals(id) & t.profileId.equals(profileId)))
        .watchSingleOrNull();
  }

  /// Insert a new analysis
  Future<int> insertAnalysis(LabAnalysesCompanion entry) {
    return into(labAnalyses).insert(entry);
  }

  /// Update an existing analysis
  Future<bool> updateAnalysis(LabAnalysesCompanion entry) {
    return update(labAnalyses).replace(entry);
  }

  /// Archive or restore an analysis
  Future<int> setArchived(int id, int profileId, bool archived) {
    return (update(labAnalyses)
          ..where((t) => t.id.equals(id) & t.profileId.equals(profileId)))
        .write(LabAnalysesCompanion(
          isArchived: Value(archived),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Permanently delete an analysis (attachments handled separately)
  Future<int> deleteAnalysis(int id, int profileId) {
    return (delete(labAnalyses)
          ..where((t) => t.id.equals(id) & t.profileId.equals(profileId)))
        .go();
  }

  /// Search analyses by title, notes, category, etc.
  Stream<List<LabAnalyse>> searchAnalyses(
    int profileId, {
    bool includeArchived = false,
    String? query,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var statement = select(labAnalyses)
      ..where((t) => t.profileId.equals(profileId));

    if (!includeArchived) {
      statement.where((t) => t.isArchived.equals(false));
    }

    if (query != null && query.isNotEmpty) {
      final searchTerm = '%$query%';
      statement.where((t) =>
          t.title.like(searchTerm) |
          t.notes.like(searchTerm));
    }

    if (category != null && category.isNotEmpty) {
      statement.where((t) => t.category.equals(category));
    }

    if (startDate != null) {
      statement.where((t) => t.analysisDate.isBiggerOrEqualValue(startDate));
    }

    if (endDate != null) {
      statement.where((t) => t.analysisDate.isSmallerOrEqualValue(endDate));
    }

    statement.orderBy([
      (t) => OrderingTerm.desc(t.analysisDate),
      (t) => OrderingTerm.desc(t.createdAt),
    ]);

    return statement.watch();
  }

  // Attachments

  /// Watch attachments for an analysis
  Stream<List<LabAnalysisAttachment>> watchAttachments(int analysisId) {
    final query = select(labAnalysisAttachments)
      ..where((t) => t.analysisId.equals(analysisId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.createdAt),
      ]);
    return query.watch();
  }

  /// Get attachments for an analysis
  Future<List<LabAnalysisAttachment>> getAttachments(int analysisId) {
    final query = select(labAnalysisAttachments)
      ..where((t) => t.analysisId.equals(analysisId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.createdAt),
      ]);
    return query.get();
  }

  /// Get attachment by ID
  Future<LabAnalysisAttachment?> getAttachment(int id) {
    return (select(labAnalysisAttachments)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Insert an attachment
  Future<int> insertAttachment(LabAnalysisAttachmentsCompanion entry) {
    return into(labAnalysisAttachments).insert(entry);
  }

  /// Update an attachment
  Future<bool> updateAttachment(LabAnalysisAttachmentsCompanion entry) {
    return update(labAnalysisAttachments).replace(entry);
  }

  /// Delete an attachment
  Future<int> deleteAttachment(int id) {
    return (delete(labAnalysisAttachments)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  /// Delete all attachments for an analysis
  Future<int> deleteAllAttachments(int analysisId) {
    return (delete(labAnalysisAttachments)
          ..where((t) => t.analysisId.equals(analysisId)))
        .go();
  }

  /// Update attachment sort order
  Future<void> updateAttachmentOrder(List<int> attachmentIds) async {
    for (var i = 0; i < attachmentIds.length; i++) {
      await (update(labAnalysisAttachments)
            ..where((t) => t.id.equals(attachmentIds[i])))
        .write(LabAnalysisAttachmentsCompanion(
          sortOrder: Value(i),
          updatedAt: Value(DateTime.now()),
        ));
    }
  }
}