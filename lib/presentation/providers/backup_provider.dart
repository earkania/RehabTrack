import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:rehab_track/core/constants/app_constants.dart';
import 'package:rehab_track/data/services/backup/backup_archive_writer.dart';
import 'package:rehab_track/data/services/backup/backup_service.dart';
import 'package:rehab_track/data/services/backup/backup_storage_gateway.dart';
import 'package:rehab_track/data/services/backup/preferences_exporter.dart';
import 'package:rehab_track/domain/backup/backup_operation_state.dart';
import 'package:rehab_track/domain/backup/backup_phase.dart';
import 'package:rehab_track/domain/backup/backup_result.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  final database = ref.watch(databaseProvider);
  return BackupService(
    database: database,
    archiveWriter: BackupArchiveWriter(),
    storageGateway: const BackupStorageGateway(),
    preferencesExporter: PreferencesExporter(ref.watch(settingsRepositoryProvider)),
    documentsDirectory: getApplicationDocumentsDirectory,
    tempBaseDir: Directory.systemTemp,
  );
});

/// Drives a single backup operation and exposes its progress.
class BackupOperationController extends StateNotifier<BackupOperationState> {
  final BackupService _service;
  final SettingsRepository _settingsRepository;

  BackupOperationController(this._service, this._settingsRepository)
      : super(const BackupOperationState());

  /// Runs a backup. Returns the operation outcome; the caller is responsible
  /// for surfacing errors to the user.
  Future<BackupResult> createBackup() async {
    if (state.isRunning) {
      return BackupResult.operationAlreadyInProgress;
    }

    state = const BackupOperationState(phase: BackupPhase.collecting);
    final outcome = await _service.createBackup(
      onPhase: (phase) => state = state.copyWith(phase: phase),
    );

    if (outcome.result == BackupResult.success) {
      await _settingsRepository.setValue(
        AppConstants.lastSuccessfulBackupKey,
        DateTime.now().toIso8601String(),
      );
      state = BackupOperationState(
        phase: BackupPhase.done,
        warnings: outcome.warnings,
      );
    } else {
      state = BackupOperationState(warnings: outcome.warnings);
    }
    return outcome.result;
  }

  /// Resets the operation state so the screen shows its initial content.
  void reset() {
    if (!state.isRunning) {
      state = const BackupOperationState();
    }
  }
}

final backupOperationProvider =
    StateNotifierProvider<BackupOperationController, BackupOperationState>(
  (ref) {
    return BackupOperationController(
      ref.watch(backupServiceProvider),
      ref.watch(settingsRepositoryProvider),
    );
  },
);

/// Timestamp (ISO 8601) of the last successful backup, or null if never.
final lastBackupAtProvider = FutureProvider<DateTime?>((ref) async {
  final raw = await ref.watch(settingsRepositoryProvider).getValue(
        AppConstants.lastSuccessfulBackupKey,
      );
  final parsed = raw == null ? null : DateTime.tryParse(raw);
  return parsed?.toLocal();
});
