import 'package:rehab_track/data/services/backup/backup_registry.dart';
import 'package:rehab_track/data/services/backup/backup_storage_gateway.dart';
import 'package:rehab_track/domain/backup/backup_availability.dart';
import 'package:rehab_track/domain/backup/registered_backup.dart';

/// Outcome of deleting a registered backup.
enum BackupDeleteOutcome {
  /// The document was deleted and the registry entry removed.
  deleted,

  /// The document could not be resolved/deleted; the registry entry was
  /// dropped so it no longer misrepresents an existing file.
  unresolved,
}

/// Coordinates "Manage Backups": the [BackupRegistry] metadata and the native
/// SAF probe/delete/share operations.
class BackupManagementService {
  final BackupRegistry _registry;
  final BackupStorageGateway _storageGateway;

  const BackupManagementService(this._registry, this._storageGateway);

  /// Lists registered backups in display order without re-probing. Availability
  /// reflects the last known state persisted in the registry.
  Future<List<RegisteredBackup>> list() => _registry.all();

  /// Re-probes [backup] against the document provider, refreshes its persisted
  /// availability and provider metadata (display name, size, last-modified) and
  /// returns the fresh copy. Accessible documents get their provider metadata
  /// refreshed too, so an external rename shows the new name.
  Future<RegisteredBackup> refresh(RegisteredBackup backup) async {
    final now = DateTime.now();
    final metadata = await _storageGateway.queryDocument(
      contentUri: backup.contentUri,
    );
    final available = metadata.accessible && metadata.probed;
    final refreshed = backup.copyWith(
      availability: available
          ? BackupAvailability.available
          : BackupAvailability.unavailable,
      lastCheckedAt: now,
      displayName: metadata.displayName ?? backup.displayName,
      fileSize: metadata.fileSize ?? backup.fileSize,
      lastModified: metadata.lastModified ?? backup.lastModified,
    );
    await _registry.update(refreshed);
    return refreshed;
  }

  /// Re-probes every registered backup and returns the refreshed list.
  /// Inaccessible entries stay listed (marked unavailable); nothing is
  /// automatically removed.
  Future<List<RegisteredBackup>> refreshAll() async {
    final backups = await _registry.all();
    final refreshed = <RegisteredBackup>[];
    for (final backup in backups) {
      try {
        refreshed.add(await refresh(backup));
      } catch (_) {
        final fallback = backup.copyWith(
          availability: BackupAvailability.unavailable,
          lastCheckedAt: DateTime.now(),
        );
        try {
          await _registry.update(fallback);
        } catch (_) {
          // Best-effort; the next refresh will probe again.
        }
        refreshed.add(fallback);
      }
    }
    return refreshed;
  }

  /// Launches the system share sheet for [backup].
  Future<void> share(RegisteredBackup backup) {
    return _storageGateway.shareDocument(
      contentUri: backup.contentUri,
      displayName: backup.displayName,
    );
  }

  /// Deletes the document behind [backup] and removes its registry entry.
  ///
  /// The document is deleted first, then the registry entry is removed. If the
  /// storage deletion succeeds but registry cleanup fails, the entry is marked
  /// unavailable so the next refresh repairs it rather than showing a deleted
  /// file as available.
  Future<BackupDeleteOutcome> delete(RegisteredBackup backup) async {
    var deleted = false;
    try {
      deleted = await _storageGateway.deleteDocument(
        contentUri: backup.contentUri,
      );
    } catch (_) {
      deleted = false;
    }
    try {
      await _registry.remove(backup.contentUri);
    } catch (_) {
      try {
        await _registry.applyProbe(
          backup.contentUri,
          availability: BackupAvailability.unavailable,
          checkedAt: DateTime.now(),
        );
      } catch (_) {
        // Best-effort; the next refresh will probe the (now missing) document.
      }
      return deleted
          ? BackupDeleteOutcome.deleted
          : BackupDeleteOutcome.unresolved;
    }
    return deleted ? BackupDeleteOutcome.deleted : BackupDeleteOutcome.unresolved;
  }

  /// Removes a registry entry only — the storage document is never touched.
  /// Intended for stale, unavailable entries whose file is already gone/moved.
  Future<void> removeFromList(String contentUri) async {
    await _registry.remove(contentUri);
  }
}