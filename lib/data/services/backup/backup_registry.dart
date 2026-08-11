import 'dart:convert';

import 'package:rehab_track/domain/backup/backup_availability.dart';
import 'package:rehab_track/domain/backup/registered_backup.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';

/// Settings key under which the serialized backup registry is persisted.
const String backupRegistryStorageKey = 'backup_registry';

/// Persists a small metadata registry of backups previously created by, or
/// imported into, this app.
///
/// Stored state is **non-sensitive only**: each entry holds the SAF `content://`
/// URI plus display name / size / timestamps / versions and a stable
/// availability state. No patient, clinical or personal data is ever written
/// here, and no filesystem paths are stored.
///
/// The registry is the storage-side answer to scoped-storage constraints: the
/// app cannot reliably enumerate arbitrary user documents, so it tracks the
/// documents it created or imported (and still holds persisted access to).
class BackupRegistry {
  final SettingsRepository _settings;

  const BackupRegistry(this._settings);

  /// Returns all registered backups, newest-first by creation time when known.
  /// Unavailable entries stay in their chronological position (they are not
  /// moved to the bottom).
  Future<List<RegisteredBackup>> all() async {
    final raw = await _settings.getValue(backupRegistryStorageKey);
    if (raw == null || raw.isEmpty) return const [];
    final List<RegisteredBackup> backups = [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      for (final item in decoded) {
        if (item is Map) {
          final backup =
              RegisteredBackup.fromJson(item.cast<String, Object?>());
          if (backup != null) backups.add(backup);
        }
      }
    } catch (_) {
      return const [];
    }
    backups.sort((a, b) {
      final aTime = a.createdAt;
      final bTime = b.createdAt;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });
    return backups;
  }

  /// Registers [backup], upserting by [RegisteredBackup.contentUri] so repeated
  /// saves/imports to the same destination never produce duplicates.
  Future<void> add(RegisteredBackup backup) async {
    final backups = await all();
    final withoutDuplicate = backups
        .where((b) => b.contentUri != backup.contentUri)
        .toList();
    withoutDuplicate.add(backup);
    await _persist(withoutDuplicate);
  }

  /// Replaces the entry for [RegisteredBackup.contentUri] with an updated copy.
  /// No-op when the URI is not registered.
  Future<void> update(RegisteredBackup backup) async {
    final backups = await all();
    final hasEntry = backups.any((b) => b.contentUri == backup.contentUri);
    if (!hasEntry) return;
    final updated = backups
        .map((b) => b.contentUri == backup.contentUri ? backup : b)
        .toList();
    await _persist(updated);
  }

  /// Whether an entry for [contentUri] is already registered.
  Future<bool> contains(String contentUri) async {
    final backups = await all();
    return backups.any((b) => b.contentUri == contentUri);
  }

  /// Records a freshly probed availability state (plus optional refreshed
  /// metadata) for [contentUri]. No-op when the URI is not registered.
  Future<void> applyProbe(
    String contentUri, {
    required BackupAvailability availability,
    DateTime? checkedAt,
  }) async {
    final backups = await all();
    final hasEntry = backups.any((b) => b.contentUri == contentUri);
    if (!hasEntry) return;
    await _persist(
      backups
          .map((b) => b.contentUri == contentUri
              ? b.copyWith(
                  availability: availability,
                  lastCheckedAt: checkedAt ?? b.lastCheckedAt,
                )
              : b)
          .toList(),
    );
  }

  /// Removes the entry for [contentUri] from the registry only; never touches
  /// any storage document.
  Future<void> remove(String contentUri) async {
    final backups = await all();
    await _persist(
      backups.where((b) => b.contentUri != contentUri).toList(),
    );
  }

  Future<void> _persist(List<RegisteredBackup> backups) async {
    final payload = jsonEncode(backups.map((b) => b.toJson()).toList());
    await _settings.setValue(backupRegistryStorageKey, payload);
  }
}