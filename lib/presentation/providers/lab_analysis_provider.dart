import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rehab_track/data/database/daos/lab_analysis_dao.dart';
import 'package:rehab_track/data/repositories/lab_analysis_repository_impl.dart';
import 'package:rehab_track/domain/entities/lab_analysis.dart';
import 'package:rehab_track/domain/repositories/lab_analysis_repository.dart';

import 'database_provider.dart';

/// Provider for LabAnalysisDao
final labAnalysisDaoProvider = Provider<LabAnalysisDao>((ref) {
  final database = ref.watch(databaseProvider);
  return database.labAnalysisDao;
});

/// Provider for LabAnalysisRepository
final labAnalysisRepositoryProvider = Provider<LabAnalysisRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return LabAnalysisRepositoryImpl(database);
});

/// Active analyses for the current profile
final activeLabAnalysesProvider = StreamProvider.autoDispose
    .family<List<LabAnalysis>, int>((ref, profileId) {
  final repository = ref.watch(labAnalysisRepositoryProvider);
  return repository.watchActiveAnalyses(profileId);
});

/// Archived analyses for the current profile
final archivedLabAnalysesProvider = StreamProvider.autoDispose
    .family<List<LabAnalysis>, int>((ref, profileId) {
  final repository = ref.watch(labAnalysisRepositoryProvider);
  return repository.watchArchivedAnalyses(profileId);
});

/// Search query for analyses
final labAnalysisSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

/// Category filter for analyses
final labAnalysisCategoryFilterProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);

/// Date range filter for analyses
class _LabAnalysisDateRange {
  const _LabAnalysisDateRange({this.start, this.end});
  final DateTime? start;
  final DateTime? end;
}

final labAnalysisDateRangeProvider =
    StateProvider.autoDispose<_LabAnalysisDateRange>(
  (ref) => const _LabAnalysisDateRange(start: null, end: null),
);

/// Search and filtered analyses for the current profile
final labAnalysesSearchProvider = StreamProvider.autoDispose
    .family<List<LabAnalysis>, int>((ref, profileId) {
  final repository = ref.watch(labAnalysisRepositoryProvider);
  final query = ref.watch(labAnalysisSearchQueryProvider);
  final category = ref.watch(labAnalysisCategoryFilterProvider);
  final dateRange = ref.watch(labAnalysisDateRangeProvider);

  return repository.searchAnalyses(
    profileId,
    query: query.isEmpty ? null : query,
    category: category,
    startDate: dateRange.start,
    endDate: dateRange.end,
  );
});

/// Sort order for analyses
enum LabAnalysisSort {
  newestFirst,
  oldestFirst,
  titleAscending,
}

/// Sort order provider
final labAnalysisSortProvider =
    StateProvider.autoDispose<LabAnalysisSort>((ref) => LabAnalysisSort.newestFirst);

/// Sorted analyses provider
final sortedLabAnalysesProvider =
    StreamProvider.autoDispose.family<List<LabAnalysis>, int>((ref, profileId) {
  final analyses = ref.watch(labAnalysesSearchProvider(profileId));
  final sort = ref.watch(labAnalysisSortProvider);

  return analyses.when(
    data: (list) {
      final sorted = List<LabAnalysis>.from(list);
      switch (sort) {
        case LabAnalysisSort.newestFirst:
          sorted.sort((a, b) => b.analysisDate.compareTo(a.analysisDate));
          break;
        case LabAnalysisSort.oldestFirst:
          sorted.sort((a, b) => a.analysisDate.compareTo(b.analysisDate));
          break;
        case LabAnalysisSort.titleAscending:
          sorted.sort((a, b) => a.title.compareTo(b.title));
          break;
      }
      return Stream.value(sorted);
    },
    loading: () => const Stream.empty(),
    error: (error, stack) => Stream.error(error),
  );
});

/// Single analysis by ID
final labAnalysisByIdProvider =
    FutureProvider.autoDispose.family<LabAnalysis?, ({int id, int profileId})>(
        (ref, params) {
  final repository = ref.watch(labAnalysisRepositoryProvider);
  return repository.getAnalysis(params.id, params.profileId);
});

/// Form controller for add/edit analysis
class LabAnalysisFormController {
  final LabAnalysisRepository _repository;
  final int _profileId;
  final LabAnalysis? _existingAnalysis;

  LabAnalysisFormController(
    this._repository,
    this._profileId,
    this._existingAnalysis,
  );

  Future<LabAnalysis> save({
    required String title,
    required String category,
    required DateTime analysisDate,
    DateTime? resultReceivedDate,
    int? laboratoryContactId,
    int? orderingDoctorContactId,
    int? relatedDoctorVisitId,
    String? notes,
    List<File> attachmentFiles = const [],
    List<LabAnalysisAttachment> existingAttachments = const [],
    List<int> removedAttachmentIds = const [],
  }) async {
    final isEditing = _existingAnalysis != null;

    final analysis = LabAnalysis(
      id: _existingAnalysis?.id,
      profileId: _profileId,
      title: title.trim(),
      category: category,
      analysisDate: analysisDate,
      resultReceivedDate: resultReceivedDate,
      laboratoryContactId: laboratoryContactId,
      orderingDoctorContactId: orderingDoctorContactId,
      relatedDoctorVisitId: relatedDoctorVisitId,
      notes: notes?.trim().isNotEmpty == true ? notes?.trim() : null,
      isArchived: false,
      createdAt: _existingAnalysis?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    for (final attachmentId in removedAttachmentIds) {
      await _repository.removeAttachment(attachmentId);
    }

    if (isEditing) {
      for (final file in attachmentFiles) {
        await _repository.addAttachment(
          analysis.id!,
          _profileId,
          file,
          _fileType(file),
          _displayName(file),
          _mimeType(file),
        );
      }
      return _repository.updateAnalysis(analysis);
    } else {
      return _repository.createAnalysis(analysis, attachmentFiles);
    }
  }

  Future<void> delete() async {
    if (_existingAnalysis != null) {
      await _repository.deleteAnalysis(_existingAnalysis.id!, _profileId);
    }
  }

  Future<void> archive() async {
    if (_existingAnalysis != null) {
      await _repository.archiveAnalysis(_existingAnalysis.id!, _profileId);
    }
  }

  Future<void> restore() async {
    if (_existingAnalysis != null) {
      await _repository.restoreAnalysis(_existingAnalysis.id!, _profileId);
    }
  }

  String _fileType(File file) {
    final path = file.path.toLowerCase();
    if (path.endsWith('.pdf')) {
      return 'pdf';
    }
    if (path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png')) {
      return 'image';
    }
    return 'other';
  }

  String _mimeType(File file) {
    final path = file.path.toLowerCase();
    if (path.endsWith('.pdf')) {
      return 'application/pdf';
    }
    if (path.endsWith('.png')) {
      return 'image/png';
    }
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    return 'application/octet-stream';
  }

  String _displayName(File file) {
    return file.path.split('/').last;
  }
}

final labAnalysisFormControllerProvider =
    Provider.autoDispose.family<LabAnalysisFormController,
        ({int profileId, int? analysisId})>((ref, params) {
  final existingAnalysis = params.analysisId != null
      ? ref.watch(
          labAnalysisByIdProvider((
            id: params.analysisId!,
            profileId: params.profileId,
          )),
        ).asData?.value
      : null;
  return LabAnalysisFormController(
    ref.read(labAnalysisRepositoryProvider),
    params.profileId,
    existingAnalysis,
  );
});

/// Attachments for a specific analysis
final labAnalysisAttachmentsProvider = StreamProvider.autoDispose
    .family<List<LabAnalysisAttachment>, int>((ref, analysisId) {
  final dao = ref.watch(labAnalysisDaoProvider);
  return dao.watchAttachments(analysisId).map(
    (list) => list.map(LabAnalysisAttachment.fromDb).toList(),
  );
});