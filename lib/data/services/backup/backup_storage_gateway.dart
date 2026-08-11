import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:rehab_track/domain/backup/backup_result.dart';

/// Outcome of asking the user for a backup destination.
class BackupSaveResult {
  final BackupResult result;

  /// URI of the chosen destination, set only on [BackupResult.success].
  final String? path;

  /// The display name the document provider assigned to the saved file, when
  /// one is available. The user (or provider) may rename the suggested name, so
  /// this reflects the final stored name rather than the suggested one.
  final String? displayName;

  /// Archive size in bytes reported by the document provider, when available.
  final int? fileSize;

  /// Whether the app obtained a persistable read/write grant for the saved
  /// document, so it can be listed, validated, restored, shared or deleted
  /// without re-picking it later.
  final bool persisted;

  const BackupSaveResult._(
    this.result,
    this.path,
    this.displayName, {
    this.fileSize,
    this.persisted = false,
  });

  factory BackupSaveResult.success(
    String path, {
    String? displayName,
    int? fileSize,
    bool persisted = false,
  }) =>
      BackupSaveResult._(
        BackupResult.success,
        path,
        displayName,
        fileSize: fileSize,
        persisted: persisted,
      );

  factory BackupSaveResult.cancelled() =>
      const BackupSaveResult._(BackupResult.cancelled, null, null);

  factory BackupSaveResult.failed(BackupResult result) =>
      BackupSaveResult._(result, null, null);

  bool get succeeded => result == BackupResult.success;
}

/// Metadata about a previously created backup document, resolved by the native
/// side via the content resolver.
class BackupDocumentMetadata {
  /// Display name assigned by the document provider, when available.
  final String? displayName;

  /// Size in bytes, when reported by the provider.
  final int? fileSize;

  /// Last-modified epoch millis, when reported by the provider.
  final int? lastModified;

  /// Whether the document received a decodable probe response from the native
  /// side (as opposed to a missing/invalid payload).
  final bool probed;

  /// Whether the underlying document could currently be opened/queried. When
  /// false the file has been removed, moved, or access revoked.
  final bool accessible;

  const BackupDocumentMetadata({
    this.displayName,
    this.fileSize,
    this.lastModified,
    this.probed = false,
    this.accessible = false,
  });

  factory BackupDocumentMetadata.fromRaw(String raw) {
    final map = _decodeRaw(raw);
    if (map == null) {
      return const BackupDocumentMetadata();
    }
    return BackupDocumentMetadata(
      displayName: map['displayName'] as String?,
      fileSize: (map['size'] as num?)?.toInt(),
      lastModified: (map['lastModified'] as num?)?.toInt(),
      probed: true,
      accessible: (map['accessible'] as bool?) ?? false,
    );
  }

  static Map<String, Object?>? _decodeRaw(String raw) {
    if (!raw.startsWith('{')) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? decoded.cast<String, Object?>() : null;
    } catch (_) {
      return null;
    }
  }
}

/// A single document the user selected for import.
class BackupImportDocument {
  /// Stable SAF `content://` URI of the selected document.
  final String contentUri;

  /// Display name assigned by the document provider, when available.
  final String? displayName;

  const BackupImportDocument({required this.contentUri, this.displayName});
}

/// Outcome of asking the user to pick backup documents for import.
class BackupImportPickResult {
  final BackupResult result;

  /// Chosen documents, set only on [BackupResult.success].
  final List<BackupImportDocument> documents;

  const BackupImportPickResult._(this.result, this.documents);

  factory BackupImportPickResult.success(List<BackupImportDocument> documents) =>
      BackupImportPickResult._(BackupResult.success, documents);

  factory BackupImportPickResult.cancelled() =>
      const BackupImportPickResult._(BackupResult.cancelled, []);

  factory BackupImportPickResult.failed(BackupResult result) =>
      BackupImportPickResult._(result, const []);

  bool get succeeded => result == BackupResult.success;
  bool get cancelled => result == BackupResult.cancelled;
}

/// Writes a backup archive to a user-selected destination.
///
/// On Android this drives the Storage Access Framework document creator
/// (`ACTION_CREATE_DOCUMENT`) via a small `MethodChannel` implemented in
/// `MainActivity`, so the app never needs broad storage permissions. The
/// chosen destination is never remembered.
class BackupStorageGateway {
  static const MethodChannel _channel =
      MethodChannel('com.earkania.rehabtrack/backup');

  const BackupStorageGateway();

  /// Presents the save dialog, writing [bytes] to the chosen destination.
  ///
  /// Returns [BackupSaveResult.cancelled] when the user dismisses the picker
  /// and [BackupSaveResult.failed] with a mapped [BackupResult] on write
  /// errors. On success the returned result carries the final display name the
  /// document provider assigned (the user may have renamed the suggested file).
  Future<BackupSaveResult> save({
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final raw = await _channel.invokeMethod<String>('createDocument', {
        'fileName': fileName,
        'bytes': bytes,
      });
      if (raw == null || raw.isEmpty) {
        return BackupSaveResult.cancelled();
      }
      return BackupSaveResult.success(
        _uriOf(raw),
        displayName: _displayNameOf(raw),
        fileSize: _fileSizeOf(raw),
        persisted: _persistedOf(raw),
      );
    } on PlatformException catch (e) {
      return BackupSaveResult.failed(_mapPlatformException(e));
    } on MissingPluginException {
      return const BackupSaveResult._(
        BackupResult.unexpectedFailure,
        null,
        null,
      );
    } catch (_) {
      return const BackupSaveResult._(
        BackupResult.storageFailure,
        null,
        null,
      );
    }
  }

  /// The native side returns either a raw URI string (older behaviour) or a
  /// JSON document `{ "uri": "...", "displayName": "..." }`. Decode both.
  static String _uriOf(String raw) {
    final map = _decode(raw);
    if (map != null) return map['uri'] as String? ?? raw;
    return raw;
  }

  static String? _displayNameOf(String raw) {
    final map = _decode(raw);
    return map?['displayName'] as String?;
  }

  static int? _fileSizeOf(String raw) {
    final map = _decode(raw);
    return (map?['size'] as num?)?.toInt();
  }

  static bool _persistedOf(String raw) {
    final map = _decode(raw);
    return (map?['persisted'] as bool?) ?? false;
  }

  /// Resolves current metadata for a previously saved backup document at
  /// [contentUri]. The native side probes the document provider; when the
  /// document no longer exists or access was revoked, the returned metadata
  /// reports `accessible: false`.
  Future<BackupDocumentMetadata> queryDocument({
    required String contentUri,
  }) async {
    try {
      final raw = await _channel.invokeMethod<String>('queryDocument', {
        'contentUri': contentUri,
      });
      if (raw == null || raw.isEmpty) {
        return const BackupDocumentMetadata();
      }
      return BackupDocumentMetadata.fromRaw(raw);
    } on PlatformException {
      return const BackupDocumentMetadata();
    } on MissingPluginException {
      return const BackupDocumentMetadata();
    } catch (_) {
      return const BackupDocumentMetadata();
    }
  }

  /// Deletes the backup document at [contentUri] via the document provider.
  /// Returns true when the provider confirmed deletion.
  Future<bool> deleteDocument({required String contentUri}) async {
    final deleted = await _channel.invokeMethod<bool>('deleteDocument', {
      'contentUri': contentUri,
    });
    return deleted ?? false;
  }

  /// Launches the system share sheet for the backup document at [contentUri],
  /// granting read access to the chosen target.
  Future<void> shareDocument({
    required String contentUri,
    String? displayName,
  }) async {
    await _channel.invokeMethod<void>('shareDocument', {
      'contentUri': contentUri,
      'displayName': displayName,
    });
  }

  /// Whether the app currently holds a persisted read grant for [contentUri].
  Future<bool> hasPersistedPermission(String contentUri) async {
    final granted =
        await _channel.invokeMethod<bool>('persistableUriPermission', {
      'contentUri': contentUri,
    });
    return granted ?? false;
  }

  /// Presents the multi-select document picker for importing backup files.
  ///
  /// Only the user-chosen documents' URIs are returned — nothing is ever
  /// enumerated from Downloads or anywhere else. The native side persists read
  /// access for each chosen document when the provider allows it.
  Future<BackupImportPickResult> pickBackupDocuments() async {
    try {
      final raw = await _channel.invokeMethod<String>('openDocuments');
      if (raw == null || raw.isEmpty) {
        return BackupImportPickResult.cancelled();
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const BackupImportPickResult._(
          BackupResult.unexpectedFailure,
          [],
        );
      }
      final documents = <BackupImportDocument>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        final map = item.cast<String, Object?>();
        final uri = map['uri'] as String?;
        if (uri == null || uri.isEmpty) continue;
        documents.add(
          BackupImportDocument(
            contentUri: uri,
            displayName: map['displayName'] as String?,
          ),
        );
      }
      if (documents.isEmpty) {
        return const BackupImportPickResult._(
          BackupResult.unexpectedFailure,
          [],
        );
      }
      return BackupImportPickResult.success(documents);
    } on PlatformException {
      return const BackupImportPickResult._(
        BackupResult.storageFailure,
        [],
      );
    } on MissingPluginException {
      return const BackupImportPickResult._(
        BackupResult.unexpectedFailure,
        [],
      );
    } catch (_) {
      return const BackupImportPickResult._(
        BackupResult.storageFailure,
        [],
      );
    }
  }

  static Map<String, Object?>? _decode(String raw) {
    if (!raw.startsWith('{')) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? decoded.cast<String, Object?>() : null;
    } catch (_) {
      return null;
    }
  }

  BackupResult _mapPlatformException(PlatformException e) {
    final message = e.message?.toLowerCase() ?? e.code.toLowerCase();
    if (message.contains('space') ||
        message.contains('enospc') ||
        message.contains('no space left')) {
      return BackupResult.notEnoughStorage;
    }
    if (message.contains('permission') || message.contains('access')) {
      return BackupResult.permissionDenied;
    }
    return BackupResult.storageFailure;
  }
}