import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import 'package:rehab_track/data/services/backup/backup_archive_reader.dart';
import 'package:rehab_track/data/services/backup/backup_validator.dart';
import 'package:rehab_track/data/services/restore/restore_database_manager.dart';
import 'package:rehab_track/data/services/restore/restore_environment.dart';
import 'package:rehab_track/data/services/restore/restore_file_manager.dart';
import 'package:rehab_track/data/services/restore/restore_image_path_remapper.dart';
import 'package:rehab_track/data/services/restore/restore_preferences_manager.dart';
import 'package:rehab_track/data/services/restore/restore_recovery_metadata.dart';
import 'package:rehab_track/data/services/restore/restore_reinitializer.dart';
import 'package:rehab_track/data/services/restore/restore_safety_snapshot_service.dart';
import 'package:rehab_track/data/services/restore/restore_workspace.dart';
import 'package:rehab_track/domain/backup/backup_manifest.dart';
import 'package:rehab_track/domain/backup/backup_preview.dart';
import 'package:rehab_track/domain/backup/backup_validation_result.dart';
import 'package:rehab_track/domain/restore/restore_apply_phase.dart';
import 'package:rehab_track/domain/restore/restore_failure.dart';
import 'package:rehab_track/domain/restore/restore_result.dart';
import 'package:rehab_track/domain/restore/restore_rollback_result.dart';

/// Orchestrates a replace-style restore: safety snapshot, prepare in temp,
/// atomic swap, reinitialize, verify, and full rollback on any failure.
///
/// Progress is reported through [RestoreApplyPhase] so the UI can show
/// localized, non-sensitive messages. The safety snapshot and rollback data
/// are retained until restore verification succeeds; they are only removed
/// afterwards (or retained deliberately on a failed rollback for recovery).
///
/// No personal data is ever written to logs or exposed by this service.
class RestoreService {
  final RestoreEnvironment environment;
  final BackupArchiveReader archiveReader;
  final BackupValidator validator;
  final RestoreRecoveryStore recoveryStore;
  final Directory tempBaseDir;
  final int currentDatabaseSchemaVersion;
  final String currentAppVersion;
  final Random _random;

  RestoreService({
    required this.environment,
    required this.archiveReader,
    required this.validator,
    required this.recoveryStore,
    required this.tempBaseDir,
    required this.currentDatabaseSchemaVersion,
    required this.currentAppVersion,
    Random? random,
  }) : _random = random ?? Random.secure();

  /// Runs the restore apply for [selectedBackupFile], which must be the same
  /// file that produced [expectedPreview]. [isCancellationRequested] is polled
  /// only in the safe pre-snapshot region; once the live state is being
  /// replaced cancellation is no longer honored.
  Future<RestoreFailure> run({
    required File selectedBackupFile,
    required BackupPreview expectedPreview,
    void Function(RestoreApplyPhase phase)? onPhase,
    Future<bool> Function()? isCancellationRequested,
  }) async {
    final operationId = _newOperationId();
    final RestoreWorkspace workspace;
    try {
      workspace = await RestoreWorkspace.create(
        baseDir: tempBaseDir,
        operationId: operationId,
      );
      await workspace.ensureSubdirectories();
    } catch (_) {
      return RestoreFailure(
        result: RestoreResult.unexpectedFailure,
        recoveryId: operationId,
      );
    }

    Future<RestoreFailure> cleanupAndFail(
      RestoreResult result, {
      bool rollbackSucceeded = false,
    }) async {
      try {
        await recoveryStore.clear(operationId);
        await workspace.deleteEntirely();
      } catch (_) {}
      // Failures that occur before the live state is replaced leave the
      // previous data intact, so the rollback is reported as succeeded.
      return RestoreFailure(
        result: result,
        recoveryId: operationId,
        rollback: rollbackSucceeded
            ? RestoreRollbackResult.rollbackSucceeded
            : null,
      );
    }

    final live = _LiveSwapTrack();

    try {
      // --- Preparing -------------------------------------------------------
      _emit(onPhase, RestoreApplyPhase.preparingRestore);
      await _writeMetadata(operationId, workspace,
          phase: RestoreApplyPhase.preparingRestore);

      final read = await archiveReader.read(selectedBackupFile);
      if (!read.succeeded) {
        return await cleanupAndFail(RestoreResult.validationFailure,
            rollbackSucceeded: true);
      }
      final handle = read.handle!;

      final outcome = await validator.validate(
        handle: handle,
        tempDir: workspace.root,
        currentDatabaseSchemaVersion: currentDatabaseSchemaVersion,
        currentAppVersion: currentAppVersion,
      );
      if (outcome.result != BackupValidationResult.valid ||
          outcome.preview == null) {
        return await cleanupAndFail(RestoreResult.validationFailure,
            rollbackSucceeded: true);
      }
      final preview = outcome.preview!;
      if (preview.migrationRequired) {
        return await cleanupAndFail(RestoreResult.migrationNotSupported, rollbackSucceeded: true);
      }
      if (preview.backupCreatedAt != expectedPreview.backupCreatedAt ||
          preview.databaseSchemaVersion != expectedPreview.databaseSchemaVersion) {
        return await cleanupAndFail(RestoreResult.validationFailure,
            rollbackSucceeded: true);
      }

      BackupManifest manifest;
      try {
        final manifestBytes = handle.content(BackupManifest.manifestFileName);
        if (manifestBytes == null) {
          return await cleanupAndFail(RestoreResult.validationFailure,
            rollbackSucceeded: true);
        }
        manifest = BackupManifest.fromJsonString(utf8.decode(manifestBytes));
      } catch (_) {
        return await cleanupAndFail(RestoreResult.validationFailure,
            rollbackSucceeded: true);
      }

      if (isCancellationRequested != null && await isCancellationRequested()) {
        return await cleanupAndFail(RestoreResult.cancelled);
      }

      // --- Safety snapshot ------------------------------------------------
      _emit(onPhase, RestoreApplyPhase.creatingSafetySnapshot);
      await _writeMetadata(operationId, workspace,
          phase: RestoreApplyPhase.creatingSafetySnapshot);
      final snapshotService = RestoreSafetySnapshotService(environment);
      try {
        await snapshotService.create(snapshotDir: workspace.safetySnapshot);
      } catch (_) {
        return await cleanupAndFail(RestoreResult.safetySnapshotFailure, rollbackSucceeded: true);
      }

      // --- Prepare database ------------------------------------------------
      _emit(onPhase, RestoreApplyPhase.preparingDatabase);
      await _writeMetadata(operationId, workspace,
          phase: RestoreApplyPhase.preparingDatabase);
      final dbManager = const RestoreDatabaseManager();
      final Uint8List? dbBytes = handle.content(BackupManifest.databaseFileName);
      if (dbBytes == null) {
        return await cleanupAndFail(RestoreResult.databasePreparationFailure, rollbackSucceeded: true);
      }
      final PreparedDatabase prepared;
      try {
        prepared = await dbManager.prepare(
          dbBytes: dbBytes,
          preparedDir: workspace.preparedDatabase,
          expectedSchemaVersion: preview.databaseSchemaVersion,
        );
      } catch (_) {
        return await cleanupAndFail(RestoreResult.databasePreparationFailure, rollbackSucceeded: true);
      }

      final documentsDir = await environment.documentsDirectory();
      try {
        RestoreImagePathRemapper.remap(
          databasePath: prepared.file.path,
          managedFilesRoot: documentsDir.path,
        );
        final stillValid = await dbManager.validatePrepared(
          file: prepared.file,
          expectedSchemaVersion: preview.databaseSchemaVersion,
        );
        if (!stillValid) {
          return await cleanupAndFail(RestoreResult.databasePreparationFailure, rollbackSucceeded: true);
        }
      } catch (_) {
        return await cleanupAndFail(RestoreResult.databasePreparationFailure, rollbackSucceeded: true);
      }

      // --- Prepare files ---------------------------------------------------
      _emit(onPhase, RestoreApplyPhase.preparingFiles);
      await _writeMetadata(operationId, workspace,
          phase: RestoreApplyPhase.preparingFiles);
      final fileManager = const RestoreFileManager();
      try {
        await fileManager.extract(
          handle: handle,
          checksums: manifest.checksums,
          preparedFilesDir: workspace.preparedFiles,
        );
      } catch (_) {
        return await cleanupAndFail(RestoreResult.managedFileRestoreFailure, rollbackSucceeded: true);
      }

      // --- Prepare preferences ---------------------------------------------
      _emit(onPhase, RestoreApplyPhase.preparingPreferences);
      await _writeMetadata(operationId, workspace,
          phase: RestoreApplyPhase.preparingPreferences);
      final prefsManager = RestorePreferencesManager(environment);
      Map<String, String> restoredPrefs = const {};
      try {
        final prefsBytes = handle.content(BackupManifest.preferencesFileName);
        if (prefsBytes == null) {
          return await cleanupAndFail(RestoreResult.preferencesRestoreFailure, rollbackSucceeded: true);
        }
        final decoded = jsonDecode(utf8.decode(prefsBytes));
        if (decoded is! Map) {
          return await cleanupAndFail(RestoreResult.preferencesRestoreFailure, rollbackSucceeded: true);
        }
        restoredPrefs = await prefsManager.normalize(decoded.cast<String, Object?>());
      } catch (_) {
        return await cleanupAndFail(RestoreResult.preferencesRestoreFailure, rollbackSucceeded: true);
      }

      // --- Pause services --------------------------------------------------
      _emit(onPhase, RestoreApplyPhase.pausingServices);
      await _writeMetadata(operationId, workspace,
          phase: RestoreApplyPhase.pausingServices);
      if (isCancellationRequested != null && await isCancellationRequested()) {
        return await cleanupAndFail(RestoreResult.cancelled);
      }
      try {
        await environment.pauseLiveDatabase();
      } catch (_) {
        return await cleanupAndFail(RestoreResult.unexpectedFailure, rollbackSucceeded: true);
      }

      // --- Replace database ------------------------------------------------
      _emit(onPhase, RestoreApplyPhase.replacingDatabase);
      final liveDbFile = File(p.join(documentsDir.path, 'rehabtrack.sqlite'));
      final dbSwap = const RestoreDatabaseSwap();
      try {
        live.databaseHandle = await dbSwap.moveAside(
          liveFile: liveDbFile,
          rollbackDir: workspace.rollbackWorkspace,
        );
        await _writeMetadata(operationId, workspace,
            phase: RestoreApplyPhase.replacingDatabase,
            databaseSwapStarted: true);
        await dbSwap.placePrepared(
          preparedFile: prepared.file,
          liveFile: liveDbFile,
        );
      } catch (_) {
        return await _rollbackAndFinish(
          operationId: operationId,
          workspace: workspace,
          onPhase: onPhase,
          live: live,
          category: RestoreResult.databaseReplacementFailure,
        );
      }

      // --- Restore files ----------------------------------------------------
      _emit(onPhase, RestoreApplyPhase.restoringFiles);
      await _writeMetadata(operationId, workspace,
          phase: RestoreApplyPhase.restoringFiles,
          databaseSwapStarted: true);
      try {
        live.filesHandle = await fileManager.replace(
          documentsDir: documentsDir,
          preparedFilesDir: workspace.preparedFiles,
          rollbackDir: workspace.rollbackWorkspace,
        );
        await _writeMetadata(operationId, workspace,
            phase: RestoreApplyPhase.restoringFiles,
            databaseSwapStarted: true,
            fileSwapStarted: true);
      } catch (_) {
        return await _rollbackAndFinish(
          operationId: operationId,
          workspace: workspace,
          onPhase: onPhase,
          live: live,
          category: RestoreResult.managedFileRestoreFailure,
        );
      }

      // --- Restore preferences ---------------------------------------------
      _emit(onPhase, RestoreApplyPhase.restoringPreferences);
      await _writeMetadata(operationId, workspace,
          phase: RestoreApplyPhase.restoringPreferences,
          databaseSwapStarted: true,
          fileSwapStarted: true);
      try {
        await prefsManager.apply(restoredPrefs);
        await _writeMetadata(operationId, workspace,
            phase: RestoreApplyPhase.restoringPreferences,
            databaseSwapStarted: true,
            fileSwapStarted: true,
            preferencesApplied: true);
      } catch (_) {
        return await _rollbackAndFinish(
          operationId: operationId,
          workspace: workspace,
          onPhase: onPhase,
          live: live,
          category: RestoreResult.preferencesRestoreFailure,
        );
      }
      _emit(onPhase, RestoreApplyPhase.reinitializing);
      await _writeMetadata(operationId, workspace,
          phase: RestoreApplyPhase.reinitializing,
          databaseSwapStarted: true,
          fileSwapStarted: true,
          preferencesApplied: true);
      final reinitializer = RestoreReinitializer(environment);
      try {
        await reinitializer.reopenAndReinitialize();
      } catch (_) {
        return await _rollbackAndFinish(
          operationId: operationId,
          workspace: workspace,
          onPhase: onPhase,
          live: live,
          category: RestoreResult.reinitializationFailure,
        );
      }

      // --- Verify -------------------------------------------------------------
      _emit(onPhase, RestoreApplyPhase.verifyingData);
      await _writeMetadata(operationId, workspace,
          phase: RestoreApplyPhase.verifyingData,
          databaseSwapStarted: true,
          fileSwapStarted: true,
          preferencesApplied: true);
      try {
        final verified = await reinitializer.verifyRestoredState();
        if (!verified) {
          return await _rollbackAndFinish(
            operationId: operationId,
            workspace: workspace,
            onPhase: onPhase,
            live: live,
            category: RestoreResult.verificationFailure,
          );
        }
      } catch (_) {
        return await _rollbackAndFinish(
          operationId: operationId,
          workspace: workspace,
          onPhase: onPhase,
          live: live,
          category: RestoreResult.verificationFailure,
        );
      }

      // --- Finalize ------------------------------------------------------------
      _emit(onPhase, RestoreApplyPhase.finalizing);
      try {
        await environment.cancelScheduledNotifications();
      } catch (_) {
        // Best-effort; a failed cancellation must not fail the restore.
      }
      try {
        await recoveryStore.write(
          RestoreRecoveryMetadata(
            operationId: operationId,
            phase: RestoreApplyPhase.finalizing.name,
            workspacePath: workspace.root.path,
            databaseSwapStarted: true,
            fileSwapStarted: true,
            preferencesApplied: true,
            finalized: true,
          ),
        );
        await recoveryStore.clear(operationId);
        await workspace.deleteEntirely();
      } catch (_) {
        // Cleanup is best-effort; the restore itself already succeeded.
      }
      return RestoreFailure.success(operationId);
    } catch (_) {
      return await _rollbackAndFinish(
        operationId: operationId,
        workspace: workspace,
        onPhase: onPhase,
        live: live,
        category: RestoreResult.unexpectedFailure,
      );
    }
  }

  /// Runs the rollback path after a failure at/after the live replacement, or
  /// maps a pre-swap failure without rollback.
  Future<RestoreFailure> _rollbackAndFinish({
    required String operationId,
    required RestoreWorkspace workspace,
    required _LiveSwapTrack live,
    required void Function(RestoreApplyPhase phase)? onPhase,
    required RestoreResult category,
  }) async {
    if (!live.movedAnything) {
      // Nothing live was replaced; the previous state is untouched.
      try {
        await recoveryStore.clear(operationId);
        await workspace.deleteEntirely();
      } catch (_) {}
      return RestoreFailure(
        result: category,
        recoveryId: operationId,
        rollback: RestoreRollbackResult.rollbackSucceeded,
      );
    }

    _emit(onPhase, RestoreApplyPhase.rollingBack);
    final rollback =
        await _rollback(operationId: operationId, workspace: workspace, live: live);

    if (rollback == RestoreRollbackResult.rollbackSucceeded) {
      try {
        await recoveryStore.clear(operationId);
        await workspace.deleteEntirely();
      } catch (_) {}
      return RestoreFailure(
        result: category,
        recoveryId: operationId,
        rollback: RestoreRollbackResult.rollbackSucceeded,
      );
    }
    // Rollback failed: retain the workspace (safety snapshot + rollback data)
    // and the recovery metadata so a startup recovery can try again.
    return RestoreFailure(
      result: category,
      recoveryId: operationId,
      rollback: RestoreRollbackResult.rollbackFailed,
    );
  }

  Future<RestoreRollbackResult> _rollback({
    required String operationId,
    required RestoreWorkspace workspace,
    required _LiveSwapTrack live,
  }) async {
    try {
      final documentsDir = await environment.documentsDirectory();
      final dbSwap = const RestoreDatabaseSwap();

      if (live.databaseHandle != null) {
        await dbSwap.restoreLive(handle: live.databaseHandle!);
      }

      if (live.filesHandle != null) {
        await const RestoreFileManager().restore(
          documentsDir: documentsDir,
          rollbackDir: workspace.rollbackWorkspace,
          handle: live.filesHandle!,
        );
      }

      final snapshot = SafetySnapshotContent(workspace.safetySnapshot);
      final originalPrefs = await snapshot.readPreferences();
      await environment.applyPreferences(originalPrefs);

      await environment.reopenDatabase();
      await environment.reinitializeProviders();
      final ok = await environment.verifyRestoredState();
      if (!ok) return RestoreRollbackResult.rollbackFailed;
      return RestoreRollbackResult.rollbackSucceeded;
    } catch (_) {
      return RestoreRollbackResult.rollbackFailed;
    }
  }

  Future<void> _writeMetadata(
    String operationId,
    RestoreWorkspace workspace, {
    required RestoreApplyPhase phase,
    bool databaseSwapStarted = false,
    bool fileSwapStarted = false,
    bool preferencesApplied = false,
    bool finalized = false,
  }) async {
    try {
      await recoveryStore.write(
        RestoreRecoveryMetadata(
          operationId: operationId,
          phase: phase.name,
          workspacePath: workspace.root.path,
          databaseSwapStarted: databaseSwapStarted,
          fileSwapStarted: fileSwapStarted,
          preferencesApplied: preferencesApplied,
          finalized: finalized,
        ),
      );
    } catch (_) {
      // Metadata persistence is best-effort.
    }
  }

  static void _emit(
    void Function(RestoreApplyPhase phase)? onPhase,
    RestoreApplyPhase phase,
  ) {
    onPhase?.call(phase);
  }

  String _newOperationId() {
    final random = _random.nextInt(0x7fffffff);
    return 'restore_${random.toRadixString(16)}';
  }
}

/// Tracks which live parts have been swapped so rollback knows what to undo.
class _LiveSwapTrack {
  DatabaseSwapHandle? databaseHandle;
  FilesSwapHandle? filesHandle;

  bool get movedAnything => databaseHandle != null || filesHandle != null;
}