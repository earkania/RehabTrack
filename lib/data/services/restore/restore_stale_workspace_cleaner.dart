import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:rehab_track/data/services/restore/restore_recovery_metadata.dart';

/// Removes temporary workspaces that no longer belong to a live operation.
///
/// Safety rules:
/// - A restore workspace is only deleted when **no** active (needs-recovery)
///   recovery metadata references it, so a real interrupted restore is never
///   wiped. Completed restores already delete their own workspace; anything
///   left behind is abandoned and safe to remove.
/// - Backup temp directories (`rehabtrack_backup_*`) are only ever used during
///   a single synchronous backup, so any that exist at startup are abandoned.
/// - The `pending-restore` app-owned copy is only meaningful while the preview
///   screen is open in the current session, so a leftover copy at startup is
///   stale.
/// - Never touches unrelated cache content.
class RestoreStaleWorkspaceCleaner {
  const RestoreStaleWorkspaceCleaner();

  Future<void> clean({
    required Directory tempBaseDir,
    required RestoreRecoveryStore recoveryStore,
  }) async {
    await _cleanRestoreWorkspaces(tempBaseDir, recoveryStore);
    await _cleanAbandonedBackupTemps(tempBaseDir);
    await _cleanPendingRestore(tempBaseDir);
  }

  Future<void> _cleanRestoreWorkspaces(
    Directory tempBaseDir,
    RestoreRecoveryStore recoveryStore,
  ) async {
    final workspacesRoot =
        Directory(p.join(tempBaseDir.path, 'restore-workspace'));
    if (!await workspacesRoot.exists()) return;

    List<RestoreRecoveryMetadata> active;
    try {
      active = (await recoveryStore.listAll())
          .where((m) => m.needsRecovery)
          .toList();
    } catch (_) {
      // Cannot read metadata: keep every workspace (conservative).
      return;
    }

    await for (final entity in workspacesRoot.list()) {
      if (entity is! Directory) continue;
      final absolute = p.normalize(entity.path);
      final referenced = active.any(
        (m) => p.normalize(m.workspacePath) == absolute,
      );
      if (referenced) continue;
      try {
        await entity.delete(recursive: true);
      } catch (_) {
        // Best-effort cleanup.
      }
    }
  }

  Future<void> _cleanAbandonedBackupTemps(Directory tempBaseDir) async {
    try {
      await for (final entity in tempBaseDir.list()) {
        if (entity is Directory &&
            p.basename(entity.path).startsWith('rehabtrack_backup_')) {
          await entity.delete(recursive: true);
        }
      }
    } catch (_) {
      // Best-effort cleanup.
    }
  }

  Future<void> _cleanPendingRestore(Directory tempBaseDir) async {
    try {
      final file = File(p.join(tempBaseDir.path, 'pending-restore', 'selected.rtb'));
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Best-effort cleanup.
    }
  }
}
