/// Compatibility between a backup's database schema and the current app.
enum BackupCompatibility {
  /// The backup's schema equals the current schema.
  compatible,

  /// The backup's schema is older but supported; migration will be required.
  compatibleMigrationRequired,

  /// The backup cannot be restored by this app version.
  incompatible,
}