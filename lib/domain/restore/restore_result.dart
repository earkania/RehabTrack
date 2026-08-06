/// Outcome of a restore-apply operation.
///
/// Structurally distinct from a boolean so the UI and logs can distinguish
/// failure categories and whether the original data was recovered.
enum RestoreResult {
  /// The restore fully completed and the restored state was verified.
  success,

  /// The restore completed and the restored state was verified, but the future
  /// reminder schedule could not be fully rebuilt.
  successWithReminderWarning,

  /// The restore completed and the restored state was verified, but some
  /// optional managed files (photos) referenced by the backup are missing and
  /// were cleared so the app falls back to avatars/initials.
  successWithMissingOptionalFiles,

  /// The user cancelled before the live state was modified.
  cancelled,

  /// The device has insufficient free storage to safely run the restore, so
  /// the live state was left untouched.
  insufficientStorage,

  /// The selected archive failed validation when re-checked immediately
  /// before restore.
  validationFailure,

  /// The safety snapshot of the current state could not be created.
  safetySnapshotFailure,

  /// The restored database could not be staged/validated.
  databasePreparationFailure,

  /// The older-schema restored database could not be migrated to the current
  /// schema.
  migrationFailure,

  /// Repairing the restored file paths could not be completed.
  pathRepairFailure,

  /// The prepared database did not reach/verify the current schema version.
  databaseVerificationFailure,

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

  /// Rebuilding future reminders after a successful data restore failed.
  reminderRebuildFailure,

  /// A failure occurred and the previous state was fully recovered.
  rollbackSucceeded,

  /// A failure occurred and automatic recovery could not be completed.
  rollbackFailed,

  /// Any unexpected error.
  unexpectedFailure,
}