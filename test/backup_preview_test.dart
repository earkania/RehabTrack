import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/domain/backup/backup_compatibility.dart';
import 'package:rehab_track/domain/backup/backup_preview.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/screens/settings/backup_preview_screen.dart';

BackupPreview _preview({
  BackupCompatibility compatibility = BackupCompatibility.compatible,
  bool migrationRequired = false,
  int? profileCount = 2,
  List<BackupWarning> warnings = const [],
}) {
  return BackupPreview(
    backupCreatedAt: DateTime.utc(2026, 8, 5),
    appVersion: '1.2.0',
    backupFormatVersion: 1,
    databaseSchemaVersion: 14,
    currentDatabaseSchemaVersion: 15,
    compatibility: compatibility,
    migrationRequired: migrationRequired,
    profileCount: profileCount,
    managedFileCount: 0,
    backupFileSize: 65536,
    warnings: warnings,
  );
}

Widget _wrap(BackupPreview preview) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: BackupPreviewScreen(preview: preview),
  );
}

void main() {
  test('preview model keeps only non-sensitive metadata', () {
    final preview = _preview();
    expect(preview.compatibility, BackupCompatibility.compatible);
    expect(preview.migrationRequired, isFalse);
    expect(preview.profileCount, 2);
    expect(preview.managedFileCount, 0);
    expect(preview.backupFileSize, 65536);
  });

  testWidgets('shows details and a compatible banner', (tester) async {
    await tester.pumpWidget(_wrap(_preview()));

    expect(find.text('Backup preview'), findsOneWidget);
    expect(find.text('Compatible'), findsOneWidget);
    expect(find.text('Backup details'), findsOneWidget);
    expect(find.textContaining('August 5, 2026'), findsOneWidget);
    expect(find.text('App version: 1.2.0'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    // No sensitive data is rendered.
    expect(find.textContaining('profile'), findsNothing);
  });

  testWidgets('shows migration-required banner and warning', (tester) async {
    await tester.pumpWidget(_wrap(
      _preview(
        compatibility: BackupCompatibility.compatibleMigrationRequired,
        migrationRequired: true,
        warnings: const [BackupWarning.migrationRequired],
      ),
    ));

    expect(find.text('Compatible, migration required'), findsOneWidget);
    expect(
      find.text('Migration will be required before restore.'),
      findsWidgets,
    );
  });

  testWidgets('confirming without a backup file shows an invalid-file notice',
      (tester) async {
    await tester.pumpWidget(_wrap(_preview()));

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Confirmation dialog explains the data replacement.
    expect(find.text('Backup preview'), findsWidgets);
    expect(
      find.text('Restoring this backup will replace the current RehabTrack '
          'data on this device with the backup contents. Photos, settings and '
          'all records will be overwritten.'),
      findsOneWidget,
    );

    // Without a persisted backup file the restore cannot start.
    await tester.tap(find.text('Continue').last);
    await tester.pumpAndSettle();

    expect(find.text('This file is not a valid RehabTrack backup.'),
        findsOneWidget);

    // The preview screen is still shown.
    expect(find.text('Backup preview'), findsWidgets);
  });

  testWidgets('migration-required backups can now start the restore', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(
      _preview(
        compatibility: BackupCompatibility.compatibleMigrationRequired,
        migrationRequired: true,
      ),
    ));

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // No "not available yet" gate: the confirmation dialog is shown directly.
    expect(find.text('Migration required'), findsNothing);
    expect(
      find.text('Restoring this backup will replace the current RehabTrack '
          'data on this device with the backup contents. Photos, settings and '
          'all records will be overwritten.'),
      findsOneWidget,
    );
  });
}