import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/services/backup/backup_archive_writer.dart';

/// A scan of app-managed image files for inclusion in a backup.
class ManagedFileCollection {
  final List<BackupSourceFile> files;

  /// Non-sensitive warnings (never contains patient data).
  final List<String> warnings;

  const ManagedFileCollection({required this.files, required this.warnings});
}

/// Collects app-managed files (profile and care-contact photos, lab analysis
/// attachments) that live under the application documents directory.
///
/// Files are assigned stable archive-relative paths under `files/<root>/` that
/// match their on-disk directory names, so a future restore can place them back
/// without renaming.
class ManagedFileCollector {
  static const profileImagesDirName = 'profile_images';
  static const careContactImagesDirName = 'care_contact_images';
  static const labAnalysesDirName = 'lab_analyses';

  final AppDatabase _database;
  final Directory _appDocumentsDir;

  ManagedFileCollector(this._database, this._appDocumentsDir);

  Future<ManagedFileCollection> collect() async {
    final referenced = await _referencedPhotoPaths();
    final warnings = <String>[];
    final files = <BackupSourceFile>[];

    final found = <String>{};
    await _scanDirectory(
      Directory(p.join(_appDocumentsDir.path, profileImagesDirName)),
      'files/profile_images',
      files,
      found,
    );
    await _scanDirectory(
      Directory(p.join(_appDocumentsDir.path, careContactImagesDirName)),
      'files/care_contact_images',
      files,
      found,
    );
    await _scanTree(
      Directory(p.join(_appDocumentsDir.path, labAnalysesDirName)),
      'files/lab_analyses',
      files,
      found,
    );

    final missing = referenced.where((path) => !found.contains(path)).toList();
    if (missing.isNotEmpty) {
      warnings.add(
        '${missing.length} files referenced by the database are missing on '
        'disk and were not included.',
      );
    }

    return ManagedFileCollection(files: files, warnings: warnings);
  }

  Future<void> _scanDirectory(
    Directory dir,
    String archivePrefix,
    List<BackupSourceFile> files,
    Set<String> found,
  ) async {
    if (!await dir.exists()) return;
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! File) continue;
      found.add(entity.path);
      files.add(
        BackupSourceFile(
          archivePath: '$archivePrefix/${entity.uri.pathSegments.last}',
          file: entity,
        ),
      );
    }
  }

  /// Recursively scans a nested managed root (lab attachments live at
  /// `lab_analyses/<profileId>/<analysisId>/<file>`), preserving the sub-
  /// directory layout in the archive path.
  Future<void> _scanTree(
    Directory dir,
    String archivePrefix,
    List<BackupSourceFile> files,
    Set<String> found,
  ) async {
    if (!await dir.exists()) return;
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is Directory) {
        await _scanTree(
          entity,
          '$archivePrefix/${p.basename(entity.path)}',
          files,
          found,
        );
      } else if (entity is File) {
        found.add(entity.path);
        files.add(
          BackupSourceFile(
            archivePath: '$archivePrefix/${entity.uri.pathSegments.last}',
            file: entity,
          ),
        );
      }
    }
  }

  /// Absolute photo paths referenced by any profile or care contact, plus
  /// absolute lab attachment paths referenced by any analysis attachment.
  Future<Set<String>> _referencedPhotoPaths() async {
    final profiles = await _database.select(_database.profiles).get();
    final contacts = await _database.select(_database.careContacts).get();
    final attachments = await _database.select(_database.labAnalysisAttachments).get();
    return {
      ...profiles.map((profile) => profile.photoPath).whereType<String>(),
      ...contacts.map((contact) => contact.photoPath).whereType<String>(),
      ...attachments.map(
        (a) => p.join(_appDocumentsDir.path, a.managedRelativePath),
      ),
    };
  }
}