import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:rehab_track/core/constants/app_constants.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/services/restore/restore_app_environment.dart';
import 'package:rehab_track/data/services/restore/restore_interrupted_recovery_service.dart';
import 'package:rehab_track/data/services/restore/restore_recovery_metadata.dart';
import 'package:rehab_track/data/services/restore/restore_service.dart';
import 'package:rehab_track/data/services/restore/restore_stale_workspace_cleaner.dart';
import 'package:rehab_track/domain/backup/backup_preview.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/domain/restore/restore_apply_phase.dart';
import 'package:rehab_track/domain/restore/restore_failure.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/restore_provider.dart';

/// Coarse lifecycle of the restore-apply controller.
enum RestoreApplyUiPhase {
  idle,
  running,
  finished,
}

/// Immutable snapshot of a restore-apply operation, exposed to the UI.
class RestoreApplyState {
  final RestoreApplyUiPhase phase;

  /// Detailed progress phase while [phase] is running.
  final RestoreApplyPhase? applyPhase;

  /// Outcome, set when [phase] is finished.
  final RestoreFailure? failure;

  const RestoreApplyState({
    this.phase = RestoreApplyUiPhase.idle,
    this.applyPhase,
    this.failure,
  });

  bool get isRunning => phase == RestoreApplyUiPhase.running;
  bool get isFinished => phase == RestoreApplyUiPhase.finished;
  bool get isIdle => phase == RestoreApplyUiPhase.idle;
}

/// Drives a single restore-apply operation and exposes its progress.
///
/// Rethrows nothing: [RestoreFailure] carries the structured outcome including
/// whether the original data was recovered.
class RestoreApplyController extends StateNotifier<RestoreApplyState> {
  final RestoreService _service;
  final SettingsRepository _settingsRepository;
  bool _cancelRequested = false;

  RestoreApplyController(this._service, this._settingsRepository)
      : super(const RestoreApplyState());

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

  /// Whether cancellation may currently be requested (only in safe phases,
  /// before any live replacement).
  bool get canCancel =>
      state.isRunning &&
      state.applyPhase != null &&
      _safeCancellationPhases.contains(state.applyPhase);

  /// Applies the restore for [backupFile], which must correspond to [preview].
  /// Returns null when another operation is already running.
  Future<RestoreFailure?> apply({
    required File backupFile,
    required BackupPreview preview,
  }) async {
    if (state.isRunning) return null;
    _cancelRequested = false;
    state = const RestoreApplyState(
      phase: RestoreApplyUiPhase.running,
      applyPhase: RestoreApplyPhase.preparingRestore,
    );
    final failure = await _service.run(
      selectedBackupFile: backupFile,
      expectedPreview: preview,
      onPhase: (phase) {
        if (!mounted) return;
        state = RestoreApplyState(
          phase: RestoreApplyUiPhase.running,
          applyPhase: phase,
        );
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

    state = RestoreApplyState(
      phase: RestoreApplyUiPhase.finished,
      failure: failure,
    );
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
    if (!state.isRunning) {
      state = const RestoreApplyState();
    }
  }
}

final restoreRecoveryStoreProvider = Provider<RestoreRecoveryStore>((ref) {
  return RestoreRecoveryStore(() async {
    try {
      final support = await getApplicationSupportDirectory();
      return Directory(p.join(support.path, 'restore_recovery'));
    } catch (_) {
      return Directory(
        p.join(Directory.systemTemp.path, 'rehabtrack_restore_recovery'),
      );
    }
  });
});

final restoreApplyProvider =
    StateNotifierProvider<RestoreApplyController, RestoreApplyState>((ref) {
  final service = RestoreService(
    environment: RestoreAppEnvironment(ref.container),
    archiveReader: ref.watch(backupArchiveReaderProvider),
    validator: ref.watch(backupValidatorProvider),
    recoveryStore: ref.watch(restoreRecoveryStoreProvider),
    tempBaseDir: Directory.systemTemp,
    currentDatabaseSchemaVersion: AppDatabase.currentSchemaVersion,
    currentAppVersion: AppConstants.appVersion,
  );
  final controller = RestoreApplyController(service, ref.watch(settingsRepositoryProvider));
  ref.keepAlive();
  return controller;
});

/// Timestamp (ISO 8601) of the last completed restore, or null if never.
/// Written only after the restored state and reminders were finalized, so it is
/// never updated by a rolled-back or interrupted restore.
final lastRestoreAtProvider = FutureProvider<DateTime?>((ref) async {
  final raw = await ref.watch(settingsRepositoryProvider).getValue(
        AppConstants.lastSuccessfulRestoreKey,
      );
  final parsed = raw == null ? null : DateTime.tryParse(raw);
  return parsed?.toLocal();
});

/// Detects and recovers an interrupted restore at app startup, then clears any
/// stale temporary workspaces.
///
/// Called from `main()` before the persisted settings are warmed up so the
/// database is not opened against a half-restored file. Returns the recovery
/// outcome; callers surface a recovery message when recovery failed.
Future<RestoreInterruptedRecoveryResult> runStartupRestoreRecovery(
  ProviderContainer container,
) async {
  final environment = RestoreAppEnvironment(container);
  final support = await getApplicationSupportDirectory();
  final store = RestoreRecoveryStore.inDirectory(
    Directory(p.join(support.path, 'restore_recovery')),
  );
  final service = RestoreInterruptedRecoveryService(
    environment: environment,
    recoveryStore: store,
  );
  final RestoreInterruptedRecoveryResult result;
  try {
    result = await service.recover();
  } catch (_) {
    return RestoreInterruptedRecoveryResult.failed;
  }

  // Clear abandoned temporary workspaces (never any workspace still referenced
  // by an active recovery marker).
  await const RestoreStaleWorkspaceCleaner().clean(
    tempBaseDir: Directory.systemTemp,
    recoveryStore: store,
  );
  return result;
}