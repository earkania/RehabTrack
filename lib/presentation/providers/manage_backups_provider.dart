import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rehab_track/data/services/backup/backup_document_gateway.dart';
import 'package:rehab_track/data/services/backup/backup_import_service.dart';
import 'package:rehab_track/data/services/backup/backup_management_service.dart';
import 'package:rehab_track/data/services/backup/backup_registry.dart';
import 'package:rehab_track/data/services/backup/backup_storage_gateway.dart';
import 'package:rehab_track/domain/backup/registered_backup.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';

final backupRegistryProvider = Provider<BackupRegistry>((ref) {
  return BackupRegistry(ref.watch(settingsRepositoryProvider));
});

final backupManagementServiceProvider = Provider<BackupManagementService>(
  (ref) => BackupManagementService(
    ref.watch(backupRegistryProvider),
    const BackupStorageGateway(),
  ),
);

final backupImportServiceProvider = Provider<BackupImportService>((ref) {
  return BackupImportService(
    storageGateway: const BackupStorageGateway(),
    documentGateway: const BackupDocumentGateway(),
    registry: ref.watch(backupRegistryProvider),
    tempBaseDir: Directory.systemTemp,
  );
});

/// UI state for the "Manage Backups" screen.
class ManageBackupsState {
  final bool isLoading;

  /// Whether an import operation is running.
  final bool isImporting;

  final List<RegisteredBackup> backups;

  /// Set when the registry could not be read or refreshed.
  final bool loadFailed;

  const ManageBackupsState({
    this.isLoading = false,
    this.isImporting = false,
    this.backups = const [],
    this.loadFailed = false,
  });

  ManageBackupsState copyWith({
    bool? isLoading,
    bool? isImporting,
    List<RegisteredBackup>? backups,
    bool? loadFailed,
  }) {
    return ManageBackupsState(
      isLoading: isLoading ?? this.isLoading,
      isImporting: isImporting ?? this.isImporting,
      backups: backups ?? this.backups,
      loadFailed: loadFailed ?? this.loadFailed,
    );
  }
}

class ManageBackupsController extends StateNotifier<ManageBackupsState> {
  final BackupManagementService _service;
  final BackupImportService _importService;

  ManageBackupsController(this._service, this._importService)
      : super(const ManageBackupsState());

  /// Loads the registered backups and probes each against the document
  /// provider so the list reflects current availability.
  Future<void> load() async {
    state = state.copyWith(isLoading: true, loadFailed: false);
    try {
      final refreshed = await _service.refreshAll();
      state = ManageBackupsState(backups: refreshed);
    } catch (_) {
      state = ManageBackupsState(loadFailed: true);
    }
  }

  /// Re-probes a single backup (e.g. before opening details) and returns the
  /// refreshed copy, or the original when the probe failed.
  Future<RegisteredBackup> refreshOne(RegisteredBackup backup) async {
    try {
      final refreshed = await _service.refresh(backup);
      state = state.copyWith(
        backups: state.backups
            .map((b) => b.contentUri == backup.contentUri ? refreshed : b)
            .toList(),
      );
      return refreshed;
    } catch (_) {
      return backup;
    }
  }

  /// Runs an import batch: picks documents via SAF, validates each and
  /// registers the valid ones. Returns the outcome for result messaging.
  Future<BackupImportOutcome> importBackups() async {
    if (state.isImporting) {
      return const BackupImportOutcome(
        status: BackupImportStatus.unexpectedFailure,
      );
    }
    state = state.copyWith(isImporting: true);
    try {
      final outcome = await _importService.import();
      if (outcome.succeeded) {
        state = state.copyWith(
          isImporting: false,
          backups: await _service.list(),
        );
      } else {
        state = state.copyWith(isImporting: false);
      }
      return outcome;
    } catch (_) {
      state = state.copyWith(isImporting: false);
      return const BackupImportOutcome(
        status: BackupImportStatus.unexpectedFailure,
      );
    }
  }

  /// Deletes [backup]'s document and drops its registry entry. On success the
  /// list is updated in place.
  Future<BackupDeleteOutcome> delete(RegisteredBackup backup) async {
    final outcome = await _service.delete(backup);
    if (outcome == BackupDeleteOutcome.deleted ||
        outcome == BackupDeleteOutcome.unresolved) {
      state = state.copyWith(
        backups: state.backups
            .where((b) => b.contentUri != backup.contentUri)
            .toList(),
      );
    }
    return outcome;
  }

  /// Removes a stale registry entry only (no storage document is deleted).
  Future<void> removeFromList(String contentUri) async {
    await _service.removeFromList(contentUri);
    state = state.copyWith(
      backups: state.backups
          .where((b) => b.contentUri != contentUri)
          .toList(),
    );
  }

  /// Shares [backup] through the system share sheet.
  Future<void> share(RegisteredBackup backup) => _service.share(backup);
}

final manageBackupsProvider =
    StateNotifierProvider<ManageBackupsController, ManageBackupsState>(
  (ref) => ManageBackupsController(
    ref.watch(backupManagementServiceProvider),
    ref.watch(backupImportServiceProvider),
  ),
);