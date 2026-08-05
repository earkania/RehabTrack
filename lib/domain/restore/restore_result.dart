/// Outcome of a restore-apply operation.
///
/// Structurally distinct from a boolean so the UI and logs can distinguish
/// failure categories and whether the original data was recovered.
enum RestoreResult {
  /// The restore fully completed and the restored state was verified.
  success,

  /// The user cancelled before the live state was modified.
  cancelled,

  /// The selected archive failed validation when re-checked immediately
  /// before restore.
  validationFailure,

  /// The safety snapshot of the current state could not be created.
  safetySnapshotFailure,

  /// The restored database could not be staged/validated.
  databasePreparationFailure,

  /// The prepared database could not be placed into the live location.
  databaseReplacementFailure,

  /// The managed files could not be staged or placed.
  managedFileRestoreFailure,

  /// The restored preferences could not be applied.
  preferencesRestoreFailure,

  /// Reopening/reinitializing the database-backed services failed.
  reinitializationFailure,

  /// Post-restore verification of the restored state failed.
  verificationFailure,

  /// A failure occurred and the previous state was fully recovered.
  rollbackSucceeded,

  /// A failure occurred and automatic recovery could not be completed.
  rollbackFailed,

  /// The backup is supported (preview-compatible) but its older database
  /// schema requires migration, which is not implemented yet.
  migrationNotSupported,

  /// Any unexpected error.
  unexpectedFailure,
}