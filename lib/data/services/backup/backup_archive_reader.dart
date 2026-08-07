import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

import 'package:rehab_track/data/services/backup/backup_limits.dart';

/// Outcome of opening and reading a backup archive.
enum BackupArchiveReadStatus {
  /// The archive opened successfully and its entry list is available.
  success,

  /// The file is not a valid ZIP archive.
  corruptedArchive,

  /// The archive exceeds the safe size limits.
  backupTooLarge,

  /// The file could not be read (I/O error).
  storageFailure,

  /// Any unexpected error.
  unexpectedFailure,
}

/// Non-sensitive metadata about a single archive entry.
class BackupArchiveEntryInfo {
  final String name;
  final bool isFile;

  /// Uncompressed size in bytes.
  final int uncompressedSize;

  const BackupArchiveEntryInfo({
    required this.name,
    required this.isFile,
    required this.uncompressedSize,
  });
}

/// Structural information about an opened backup archive.
///
/// Contains entry names, sizes and presence flags only — never any file
/// contents or personal data.
class BackupArchiveInfo {
  final int entryCount;

  /// Unique entries in the archive (duplicates are rejected separately).
  final List<BackupArchiveEntryInfo> entries;

  /// Entry names that appear more than once (ambiguity/overwrite risk).
  final List<String> duplicateEntryNames;

  /// Sum of the uncompressed sizes of all unique entries.
  final int totalUncompressedSize;

  final bool hasManifest;
  final bool hasDatabase;
  final bool hasPreferences;

  /// Size of the archive file on disk in bytes.
  final int archiveSizeBytes;

  const BackupArchiveInfo({
    required this.entryCount,
    required this.entries,
    required this.duplicateEntryNames,
    required this.totalUncompressedSize,
    required this.hasManifest,
    required this.hasDatabase,
    required this.hasPreferences,
    required this.archiveSizeBytes,
  });

  BackupArchiveEntryInfo? entryByName(String name) {
    for (final entry in entries) {
      if (entry.name == name) return entry;
    }
    return null;
  }
}

/// Result of [BackupArchiveReader.read].
class BackupArchiveReadResult {
  final BackupArchiveReadStatus status;

  /// Set only on [BackupArchiveReadStatus.success].
  final BackupArchiveHandle? handle;

  const BackupArchiveReadResult.success(this.handle)
      : status = BackupArchiveReadStatus.success;

  const BackupArchiveReadResult.failure(this.status) : handle = null;

  bool get succeeded => status == BackupArchiveReadStatus.success;
}

/// A successfully opened archive plus lazy access to entry contents.
///
/// Entry content is decompressed on demand via [content]; no managed files are
/// extracted to disk during preview.
class BackupArchiveHandle {
  final Archive _archive;
  final BackupArchiveInfo info;

  BackupArchiveHandle._(this._archive, this.info);

  /// Decompressed content of the named entry, or null when missing/directory.
  Uint8List? content(String name) => _archive.findFile(name)?.content;
}

/// Reads the structure of a `.rtb` backup archive safely.
///
/// The reader lists entries, detects duplicates, enforces size limits and
/// makes entry contents available for validation. It never extracts managed
/// files to disk and never exposes raw archive paths to the UI.
class BackupArchiveReader {
  const BackupArchiveReader();

  Future<BackupArchiveReadResult> read(File archiveFile) async {
    final int size;
    try {
      size = await archiveFile.length();
    } catch (_) {
      return const BackupArchiveReadResult.failure(
        BackupArchiveReadStatus.storageFailure,
      );
    }
    if (size > BackupLimits.maxArchiveFileBytes) {
      return const BackupArchiveReadResult.failure(
        BackupArchiveReadStatus.backupTooLarge,
      );
    }

    final Uint8List bytes;
    try {
      bytes = await archiveFile.readAsBytes();
    } catch (_) {
      return const BackupArchiveReadResult.failure(
        BackupArchiveReadStatus.storageFailure,
      );
    }

    final Archive archive;
    final decoder = ZipDecoder();
    try {
      archive = decoder.decodeBytes(bytes);
    } catch (_) {
      return const BackupArchiveReadResult.failure(
        BackupArchiveReadStatus.corruptedArchive,
      );
    }

    // The decoder is lenient and returns an empty archive for truncated or
    // non-ZIP bytes. A valid RehabTrack backup always contains entries, so an
    // empty result is treated as corrupt.
    if (archive.files.isEmpty) {
      return const BackupArchiveReadResult.failure(
        BackupArchiveReadStatus.corruptedArchive,
      );
    }

    if (archive.files.length > BackupLimits.maxEntryCount) {
      return const BackupArchiveReadResult.failure(
        BackupArchiveReadStatus.backupTooLarge,
      );
    }

    // Raw central-directory names include duplicates; the Archive object
    // silently merges them, so duplicates are detected from the headers.
    final rawHeaders = decoder.directory.fileHeaders;
    final rawNames = rawHeaders.map((h) => h.filename).toList();
    final duplicateEntryNames = rawNames
        .toSet()
        .where((name) => rawNames.where((n) => n == name).length > 1)
        .toList();

    // Size-limit checks are performed against the central directory before
    // any content is decompressed.
    for (final header in rawHeaders) {
      final uncompressed = header.uncompressedSize;
      final compressed = header.compressedSize;
      if (uncompressed > BackupLimits.maxPerEntryUncompressedBytes) {
        return const BackupArchiveReadResult.failure(
          BackupArchiveReadStatus.backupTooLarge,
        );
      }
      final ratioGuard = BackupLimits.maxCompressionRatio *
          (compressed > 0 ? compressed : 1);
      if (uncompressed > ratioGuard) {
        return const BackupArchiveReadResult.failure(
          BackupArchiveReadStatus.backupTooLarge,
        );
      }
    }

    final entries = <BackupArchiveEntryInfo>[
      for (final file in archive.files)
        BackupArchiveEntryInfo(
          name: file.name,
          isFile: file.isFile,
          uncompressedSize: file.size,
        ),
    ];
    var totalUncompressedSize = 0;
    for (final entry in entries) {
      totalUncompressedSize += entry.uncompressedSize;
    }
    if (totalUncompressedSize > BackupLimits.maxTotalUncompressedBytes) {
      return const BackupArchiveReadResult.failure(
        BackupArchiveReadStatus.backupTooLarge,
      );
    }

    final info = BackupArchiveInfo(
      entryCount: entries.length,
      entries: entries,
      duplicateEntryNames: duplicateEntryNames,
      totalUncompressedSize: totalUncompressedSize,
      hasManifest: archive.findFile('manifest.json') != null,
      hasDatabase: archive.findFile('database.sqlite') != null,
      hasPreferences: archive.findFile('preferences.json') != null,
      archiveSizeBytes: size,
    );

    return BackupArchiveReadResult.success(
      BackupArchiveHandle._(archive, info),
    );
  }
}
