import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/core/constants/app_constants.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/services/backup/backup_archive_writer.dart';
import 'package:rehab_track/data/services/backup/backup_service.dart';
import 'package:rehab_track/data/services/backup/backup_storage_gateway.dart';
import 'package:rehab_track/data/services/backup/preferences_exporter.dart';
import 'package:rehab_track/domain/backup/backup_phase.dart';
import 'package:rehab_track/domain/backup/backup_result.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/presentation/providers/backup_provider.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';

class FakeSettingsRepository implements SettingsRepository {
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

class FakeStorageGateway extends BackupStorageGateway {
  @override
  Future<BackupSaveResult> save({
    required Uint8List bytes,
    required String fileName,
  }) async {
    return BackupSaveResult.success('/tmp/out.rtb');
  }
}

class ControllableBackupService extends BackupService {
  final Completer<BackupOutcome> gate = Completer<BackupOutcome>();
  final List<BackupPhase> phases = [];

  ControllableBackupService()
      : super(
          database: AppDatabase.test(),
          archiveWriter: BackupArchiveWriter(),
          storageGateway: const BackupStorageGateway(),
          preferencesExporter: PreferencesExporter(FakeSettingsRepository()),
          documentsDirectory: () async => Directory.systemTemp,
          tempBaseDir: Directory.systemTemp,
          platform: 'test',
        );

  @override
  Future<BackupOutcome> createBackup({
    void Function(BackupPhase phase)? onPhase,
  }) {
    onPhase?.call(BackupPhase.collecting);
    return gate.future;
  }
}

void main() {
  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  test('createBackup writes last-backup metadata on success', () async {
    final service = ControllableBackupService();
    final settings = FakeSettingsRepository();
    final controller = BackupOperationController(service, settings);

    final future = controller.createBackup();
    expect(controller.state.isRunning, isTrue);

    service.gate.complete(
      const BackupOutcome(result: BackupResult.success),
    );
    final result = await future;

    expect(result, BackupResult.success);
    expect(controller.state.isDone, isTrue);
    expect(settings.store[AppConstants.lastSuccessfulBackupKey], isNotNull);
  });

  test('does not write metadata when the backup fails', () async {
    final service = ControllableBackupService();
    final settings = FakeSettingsRepository();
    final controller = BackupOperationController(service, settings);

    final future = controller.createBackup();
    service.gate.complete(
      const BackupOutcome(result: BackupResult.storageFailure),
    );
    final result = await future;

    expect(result, BackupResult.storageFailure);
    expect(controller.state.isRunning, isFalse);
    expect(settings.store.containsKey(AppConstants.lastSuccessfulBackupKey),
        isFalse);
  });

  test('returns operationAlreadyInProgress while running', () async {
    final service = ControllableBackupService();
    final controller = BackupOperationController(service, FakeSettingsRepository());

    final first = controller.createBackup();
    final second = await controller.createBackup();

    expect(second, BackupResult.operationAlreadyInProgress);
    service.gate.complete(const BackupOutcome(result: BackupResult.success));
    await first;
  });

  test('stores warnings on failure state', () async {
    final service = ControllableBackupService();
    final controller = BackupOperationController(service, FakeSettingsRepository());

    final future = controller.createBackup();
    service.gate.complete(
      const BackupOutcome(
        result: BackupResult.archiveFailure,
        warnings: ['1 photo missing'],
      ),
    );
    await future;

    expect(controller.state.warnings, ['1 photo missing']);
    expect(controller.state.phase, BackupPhase.idle);
  });

  test('reset restores the initial state', () async {
    final service = ControllableBackupService();
    final controller = BackupOperationController(service, FakeSettingsRepository());

    final future = controller.createBackup();
    service.gate.complete(
      const BackupOutcome(result: BackupResult.success),
    );
    await future;
    expect(controller.state.isDone, isTrue);

    controller.reset();
    expect(controller.state.phase, BackupPhase.idle);
    expect(controller.state.warnings, isEmpty);
  });

  group('lastBackupAtProvider', () {
    test('maps persisted timestamp to a local DateTime', () async {
      final settings = FakeSettingsRepository();
      settings.store[AppConstants.lastSuccessfulBackupKey] =
          '2026-08-04T12:00:00.000';
      final container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settings),
        ],
      );
      addTearDown(container.dispose);

      final value = await container.read(lastBackupAtProvider.future);
      expect(value, DateTime.parse('2026-08-04T12:00:00.000').toLocal());
    });

    test('resolves to null when never backed up', () async {
      final container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            FakeSettingsRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(await container.read(lastBackupAtProvider.future), isNull);
    });
  });
}
