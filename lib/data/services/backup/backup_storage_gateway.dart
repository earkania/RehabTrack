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

  const BackupSaveResult._(this.result, this.path, this.displayName);

  factory BackupSaveResult.success(String path, {String? displayName}) =>
      BackupSaveResult._(BackupResult.success, path, displayName);

  factory BackupSaveResult.cancelled() =>
      const BackupSaveResult._(BackupResult.cancelled, null, null);

  factory BackupSaveResult.failed(BackupResult result) =>
      BackupSaveResult._(result, null, null);

  bool get succeeded => result == BackupResult.success;
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