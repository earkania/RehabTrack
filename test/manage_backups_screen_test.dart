import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/data/services/backup/backup_archive_reader.dart';
import 'package:rehab_track/data/services/backup/backup_document_gateway.dart';
import 'package:rehab_track/data/services/backup/backup_import_service.dart';
import 'package:rehab_track/data/services/backup/backup_management_service.dart';
import 'package:rehab_track/data/services/backup/backup_registry.dart';
import 'package:rehab_track/data/services/backup/backup_storage_gateway.dart';
import 'package:rehab_track/data/services/backup/backup_validator.dart';
import 'package:rehab_track/data/services/backup/restore_selection_service.dart';
import 'package:rehab_track/domain/backup/backup_availability.dart';
import 'package:rehab_track/domain/backup/backup_compatibility.dart';
import 'package:rehab_track/domain/backup/backup_preview.dart';
import 'package:rehab_track/domain/backup/backup_validation_result.dart';
import 'package:rehab_track/domain/backup/registered_backup.dart';
import 'package:rehab_track/domain/backup/restore_operation_state.dart';
import 'package:rehab_track/domain/backup/restore_phase.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/manage_backups_provider.dart';
import 'package:rehab_track/presentation/providers/restore_provider.dart';
import 'package:rehab_track/presentation/screens/settings/backup_preview_screen.dart';
import 'package:rehab_track/presentation/screens/settings/manage_backups_screen.dart';

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
  final Map<String, BackupDocumentMetadata> queryResults;
  final Map<String, bool> deleteResults;
  final List<String> deleted = [];

  FakeStorageGateway({
    this.queryResults = const {},
    this.deleteResults = const {},
  });

  @override
  Future<BackupDocumentMetadata> queryDocument({
    required String contentUri,
  }) async {
    return queryResults[contentUri] ??
        const BackupDocumentMetadata(probed: true, accessible: true);
  }

  @override
  Future<bool> deleteDocument({required String contentUri}) async {
    deleted.add(contentUri);
    return deleteResults[contentUri] ?? true;
  }
}

/// Restore controller that always validates successfully, so the widget test
/// can exercise the pop-then-navigate path without touching real archives.
///
/// When [gate] is provided, [restoreFromUri] waits for it before completing.
/// This lets the test run the details-dialog pop to completion (disposing the
/// dialog state) before the restore finishes, reproducing the on-device timing
/// where the restore takes multiple frames.
class FakeRestoreController extends RestoreOperationController {
  final BackupPreview resultPreview;
  final Completer<void>? gate;

  FakeRestoreController(
    this.resultPreview, {
    this.gate,
  }) : super(
          selectionService: const RestoreSelectionService(
            BackupDocumentGateway(),
          ),
          archiveReader: const BackupArchiveReader(),
          validator: const BackupValidator(),
          tempBaseDir: Directory.systemTemp,
        );

  @override
  Future<BackupValidationResult> restoreFromUri(String contentUri) async {
    if (gate != null) {
      await gate!.future;
    }
    state = RestoreOperationState(
      phase: RestorePhase.readyForPreview,
      result: BackupValidationResult.valid,
      preview: resultPreview,
      backupFilePath: '/tmp/selected.rtb',
    );
    return BackupValidationResult.valid;
  }
}

/// Import service whose [import] returns a fixed outcome the test controls.
class FakeImportService extends BackupImportService {
  BackupImportOutcome outcome = const BackupImportOutcome(
    status: BackupImportStatus.success,
    imported: 1,
  );
  int calls = 0;

  FakeImportService()
      : super(
          storageGateway: const BackupStorageGateway(),
          documentGateway: const BackupDocumentGateway(),
          registry: BackupRegistry(FakeSettingsRepository()),
          tempBaseDir: Directory.systemTemp,
        );

  @override
  Future<BackupImportOutcome> import() async {
    calls++;
    return outcome;
  }
}

Widget _wrap(
  FakeSettingsRepository settings,
  FakeStorageGateway gateway, {
  BackupImportService? importService,
  Locale? locale,
  ThemeData? theme,
  TextScaler? textScaler,
}) {
  final registry = BackupRegistry(settings);
  final service = BackupManagementService(registry, gateway);
  final controller = ManageBackupsController(
    service,
    importService ??
        BackupImportService(
          storageGateway: gateway,
          documentGateway: const BackupDocumentGateway(),
          registry: registry,
          tempBaseDir: Directory.systemTemp,
        ),
  );

  return ProviderScope(
    overrides: [
      manageBackupsProvider.overrideWith((ref) => controller),
    ],
    child: MaterialApp(
      locale: locale,
      theme: theme ?? ThemeData(),
      builder: textScaler == null
          ? null
          : (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: textScaler),
                child: child!,
              ),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: ManageBackupsScreen(),
    ),
  );
}

Future<void> seed(
  FakeSettingsRepository settings,
  List<RegisteredBackup> backups,
) async {
  final registry = BackupRegistry(settings);
  for (final backup in backups) {
    await registry.add(backup);
  }
}

void main() {
  testWidgets('shows the empty state when no backups are registered',
      (tester) async {
    final settings = FakeSettingsRepository();
    await tester.pumpWidget(_wrap(settings, FakeStorageGateway()));
    await tester.pumpAndSettle();

    expect(find.text('Manage Backups'), findsOneWidget);
    expect(find.text('No backups have been created yet'), findsOneWidget);
  });

  testWidgets('lists registered backups with their metadata', (tester) async {
    final settings = FakeSettingsRepository();
    await seed(settings, [
      RegisteredBackup(
        contentUri: 'content://doc/1',
        displayName: 'Morning Backup.rtb',
        createdAt: DateTime(2026, 8, 1, 9),
        fileSize: 2048,
      ),
      RegisteredBackup(
        contentUri: 'content://doc/2',
        displayName: 'Evening Backup.rtb',
        createdAt: DateTime(2026, 8, 1, 20),
      ),
    ]);
    await tester.pumpWidget(_wrap(settings, FakeStorageGateway()));
    await tester.pumpAndSettle();

    expect(find.text('Morning Backup.rtb'), findsOneWidget);
    expect(find.text('Evening Backup.rtb'), findsOneWidget);
    expect(find.textContaining('2026'), findsNWidgets(2));
    expect(find.textContaining('2.0 KB'), findsOneWidget);
  });

  testWidgets('marks backup rows whose document is gone as unavailable',
      (tester) async {
    final settings = FakeSettingsRepository();
    await seed(settings, [
      RegisteredBackup(
        contentUri: 'content://doc/1',
        displayName: 'Gone.rtb',
        createdAt: DateTime(2026, 8, 1),
      ),
    ]);
    final gateway = FakeStorageGateway(
      queryResults: {
        'content://doc/1': const BackupDocumentMetadata(
          probed: true,
          accessible: false,
        ),
      },
    );
    await tester.pumpWidget(_wrap(settings, gateway));
    await tester.pumpAndSettle();

    expect(find.text('Unavailable'), findsOneWidget);
  });

  testWidgets('opens details and restores availability state in the row',
      (tester) async {
    final settings = FakeSettingsRepository();
    await seed(settings, [
      RegisteredBackup(
        contentUri: 'content://doc/1',
        displayName: 'Morning Backup.rtb',
        createdAt: DateTime(2026, 8, 1),
        fileSize: 1024,
      ),
    ]);
    await tester.pumpWidget(_wrap(settings, FakeStorageGateway()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Morning Backup.rtb'));
    await tester.pumpAndSettle();

    expect(find.text('Restore'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Delete'), findsWidgets);
    expect(find.textContaining('1.0 KB'), findsWidgets);
  });

  testWidgets('delete flow removes the registry entry after confirmation',
      (tester) async {
    final settings = FakeSettingsRepository();
    await seed(settings, [
      RegisteredBackup(
        contentUri: 'content://doc/1',
        displayName: 'Morning Backup.rtb',
        createdAt: DateTime(2026, 8, 1),
      ),
    ]);
    final gateway = FakeStorageGateway();
    await tester.pumpWidget(_wrap(settings, gateway));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Morning Backup.rtb'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();
    expect(find.text('Delete backup?'), findsOneWidget);

    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(gateway.deleted, ['content://doc/1']);
    expect(find.text('Backup deleted'), findsOneWidget);
    expect(find.text('Morning Backup.rtb'), findsNothing);
    expect(find.text('No backups have been created yet'), findsOneWidget);
  });

  testWidgets('cancelling the delete confirmation keeps the entry',
      (tester) async {
    final settings = FakeSettingsRepository();
    await seed(settings, [
      RegisteredBackup(
        contentUri: 'content://doc/1',
        displayName: 'Morning Backup.rtb',
        createdAt: DateTime(2026, 8, 1),
      ),
    ]);
    final gateway = FakeStorageGateway();
    await tester.pumpWidget(_wrap(settings, gateway));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Morning Backup.rtb'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();

    expect(gateway.deleted, isEmpty);
    // Row behind the details dialog still exists, so the name appears twice.
    expect(find.text('Morning Backup.rtb'), findsNWidgets(2));
  });

  testWidgets('cancelling restore confirmation does not start a restore',
      (tester) async {
    final settings = FakeSettingsRepository();
    await seed(settings, [
      RegisteredBackup(
        contentUri: 'content://doc/1',
        displayName: 'Morning Backup.rtb',
        createdAt: DateTime(2026, 8, 1),
      ),
    ]);
    await tester.pumpWidget(_wrap(settings, FakeStorageGateway()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Morning Backup.rtb'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();

    expect(find.text('Restore backup?'), findsOneWidget);
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();

    // Details dialog is still open; no restore started.
    expect(find.text('Share'), findsOneWidget);
  });

  testWidgets('unavailable backup disables restore and share', (tester) async {
    final settings = FakeSettingsRepository();
    await seed(settings, [
      RegisteredBackup(
        contentUri: 'content://doc/1',
        displayName: 'Gone.rtb',
        createdAt: DateTime(2026, 8, 1),
        availability: BackupAvailability.unavailable,
      ),
    ]);
    final gateway = FakeStorageGateway(
      queryResults: {
        'content://doc/1': const BackupDocumentMetadata(
          probed: true,
          accessible: false,
        ),
      },
    );
    await tester.pumpWidget(_wrap(settings, gateway));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gone.rtb'));
    await tester.pumpAndSettle();

    final restoreButton = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Restore'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(restoreButton.onPressed, isNull);
  });

  testWidgets('confirming restore pops the details dialog and opens the preview',
      (tester) async {
    final settings = FakeSettingsRepository();
    await seed(settings, [
      RegisteredBackup(
        contentUri: 'content://doc/1',
        displayName: 'Morning Backup.rtb',
        createdAt: DateTime(2026, 8, 1),
      ),
    ]);
    final gateway = FakeStorageGateway();
    final preview = BackupPreview(
      backupCreatedAt: DateTime(2026, 8, 1, 9),
      appVersion: '2.5.0',
      backupFormatVersion: 1,
      databaseSchemaVersion: 17,
      currentDatabaseSchemaVersion: 17,
      compatibility: BackupCompatibility.compatible,
      migrationRequired: false,
      managedFileCount: 0,
      backupFileSize: 2048,
    );
    final restoreGate = Completer<void>();
    final restoreController = FakeRestoreController(preview, gate: restoreGate);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        manageBackupsProvider.overrideWith(
          (ref) => ManageBackupsController(
            BackupManagementService(
              BackupRegistry(settings),
              gateway,
            ),
            BackupImportService(
              storageGateway: gateway,
              documentGateway: const BackupDocumentGateway(),
              registry: BackupRegistry(settings),
              tempBaseDir: Directory.systemTemp,
            ),
          ),
        ),
        restoreOperationProvider.overrideWith((ref) => restoreController),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: ManageBackupsScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Morning Backup.rtb'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    // Let the details dialog pop run to completion so its state is disposed
    // while the restore is still in flight (as happens on device).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    restoreGate.complete();
    await tester.pumpAndSettle();

    // The details dialog must have popped and the preview screen opened, even
    // though the dialog's context/ref were disposed by the pop (regression:
    // "Cannot use ref after the widget was disposed").
    expect(find.text('Restore backup?'), findsNothing);
    expect(find.byType(BackupPreviewScreen), findsOneWidget);
  });

  testWidgets('shows the Import Existing Backups entry', (tester) async {
    final settings = FakeSettingsRepository();
    final importService = FakeImportService();
    await tester.pumpWidget(_wrap(
      settings,
      FakeStorageGateway(),
      importService: importService,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Import Existing Backups'), findsOneWidget);
  });

  testWidgets('importing reports the imported count', (tester) async {
    final settings = FakeSettingsRepository();
    final importService = FakeImportService()
      ..outcome = const BackupImportOutcome(
        status: BackupImportStatus.success,
        imported: 2,
      );
    await tester.pumpWidget(_wrap(
      settings,
      FakeStorageGateway(),
      importService: importService,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Import Existing Backups'));
    await tester.pumpAndSettle();

    expect(importService.calls, 1);
    expect(find.text('2 backups imported'), findsOneWidget);
  });

  testWidgets('importing already-present backups reports refreshed count and '
      'shows them', (tester) async {
    final settings = FakeSettingsRepository();
    final importService = FakeImportService()
      ..outcome = const BackupImportOutcome(
        status: BackupImportStatus.success,
        refreshed: 3,
      );
    final registry = BackupRegistry(settings);
    // The controller reloads the list from the registry after a successful
    // import, so a pre-seeded available entry becomes visible.
    await registry.add(
      const RegisteredBackup(contentUri: 'content://doc/one'),
    );
    await tester.pumpWidget(_wrap(
      settings,
      FakeStorageGateway(),
      importService: importService,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Import Existing Backups'));
    await tester.pumpAndSettle();

    expect(
      find.text('3 backups were already in your list and were updated'),
      findsOneWidget,
    );
  });

  testWidgets('importing reports skipped invalid files and a failure outcome',
      (tester) async {
    final settings = FakeSettingsRepository();
    final importService = FakeImportService()
      ..outcome = const BackupImportOutcome(
        status: BackupImportStatus.success,
        invalidSkipped: 2,
      );
    await tester.pumpWidget(_wrap(
      settings,
      FakeStorageGateway(),
      importService: importService,
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import Existing Backups'));
    await tester.pumpAndSettle();
    expect(
      find.text('2 files were not valid RehabTrack backups and were skipped'),
      findsOneWidget,
    );

    importService.outcome = const BackupImportOutcome(
      status: BackupImportStatus.unexpectedFailure,
    );
    await tester.tap(find.text('Import Existing Backups'));
    await tester.pumpAndSettle();
    expect(find.text('Could not import the selected files.'), findsOneWidget);
  });

  testWidgets('a cancelled picker shows no message', (tester) async {
    final settings = FakeSettingsRepository();
    final importService = FakeImportService()
      ..outcome = const BackupImportOutcome(
        status: BackupImportStatus.cancelled,
      );
    await tester.pumpWidget(_wrap(
      settings,
      FakeStorageGateway(),
      importService: importService,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Import Existing Backups'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('unavailable rows are announced with their state and show a '
      'not-found subtitle', (tester) async {
    final settings = FakeSettingsRepository();
    await seed(settings, [
      RegisteredBackup(
        contentUri: 'content://doc/1',
        displayName: 'Gone.rtb',
        createdAt: DateTime(2026, 8, 1),
      ),
    ]);
    final gateway = FakeStorageGateway(
      queryResults: {
        'content://doc/1': const BackupDocumentMetadata(
          probed: true,
          accessible: false,
        ),
      },
    );
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_wrap(settings, gateway));
    await tester.pumpAndSettle();

    expect(find.text('Backup file not found'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Gone.rtb, Unavailable'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('remove from list drops the registry entry without deleting '
      'the file', (tester) async {
    final settings = FakeSettingsRepository();
    await seed(settings, [
      RegisteredBackup(
        contentUri: 'content://doc/1',
        displayName: 'Gone.rtb',
        createdAt: DateTime(2026, 8, 1),
      ),
    ]);
    final gateway = FakeStorageGateway(
      queryResults: {
        'content://doc/1': const BackupDocumentMetadata(
          probed: true,
          accessible: false,
        ),
      },
    );
    await tester.pumpWidget(_wrap(settings, gateway));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gone.rtb'));
    await tester.pumpAndSettle();

    expect(find.text('Remove from List'), findsOneWidget);
    await tester.tap(find.text('Remove from List'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Remove this backup from the list?'),
      findsOneWidget,
    );
    await tester.tap(
      find.widgetWithText(FilledButton, 'Remove from List'),
    );
    await tester.pumpAndSettle();

    expect(gateway.deleted, isEmpty);
    expect(find.text('Backup removed from list'), findsOneWidget);
    expect(find.text('Gone.rtb'), findsNothing);
  });

  testWidgets('restore and share are disabled for an unavailable backup',
      (tester) async {
    final settings = FakeSettingsRepository();
    await seed(settings, [
      RegisteredBackup(
        contentUri: 'content://doc/1',
        displayName: 'Gone.rtb',
        createdAt: DateTime(2026, 8, 1),
        availability: BackupAvailability.unavailable,
      ),
    ]);
    final gateway = FakeStorageGateway(
      queryResults: {
        'content://doc/1': const BackupDocumentMetadata(
          probed: true,
          accessible: false,
        ),
      },
    );
    await tester.pumpWidget(_wrap(settings, gateway));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gone.rtb'));
    await tester.pumpAndSettle();

    final restoreButton = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Restore'),
        matching: find.byType(FilledButton),
      ),
    );
    final shareButton = tester.widget<TextButton>(
      find.ancestor(
        of: find.text('Share'),
        matching: find.byType(TextButton),
      ),
    );
    expect(restoreButton.onPressed, isNull);
    expect(shareButton.onPressed, isNull);
  });

  group('Backup Details action layout', () {
    late Locale locale;

    void usePhoneViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    Future<void> openDetails(
        WidgetTester tester, {
        TextScaler? textScaler,
      }) async {
      final settings = FakeSettingsRepository();
      await seed(settings, [
        RegisteredBackup(
          contentUri: 'content://doc/1',
          displayName: 'Morning Backup.rtb',
          createdAt: DateTime(2026, 8, 1),
          fileSize: 2048,
        ),
      ]);
      await tester.pumpWidget(_wrap(
        settings,
        FakeStorageGateway(),
        locale: locale,
        textScaler: textScaler,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Morning Backup.rtb'));
      await tester.pumpAndSettle();
    }

    Rect buttonRect(WidgetTester tester, String label) {
      return tester.getRect(
        find.ancestor(
          of: find.text(label),
          matching: find.byWidgetPredicate(
            (w) => w is TextButton || w is FilledButton,
          ),
        ),
      );
    }

    setUp(() {
      locale = const Locale('en');
    });

    testWidgets('English renders the actions in one horizontal row',
        (tester) async {
      await openDetails(tester);

      final share = buttonRect(tester, 'Share');
      final delete = buttonRect(tester, 'Delete');
      final close = buttonRect(tester, 'Close');
      final restore = buttonRect(tester, 'Restore');

      expect(share.top, closeTo(delete.top, 0.5));
      expect(delete.top, closeTo(close.top, 0.5));
      expect(close.top, closeTo(restore.top, 0.5));
      expect(share.bottom, closeTo(restore.bottom, 0.5));

      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Restore'),
            )
            .onPressed,
        isNotNull,
      );
      final deleteButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Delete'),
      );
      final error =
          Theme.of(tester.element(find.text('Delete'))).colorScheme.error;
      expect(deleteButton.style?.foregroundColor?.resolve({}), error);
    });

    testWidgets('Georgian on a phone switches to full-width equal buttons',
        (tester) async {
      locale = const Locale('ka');
      usePhoneViewport(tester);
      await openDetails(tester);

      final share = buttonRect(tester, 'გაზიარება');
      final delete = buttonRect(tester, 'წაშლა');
      final close = buttonRect(tester, 'დახურვა');
      final restore = buttonRect(tester, 'აღდგენა');

      expect(share.left, closeTo(delete.left, 0.5));
      expect(delete.left, closeTo(close.left, 0.5));
      expect(close.left, closeTo(restore.left, 0.5));
      expect(share.width, closeTo(delete.width, 0.5));
      expect(delete.width, closeTo(close.width, 0.5));
      expect(close.width, closeTo(restore.width, 0.5));
      expect(restore.right, closeTo(restore.left + restore.width, 0.5));

      expect(delete.top, greaterThan(share.top));
      expect(close.top, greaterThan(delete.top));
      expect(restore.top, greaterThan(close.top));

      expect(
        tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'აღდგენა'),
        ),
        isA<FilledButton>(),
      );
      final deleteButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'წაშლა'),
      );
      final error =
          Theme.of(tester.element(find.text('წაშლა'))).colorScheme.error;
      expect(deleteButton.style?.foregroundColor?.resolve({}), error);
    });

    testWidgets('English large text avoids overflow with equal-width buttons',
        (tester) async {
      locale = const Locale('en');
      usePhoneViewport(tester);
      await openDetails(tester, textScaler: const TextScaler.linear(2.0));

      final share = buttonRect(tester, 'Share');
      final restore = buttonRect(tester, 'Restore');
      expect(share.left, closeTo(restore.left, 0.5));
      expect(share.width, closeTo(restore.width, 0.5));
      expect(restore.top, greaterThan(share.top));
    });

    testWidgets('Georgian large text avoids overflow with equal-width buttons',
        (tester) async {
      locale = const Locale('ka');
      usePhoneViewport(tester);
      await openDetails(tester, textScaler: const TextScaler.linear(2.0));

      final share = buttonRect(tester, 'გაზიარება');
      final restore = buttonRect(tester, 'აღდგენა');
      expect(share.left, closeTo(restore.left, 0.5));
      expect(share.width, closeTo(restore.width, 0.5));
      expect(restore.top, greaterThan(share.top));
    });

    testWidgets('the dialog renders in light and dark themes', (tester) async {
      for (final isDark in [false, true]) {
        final settings = FakeSettingsRepository();
        await seed(settings, [
          RegisteredBackup(
            contentUri: 'content://doc/1',
            displayName: 'Morning Backup.rtb',
            createdAt: DateTime(2026, 8, 1),
          ),
        ]);
        await tester.pumpWidget(_wrap(
          settings,
          FakeStorageGateway(),
          theme: ThemeData(brightness: isDark ? Brightness.dark : Brightness.light),
        ));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Morning Backup.rtb'));
        await tester.pumpAndSettle();

        expect(find.text('Share'), findsOneWidget);
        expect(find.text('Delete'), findsWidgets);
        expect(find.text('Restore'), findsOneWidget);
        expect(
          tester.widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Restore'),
          ),
          isA<FilledButton>(),
        );

        // Close the dialog between theme iterations.
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
      }
    });
  });
}