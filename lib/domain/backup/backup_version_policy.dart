import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/domain/backup/backup_manifest.dart';

/// Single source of truth for the version policies that govern backup/restore
/// compatibility.
///
/// Every layer (preview validation, restore apply, interrupted recovery) must
/// read these constants rather than duplicating the numbers, so a future
/// schema bump or an expanded migration path is kept consistent.
abstract final class BackupVersionPolicy {
  /// Current on-disk database schema produced by [AppDatabase]'s migration
  /// strategy. A backup whose declared schema is greater than this is a
  /// "newer" backup and cannot be restored.
  static const int currentDatabaseSchemaVersion =
      AppDatabase.currentSchemaVersion;

  /// Oldest database schema this app can restore. Drift's cumulative migration
  /// strategy covers every `from >= 1`, so any backup at or above this version
  /// has a supported migration path.
  static const int minSupportedDatabaseSchemaVersion = 1;

  /// The backup-archive layout version this app understands. Backups with a
  /// greater [BackupManifest.backupFormatVersion] are rejected as unsupported.
  static const int supportedBackupFormatVersion =
      BackupManifest.currentFormatVersion;

  /// Whether a backup at [schemaVersion] is restorable by the current app.
  ///
  /// A backup is restorable when its schema is not newer than the app and not
  /// older than the oldest schema we have a migration path from.
  static bool isSchemaRestorable(int schemaVersion) =>
      schemaVersion >= minSupportedDatabaseSchemaVersion &&
      schemaVersion <= currentDatabaseSchemaVersion;
}