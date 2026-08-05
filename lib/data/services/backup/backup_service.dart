// Named constructor parameters intentionally assign to private fields; the
// parameters must stay public so other libraries can construct the service.
// ignore_for_file: prefer_initializing_formals

import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'package:rehab_track/core/constants/app_constants.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/services/backup/backup_archive_writer.dart';
import 'package:rehab_track/data/services/backup/backup_storage_gateway.dart';
import 'package:rehab_track/data/services/backup/managed_file_collector.dart';
import 'package:rehab_track/data/services/backup/preferences_exporter.dart';
import 'package:rehab_track/domain/backup/backup_manifest.dart';
import 'package:rehab_track/domain/backup/backup_phase.dart';
import 'package:rehab_track/domain/backup/backup_result.dart';

/// Result of a completed backup operation.
class BackupOutcome {
  final BackupResult result;

  /// Non-sensitive warnings collected during the operation.
  final List<String> warnings;

  const BackupOutcome({
    required this.result,
    this.warnings = const [],
  });
}

/// Orchestrates a manual backup: snapshots the database, exports settings,
/// collects managed files, builds a `.rtb` archive and writes it to a
/// user-selected destination.
class BackupService {
  final AppDatabase _database;
  final BackupArchiveWriter _archiveWriter;
  final BackupStorageGateway _storageGateway;
  final PreferencesExporter _preferencesExporter;

  /// Resolves the application documents directory lazily so the service can be
  /// constructed synchronously and tests can inject a temp directory.
  final Future<Directory> Function() _documentsDirectory;

  /// Base directory used for temporary snapshot/archive files.
  final Directory _tempBaseDir;

  final String _appVersion;
  final String _platform;
  final DateTime Function() _clock;

  BackupService({
    required AppDatabase database,
    required BackupArchiveWriter archiveWriter,
    required BackupStorageGateway storageGateway,
    required PreferencesExporter preferencesExporter,
    required Future<Directory> Function() documentsDirectory,
    required Directory tempBaseDir,
    String appVersion = AppConstants.appVersion,
    String? platform,
    DateTime Function()? clock,
  })  : _database = database,
        _archiveWriter = archiveWriter,
        _storageGateway = storageGateway,
        _preferencesExporter = preferencesExporter,
        _documentsDirectory = documentsDirectory,
        _tempBaseDir = tempBaseDir,
        _appVersion = appVersion,
        _platform = platform ?? Platform.operatingSystem,
        _clock = clock ?? DateTime.now;

  /// Runs a full backup operation. [onPhase] is invoked when the operation
  /// transitions between phases.
  Future<BackupOutcome> createBackup({
    void Function(BackupPhase phase)? onPhase,
  }) async {
    final Directory workDir;
    try {
      workDir = await _tempBaseDir.createTemp('rehabtrack_backup_');
    } catch (_) {
      return const BackupOutcome(result: BackupResult.storageFailure);
    }
    try {
      onPhase?.call(BackupPhase.collecting);
      final collector = ManagedFileCollector(_database, await _documentsDirectory());
      final collection = await collector.collect();

      onPhase?.call(BackupPhase.snapshotting);
      final snapshotPath = p.join(workDir.path, 'database.sqlite');
      try {
        await _snapshotDatabase(snapshotPath);
      } catch (_) {
        return BackupOutcome(
          result: BackupResult.databaseFailure,
          warnings: collection.warnings,
        );
      }

      onPhase?.call(BackupPhase.collecting);
      final preferencesJson = await _preferencesExporter.exportJson();

      final manifest = await _buildManifest(
        snapshotFile: File(snapshotPath),
        preferencesBytes: Uint8List.fromList(preferencesJson.codeUnits),
        files: collection.files,
        now: _clock(),
      );

      onPhase?.call(BackupPhase.archiving);
      final archivePath = p.join(workDir.path, 'backup.rtb');
      try {
        await _archiveWriter.writeArchive(
          outputPath: archivePath,
          manifestBytes: Uint8List.fromList(
            manifest.toJsonString().codeUnits,
          ),
          databaseFile: File(snapshotPath),
          preferencesBytes: Uint8List.fromList(preferencesJson.codeUnits),
          files: collection.files,
        );
      } catch (_) {
        return BackupOutcome(
          result: BackupResult.archiveFailure,
          warnings: collection.warnings,
        );
      }

      onPhase?.call(BackupPhase.writing);
      final fileName =
          'RehabTrack-Backup-${_formatTimestamp(_clock())}.rtb';
      final saveResult = await _storageGateway.save(
        bytes: await File(archivePath).readAsBytes(),
        fileName: fileName,
      );

      if (!saveResult.succeeded) {
        return BackupOutcome(
          result: saveResult.result,
          warnings: collection.warnings,
        );
      }
      onPhase?.call(BackupPhase.done);
      return BackupOutcome(
        result: BackupResult.success,
        warnings: collection.warnings,
      );
    } catch (_) {
      return const BackupOutcome(result: BackupResult.unexpectedFailure);
    } finally {
      try {
        await workDir.delete(recursive: true);
      } catch (_) {}
    }
  }

  Future<void> _snapshotDatabase(String outputPath) async {
    final escaped = outputPath.replaceAll("'", "''");
    await _database.customStatement("VACUUM INTO '$escaped'");
  }

  Future<BackupManifest> _buildManifest({
    required File snapshotFile,
    required Uint8List preferencesBytes,
    required List<BackupSourceFile> files,
    required DateTime now,
  }) async {
    final checksums = <String, String>{
      BackupManifest.databaseFileName:
          await _sha256File(snapshotFile),
      BackupManifest.preferencesFileName: sha256.convert(preferencesBytes).toString(),
    };
    var totalSize = await snapshotFile.length() + preferencesBytes.length;
    for (final entry in files) {
      final size = await entry.file.length();
      totalSize += size;
      checksums[entry.archivePath] = await _sha256File(entry.file);
    }

    return BackupManifest(
      backupFormatVersion: BackupManifest.currentFormatVersion,
      appVersion: _appVersion,
      databaseSchemaVersion: _database.schemaVersion,
      createdAt: now,
      platform: _platform,
      fileCount: files.length,
      totalUncompressedSize: totalSize,
      checksums: checksums,
    );
  }

  static Future<String> _sha256File(File file) async {
    final digest = sha256.bind(file.openRead());
    final bytes = await digest.first;
    return bytes.toString();
  }

  static String _formatTimestamp(DateTime time) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${time.year.toString().padLeft(4, '0')}-'
        '${two(time.month)}-${two(time.day)}_'
        '${two(time.hour)}-${two(time.minute)}';
  }
}
