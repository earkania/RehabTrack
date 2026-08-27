/// Metadata for a report PDF persisted in a user-accessible location
/// (`Downloads/RehabTrack` on Android 10+, app-specific Downloads folder on
/// older versions).
class SavedReportFile {
  const SavedReportFile({
    required this.displayName,
    required this.logicalLocation,
    required this.mimeType,
    required this.size,
    required this.createdAt,
    this.contentUri,
  });

  /// Final on-disk name, duplicate-safe (e.g. `Report_2.pdf`).
  final String displayName;

  /// Friendly, user-facing location label such as `Downloads/RehabTrack`.
  /// Never a raw filesystem path or content URI.
  final String logicalLocation;

  final String mimeType;
  final int size;
  final DateTime createdAt;

  /// `content://` URI used for open/share. Null only if the platform could
  /// not expose one; downstream actions require it.
  final String? contentUri;

  factory SavedReportFile.fromJson(Map<String, dynamic> json) {
    return SavedReportFile(
      displayName: json['displayName'] as String,
      logicalLocation: json['logicalLocation'] as String,
      mimeType: json['mimeType'] as String? ?? 'application/pdf',
      size: json['size'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : DateTime.now(),
      contentUri: json['contentUri'] as String?,
    );
  }
}

/// Controlled failure of a save/open/share operation. [code] mirrors the
/// native error codes so callers can branch without parsing messages.
class ReportStorageException implements Exception {
  const ReportStorageException(this.code, {this.message});

  /// `SAVE_ERROR`, `STORAGE_UNAVAILABLE`, `NO_VIEWER`, `SHARE_ERROR`,
  /// `INVALID_ARGUMENTS`, `MISSING_PLUGIN`.
  final String code;
  final String? message;

  @override
  String toString() => 'ReportStorageException($code): $message';
}
