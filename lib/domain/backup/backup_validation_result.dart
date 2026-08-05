/// Outcome of validating a selected backup archive before restore.
///
/// Each value maps to a localized, safe user message. `valid` (preview ready)
/// and `cancelled` are terminal states; the rest are failures. The restore
/// engine is not invoked in this phase — seeing `valid` only means the archive
/// passed every check and a preview can be shown.
enum BackupValidationResult {
  /// The archive is fully valid and a preview is available. Restore itself is
  /// intentionally not performed yet.
  valid,

  /// The user dismissed the document picker. Not an error.
  cancelled,

  /// Another backup or restore operation is already running.
  operationAlreadyInProgress,

  /// The file is not a readable RehabTrack backup archive.
  invalidArchive,

  /// The archive has no `manifest.json`.
  missingManifest,

  /// The manifest could not be parsed or is structurally invalid.
  invalidManifest,

  /// The backup format version is newer than this app supports.
  unsupportedBackupFormat,

  /// The backup database schema is newer than this app supports.
  newerDatabaseVersion,

  /// The backup database schema is too old and no supported migration path
  /// exists.
  unsupportedOldDatabaseVersion,

  /// The database entry is missing from the archive.
  missingDatabase,

  /// The preferences entry is missing from the archive.
  missingPreferences,

  /// A required checksum is missing or does not match.
  checksumMismatch,

  /// The archive contains unsafe or ambiguous entry paths.
  unsafeArchivePath,

  /// The archive is corrupted or not a valid ZIP.
  corruptedArchive,

  /// The archive exceeds the safe size limits.
  backupTooLarge,

  /// The `database.sqlite` is not a valid SQLite database for its schema.
  invalidBackupDatabase,

  /// The `preferences.json` is invalid or contains invalid values.
  invalidBackupPreferences,

  /// A storage/IO failure occurred while reading the backup.
  storageFailure,

  /// Any unexpected error.
  unexpectedFailure,
}