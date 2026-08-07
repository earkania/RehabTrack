/// Outcome of a completed backup operation.
///
/// Each value maps to a user-facing message in the backup screen. `success`
/// and `cancelled` are terminal states reached from any phase; the rest are
/// failures.
enum BackupResult {
  /// The backup archive was created and written to the chosen destination.
  success,

  /// The user cancelled the destination picker (or the operation).
  cancelled,

  /// Writing to the chosen destination failed (I/O, content provider, ...).
  storageFailure,

  /// The database snapshot could not be produced.
  databaseFailure,

  /// The archive could not be encoded (ZIP writer failure).
  archiveFailure,

  /// The app lacks permission to write to the chosen destination.
  permissionDenied,

  /// The destination reported insufficient free space.
  notEnoughStorage,

  /// Another backup operation is already running.
  operationAlreadyInProgress,

  /// Any unexpected error.
  unexpectedFailure,
}
