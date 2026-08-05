import 'package:rehab_track/domain/restore/restore_result.dart';
import 'package:rehab_track/domain/restore/restore_rollback_result.dart';

/// Structured, non-sensitive outcome of a restore-apply attempt.
///
/// [recoveryId] is a random identifier used for diagnostics and interrupted-
/// operation recovery. It never contains personal data. [debugSummary] may
/// carry a short non-sensitive reason for logs/diagnostics but must never
/// include personal data or raw paths.
class RestoreFailure {
  final RestoreResult result;

  /// Recovery/diagnostic identifier, safe to show in logs and to the user.
  final String recoveryId;

  /// Outcome of the rollback attempt. Set to [RestoreRollbackResult.rollbackSucceeded]
  /// when the previous state was recovered after a post-snapshot failure (or
  /// when no live change had happened yet), and to rollbackFailed when
  /// automatic recovery could not complete. Null only on success/cancellation.
  final RestoreRollbackResult? rollback;

  /// Optional non-sensitive diagnostic summary.
  final String? debugSummary;

  const RestoreFailure({
    required this.result,
    required this.recoveryId,
    this.rollback,
    this.debugSummary,
  });

  const RestoreFailure.success(String recoveryId)
      : this(result: RestoreResult.success, recoveryId: recoveryId);

  /// Whether the operation succeeded.
  bool get succeeded => result == RestoreResult.success;

  /// Whether automatic recovery could not complete.
  bool get rollbackFailed => rollback == RestoreRollbackResult.rollbackFailed;

  /// Whether the previous state is intact (either rollback succeeded or no
  /// live change had started yet).
  bool get originalDataRecovered =>
      rollback == RestoreRollbackResult.rollbackSucceeded;
}