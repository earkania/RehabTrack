import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:rehab_track/core/constants/app_constants.dart';
import 'package:rehab_track/data/services/backup/backup_archive_writer.dart';
import 'package:rehab_track/data/services/backup/backup_registry.dart';
import 'package:rehab_track/data/services/backup/backup_service.dart';
import 'package:rehab_track/data/services/backup/backup_storage_gateway.dart';
import 'package:rehab_track/data/services/backup/preferences_exporter.dart';
import 'package:rehab_track/domain/backup/backup_availability.dart';
import 'package:rehab_track/domain/backup/backup_operation_state.dart';
import 'package:rehab_track/domain/backup/backup_phase.dart';
import 'package:rehab_track/domain/backup/backup_result.dart';
import 'package:rehab_track/domain/backup/registered_backup.dart';
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
  final BackupRegistry _backupRegistry;

  BackupOperationController(
    this._service,
    this._settingsRepository, {
    BackupRegistry? backupRegistry,
  })  : _backupRegistry = backupRegistry ??
            BackupRegistry(_settingsRepository),
        super(const BackupOperationState());

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
      if (outcome.savedFileName != null) {
        await _settingsRepository.setValue(
          AppConstants.lastBackupDisplayNameKey,
          outcome.savedFileName!,
        );
      }
      if (outcome.savedContentUri != null) {
        await _settingsRepository.setValue(
          AppConstants.lastBackupContentUriKey,
          outcome.savedContentUri!,
        );
      }
      await _registerBackup(outcome);
      state = BackupOperationState(
        phase: BackupPhase.done,
        warnings: outcome.warnings,
      );
    } else {
      state = BackupOperationState(warnings: outcome.warnings);
    }
    return outcome.result;
  }

  /// Records the freshly stored document in the backup registry so it can be
  /// listed, validated, restored, shared or deleted from "Manage Backups".
  /// Only stable `content://` URIs are registered; anything else (e.g. legacy
  /// raw paths) is skipped.
  Future<void> _registerBackup(BackupOutcome outcome) async {
    final uri = outcome.savedContentUri;
    if (uri == null || !uri.startsWith('content://')) return;
    final backup = RegisteredBackup(
      contentUri: uri,
      displayName: outcome.savedFileName,
      createdAt: DateTime.now(),
      fileSize: outcome.savedFileSize,
      availability: BackupAvailability.available,
      lastCheckedAt: DateTime.now(),
    );
    try {
      await _backupRegistry.add(backup);
    } catch (_) {
      // A failed registry write must never fail an otherwise successful backup.
    }
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

/// Display name of the last successful backup file as reported by the document
/// provider, when available.
final lastBackupDisplayNameProvider = FutureProvider<String?>((ref) async {
  return ref.watch(settingsRepositoryProvider).getValue(
        AppConstants.lastBackupDisplayNameKey,
      );
});

/// Availability of the registry entry that backs the "Last backup" tile, when
/// it can be linked (the last successful backup stored a `content://` URI and
/// that URI is still registered). `null` when there is nothing to check.
final lastBackupAvailabilityProvider = FutureProvider<BackupAvailability?>(
  (ref) async {
    final uri = await ref.watch(settingsRepositoryProvider).getValue(
          AppConstants.lastBackupContentUriKey,
        );
    if (uri == null || uri.isEmpty || !uri.startsWith('content://')) {
      return null;
    }
    final registry = BackupRegistry(ref.watch(settingsRepositoryProvider));
    final backups = await registry.all();
    for (final backup in backups) {
      if (backup.contentUri == uri) return backup.availability;
    }
    return null;
  },
);
