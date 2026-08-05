import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/services/backup/backup_archive_writer.dart';
import 'package:rehab_track/data/services/backup/backup_service.dart';
import 'package:rehab_track/data/services/backup/backup_storage_gateway.dart';
import 'package:rehab_track/data/services/backup/preferences_exporter.dart';
import 'package:rehab_track/domain/backup/backup_phase.dart';
import 'package:rehab_track/domain/backup/backup_result.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/backup_provider.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
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
  final BackupResult result;

  ControllableBackupService(this.result)
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

Widget _wrap(BackupService service, SettingsRepository settings) {
  return ProviderScope(
    overrides: [
      backupServiceProvider.overrideWithValue(service),
      settingsRepositoryProvider.overrideWithValue(settings),
    ],
    child: const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: BackupAndRestoreScreen(),
    ),
  );
}

void main() {
  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  testWidgets('renders description, includes list and coming-soon restore',
      (tester) async {
    final settings = FakeSettingsRepository();
    await tester.pumpWidget(_wrap(ControllableBackupService(BackupResult.success), settings));

    expect(find.text('Backup & Restore'), findsOneWidget);
    expect(find.textContaining('Create a copy of all your data'), findsOneWidget);
    expect(find.text('What\'s included'), findsOneWidget);
    expect(find.text('All your health records and history'), findsOneWidget);
    expect(find.text('Profile and care contact photos'), findsOneWidget);
    expect(find.text('App settings and preferences'), findsOneWidget);
    expect(find.text('Create backup'), findsOneWidget);
    expect(find.text('No backup created yet'), findsOneWidget);
    expect(find.text('Restore will be available in a future update.'), findsOneWidget);
  });

  testWidgets('shows progress while running and success dialog afterwards',
      (tester) async {
    final settings = FakeSettingsRepository();
    final service = ControllableBackupService(BackupResult.success);
    await tester.pumpWidget(_wrap(service, settings));

    await tester.tap(find.text('Create backup'));
    await tester.pump();

    expect(find.text('Creating backup…'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    service.gate.complete(const BackupOutcome(result: BackupResult.success));
    await tester.pumpAndSettle();

    expect(find.text('Backup created'), findsOneWidget);
    expect(find.text('Your backup file has been saved to the chosen location.'),
        findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Backup created'), findsNothing);
  });

  testWidgets('shows a failure dialog with the mapped message', (tester) async {
    final service = ControllableBackupService(BackupResult.storageFailure);
    await tester.pumpWidget(_wrap(service, FakeSettingsRepository()));

    await tester.tap(find.text('Create backup'));
    await tester.pump();
    service.gate.complete(
      const BackupOutcome(result: BackupResult.storageFailure),
    );
    await tester.pumpAndSettle();

    expect(find.text('Backup failed'), findsOneWidget);
    expect(
      find.text(
        'Could not write the backup to the selected location. '
        'Try again or choose a different location.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows the cancelled dialog when the picker is dismissed',
      (tester) async {
    final service = ControllableBackupService(BackupResult.cancelled);
    await tester.pumpWidget(_wrap(service, FakeSettingsRepository()));

    await tester.tap(find.text('Create backup'));
    await tester.pump();
    service.gate.complete(const BackupOutcome(result: BackupResult.cancelled));
    await tester.pumpAndSettle();

    expect(find.text('Backup cancelled'), findsOneWidget);
    expect(find.text('No backup was created.'), findsOneWidget);
  });

  testWidgets('shows the last successful backup timestamp', (tester) async {
    final settings = FakeSettingsRepository()
      ..store['last_backup_at'] = '2026-08-04T12:00:00.000';
    await tester.pumpWidget(_wrap(ControllableBackupService(BackupResult.success), settings));
    await tester.pumpAndSettle();

    expect(find.textContaining('Last successful backup:'), findsOneWidget);
  });
}
