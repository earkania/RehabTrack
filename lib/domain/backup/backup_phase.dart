/// Phases of a manual backup operation, in execution order.
///
/// The UI observes [BackupOperationState.phase] to show progress.
enum BackupPhase {
  /// No operation running.
  idle,

  /// Collecting managed files (profile/care-contact photos) and exporting
  /// settings.
  collecting,

  /// Creating a consistent snapshot of the database.
  snapshotting,

  /// Building the manifest and writing the ZIP archive.
  archiving,

  /// Writing the archive to the chosen destination.
  writing,

  /// Operation finished successfully.
  done,
}
