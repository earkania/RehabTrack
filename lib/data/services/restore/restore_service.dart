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
import 'package:rehab_track/data/services/restore/restore_sqlite_migrator.dart';
import 'package:rehab_track/data/services/restore/restore_workspace.dart';
import 'package:rehab_track/data/services/storage/storage_inspector.dart';
import 'package:rehab_track/domain/backup/backup_manifest.dart';
import 'package:rehab_track/domain/backup/backup_preview.dart';
import 'package:rehab_track/domain/backup/backup_validation_result.dart';
import 'package:rehab_track/domain/restore/reminder_rebuild_report.dart';
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
  final RestoreSqliteMigrator migrator;
  final StorageInspector storageInspector;
  final Random _random;

  RestoreService({
    required this.environment,
    required this.archiveReader,
    required this.validator,
    required this.recoveryStore,
    required this.tempBaseDir,
    required this.currentDatabaseSchemaVersion,
    required this.currentAppVersion,
    this.migrator = const RestoreSqliteMigrator(),
    this.storageInspector = const StorageInspector(),
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

      // --- Migrate an older schema (strictly on the temp copy, never live) --
      final migrated = preview.migrationRequired;
      if (migrated) {
        _emit(onPhase, RestoreApplyPhase.migratingDatabase);
        await _writeMetadata(operationId, workspace,
            phase: RestoreApplyPhase.migratingDatabase);
        try {
          await migrator.migrateToCurrent(
            file: prepared.file,
            fromSchemaVersion: preview.databaseSchemaVersion,
          );
        } catch (_) {
          return await cleanupAndFail(RestoreResult.migrationFailure,
              rollbackSucceeded: true);
        }
        _emit(onPhase, RestoreApplyPhase.validatingMigratedDatabase);
        await _writeMetadata(operationId, workspace,
            phase: RestoreApplyPhase.validatingMigratedDatabase);
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

      // --- Repair paths + validate prepared database ------------------------
      _emit(onPhase, RestoreApplyPhase.repairingFilePaths);
      await _writeMetadata(operationId, workspace,
          phase: RestoreApplyPhase.repairingFilePaths);
      final documentsDir = await environment.documentsDirectory();
      var missingManagedFiles = false;
      try {
        final repair = RestoreImagePathRemapper.remap(
          databasePath: prepared.file.path,
          managedFilesRoot: documentsDir.path,
          restoredFilesDir: workspace.preparedFiles.path,
        );
        missingManagedFiles = repair.hasMissingFiles;
      } catch (_) {
        return await cleanupAndFail(RestoreResult.pathRepairFailure, rollbackSucceeded: true);
      }
      final expectedFinalSchema = migrated
          ? currentDatabaseSchemaVersion
          : preview.databaseSchemaVersion;
      final bool stillValid;
      try {
        stillValid = await dbManager.validatePrepared(
          file: prepared.file,
          expectedSchemaVersion: expectedFinalSchema,
        );
      } catch (_) {
        return await cleanupAndFail(RestoreResult.databaseVerificationFailure, rollbackSucceeded: true);
      }
      if (!stillValid) {
        return await cleanupAndFail(RestoreResult.databaseVerificationFailure, rollbackSucceeded: true);
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

      // --- Storage guard ---------------------------------------------------
      // Before any live change, ensure the workspace (safety snapshot +
      // prepared data) does not clearly exceed the available temporary space.
      // A failed guard leaves the live state untouched.
      final freeBytes = await storageInspector.freeBytes(workspace.root.path)
          .timeout(const Duration(seconds: 10), onTimeout: () => null);
      if (freeBytes != null) {
        final needed = await _directoryBytes(workspace.root)
            .timeout(const Duration(seconds: 10), onTimeout: () => 0) * 2;
        if (freeBytes < needed) {
          return await cleanupAndFail(RestoreResult.insufficientStorage,
              rollbackSucceeded: true);
        }
      }

      if (isCancellationRequested != null && await isCancellationRequested()) {
        return await cleanupAndFail(RestoreResult.cancelled);
      }
      try {
        await environment.pauseLiveDatabase()
            .timeout(const Duration(seconds: 15), onTimeout: () {
              throw const RestoreEnvironmentFailure(reason: 'pause-timeout');
            });
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
        final verified = await reinitializer.verifyRestoredState()
            .timeout(const Duration(seconds: 30), onTimeout: () => false);
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

      // --- Durable completion marker ----------------------------------------
      // Data is restored and verified from here on. Any interruption after this
      // point must not trigger a rollback (the marker is finalized); reminders
      // are rebuilt and the marker is cleared only once they finish.
      await _writeMetadata(operationId, workspace,
          phase: RestoreApplyPhase.verifyingData,
          databaseSwapStarted: true,
          fileSwapStarted: true,
          preferencesApplied: true,
          finalized: true);

      // --- Rebuild reminders ------------------------------------------------
      _emit(onPhase, RestoreApplyPhase.rebuildingReminders);
      await _writeMetadata(operationId, workspace,
          phase: RestoreApplyPhase.rebuildingReminders,
          databaseSwapStarted: true,
          fileSwapStarted: true,
          preferencesApplied: true,
          finalized: true);
      try {
        await environment.cancelScheduledNotifications()
            .timeout(const Duration(seconds: 15), onTimeout: () {});
      } catch (_) {
        // Best-effort; a failed/timeout cancellation must not fail the restore.
      }
      var remindersSucceeded = true;
      try {
        final report = await environment.rebuildScheduledNotifications()
            .timeout(const Duration(seconds: 30), onTimeout: () => const ReminderRebuildReport.failure());
        remindersSucceeded = report.succeeded;
      } catch (_) {
        remindersSucceeded = false;
      }

      // Duplicate notification IDs would double-fires; treat as a warning so
      // the user can retry the rebuild, never as a data-rollback condition.
      if (remindersSucceeded) {
        try {
          final noDuplicates = await environment.verifyScheduledNotificationsNoDuplicates()
              .timeout(const Duration(seconds: 10), onTimeout: () => true);
          if (!noDuplicates) remindersSucceeded = false;
        } catch (_) {
          // Unknown: keep the successful verdict.
        }
      }

      // --- Finalize ------------------------------------------------------------
      _emit(onPhase, RestoreApplyPhase.finalizing);
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
        ).timeout(const Duration(seconds: 5), onTimeout: () {});
        await recoveryStore.clear(operationId)
            .timeout(const Duration(seconds: 5), onTimeout: () {});
        await workspace.deleteEntirely()
            .timeout(const Duration(seconds: 10), onTimeout: () {});
      } catch (_) {
        // Cleanup is best-effort; the restore itself already succeeded.
      }

      if (!remindersSucceeded) {
        // The data restore succeeded and was verified, but reminders could not
        // be fully rebuilt. This is a success-with-warning, never a rollback.
        return RestoreFailure.successWithReminderWarning(operationId);
      }
      if (missingManagedFiles) {
        return RestoreFailure.successWithMissingOptionalFiles(operationId);
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

      await environment.reopenDatabase()
          .timeout(const Duration(seconds: 15), onTimeout: () {
            throw const RestoreEnvironmentFailure(reason: 'reopen-timeout');
          });
      await environment.reinitializeProviders()
          .timeout(const Duration(seconds: 15), onTimeout: () {});
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

  /// Total size in bytes of every file under [directory] (recursive).
  Future<int> _directoryBytes(Directory directory) async {
    var total = 0;
    try {
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          total += await entity.length();
        }
      }
    } catch (_) {
      // Best-effort estimate.
    }
    return total;
  }
}

/// Tracks which live parts have been swapped so rollback knows what to undo.
class _LiveSwapTrack {
  DatabaseSwapHandle? databaseHandle;
  FilesSwapHandle? filesHandle;

  bool get movedAnything => databaseHandle != null || filesHandle != null;
}