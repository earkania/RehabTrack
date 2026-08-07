import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/core/constants/app_constants.dart';
import 'package:rehab_track/data/services/backup/backup_archive_reader.dart';
import 'package:rehab_track/data/services/backup/backup_validator.dart';
import 'package:rehab_track/data/services/restore/restore_recovery_metadata.dart';
import 'package:rehab_track/data/services/restore/restore_service.dart';
import 'package:rehab_track/domain/backup/backup_compatibility.dart';
import 'package:rehab_track/domain/backup/backup_preview.dart';
import 'package:rehab_track/domain/restore/restore_apply_phase.dart';
import 'package:rehab_track/domain/restore/restore_failure.dart';
import 'package:rehab_track/domain/restore/restore_result.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/presentation/providers/restore_apply_provider.dart';

import 'helpers/restore_test_utils.dart';

class _FakeSettings implements SettingsRepository {
  final Map<String, String> store = {};

  @override
  Future<String?> getValue(String key) async => store[key];

  @override
  Future<void> setValue(String key, String value) async {
    store[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    store.remove(key);
  }

  @override
  Stream<Map<String, String>> watchAll() async* {
    yield Map.from(store);
  }

  @override
  Future<Map<String, String>> getAll() async => Map.from(store);
}

class _StubApplyService extends RestoreService {
  RestoreFailure result;

  _StubApplyService(this.result)
      : super(
          environment: FakeRestoreEnvironment(
            Directory.systemTemp.createTempSync('meta_apply_'),
          ),
          archiveReader: const BackupArchiveReader(),
          validator: const BackupValidator(),
          recoveryStore: RestoreRecoveryStore.inDirectory(
            Directory.systemTemp.createTempSync('meta_recovery_'),
          ),
          tempBaseDir: Directory.systemTemp,
          currentDatabaseSchemaVersion: 15,
          currentAppVersion: '1.2.0',
        );

  @override
  Future<RestoreFailure> run({
    required File selectedBackupFile,
    required BackupPreview expectedPreview,
    void Function(RestoreApplyPhase phase)? onPhase,
    Future<bool> Function()? isCancellationRequested,
  }) async {
    return result;
  }
}

BackupPreview _preview() => BackupPreview(
      backupCreatedAt: DateTime.utc(2026, 8, 5),
      appVersion: '1.2.0',
      backupFormatVersion: 1,
      databaseSchemaVersion: 14,
      currentDatabaseSchemaVersion: 15,
      compatibility: BackupCompatibility.compatible,
      migrationRequired: false,
      profileCount: 2,
      managedFileCount: 1,
      backupFileSize: 65536,
    );

void main() {
  final file = File('selected.rtb');
  final preview = _preview();

  test('records last_restore_at only after a successful apply', () async {
    final settings = _FakeSettings();
    final controller = RestoreApplyController(
      _StubApplyService(
        const RestoreFailure(result: RestoreResult.success, recoveryId: 'op_success'),
      ),
      settings,
    );

    final failure = await controller.apply(backupFile: file, preview: preview);
    expect(failure!.succeeded, isTrue);
    expect(
      settings.store,
      contains(AppConstants.lastSuccessfulRestoreKey),
    );
    expect(
      DateTime.tryParse(settings.store[AppConstants.lastSuccessfulRestoreKey]!),
      isNotNull,
    );
  });

  test('does not record last_restore_at when the restore failed', () async {
    final settings = _FakeSettings();
    final controller = RestoreApplyController(
      _StubApplyService(
        const RestoreFailure(result: RestoreResult.unexpectedFailure, recoveryId: 'op_fail'),
      ),
      settings,
    );

    await controller.apply(backupFile: file, preview: preview);

    expect(settings.store, isNot(contains(AppConstants.lastSuccessfulRestoreKey)));
  });

  test('does not record last_restore_at when the restore was cancelled',
      () async {
    final settings = _FakeSettings();
    final controller = RestoreApplyController(
      _StubApplyService(
        const RestoreFailure(
          result: RestoreResult.cancelled,
          recoveryId: 'op_cancel',
        ),
      ),
      settings,
    );

    await controller.apply(backupFile: file, preview: preview);

    expect(settings.store, isNot(contains(AppConstants.lastSuccessfulRestoreKey)));
  });
}