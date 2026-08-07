import 'package:rehab_track/domain/backup/backup_phase.dart';

/// Immutable snapshot of a backup operation's progress.
class BackupOperationState {
  final BackupPhase phase;

  /// Number of managed files already added to the archive.
  final int collectedFiles;

  /// Total number of managed files expected. `null` until the collection
  /// phase finishes.
  final int? totalFiles;

  /// Non-sensitive warnings gathered during the operation (e.g. count of
  /// referenced photos missing on disk). Never contains patient data.
  final List<String> warnings;

  const BackupOperationState({
    this.phase = BackupPhase.idle,
    this.collectedFiles = 0,
    this.totalFiles,
    this.warnings = const [],
  });

  BackupOperationState copyWith({
    BackupPhase? phase,
    int? collectedFiles,
    int? totalFiles,
    List<String>? warnings,
  }) {
    return BackupOperationState(
      phase: phase ?? this.phase,
      collectedFiles: collectedFiles ?? this.collectedFiles,
      totalFiles: totalFiles ?? this.totalFiles,
      warnings: warnings ?? this.warnings,
    );
  }

  /// Whether a backup operation is currently running.
  bool get isRunning => phase != BackupPhase.idle && phase != BackupPhase.done;

  bool get isDone => phase == BackupPhase.done;
}
