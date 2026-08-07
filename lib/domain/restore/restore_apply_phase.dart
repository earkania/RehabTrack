/// Phases of a restore-apply operation, in execution order.
///
/// The UI maps these to localized, non-sensitive progress messages. Exact
/// phase names do not expose personal data or filesystem details.
enum RestoreApplyPhase {
  /// Preparing the restore workspace and reading the validated backup.
  preparingRestore,

  /// Capturing the current database, preferences and managed files so the
  /// operation can be rolled back.
  creatingSafetySnapshot,

  /// Validating and staging the restored database in temporary storage.
  preparingDatabase,

  /// Migrating an older-schema restored database to the current schema (only
  /// when the backup predates the current schema).
  migratingDatabase,

  /// Validating that the migrated database reached the current schema and is
  /// internally consistent.
  validatingMigratedDatabase,

  /// Repairing stored file paths in the prepared database so they resolve to
  /// this device's managed-file location.
  repairingFilePaths,

  /// Staging restored managed files in temporary storage.
  preparingFiles,

  /// Staging restored preferences.
  preparingPreferences,

  /// Closing/pausing live database-backed services before replacement.
  pausingServices,

  /// Replacing the live database with the prepared database.
  replacingDatabase,

  /// Replacing the live managed files with the prepared files.
  restoringFiles,

  /// Applying the restored preferences.
  restoringPreferences,

  /// Reopening the database and reinitializing services and providers.
  reinitializing,

  /// Verifying that the restored state can be read.
  verifyingData,

  /// Rebuilding future medication, measurement and doctor-visit reminders from
  /// the restored data.
  rebuildingReminders,

  /// Recovering the previous state after a failure.
  rollingBack,

  /// Cleaning up temporary resources and finalizing.
  finalizing,
}