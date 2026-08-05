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

  /// Path of the selected backup copy that produced [preview]. The file is an
  /// app-owned copy kept until the restore is applied or a new backup is
  /// selected.
  final String? backupFilePath;

  /// Non-sensitive warnings surfaced during validation.
  final List<BackupWarning> warnings;

  const RestoreOperationState({
    this.phase = RestorePhase.idle,
    this.result,
    this.preview,
    this.backupFilePath,
    this.warnings = const [],
  });

  RestoreOperationState copyWith({
    RestorePhase? phase,
    BackupValidationResult? result,
    BackupPreview? preview,
    String? backupFilePath,
    List<BackupWarning>? warnings,
    bool clearResult = false,
  }) {
    return RestoreOperationState(
      phase: phase ?? this.phase,
      result: clearResult ? null : (result ?? this.result),
      preview: preview ?? this.preview,
      backupFilePath: backupFilePath ?? this.backupFilePath,
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
