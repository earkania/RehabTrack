import 'dart:io';

import 'package:rehab_track/data/services/backup/backup_document_gateway.dart';
import 'package:rehab_track/domain/backup/backup_validation_result.dart';

/// Result of selecting and copying a backup document.
class BackupSelectionOutcome {
  final BackupValidationResult result;

  /// The copied local file, set only on success.
  final File? file;

  const BackupSelectionOutcome._(this.result, this.file);

  factory BackupSelectionOutcome.success(File file) =>
      BackupSelectionOutcome._(BackupValidationResult.valid, file);

  factory BackupSelectionOutcome.cancelled() =>
      const BackupSelectionOutcome._(BackupValidationResult.cancelled, null);

  factory BackupSelectionOutcome.failure(BackupValidationResult result) =>
      BackupSelectionOutcome._(result, null);

  bool get succeeded => file != null;
  bool get cancelled => result == BackupValidationResult.cancelled;
}

/// Selects a backup document through the Android Storage Access Framework and
/// copies it into an app-owned temporary file.
///
/// The destination is created inside the app's temporary directory; the
/// selected content URI is only ever resolved by the native content resolver,
/// never treated as a filesystem path and never exposed to callers.
class RestoreSelectionService {
  final BackupDocumentGateway _gateway;

  const RestoreSelectionService(this._gateway);

  /// Opens the document picker and copies the chosen file to [tempFilePath].
  Future<BackupSelectionOutcome> select({
    required String tempFilePath,
  }) async {
    String? contentUri;
    try {
      contentUri = await _gateway.openDocument();
    } catch (_) {
      return BackupSelectionOutcome.failure(
        BackupValidationResult.storageFailure,
      );
    }
    if (contentUri == null) {
      return BackupSelectionOutcome.cancelled();
    }
    try {
      await _gateway.copyDocument(
        contentUri: contentUri,
        destinationPath: tempFilePath,
      );
    } catch (_) {
      return BackupSelectionOutcome.failure(
        BackupValidationResult.storageFailure,
      );
    }
    return BackupSelectionOutcome.success(File(tempFilePath));
  }
}