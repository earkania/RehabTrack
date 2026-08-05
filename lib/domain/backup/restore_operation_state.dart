import 'package:rehab_track/domain/backup/backup_preview.dart';
import 'package:rehab_track/domain/backup/backup_validation_result.dart';
import 'package:rehab_track/domain/backup/restore_phase.dart';

/// Immutable snapshot of a restore-validation operation.
class RestoreOperationState {
  final RestorePhase phase;

  /// Result of the last finished operation. `null` until it completes.
  final BackupValidationResult? result;

  /// Validated preview, set only when [phase] is [RestorePhase.readyForPreview].
  final BackupPreview? preview;

  /// Non-sensitive warnings surfaced during validation.
  final List<BackupWarning> warnings;

  const RestoreOperationState({
    this.phase = RestorePhase.idle,
    this.result,
    this.preview,
    this.warnings = const [],
  });

  RestoreOperationState copyWith({
    RestorePhase? phase,
    BackupValidationResult? result,
    BackupPreview? preview,
    List<BackupWarning>? warnings,
    bool clearResult = false,
  }) {
    return RestoreOperationState(
      phase: phase ?? this.phase,
      result: clearResult ? null : (result ?? this.result),
      preview: preview ?? this.preview,
      warnings: warnings ?? this.warnings,
    );
  }

  /// Whether a restore-validation operation is currently running.
  bool get isRunning => switch (phase) {
        RestorePhase.selectingFile ||
        RestorePhase.readingArchive ||
        RestorePhase.validatingManifest ||
        RestorePhase.verifyingChecksums ||
        RestorePhase.checkingCompatibility =>
          true,
        _ => false,
      };

  bool get isReadyForPreview => phase == RestorePhase.readyForPreview;
}
