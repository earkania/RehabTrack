import 'package:rehab_track/domain/backup/backup_availability.dart';

/// A backup previously created by, or imported into, this app, tracked so it
/// can be listed, inspected, validated, restored, shared or deleted from
/// "Manage Backups".
///
/// The registry intentionally stores **non-sensitive metadata only**: the
/// stable `content://` URI, display name, size, timestamps/versions and
/// availability state. It never stores patient, clinical or personal data, and
/// it never stores raw filesystem paths.
class RegisteredBackup {
  /// Stable SAF `content://` URI of the stored document. This is also the
  /// registry identity — see [id].
  final String contentUri;

  /// Display name assigned by the document provider (the user may rename the
  /// file; a refresh updates this to the current provider name).
  final String? displayName;

  /// When the backup was created/imported, when known.
  final DateTime? createdAt;

  /// Archive size in bytes, when known.
  final int? fileSize;

  /// Backup format version captured from the manifest, when available.
  final int? backupFormatVersion;

  /// Database schema version captured from the manifest, when available.
  final int? databaseSchemaVersion;

  /// Last known availability, always set by a probe — never claimed from a
  /// stale registry value.
  final BackupAvailability availability;

  /// When [availability] was last probed, when known.
  final DateTime? lastCheckedAt;

  /// Last-modified epoch millis reported by the document provider on the most
  /// recent probe, when available.
  final int? lastModified;

  const RegisteredBackup({
    required this.contentUri,
    this.displayName,
    this.createdAt,
    this.fileSize,
    this.backupFormatVersion,
    this.databaseSchemaVersion,
    this.availability = BackupAvailability.unknown,
    this.lastCheckedAt,
    this.lastModified,
  });

  /// The registry identity of this entry. The document URI is inherently
  /// unique per registered document, so it doubles as the stable id.
  String get id => contentUri;

  /// Whether the underlying document is currently believed to be reachable.
  bool get available => availability == BackupAvailability.available;

  /// Display name for list rows: prefers the provider-assigned name, otherwise
  /// a neutral fallback derived from the URI.
  String get displayLabel =>
      (displayName != null && displayName!.trim().isNotEmpty)
          ? displayName!
          : 'RehabTrack-Backup';

  RegisteredBackup copyWith({
    String? displayName,
    DateTime? createdAt,
    int? fileSize,
    int? backupFormatVersion,
    int? databaseSchemaVersion,
    BackupAvailability? availability,
    DateTime? lastCheckedAt,
    int? lastModified,
  }) {
    return RegisteredBackup(
      contentUri: contentUri,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      fileSize: fileSize ?? this.fileSize,
      backupFormatVersion: backupFormatVersion ?? this.backupFormatVersion,
      databaseSchemaVersion:
          databaseSchemaVersion ?? this.databaseSchemaVersion,
      availability: availability ?? this.availability,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'contentUri': contentUri,
      if (displayName != null) 'displayName': displayName,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (fileSize != null) 'fileSize': fileSize,
      if (backupFormatVersion != null)
        'backupFormatVersion': backupFormatVersion,
      if (databaseSchemaVersion != null)
        'databaseSchemaVersion': databaseSchemaVersion,
      // Stable non-localized availability value.
      'availabilityState': availability.storageKey,
      if (lastCheckedAt != null)
        'lastCheckedAt': lastCheckedAt!.toIso8601String(),
      if (lastModified != null) 'lastModified': lastModified,
    };
  }

  static RegisteredBackup? fromJson(Map<String, Object?> json) {
    final contentUri = json['contentUri'];
    if (contentUri is! String || contentUri.isEmpty) return null;
    final createdAtRaw = json['createdAt'];
    final lastCheckedRaw = json['lastCheckedAt'];
    return RegisteredBackup(
      contentUri: contentUri,
      displayName: json['displayName'] as String?,
      createdAt: createdAtRaw is String
          ? DateTime.tryParse(createdAtRaw)
          : null,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      backupFormatVersion: (json['backupFormatVersion'] as num?)?.toInt(),
      databaseSchemaVersion:
          (json['databaseSchemaVersion'] as num?)?.toInt(),
      // New payloads carry `availabilityState`; legacy payloads carried a
      // plain `available` boolean which fromStorage still understands.
      availability: BackupAvailability.fromStorage(
        json['availabilityState'] ?? json['available'],
      ),
      lastCheckedAt: lastCheckedRaw is String
          ? DateTime.tryParse(lastCheckedRaw)
          : null,
      lastModified: (json['lastModified'] as num?)?.toInt(),
    );
  }
}