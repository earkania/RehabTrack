import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

/// A managed file to be embedded in a backup archive.
///
/// [archivePath] must be a valid archive-relative path (see
/// [BackupArchivePath.validate]).
class BackupSourceFile {
  final String archivePath;
  final File file;

  const BackupSourceFile({required this.archivePath, required this.file});
}

/// Central validation of archive-relative entry names.
///
/// Entry names must never be absolute, must never traverse directories
/// (`..`), must not contain backslashes, and must live either at the archive
/// root (manifest/database/preferences) or under `files/`.
class BackupArchivePath {
  BackupArchivePath._();

  static const _allowedRootEntries = {
    'manifest.json',
    'database.sqlite',
    'preferences.json',
  };

  /// Throws a [FormatException] when [path] is not a safe archive entry name.
  static void validate(String path) {
    if (path.isEmpty) {
      throw const FormatException('Archive entry name must not be empty.');
    }
    if (path.startsWith('/') || path.contains('\\')) {
      throw FormatException('Unsafe archive entry name: "$path".');
    }
    if (p.isAbsolute(path)) {
      throw FormatException('Absolute archive entry name: "$path".');
    }
    final segments = p.posix.split(p.posix.normalize(path));
    if (segments.contains('..') || segments.contains('.')) {
      throw FormatException('Archive entry traverses directories: "$path".');
    }
    if (!_allowedRootEntries.contains(path) &&
        !path.startsWith('files/')) {
      throw FormatException('Unexpected archive entry name: "$path".');
    }
  }
}

/// Writes the contents of a `.rtb` backup as a ZIP archive.
///
/// The database and managed files are streamed from disk so that memory usage
/// stays bounded regardless of archive size.
class BackupArchiveWriter {
  /// Streams a ZIP archive to [outputPath].
  ///
  /// Entries are written in a fixed order: `manifest.json`, `database.sqlite`,
  /// `preferences.json`, then every managed file under `files/`.
  Future<void> writeArchive({
    required String outputPath,
    required Uint8List manifestBytes,
    required File databaseFile,
    required Uint8List preferencesBytes,
    required List<BackupSourceFile> files,
  }) async {
    final encoder = ZipFileEncoder();
    encoder.create(outputPath);
    try {
      encoder.addArchiveFile(
        ArchiveFile.typedData('manifest.json', manifestBytes),
      );
      await encoder.addFile(databaseFile, 'database.sqlite');
      encoder.addArchiveFile(
        ArchiveFile.typedData('preferences.json', preferencesBytes),
      );
      for (final entry in files) {
        BackupArchivePath.validate(entry.archivePath);
        await encoder.addFile(entry.file, entry.archivePath);
      }
    } finally {
      await encoder.close();
    }
  }
}
