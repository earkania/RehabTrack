/// Outcome of a rollback attempt after a failed restore.
enum RestoreRollbackResult {
  /// The previous state (database, managed files, preferences) was restored
  /// and verified.
  rollbackSucceeded,

  /// Automatic recovery could not be completed; recovery files are retained in
  /// app-private storage.
  rollbackFailed,
}