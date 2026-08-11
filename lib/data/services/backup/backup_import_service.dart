// Named constructor parameters intentionally assign to private fields; the
// parameters must stay public so other libraries can construct the service.
// ignore_for_file: prefer_initializing_formals

import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:rehab_track/core/constants/app_constants.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/services/backup/backup_archive_reader.dart';
import 'package:rehab_track/data/services/backup/backup_document_gateway.dart';
import 'package:rehab_track/data/services/backup/backup_registry.dart';
import 'package:rehab_track/data/services/backup/backup_storage_gateway.dart';
import 'package:rehab_track/data/services/backup/backup_validator.dart';
import 'package:rehab_track/domain/backup/backup_availability.dart';
import 'package:rehab_track/domain/backup/backup_result.dart';
import 'package:rehab_track/domain/backup/backup_validation_result.dart';
import 'package:rehab_track/domain/backup/registered_backup.dart';

/// Overall status of an import operation.
enum BackupImportStatus {
  /// At least one file was processed and no fatal error occurred.
  success,

  /// The user dismissed the picker.
  cancelled,

  /// The picker or a copy step failed in a way unrelated to file validity.
  storageFailure,

  /// Any other unexpected failure.
  unexpectedFailure,
}

/// Aggregated result of importing one batch of backup documents.
class BackupImportOutcome {
  final BackupImportStatus status;

  /// Documents that were newly registered.
  final int imported;

  /// Documents that were already registered and merely had metadata refreshed.
  final int refreshed;

  /// Selected files that were not valid RehabTrack backups and were skipped.
  final int invalidSkipped;

  /// Files that could not be copied or registered due to I/O/storage errors.
  final int failed;

  const BackupImportOutcome({
    required this.status,
    this.imported = 0,
    this.refreshed = 0,
    this.invalidSkipped = 0,
    this.failed = 0,
  });

  bool get succeeded => status == BackupImportStatus.success;
  bool get cancelled => status == BackupImportStatus.cancelled;
}

/// Imports existing `.rtb` backup documents into the backup registry.
///
/// The user picks one or more documents through the Storage Access Framework
/// picker ([BackupStorageGateway.pickBackupDocuments]); the app never scans
/// the filesystem and never requests broad storage permissions.
///
/// Every selected file is copied to an app-owned temp file and validated with
/// the canonical [BackupValidator]. Valid documents are registered with their
/// manifest-derived versions plus provider metadata; invalid ones are skipped
/// without failing the rest of the batch. Duplicate URIs refresh the existing
/// registry entry instead of creating a second one.
class BackupImportService {
  final BackupStorageGateway _storageGateway;
  final BackupDocumentGateway _documentGateway;
  final BackupRegistry _registry;
  final BackupArchiveReader _archiveReader;
  final BackupValidator _validator;
  final Directory _tempBaseDir;
  final int _currentDatabaseSchemaVersion;
  final String _currentAppVersion;
  final DateTime Function() _clock;

  BackupImportService({
    required BackupStorageGateway storageGateway,
    required BackupDocumentGateway documentGateway,
    required BackupRegistry registry,
    required Directory tempBaseDir,
    BackupArchiveReader archiveReader = const BackupArchiveReader(),
    BackupValidator validator = const BackupValidator(),
    int currentDatabaseSchemaVersion = AppDatabase.currentSchemaVersion,
    String currentAppVersion = AppConstants.appVersion,
    DateTime Function()? clock,
  })  : _storageGateway = storageGateway,
        _documentGateway = documentGateway,
        _registry = registry,
        _archiveReader = archiveReader,
        _validator = validator,
        _tempBaseDir = tempBaseDir,
        _currentDatabaseSchemaVersion = currentDatabaseSchemaVersion,
        _currentAppVersion = currentAppVersion,
        _clock = clock ?? DateTime.now;

  /// Runs an import batch, returning aggregated per-file results.
  Future<BackupImportOutcome> import() async {
    final pick = await _storageGateway.pickBackupDocuments();
    if (pick.cancelled) {
      return const BackupImportOutcome(status: BackupImportStatus.cancelled);
    }
    if (!pick.succeeded) {
      return BackupImportOutcome(
        status: pick.result == BackupResult.storageFailure
            ? BackupImportStatus.storageFailure
            : BackupImportStatus.unexpectedFailure,
      );
    }

    final Directory workDir;
    try {
      workDir = await _tempBaseDir.createTemp('rehabtrack_import_');
    } catch (_) {
      return const BackupImportOutcome(
        status: BackupImportStatus.storageFailure,
      );
    }

    var imported = 0;
    var refreshed = 0;
    var invalidSkipped = 0;
    var failed = 0;
    try {
      for (var i = 0; i < pick.documents.length; i++) {
        final document = pick.documents[i];
        final file = File(p.join(workDir.path, 'import_$i.rtb'));
        try {
          await _documentGateway.copyDocument(
            contentUri: document.contentUri,
            destinationPath: file.path,
          );
        } catch (_) {
          failed++;
          continue;
        }

        final read = await _archiveReader.read(file);
        if (!read.succeeded) {
          invalidSkipped++;
          continue;
        }

        final BackupValidationOutcome outcome;
        try {
          outcome = await _validator.validate(
            handle: read.handle!,
            tempDir: workDir,
            currentDatabaseSchemaVersion: _currentDatabaseSchemaVersion,
            currentAppVersion: _currentAppVersion,
          );
        } catch (_) {
          failed++;
          continue;
        }
        if (outcome.result != BackupValidationResult.valid ||
            outcome.preview == null) {
          invalidSkipped++;
          continue;
        }

        final preview = outcome.preview!;
        final entry = RegisteredBackup(
          contentUri: document.contentUri,
          displayName: document.displayName,
          createdAt: preview.backupCreatedAt,
          fileSize: preview.backupFileSize,
          backupFormatVersion: preview.backupFormatVersion,
          databaseSchemaVersion: preview.databaseSchemaVersion,
          availability: BackupAvailability.available,
          lastCheckedAt: _clock(),
        );

        final alreadyRegistered = await _registry.contains(document.contentUri);
        if (alreadyRegistered) {
          await _registry.update(entry);
          refreshed++;
        } else {
          await _registry.add(entry);
          imported++;
        }
      }
      return BackupImportOutcome(
        status: BackupImportStatus.success,
        imported: imported,
        refreshed: refreshed,
        invalidSkipped: invalidSkipped,
        failed: failed,
      );
    } catch (_) {
      return BackupImportOutcome(
        status: BackupImportStatus.unexpectedFailure,
        imported: imported,
        refreshed: refreshed,
        invalidSkipped: invalidSkipped,
        failed: failed,
      );
    } finally {
      try {
        await workDir.delete(recursive: true);
      } catch (_) {
        // Best-effort temp cleanup.
      }
    }
  }
}