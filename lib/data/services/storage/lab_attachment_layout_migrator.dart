import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:rehab_track/data/services/backup/managed_file_collector.dart';

/// One-time relocation of lab analysis attachment files from the legacy
/// `files/lab_analyses/` layout to the managed root `lab_analyses/`.
///
/// Attachment DB rows store `managedRelativePath` as `lab_analyses/{profileId}/
/// {analysisId}/{file}` (relative to the documents directory, no `files`
/// segment). Older builds wrote the bytes to `documents/files/lab_analyses/...`
/// while the backup archive treats `files/` as a virtual container that is
/// stripped during extraction, so the physical location must match the managed
/// root `lab_analyses/` for backup/restore consistency.
class LabAttachmentLayoutMigrator {
  const LabAttachmentLayoutMigrator();

  /// Moves `documents/files/lab_analyses` to `documents/lab_analyses` when the
  /// legacy directory exists and the new one does not yet exist.
  Future<void> migrate(Directory documentsDir) async {
    final legacy = Directory(
      p.join(documentsDir.path, 'files', ManagedFileCollector.labAnalysesDirName),
    );
    if (!await legacy.exists()) return;
    final target = Directory(
      p.join(documentsDir.path, ManagedFileCollector.labAnalysesDirName),
    );
    if (await target.exists()) return;
    await target.create(recursive: true);
    await legacy.rename(target.path);
  }
}