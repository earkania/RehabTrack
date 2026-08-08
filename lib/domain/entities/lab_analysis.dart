import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart'
    hide LabAnalyse, LabAnalysisAttachment;

/// Lab Analysis domain entity
class LabAnalysis {
  final int? id;
  final int profileId;
  final String title;
  final String category;
  final DateTime analysisDate;
  final DateTime? resultReceivedDate;
  final int? laboratoryContactId;
  final int? orderingDoctorContactId;
  final int? relatedDoctorVisitId;
  final String? notes;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LabAnalysis({
    this.id,
    required this.profileId,
    required this.title,
    required this.category,
    required this.analysisDate,
    this.resultReceivedDate,
    this.laboratoryContactId,
    this.orderingDoctorContactId,
    this.relatedDoctorVisitId,
    this.notes,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  LabAnalysis copyWith({
    int? id,
    int? profileId,
    String? title,
    String? category,
    DateTime? analysisDate,
    DateTime? resultReceivedDate,
    int? laboratoryContactId,
    int? orderingDoctorContactId,
    int? relatedDoctorVisitId,
    String? notes,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LabAnalysis(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      title: title ?? this.title,
      category: category ?? this.category,
      analysisDate: analysisDate ?? this.analysisDate,
      resultReceivedDate: resultReceivedDate ?? this.resultReceivedDate,
      laboratoryContactId: laboratoryContactId ?? this.laboratoryContactId,
      orderingDoctorContactId: orderingDoctorContactId ?? this.orderingDoctorContactId,
      relatedDoctorVisitId: relatedDoctorVisitId ?? this.relatedDoctorVisitId,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert from database model
  static LabAnalysis fromDb(
    dynamic dbModel, {
    int? laboratoryContactId,
    int? orderingDoctorContactId,
    int? relatedDoctorVisitId,
  }) {
    return LabAnalysis(
      id: dbModel.id,
      profileId: dbModel.profileId,
      title: dbModel.title,
      category: dbModel.category,
      analysisDate: dbModel.analysisDate,
      resultReceivedDate: dbModel.resultReceivedDate,
      laboratoryContactId: laboratoryContactId ?? dbModel.laboratoryContactId,
      orderingDoctorContactId: orderingDoctorContactId ?? dbModel.orderingDoctorContactId,
      relatedDoctorVisitId: relatedDoctorVisitId ?? dbModel.relatedDoctorVisitId,
      notes: dbModel.notes,
      isArchived: dbModel.isArchived,
      createdAt: dbModel.createdAt,
      updatedAt: dbModel.updatedAt,
    );
  }

  /// Convert to database companion for insertion
  LabAnalysesCompanion toCompanion({bool includeId = false}) {
    return LabAnalysesCompanion(
      id: includeId && id != null ? Value(id!) : const Value.absent(),
      profileId: Value(profileId),
      title: Value(title),
      category: Value(category),
      analysisDate: Value(analysisDate),
      resultReceivedDate: Value(resultReceivedDate),
      laboratoryContactId: Value(laboratoryContactId),
      orderingDoctorContactId: Value(orderingDoctorContactId),
      relatedDoctorVisitId: Value(relatedDoctorVisitId),
      notes: Value(notes),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  /// Convert to database companion for update
  LabAnalysesCompanion toUpdateCompanion() {
    return LabAnalysesCompanion(
      id: Value(id!),
      profileId: Value(profileId),
      title: Value(title),
      category: Value(category),
      analysisDate: Value(analysisDate),
      resultReceivedDate: Value(resultReceivedDate),
      laboratoryContactId: Value(laboratoryContactId),
      orderingDoctorContactId: Value(orderingDoctorContactId),
      relatedDoctorVisitId: Value(relatedDoctorVisitId),
      notes: Value(notes),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(DateTime.now()),
    );
  }
}

/// Lab Analysis Attachment domain entity
class LabAnalysisAttachment {
  final int? id;
  final int analysisId;
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

  const LabAnalysisAttachment({
    this.id,
    required this.analysisId,
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

  LabAnalysisAttachment copyWith({
    int? id,
    int? analysisId,
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
    return LabAnalysisAttachment(
      id: id ?? this.id,
      analysisId: analysisId ?? this.analysisId,
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
  static LabAnalysisAttachment fromDb(dynamic dbModel) {
    return LabAnalysisAttachment(
      id: dbModel.id,
      analysisId: dbModel.analysisId,
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
  LabAnalysisAttachmentsCompanion toCompanion({bool includeId = false}) {
    return LabAnalysisAttachmentsCompanion(
      id: includeId && id != null ? Value(id!) : const Value.absent(),
      analysisId: Value(analysisId),
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
  LabAnalysisAttachmentsCompanion toUpdateCompanion() {
    return LabAnalysisAttachmentsCompanion(
      id: Value(id!),
      displayName: Value(displayName),
      sortOrder: Value(sortOrder),
      updatedAt: Value(DateTime.now()),
    );
  }
}