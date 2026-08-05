import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/services/backup/backup_archive_reader.dart';
import 'package:rehab_track/data/services/backup/backup_archive_writer.dart';
import 'package:rehab_track/data/services/backup/backup_document_gateway.dart';
import 'package:rehab_track/data/services/backup/backup_service.dart';
import 'package:rehab_track/data/services/backup/backup_storage_gateway.dart';
import 'package:rehab_track/data/services/backup/backup_validator.dart';
import 'package:rehab_track/data/services/backup/preferences_exporter.dart';
import 'package:rehab_track/data/services/backup/restore_selection_service.dart';
import 'package:rehab_track/domain/backup/backup_compatibility.dart';
import 'package:rehab_track/domain/backup/backup_phase.dart';
import 'package:rehab_track/domain/backup/backup_preview.dart';
import 'package:rehab_track/domain/backup/backup_result.dart';
import 'package:rehab_track/domain/backup/backup_validation_result.dart';
import 'package:rehab_track/domain/backup/restore_operation_state.dart';
import 'package:rehab_track/domain/backup/restore_phase.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/backup_provider.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/restore_provider.dart';
import 'package:rehab_track/presentation/screens/settings/backup_and_restore_screen.dart';

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

class ControllableBackupService extends BackupService {
  final Completer<BackupOutcome> gate = Completer<BackupOutcome>();

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
    return gate.future;
  }
}

class FakeRestoreController extends RestoreOperationController {
  final BackupValidationResult outcome;
  final BackupPreview? preview;
  Completer<BackupValidationResult>? gate;

  FakeRestoreController(this.outcome, {this.preview})
      : super(
          selectionService: const RestoreSelectionService(
            BackupDocumentGateway(),
          ),
          archiveReader: const BackupArchiveReader(),
          validator: const BackupValidator(),
          tempBaseDir: Directory.systemTemp,
        );

  @override
  Future<BackupValidationResult> restoreBackup() async {
    if (gate != null) {
      state =
          const RestoreOperationState(phase: RestorePhase.selectingFile);
      final resolved = await gate!.future;
      return _resolve(resolved);
    }
    return _resolve(outcome);
  }

  BackupValidationResult _resolve(BackupValidationResult result) {
    switch (result) {
      case BackupValidationResult.valid:
        state = RestoreOperationState(
          phase: RestorePhase.readyForPreview,
          result: BackupValidationResult.valid,
          preview: preview,
        );
      case BackupValidationResult.cancelled:
        state = const RestoreOperationState(
          phase: RestorePhase.cancelled,
          result: BackupValidationResult.cancelled,
        );
      default:
        state = RestoreOperationState(
          phase: RestorePhase.failure,
          result: result,
        );
    }
    return result;
  }
}

BackupPreview _preview() {
  return BackupPreview(
    backupCreatedAt: DateTime.utc(2026, 8, 5),
    appVersion: '1.2.0',
    backupFormatVersion: 1,
    databaseSchemaVersion: 14,
    currentDatabaseSchemaVersion: 14,
    compatibility: BackupCompatibility.compatible,
    migrationRequired: false,
    profileCount: 2,
    managedFileCount: 0,
    backupFileSize: 128,
  );
}

Widget _wrap({
  required BackupService backupService,
  required SettingsRepository settings,
  required FakeRestoreController restoreController,
}) {
  return ProviderScope(
    overrides: [
      backupServiceProvider.overrideWithValue(backupService),
      settingsRepositoryProvider.overrideWithValue(settings),
      restoreOperationProvider
          .overrideWith((ref) => restoreController),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const BackupAndRestoreScreen(),
    ),
  );
}

void main() {
  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('disables Create backup while restore is running',
      (tester) async {
    final controller = FakeRestoreController(BackupValidationResult.cancelled);
    controller.gate = Completer<BackupValidationResult>();

    await tester.pumpWidget(_wrap(
      backupService: ControllableBackupService(),
      settings: FakeSettingsRepository(),
      restoreController: controller,
    ));

    await tester.tap(find.text('Restore backup'));
    await tester.pump();

    expect(find.text('Selecting backup…'), findsOneWidget);
    final createButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Create backup'),
    );
    expect(createButton.onPressed, isNull);

    controller.gate!
        .complete(BackupValidationResult.cancelled);
    await settle(tester);
    expect(find.text('Selecting backup…'), findsNothing);
  });

  testWidgets('disables Restore backup while backup is running',
      (tester) async {
    final service = ControllableBackupService();
    await tester.pumpWidget(_wrap(
      backupService: service,
      settings: FakeSettingsRepository(),
      restoreController:
          FakeRestoreController(BackupValidationResult.cancelled),
    ));

    await tester.tap(find.text('Create backup'));
    await tester.pump();

    final restoreButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Restore backup'),
    );
    expect(restoreButton.onPressed, isNull);

    service.gate.complete(const BackupOutcome(result: BackupResult.cancelled));
    await settle(tester);
  });

  testWidgets('navigates to the preview screen on a valid backup',
      (tester) async {
    await tester.pumpWidget(_wrap(
      backupService: ControllableBackupService(),
      settings: FakeSettingsRepository(),
      restoreController: FakeRestoreController(
        BackupValidationResult.valid,
        preview: _preview(),
      ),
    ));

    await tester.tap(find.text('Restore backup'));
    await settle(tester);

    expect(find.text('Backup preview'), findsOneWidget);
    expect(find.text('Compatible'), findsOneWidget);
  });

  testWidgets('shows an error dialog on an invalid backup', (tester) async {
    await tester.pumpWidget(_wrap(
      backupService: ControllableBackupService(),
      settings: FakeSettingsRepository(),
      restoreController:
          FakeRestoreController(BackupValidationResult.newerDatabaseVersion),
    ));

    await tester.tap(find.text('Restore backup'));
    await settle(tester);

    expect(find.text('Backup validation failed'), findsOneWidget);
    expect(
      find.text('The backup database is newer than this app supports.'),
      findsOneWidget,
    );

    await tester.tap(find.text('OK'));
    await settle(tester);
    expect(find.text('Backup validation failed'), findsNothing);
  });

  testWidgets('does nothing visually when the picker is cancelled',
      (tester) async {
    await tester.pumpWidget(_wrap(
      backupService: ControllableBackupService(),
      settings: FakeSettingsRepository(),
      restoreController:
          FakeRestoreController(BackupValidationResult.cancelled),
    ));

    await tester.tap(find.text('Restore backup'));
    await settle(tester);

    expect(find.text('Backup preview'), findsNothing);
    expect(find.text('Backup validation failed'), findsNothing);
  });
}