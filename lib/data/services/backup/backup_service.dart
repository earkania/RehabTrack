// Named constructor parameters intentionally assign to private fields; the
// parameters must stay public so other libraries can construct the service.
// ignore_for_file: prefer_initializing_formals

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'package:rehab_track/core/constants/app_constants.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/services/backup/backup_archive_reader.dart';
import 'package:rehab_track/data/services/backup/backup_archive_writer.dart';
import 'package:rehab_track/data/services/backup/backup_storage_gateway.dart';
import 'package:rehab_track/data/services/backup/managed_file_collector.dart';
import 'package:rehab_track/data/services/backup/preferences_exporter.dart';
import 'package:rehab_track/data/services/storage/storage_inspector.dart';
import 'package:rehab_track/domain/backup/backup_manifest.dart';
import 'package:rehab_track/domain/backup/backup_phase.dart';
import 'package:rehab_track/domain/backup/backup_result.dart';

/// Result of a completed backup operation.
class BackupOutcome {
  final BackupResult result;

  /// Non-sensitive warnings collected during the operation.
  final List<String> warnings;

  /// Final display name of the stored file as reported by the document
  /// provider, when available (set only on success).
  final String? savedFileName;

  /// Stable `content://` URI of the stored document, when available (set only
  /// on success).
  final String? savedContentUri;

  /// Archive size in bytes reported by the document provider, when available.
  final int? savedFileSize;

  /// Whether the app obtained a persistable grant for the stored document.
  final bool persisted;

  const BackupOutcome({
    required this.result,
    this.warnings = const [],
    this.savedFileName,
    this.savedContentUri,
    this.savedFileSize,
    this.persisted = false,
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
  final BackupArchiveReader _archiveReader;
  final StorageInspector _storageInspector;

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
    BackupArchiveReader archiveReader = const BackupArchiveReader(),
    StorageInspector storageInspector = const StorageInspector(),
  })  : _database = database,
        _archiveWriter = archiveWriter,
        _storageGateway = storageGateway,
        _preferencesExporter = preferencesExporter,
        _archiveReader = archiveReader,
        _storageInspector = storageInspector,
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

      // Integrity self-check: reopen the freshly written archive and re-verify
      // structure, manifest and checksums before presenting it to the user.
      // A backup is only reported successful after this passes.
      final archive = File(archivePath);
      final selfCheck = await _selfCheckArchive(archive);
      if (!selfCheck) {
        return BackupOutcome(
          result: BackupResult.archiveFailure,
          warnings: collection.warnings,
        );
      }

      // Conservative storage guard: the destination write needs roughly the
      // archive size; require a safe margin so a partial write is avoided
      // where the free space can be measured.
      final freeBytes = await _storageInspector.freeBytes(workDir.path);
      final archiveSize = await archive.length();
      if (freeBytes != null && freeBytes < archiveSize * 2) {
        return BackupOutcome(
          result: BackupResult.notEnoughStorage,
          warnings: collection.warnings,
        );
      }

      onPhase?.call(BackupPhase.writing);
      final fileName =
          _sanitizeFileName('RehabTrack-Backup-${_formatTimestamp(_clock())}.rtb');
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
        savedFileName: saveResult.displayName,
        savedContentUri: saveResult.path,
        savedFileSize: saveResult.fileSize,
        persisted: saveResult.persisted,
      );
    } catch (_) {
      return const BackupOutcome(result: BackupResult.unexpectedFailure);
    } finally {
      try {
        await workDir.delete(recursive: true);
      } catch (_) {}
    }
  }

  /// Reopens [archive] and verifies required entries, manifest structure,
  /// checksums and entry-path safety. Returns false when any check fails so a
  /// corrupt or incomplete archive is never presented as a valid backup.
  Future<bool> _selfCheckArchive(File archive) async {
    try {
      final read = await _archiveReader.read(archive);
      if (!read.succeeded) return false;
      final handle = read.handle!;
      final info = handle.info;
      if (info.duplicateEntryNames.isNotEmpty) return false;
      if (!info.hasManifest || !info.hasDatabase || !info.hasPreferences) {
        return false;
      }
      for (final entry in info.entries) {
        try {
          BackupArchivePath.validate(entry.name);
        } catch (_) {
          return false;
        }
      }
      final manifestBytes = handle.content(BackupManifest.manifestFileName);
      if (manifestBytes == null) return false;
      final manifest = BackupManifest.fromJsonString(utf8.decode(manifestBytes));
      if (manifest.validate().isNotEmpty) return false;
      if (!manifestChecksumsComplete(manifest, info.entries
              .where((e) => e.name.startsWith(BackupManifest.filesDirectory))
              .length)) {
        return false;
      }
      for (final entry in manifest.checksums.entries) {
        final content = handle.content(entry.key);
        if (content == null) return false;
        if (sha256.convert(content).toString() != entry.value) return false;
      }
      return true;
    } catch (_) {
      return false;
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

  /// Sanitizes a suggested backup file name so it never carries path
  /// separators, control characters or other invalid filesystem characters.
  /// The generated names already comply; this guards against edge cases.
  static String _sanitizeFileName(String fileName) {
    final cleaned = fileName.replaceAll(
      RegExp(r'[\\/:*?"<>|\x00-\x1f]'),
      '-',
    );
    final trimmed = cleaned.trim();
    if (trimmed.isEmpty) return 'RehabTrack-Backup.rtb';
    return trimmed;
  }
}
