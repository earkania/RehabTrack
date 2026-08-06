import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:rehab_track/data/services/restore/restore_database_manager.dart';
import 'package:rehab_track/data/services/restore/restore_environment.dart';
import 'package:rehab_track/data/services/restore/restore_file_manager.dart';
import 'package:rehab_track/data/services/restore/restore_recovery_metadata.dart';
import 'package:rehab_track/data/services/restore/restore_reinitializer.dart';
import 'package:rehab_track/data/services/restore/restore_safety_snapshot_service.dart';
import 'package:rehab_track/data/services/restore/restore_workspace.dart';

/// Outcome of a startup interrupted-restore scan.
enum RestoreInterruptedRecoveryResult {
  /// No interrupted restore was detected; nothing to do.
  none,

  /// An interrupted restore was found and fully rolled back to the pre-restore
  /// state.
  recovered,

  /// An interrupted restore was found but automatic recovery could not
  /// complete; the recovery metadata and safety snapshot are retained.
  failed,

  /// Automatic recovery has already been attempted the maximum number of times
  /// for this operation. Further automatic attempts are stopped (terminal
  /// state) so the app never retries a persistent failure forever; the
  /// metadata and snapshot are retained for manual action.
  recoveryLimitReached,
}

/// Detects and recovers an interrupted restore on app startup.
///
/// Recovery reconstructs the pre-restore state from the retained safety
/// snapshot (database, managed files and preferences), then reopens the
/// database, reinitializes services and verifies. Because the snapshot is the
/// ground truth of the pre-restore state, this is safe regardless of whether
/// the interruption happened before or during the live replacement.
///
/// Recovery is attempted at most [maxRecoveryAttempts] times per operation;
/// afterwards the operation reaches a terminal state and is no longer retried.
class RestoreInterruptedRecoveryService {
  final RestoreEnvironment environment;
  final RestoreRecoveryStore recoveryStore;

  /// Maximum automatic recovery attempts per interrupted operation before the
  /// recovery enters a terminal state.
  static const int maxRecoveryAttempts = 3;

  RestoreInterruptedRecoveryService({
    required this.environment,
    required this.recoveryStore,
  });

  Future<RestoreInterruptedRecoveryResult> recover() async {
    final List<RestoreRecoveryMetadata> pending;
    try {
      pending = await recoveryStore.listAll();
    } catch (_) {
      return RestoreInterruptedRecoveryResult.failed;
    }
    if (pending.isEmpty) return RestoreInterruptedRecoveryResult.none;

    // Discard metadata that does not represent a live change (e.g. a restore
    // interrupted during preparation before anything was swapped).
    for (final metadata in pending) {
      if (!metadata.needsRecovery) {
        await _discard(metadata);
      }
    }

    RestoreRecoveryMetadata? target;
    for (final metadata in pending) {
      if (metadata.needsRecovery) {
        target = metadata;
        break;
      }
    }
    if (target == null) return RestoreInterruptedRecoveryResult.none;

    // Terminal state: further automatic attempts are deliberately skipped.
    if (target.attemptCount >= maxRecoveryAttempts) {
      return RestoreInterruptedRecoveryResult.recoveryLimitReached;
    }

    return await _recoverOne(target);
  }

  Future<RestoreInterruptedRecoveryResult> _recoverOne(
    RestoreRecoveryMetadata metadata,
  ) async {
    final workspace = RestoreWorkspace.open(Directory(metadata.workspacePath));
    final snapshot = SafetySnapshotContent(workspace.safetySnapshot);

    if (!await workspace.exists() ||
        !await snapshot.databaseFile.exists()) {
      // Cannot recover automatically: the workspace/snapshot is gone.
      await _recordAttempt(metadata);
      return RestoreInterruptedRecoveryResult.failed;
    }

    try {
      final documentsDir = await environment.documentsDirectory();
      final liveDbFile = File(p.join(documentsDir.path, 'rehabtrack.sqlite'));

      // Database: place the snapshot database at the live location.
      if (await liveDbFile.exists()) {
        await liveDbFile.delete();
      }
      for (final sidecar
          in RestoreDatabaseSwap.sidecarNamesFor(liveDbFile.path)) {
        final f = File(sidecar);
        if (await f.exists()) {
          await f.delete();
        }
      }
      await snapshot.databaseFile.copy(liveDbFile.path);

      // Files: restore the snapshot managed files into the live location.
      await restoreManagedFilesFrom(snapshot.filesRoot, documentsDir);

      // Preferences: apply the snapshot values.
      await environment.applyPreferences(await snapshot.readPreferences());

      // Reinitialize and verify.
      await environment.reopenDatabase();
      await environment.reinitializeProviders();
      final ok = await RestoreReinitializer(environment).verifyRestoredState();
      if (!ok) {
        await _recordAttempt(metadata);
        return RestoreInterruptedRecoveryResult.failed;
      }

      await recoveryStore.clear(metadata.operationId);
      try {
        await workspace.deleteEntirely();
      } catch (_) {}
      return RestoreInterruptedRecoveryResult.recovered;
    } catch (_) {
      await _recordAttempt(metadata);
      return RestoreInterruptedRecoveryResult.failed;
    }
  }

  /// Persists an incremented attempt counter so the next launch can decide
  /// whether to keep retrying. Best-effort.
  Future<void> _recordAttempt(RestoreRecoveryMetadata metadata) async {
    try {
      await recoveryStore.write(
        RestoreRecoveryMetadata(
          operationId: metadata.operationId,
          phase: metadata.phase,
          workspacePath: metadata.workspacePath,
          databaseSwapStarted: metadata.databaseSwapStarted,
          fileSwapStarted: metadata.fileSwapStarted,
          preferencesApplied: metadata.preferencesApplied,
          finalized: metadata.finalized,
          attemptCount: metadata.attemptCount + 1,
        ),
      );
    } catch (_) {
      // Best-effort.
    }
  }

  Future<void> _discard(RestoreRecoveryMetadata metadata) async {
    try {
      await recoveryStore.clear(metadata.operationId);
      final workspace = RestoreWorkspace.open(Directory(metadata.workspacePath));
      if (await workspace.exists()) {
        await workspace.deleteEntirely();
      }
    } catch (_) {
      // Best-effort cleanup.
    }
  }
}