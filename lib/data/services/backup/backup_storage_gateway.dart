import 'package:flutter/services.dart';

import 'package:rehab_track/domain/backup/backup_result.dart';

/// Outcome of asking the user for a backup destination.
class BackupSaveResult {
  final BackupResult result;

  /// URI of the chosen destination, set only on [BackupResult.success].
  final String? path;

  const BackupSaveResult._(this.result, this.path);

  factory BackupSaveResult.success(String path) =>
      BackupSaveResult._(BackupResult.success, path);

  factory BackupSaveResult.cancelled() =>
      const BackupSaveResult._(BackupResult.cancelled, null);

  factory BackupSaveResult.failed(BackupResult result) =>
      BackupSaveResult._(result, null);

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
  /// errors.
  Future<BackupSaveResult> save({
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final path = await _channel.invokeMethod<String>('createDocument', {
        'fileName': fileName,
        'bytes': bytes,
      });
      if (path == null || path.isEmpty) {
        return BackupSaveResult.cancelled();
      }
      return BackupSaveResult.success(path);
    } on PlatformException catch (e) {
      return BackupSaveResult.failed(_mapPlatformException(e));
    } on MissingPluginException {
      return const BackupSaveResult._(
        BackupResult.unexpectedFailure,
        null,
      );
    } catch (_) {
      return const BackupSaveResult._(
        BackupResult.storageFailure,
        null,
      );
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