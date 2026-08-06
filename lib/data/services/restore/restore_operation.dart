import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rehab_track/core/constants/app_constants.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/services/restore/restore_app_environment.dart';
import 'package:rehab_track/data/services/restore/restore_service.dart';
import 'package:rehab_track/domain/backup/backup_preview.dart';
import 'package:rehab_track/domain/restore/restore_apply_phase.dart';
import 'package:rehab_track/domain/restore/restore_failure.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/restore_apply_provider.dart';
import 'package:rehab_track/presentation/providers/restore_provider.dart';

/// Independent restore operation that doesn't depend on Riverpod.
/// All dependencies are injected at construction time.
class RestoreOperation {
  final RestoreService _service;
  final SettingsRepository _settingsRepository;
  final StreamController<RestoreOperationState> _stateController =
      StreamController.broadcast();

  bool _cancelRequested = false;
  RestoreOperationState _state = const RestoreOperationState();

  RestoreOperation({
    required RestoreService service,
    required SettingsRepository settingsRepository,
  })  : _service = service,
        _settingsRepository = settingsRepository;

  Stream<RestoreOperationState> get stateStream => _stateController.stream;
  RestoreOperationState get state => _state;

  static const Set<RestoreApplyPhase> _safeCancellationPhases = {
    RestoreApplyPhase.preparingRestore,
    RestoreApplyPhase.creatingSafetySnapshot,
    RestoreApplyPhase.preparingDatabase,
    RestoreApplyPhase.migratingDatabase,
    RestoreApplyPhase.validatingMigratedDatabase,
    RestoreApplyPhase.repairingFilePaths,
    RestoreApplyPhase.preparingFiles,
    RestoreApplyPhase.preparingPreferences,
  };

  bool get canCancel =>
      _state.isRunning &&
      _state.applyPhase != null &&
      _safeCancellationPhases.contains(_state.applyPhase);

  /// Applies the restore for [backupFile], which must correspond to [preview].
  /// Returns null when another operation is already running.
  Future<RestoreFailure?> apply({
    required File backupFile,
    required BackupPreview preview,
  }) async {
    if (_state.isRunning) return null;
    _cancelRequested = false;
    _updateState(const RestoreOperationState(
      phase: RestoreApplyUiPhase.running,
      applyPhase: RestoreApplyPhase.preparingRestore,
    ));

    final failure = await _service.run(
      selectedBackupFile: backupFile,
      expectedPreview: preview,
      onPhase: (phase) {
        _updateState(RestoreOperationState(
          phase: RestoreApplyUiPhase.running,
          applyPhase: phase,
        ));
      },
      isCancellationRequested: () async => _cancelRequested,
    );

    // "Last restore" is recorded only after the restored state and reminder
    // rebuild were finalized — never after a rollback. Restoring never touches
    // the "last backup" marker.
    if (failure.succeeded) {
      try {
        await _settingsRepository.setValue(
          AppConstants.lastSuccessfulRestoreKey,
          DateTime.now().toIso8601String(),
        );
      } catch (_) {
        // Best-effort metadata; the restore itself already succeeded.
      }
    }

    _updateState(RestoreOperationState(
      phase: RestoreApplyUiPhase.finished,
      failure: failure,
    ));
    return failure;
  }

  /// Requests cancellation. Honoured only while in a safe phase.
  void requestCancel() {
    _cancelRequested = true;
  }

  /// Retries rebuilding future reminders after a restore that completed with a
  /// reminder warning. Returns whether the rebuild succeeded.
  Future<bool> retryReminderRebuild() async {
    try {
      final report = await _service.environment.rebuildScheduledNotifications();
      return report.succeeded;
    } catch (_) {
      return false;
    }
  }

  /// Resets to idle so the screen can start fresh.
  void reset() {
    if (!_state.isRunning) {
      _updateState(const RestoreOperationState());
    }
  }

  void _updateState(RestoreOperationState newState) {
    _state = newState;
    _stateController.add(_state);
  }

  void dispose() {
    _stateController.close();
  }
}

/// Immutable snapshot of a restore-apply operation, exposed to the UI.
class RestoreOperationState {
  final RestoreApplyUiPhase phase;
  final RestoreApplyPhase? applyPhase;
  final RestoreFailure? failure;

  const RestoreOperationState({
    this.phase = RestoreApplyUiPhase.idle,
    this.applyPhase,
    this.failure,
  });

  bool get isRunning => phase == RestoreApplyUiPhase.running;
  bool get isFinished => phase == RestoreApplyUiPhase.finished;
  bool get isIdle => phase == RestoreApplyUiPhase.idle;
}

/// Creates a fully configured [RestoreOperation] with all dependencies.
Future<RestoreOperation> createRestoreOperation(
  ProviderContainer container, {
  Directory? tempBaseDir,
}) async {
  final service = RestoreService(
    environment: RestoreAppEnvironment(container),
    archiveReader: container.read(backupArchiveReaderProvider),
    validator: container.read(backupValidatorProvider),
    recoveryStore: container.read(restoreRecoveryStoreProvider),
    tempBaseDir: tempBaseDir ?? Directory.systemTemp,
    currentDatabaseSchemaVersion: AppDatabase.currentSchemaVersion,
    currentAppVersion: AppConstants.appVersion,
  );
  return RestoreOperation(
    service: service,
    settingsRepository: container.read(settingsRepositoryProvider),
  );
}