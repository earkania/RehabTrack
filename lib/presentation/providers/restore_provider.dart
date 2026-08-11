import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import 'package:rehab_track/core/constants/app_constants.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/services/backup/backup_archive_reader.dart';
import 'package:rehab_track/data/services/backup/backup_document_gateway.dart';
import 'package:rehab_track/data/services/backup/backup_validator.dart';
import 'package:rehab_track/data/services/backup/restore_selection_service.dart';
import 'package:rehab_track/domain/backup/backup_preview.dart';
import 'package:rehab_track/domain/backup/backup_validation_result.dart';
import 'package:rehab_track/domain/backup/restore_operation_state.dart';
import 'package:rehab_track/domain/backup/restore_phase.dart';

final backupDocumentGatewayProvider = Provider<BackupDocumentGateway>((ref) {
  return const BackupDocumentGateway();
});

final restoreSelectionServiceProvider = Provider<RestoreSelectionService>(
  (ref) => RestoreSelectionService(ref.watch(backupDocumentGatewayProvider)),
);

final backupArchiveReaderProvider = Provider<BackupArchiveReader>(
  (ref) => const BackupArchiveReader(),
);

final backupValidatorProvider = Provider<BackupValidator>(
  (ref) => const BackupValidator(),
);

/// Drives a single restore-validation operation and exposes its progress.
///
/// This phase only validates a selected backup and prepares a preview. It
/// never modifies the database, preferences or managed files, and never
/// rebuilds notifications.
class RestoreOperationController extends StateNotifier<RestoreOperationState> {
  final RestoreSelectionService _selectionService;
  final BackupArchiveReader _archiveReader;
  final BackupValidator _validator;
  final Directory _tempBaseDir;
  final int _currentSchemaVersion;
  final String _currentAppVersion;

  RestoreOperationController({
    required this._selectionService,
    required this._archiveReader,
    required this._validator,
    required this._tempBaseDir,
    this._currentSchemaVersion = AppDatabase.currentSchemaVersion,
    this._currentAppVersion = AppConstants.appVersion,
  }) : super(const RestoreOperationState());
  /// Selects, reads and validates a backup. Returns the validation result so
  /// the UI can surface the right message.
  Future<BackupValidationResult> restoreBackup() async {
    if (state.isRunning) {
      return BackupValidationResult.operationAlreadyInProgress;
    }

    // Mark running synchronously so a concurrent call is rejected before any
    // await.
    state = const RestoreOperationState(phase: RestorePhase.selectingFile);

    final Directory workDir;
    try {
      workDir = await _tempBaseDir.createTemp('rehabtrack_restore_');
    } catch (_) {
      _finishFailure(BackupValidationResult.storageFailure);
      return BackupValidationResult.storageFailure;
    }

    try {
      final selection = await _selectionService.select(
        tempFilePath: p.join(workDir.path, 'selected.rtb'),
      );
      // `await` (not a bare return) keeps the `finally` cleanup below from
      // deleting the ephemeral work directory while the shared pipeline runs.
      return await _continueFromSelection(selection, workDir);
    } catch (_) {
      _finishFailure(BackupValidationResult.unexpectedFailure);
      return BackupValidationResult.unexpectedFailure;
    } finally {
      try {
        await workDir.delete(recursive: true);
      } catch (_) {
        // Best-effort temp cleanup.
      }
    }
  }

  /// Restores a backup that was previously tracked by "Manage Backups",
  /// identified by [contentUri], without showing the document picker.
  Future<BackupValidationResult> restoreFromUri(String contentUri) async {
    if (state.isRunning) {
      return BackupValidationResult.operationAlreadyInProgress;
    }

    state = const RestoreOperationState(phase: RestorePhase.selectingFile);

    final Directory workDir;
    try {
      workDir = await _tempBaseDir.createTemp('rehabtrack_restore_');
    } catch (_) {
      _finishFailure(BackupValidationResult.storageFailure);
      return BackupValidationResult.storageFailure;
    }

    try {
      final selection = await _selectionService.selectFromUri(
        contentUri: contentUri,
        tempFilePath: p.join(workDir.path, 'selected.rtb'),
      );
      return await _continueFromSelection(selection, workDir);
    } catch (_) {
      _finishFailure(BackupValidationResult.unexpectedFailure);
      return BackupValidationResult.unexpectedFailure;
    } finally {
      try {
        await workDir.delete(recursive: true);
      } catch (_) {
        // Best-effort temp cleanup.
      }
    }
  }

  /// Shared validation pipeline for a copied backup selected either via the
  /// picker or by an already-known URI.
  Future<BackupValidationResult> _continueFromSelection(
    BackupSelectionOutcome selection,
    Directory workDir,
  ) async {
    if (!selection.succeeded) {
      if (selection.cancelled) {
        state = const RestoreOperationState(phase: RestorePhase.cancelled);
      } else {
        _finishFailure(selection.result);
      }
      return selection.result;
    }

    state = const RestoreOperationState(phase: RestorePhase.readingArchive);
    final read = await _archiveReader.read(selection.file!);
    if (!read.succeeded) {
      final mapped = _mapReadFailure(read.status);
      _finishFailure(mapped);
      return mapped;
    }

    final outcome = await _validator.validate(
      handle: read.handle!,
      tempDir: workDir,
      currentDatabaseSchemaVersion: _currentSchemaVersion,
      currentAppVersion: _currentAppVersion,
      onPhase: (phase) => state = state.copyWith(phase: phase),
    );

    if (outcome.result != BackupValidationResult.valid) {
      _finishFailure(outcome.result, warnings: outcome.warnings);
      return outcome.result;
    }

    // Persist an app-owned copy of the selected backup so the restore-apply
    // flow can reuse the exact validated file (the ephemeral work directory
    // is removed below).
    final String pendingPath;
    try {
      final pendingDir =
          Directory(p.join(_tempBaseDir.path, 'pending-restore'));
      await pendingDir.create(recursive: true);
      final pendingFile = File(p.join(pendingDir.path, 'selected.rtb'));
      if (await pendingFile.exists()) {
        await pendingFile.delete();
      }
      await selection.file!.copy(pendingFile.path);
      pendingPath = pendingFile.path;
    } catch (_) {
      _finishFailure(BackupValidationResult.storageFailure);
      return BackupValidationResult.storageFailure;
    }

    state = RestoreOperationState(
      phase: RestorePhase.readyForPreview,
      result: BackupValidationResult.valid,
      preview: outcome.preview,
      warnings: outcome.warnings,
      backupFilePath: pendingPath,
    );
    return BackupValidationResult.valid;
  }

  BackupValidationResult _mapReadFailure(BackupArchiveReadStatus status) {
    return switch (status) {
      BackupArchiveReadStatus.corruptedArchive =>
        BackupValidationResult.corruptedArchive,
      BackupArchiveReadStatus.backupTooLarge =>
        BackupValidationResult.backupTooLarge,
      BackupArchiveReadStatus.storageFailure =>
        BackupValidationResult.storageFailure,
      BackupArchiveReadStatus.unexpectedFailure =>
        BackupValidationResult.unexpectedFailure,
      BackupArchiveReadStatus.success => BackupValidationResult.valid,
    };
  }

  void _finishFailure(
    BackupValidationResult result, {
    List<BackupWarning> warnings = const [],
  }) {
    state = RestoreOperationState(
      phase: RestorePhase.failure,
      result: result,
      warnings: warnings,
    );
  }

  /// Resets the operation state so the screen shows its initial content.
  void reset() {
    if (!state.isRunning) {
      try {
        final pendingFile = File(
          p.join(_tempBaseDir.path, 'pending-restore', 'selected.rtb'),
        );
        if (pendingFile.existsSync()) {
          pendingFile.deleteSync();
        }
      } catch (_) {
        // Best-effort cleanup.
      }
      state = const RestoreOperationState();
    }
  }
}

final restoreOperationProvider =
    StateNotifierProvider<RestoreOperationController, RestoreOperationState>(
  (ref) {
    return RestoreOperationController(
      selectionService: ref.watch(restoreSelectionServiceProvider),
      archiveReader: ref.watch(backupArchiveReaderProvider),
      validator: ref.watch(backupValidatorProvider),
      tempBaseDir: Directory.systemTemp,
    );
  },
);