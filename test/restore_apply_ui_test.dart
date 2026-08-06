import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/data/services/backup/backup_archive_reader.dart';
import 'package:rehab_track/data/services/backup/backup_validator.dart';
import 'package:rehab_track/data/services/restore/restore_recovery_metadata.dart';
import 'package:rehab_track/data/services/restore/restore_service.dart';
import 'package:rehab_track/domain/backup/backup_compatibility.dart';
import 'package:rehab_track/domain/backup/backup_preview.dart';
import 'package:rehab_track/domain/restore/restore_apply_phase.dart';
import 'package:rehab_track/domain/restore/restore_failure.dart';
import 'package:rehab_track/domain/restore/restore_result.dart';
import 'package:rehab_track/domain/restore/restore_rollback_result.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/restore_apply_provider.dart';
import 'package:rehab_track/presentation/screens/settings/backup_preview_screen.dart';

import 'helpers/restore_test_utils.dart';

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
    managedFileCount: 1,
    backupFileSize: 65536,
  );
}

class FakeApplyService extends RestoreService {
  final List<RestoreApplyPhase> phases;
  RestoreFailure? failure;
  Completer<void>? gate;

  FakeApplyService({required this.phases})
      : super(
          environment: FakeRestoreEnvironment(
            Directory.systemTemp.createTempSync('apply_ui_'),
          ),
          archiveReader: const BackupArchiveReader(),
          validator: const BackupValidator(),
          recoveryStore: RestoreRecoveryStore.inDirectory(
            Directory.systemTemp.createTempSync('apply_recovery_'),
          ),
          tempBaseDir: Directory.systemTemp,
          currentDatabaseSchemaVersion: 14,
          currentAppVersion: '1.2.0',
        );

  @override
  Future<RestoreFailure> run({
    required File selectedBackupFile,
    required BackupPreview expectedPreview,
    void Function(RestoreApplyPhase phase)? onPhase,
    Future<bool> Function()? isCancellationRequested,
  }) async {
    for (final phase in phases) {
      onPhase?.call(phase);
    }
    if (gate != null) await gate!.future;
    if (isCancellationRequested != null && await isCancellationRequested()) {
      return RestoreFailure(
        result: RestoreResult.cancelled,
        recoveryId: 'op_cancel',
      );
    }
    return failure!;
  }
}

const _phases = [
  RestoreApplyPhase.preparingRestore,
  RestoreApplyPhase.creatingSafetySnapshot,
  RestoreApplyPhase.preparingDatabase,
  RestoreApplyPhase.preparingFiles,
  RestoreApplyPhase.preparingPreferences,
  RestoreApplyPhase.pausingServices,
  RestoreApplyPhase.replacingDatabase,
  RestoreApplyPhase.restoringFiles,
  RestoreApplyPhase.restoringPreferences,
  RestoreApplyPhase.reinitializing,
  RestoreApplyPhase.verifyingData,
  RestoreApplyPhase.finalizing,
];

Widget _app(Widget child) => MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

Widget _wrap(FakeApplyService service) {
  return ProviderScope(
    overrides: [
      restoreApplyProvider.overrideWith(
        (ref) => RestoreApplyController(service),
      ),
    ],
    child: _app(BackupPreviewScreen(
      preview: _preview(),
      backupFilePath: '/tmp/selected.rtb',
    )),
  );
}

Future<void> _startRestore(WidgetTester tester) async {
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  final dialogContinue = find.descendant(
    of: find.byType(AlertDialog),
    matching: find.widgetWithText(FilledButton, 'Continue'),
  );
  await tester.tap(dialogContinue);
  // Allow the confirmation dialog to close and the progress dialog to appear.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
}

void main() {
  testWidgets('successful restore shows the completion dialog with the '
      'reminder warning', (tester) async {
    final service = FakeApplyService(phases: _phases)
      ..failure = RestoreFailure.successWithReminderWarning('op1')
      ..gate = Completer<void>();

    await tester.pumpWidget(_wrap(service));
    await _startRestore(tester);

    // Progress dialog shown while the restore is held in progress.
    expect(find.text('Restoring your data'), findsOneWidget);

    service.gate!.complete();
    await tester.pumpAndSettle();

    expect(find.text('Restore completed'), findsOneWidget);
    expect(find.textContaining('Your data was restored'), findsOneWidget);
    expect(
      find.textContaining('Reminders could not be fully rebuilt'),
      findsOneWidget,
    );

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    // The preview screen has been popped back.
    expect(find.text('Backup preview'), findsNothing);
  });

  testWidgets('cancel button is offered only in safe pre-swap phases', (
    tester,
  ) async {
    final safeService = FakeApplyService(
      phases: [RestoreApplyPhase.preparingRestore],
    )
      ..gate = Completer<void>()
      ..failure = RestoreFailure(
        result: RestoreResult.unexpectedFailure,
        recoveryId: 'op_safe',
      );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        restoreApplyProvider.overrideWith(
          (ref) => RestoreApplyController(safeService),
        ),
      ],
      child: _app(BackupPreviewScreen(
        preview: _preview(),
        backupFilePath: '/tmp/selected.rtb',
      )),
    ));
    await _startRestore(tester);
    expect(find.text('Restoring your data'), findsOneWidget);
    // PreparingRestore is a safe phase: cancellation is offered (TextButton).
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(TextButton, 'Cancel'),
      ),
      findsOneWidget,
    );

    safeService.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Restore failed'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  });

  testWidgets('cancel button is hidden once the live replacement begins', (
    tester,
  ) async {
    final service = FakeApplyService(
      phases: [RestoreApplyPhase.replacingDatabase],
    )
      ..gate = Completer<void>()
      ..failure = RestoreFailure.success('op2');

    await tester.pumpWidget(_wrap(service));
    await _startRestore(tester);

    // ReplacingDatabase is not a safe cancellation phase: no cancel button.
    expect(find.text('Restoring your data'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(TextButton, 'Cancel'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Cancel'),
      ),
      findsNothing,
    );

    service.gate!.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('a failed verification reports the original data was recovered',
      (tester) async {
    final service = FakeApplyService(phases: _phases)
      ..failure = RestoreFailure(
        result: RestoreResult.verificationFailure,
        recoveryId: 'op_v',
        rollback: RestoreRollbackResult.rollbackSucceeded,
      );

    await tester.pumpWidget(_wrap(service));
    await _startRestore(tester);
    await tester.pumpAndSettle();

    expect(find.text('Restore failed'), findsOneWidget);
    expect(find.text('Your original data was recovered.'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  });

  testWidgets('a failed rollback asks the user to contact support with a code',
      (tester) async {
    final service = FakeApplyService(phases: _phases)
      ..failure = RestoreFailure(
        result: RestoreResult.verificationFailure,
        recoveryId: 'recovery_abc',
        rollback: RestoreRollbackResult.rollbackFailed,
      );

    await tester.pumpWidget(_wrap(service));
    await _startRestore(tester);
    await tester.pumpAndSettle();

    expect(find.text('Restore failed'), findsOneWidget);
    expect(find.textContaining('recovery_abc'), findsOneWidget);
    expect(
      find.textContaining('Automatic recovery could not complete'),
      findsOneWidget,
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  });

  testWidgets('a cancelled restore shows the cancellation message',
      (tester) async {
    final service = FakeApplyService(
      phases: [RestoreApplyPhase.preparingRestore],
    )..failure = RestoreFailure(
        result: RestoreResult.cancelled,
        recoveryId: 'op_cancel',
      );

    await tester.pumpWidget(_wrap(service));
    await _startRestore(tester);
    await tester.pumpAndSettle();

    expect(find.text('Restore cancelled'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  });
}