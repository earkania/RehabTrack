import 'package:rehab_track/domain/backup/backup_compatibility.dart';

/// Non-sensitive warnings surfaced on the backup preview.
enum BackupWarning {
  /// The backup was created by a different app version than the current one.
  olderAppVersion,

  /// The backup database schema is older and will be migrated on restore.
  migrationRequired,
}

/// Safe metadata about a validated backup, shown on the preview screen.
///
/// The model deliberately contains **no patient, clinical, or personal data**:
/// no names, medication names, measurements, contacts, diagnoses, notes,
/// phone numbers, emails, addresses, policy numbers, or internal file paths.
class BackupPreview {
  final DateTime backupCreatedAt;

  final String appVersion;

  final int backupFormatVersion;

  /// Database schema version declared by the backup manifest.
  final int databaseSchemaVersion;

  /// Database schema version of the current app.
  final int currentDatabaseSchemaVersion;

  final BackupCompatibility compatibility;

  /// Whether the backup schema is older and will require migration.
  final bool migrationRequired;

  /// Number of patient profiles in the backup, when it could be determined
  /// safely. `null` means the count could not be read without risk.
  final int? profileCount;

  /// Number of managed files (photos) stored in the archive.
  final int managedFileCount;

  /// Size of the backup archive file in bytes.
  final int backupFileSize;

  final List<BackupWarning> warnings;

  const BackupPreview({
    required this.backupCreatedAt,
    required this.appVersion,
    required this.backupFormatVersion,
    required this.databaseSchemaVersion,
    required this.currentDatabaseSchemaVersion,
    required this.compatibility,
    required this.migrationRequired,
    this.profileCount,
    required this.managedFileCount,
    required this.backupFileSize,
    this.warnings = const [],
  });
}
