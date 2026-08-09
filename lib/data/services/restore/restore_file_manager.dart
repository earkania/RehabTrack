import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'package:rehab_track/data/services/backup/backup_archive_reader.dart';
import 'package:rehab_track/data/services/backup/backup_archive_writer.dart';
import 'package:rehab_track/domain/backup/backup_manifest.dart';

/// Thrown when restored managed files cannot be staged or placed.
class ManagedFileRestoreException implements Exception {
  const ManagedFileRestoreException();
}

/// Record of which managed roots were moved aside during replacement, so the
/// swap can be reversed.
class FilesSwapHandle {
  final List<String> movedRootNames;

  const FilesSwapHandle({required this.movedRootNames});
}

/// Stages, validates and replaces app-managed files (profile and care-contact
/// photos, lab analysis attachments) from the backup archive.
///
/// Extraction re-validates every path and re-verifies SHA-256 checksums against
/// the manifest, independent of the earlier preview validation. Replacement
/// moves the live directory aside into the rollback workspace and moves the
/// prepared directory into place (no merging): the resulting state mirrors the
/// backup exactly.
class RestoreFileManager {
  const RestoreFileManager();

  static const List<String> managedRootNames = [
    'profile_images',
    'care_contact_images',
    'lab_analyses',
    'doctor_prescriptions',
  ];

  /// Extracts all entries under `files/` into [preparedFilesDir], preserving
  /// their relative layout. Returns the number of files extracted.
  Future<int> extract({
    required BackupArchiveHandle handle,
    required Map<String, String> checksums,
    required Directory preparedFilesDir,
  }) async {
    await preparedFilesDir.create(recursive: true);
    var count = 0;
    try {
      for (final entry in handle.info.entries) {
        if (!entry.name.startsWith(BackupManifest.filesDirectory) ||
            !entry.isFile) {
          continue;
        }
        BackupArchivePath.validate(entry.name);
        final relative = entry.name.substring(
          BackupManifest.filesDirectory.length,
        );
        if (relative.isEmpty) continue;

        final content = handle.content(entry.name);
        if (content == null) {
          throw const ManagedFileRestoreException();
        }
        final digest = sha256.convert(content).toString();
        if (checksums[entry.name] != digest) {
          throw const ManagedFileRestoreException();
        }

        final target = File(
          p.join(preparedFilesDir.path, p.posix.normalize(relative)),
        );
        await target.parent.create(recursive: true);
        await target.writeAsBytes(content, flush: true);
        count++;
      }
    } catch (_) {
      throw const ManagedFileRestoreException();
    }
    return count;
  }

  /// Replaces live managed roots with the prepared ones. Returns a handle for
  /// rollback. Missing prepared roots result in the live root being removed
  /// (moved aside), mirroring an empty backup. On a partial failure any roots
  /// already moved aside are moved back before rethrowing.
  Future<FilesSwapHandle> replace({
    required Directory documentsDir,
    required Directory preparedFilesDir,
    required Directory rollbackDir,
  }) async {
    final moved = <String>[];
    try {
      for (final name in managedRootNames) {
        final live = Directory(p.join(documentsDir.path, name));
        final prepared = Directory(p.join(preparedFilesDir.path, name));

        if (await live.exists()) {
          final aside = Directory(
            p.join(rollbackDir.path, 'files', name),
          );
          await aside.parent.create(recursive: true);
          if (await aside.exists()) {
            await aside.delete(recursive: true);
          }
          await live.rename(aside.path);
          moved.add(name);
        }
        if (await prepared.exists()) {
          final target = Directory(p.join(documentsDir.path, name));
          await target.parent.create(recursive: true);
          if (await target.exists()) {
            await target.delete(recursive: true);
          }
          await prepared.rename(target.path);
        }
      }
    } catch (_) {
      for (final name in moved.reversed) {
        try {
          final live = Directory(p.join(documentsDir.path, name));
          final aside = Directory(p.join(rollbackDir.path, 'files', name));
          if (await live.exists()) {
            await live.delete(recursive: true);
          }
          if (await aside.exists()) {
            await aside.rename(live.path);
          }
        } catch (_) {}
      }
      throw const ManagedFileRestoreException();
    }
    return FilesSwapHandle(movedRootNames: moved);
  }

  /// Reverses a files swap: removes the restored roots and moves any aside
  /// directories back.
  Future<void> restore({
    required Directory documentsDir,
    required Directory rollbackDir,
    required FilesSwapHandle handle,
  }) async {
    try {
      for (final name in managedRootNames) {
        final live = Directory(p.join(documentsDir.path, name));
        final aside = Directory(p.join(rollbackDir.path, 'files', name));

        if (await live.exists()) {
          await live.delete(recursive: true);
        }
        if (await aside.exists()) {
          await aside.rename(live.path);
        }
      }
    } catch (_) {
      throw const ManagedFileRestoreException();
    }
  }
}

/// Copies a managed directory tree (used when reading the safety snapshot back
/// during rollback).
Future<void> copyDirectoryTree(Directory source, Directory target) async {
  if (!await source.exists()) return;
  await target.create(recursive: true);
  await for (final entity in source.list(recursive: false)) {
    if (entity is Directory) {
      await copyDirectoryTree(
        entity,
        Directory(p.join(target.path, p.basename(entity.path))),
      );
    } else if (entity is File) {
      await File(p.join(target.path, p.basename(entity.path)))
          .writeAsBytes(await entity.readAsBytes(), flush: true);
    }
  }
}

/// Moves the managed-file tree back into the live documents directory.
Future<void> restoreManagedFilesFrom(
  Directory source,
  Directory documentsDir,
) async {
  if (!await source.exists()) return;
  for (final name in RestoreFileManager.managedRootNames) {
    final from = Directory(p.join(source.path, name));
    if (!await from.exists()) continue;
    final live = Directory(p.join(documentsDir.path, name));
    if (await live.exists()) {
      await live.delete(recursive: true);
    }
    await from.rename(live.path);
  }
}