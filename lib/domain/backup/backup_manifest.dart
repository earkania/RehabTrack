import 'dart:convert';

/// Contents of the `manifest.json` entry inside a `.rtb` backup archive.
///
/// The format is versioned independently of the app and of the database
/// schema, so future readers can detect and reject unknown layouts instead of
/// misinterpreting them.
class BackupManifest {
  /// Version of the `.rtb` archive layout. Bumped only when the archive
  /// structure changes (not per app release).
  static const int currentFormatVersion = 1;

  static const String databaseFileName = 'database.sqlite';
  static const String preferencesFileName = 'preferences.json';
  static const String manifestFileName = 'manifest.json';
  static const String filesDirectory = 'files/';

  final int backupFormatVersion;
  final String appVersion;
  final int databaseSchemaVersion;

  /// UTC timestamp of when the backup was created (ISO 8601).
  final DateTime createdAt;

  final String platform;

  /// Number of managed files stored under [filesDirectory].
  final int fileCount;

  /// Combined uncompressed size in bytes of the database, preferences and all
  /// managed files.
  final int totalUncompressedSize;

  /// SHA-256 hex digest keyed by archive-relative path for the database,
  /// preferences and every managed file.
  final Map<String, String> checksums;

  const BackupManifest({
    required this.backupFormatVersion,
    required this.appVersion,
    required this.databaseSchemaVersion,
    required this.createdAt,
    required this.platform,
    required this.fileCount,
    required this.totalUncompressedSize,
    required this.checksums,
  });

  Map<String, Object?> toJson() {
    return {
      'backupFormatVersion': backupFormatVersion,
      'appVersion': appVersion,
      'databaseSchemaVersion': databaseSchemaVersion,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'platform': platform,
      'databaseFileName': databaseFileName,
      'preferencesFileName': preferencesFileName,
      'fileCount': fileCount,
      'totalUncompressedSize': totalUncompressedSize,
      'checksums': checksums,
    };
  }

  factory BackupManifest.fromJson(Map<String, Object?> json) {
    return BackupManifest(
      backupFormatVersion: json['backupFormatVersion'] as int,
      appVersion: json['appVersion'] as String,
      databaseSchemaVersion: json['databaseSchemaVersion'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      platform: json['platform'] as String,
      fileCount: json['fileCount'] as int,
      totalUncompressedSize: json['totalUncompressedSize'] as int,
      checksums: Map<String, String>.from(
        (json['checksums'] as Map).cast<String, Object?>(),
      ),
    );
  }

  factory BackupManifest.fromJsonString(String source) {
    return BackupManifest.fromJson(
      jsonDecode(source) as Map<String, Object?>,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  /// Validates structural constraints of a parsed manifest. Returns a list of
  /// problems; an empty list means the manifest is well-formed.
  List<String> validate() {
    final problems = <String>[];
    if (backupFormatVersion != currentFormatVersion) {
      problems.add(
        'Unsupported backup format version $backupFormatVersion '
        '(expected $currentFormatVersion).',
      );
    }
    if (appVersion.isEmpty) {
      problems.add('appVersion must not be empty.');
    }
    if (databaseSchemaVersion <= 0) {
      problems.add('databaseSchemaVersion must be positive.');
    }
    if (fileCount < 0) {
      problems.add('fileCount must not be negative.');
    }
    if (totalUncompressedSize < 0) {
      problems.add('totalUncompressedSize must not be negative.');
    }
    checksums.forEach((path, digest) {
      if (!_isAllowedArchivePath(path)) {
        problems.add('Checksum key "$path" is not a valid archive path.');
      }
      if (digest.isEmpty) {
        problems.add('Checksum for "$path" must not be empty.');
      }
    });
    return problems;
  }

  /// Whether [path] is an allowed archive-relative path for a manifest
  /// checksum (top-level entry or a file under `files/`).
  static bool _isAllowedArchivePath(String path) {
    if (path == databaseFileName ||
        path == preferencesFileName ||
        path == manifestFileName) {
      return true;
    }
    return path.startsWith(filesDirectory) && !path.contains('..');
  }
}

/// True when the checksum map covers the database, preferences and all managed
/// files listed in the archive.
bool manifestChecksumsComplete(BackupManifest manifest, int fileCount) {
  if (!manifest.checksums.containsKey(BackupManifest.databaseFileName)) {
    return false;
  }
  if (!manifest.checksums
      .containsKey(BackupManifest.preferencesFileName)) {
    return false;
  }
  final fileEntries = manifest.checksums.keys
      .where((p) => p.startsWith(BackupManifest.filesDirectory));
  return fileEntries.length == fileCount;
}
