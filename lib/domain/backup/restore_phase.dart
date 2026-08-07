/// Phases of a restore-validation operation, in execution order.
///
/// The UI observes [RestoreOperationState.phase] to show progress.
enum RestorePhase {
  /// No restore operation running.
  idle,

  /// Waiting for the user to choose a backup file in the document picker.
  selectingFile,

  /// Reading and opening the selected archive.
  readingArchive,

  /// Validating archive structure and the manifest.
  validatingManifest,

  /// Verifying the checksums recorded in the manifest.
  verifyingChecksums,

  /// Checking backup-format and database-schema compatibility plus the
  /// database and preferences contents.
  checkingCompatibility,

  /// Validation finished successfully and a preview is available.
  readyForPreview,

  /// The user cancelled file selection.
  cancelled,

  /// Validation failed.
  failure,
}
