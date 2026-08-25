import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:rehab_track/data/services/report/report_storage_service.dart';
import 'package:rehab_track/data/services/report/saved_report_file.dart';
import 'package:rehab_track/domain/entities/report_configuration.dart';
import 'package:rehab_track/domain/entities/report_data.dart';
import 'package:rehab_track/domain/entities/report_date_range.dart';
import 'package:rehab_track/domain/entities/report_section.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/report_provider.dart';
import 'package:rehab_track/presentation/screens/reports/report_preview_screen.dart';

class _RecordingFakeStorage implements ReportStorageService {
  int saveCalls = 0;
  int openCalls = 0;
  int shareCalls = 0;
  bool failSave = false;
  Uint8List? savedBytes;

  @override
  Future<SavedReportFile> savePdf({
    required Uint8List bytes,
    required String displayName,
  }) async {
    if (failSave) {
      throw const ReportStorageException('SAVE_ERROR', message: 'disk full');
    }
    saveCalls++;
    savedBytes = bytes;
    return SavedReportFile(
      displayName: displayName,
      logicalLocation: 'Downloads/RehabTrack',
      mimeType: 'application/pdf',
      size: bytes.length,
      createdAt: DateTime.now(),
      contentUri: 'content://media/external/downloads/42',
    );
  }

  @override
  Future<void> open(SavedReportFile file) async => openCalls++;

  @override
  Future<void> share(SavedReportFile file) async => shareCalls++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late ProviderContainer container;
  late _RecordingFakeStorage storage;

  setUp(() {
    storage = _RecordingFakeStorage();
    container = ProviderContainer(
      overrides: [
        reportStorageServiceProvider.overrideWithValue(storage),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  ReportData minimalData() => ReportData(
        configuration: ReportConfiguration(
          title: 'Health Summary',
          dateRangeType: ReportDateRangeType.last30Days,
          selectedSections: {...ReportSection.ordered},
          profileId: 1,
        ),
        generatedAt: DateTime.now(),
        profileSummary: const ReportProfileSummary(fullName: 'Test User'),
      );

  Future<void> pumpPreview(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/preview',
      routes: [
        GoRoute(
          path: '/preview',
          builder: (context, state) =>
              ReportPreviewScreen(data: minimalData()),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  void expectNoPendingSheet() {
    expect(find.text('Report generated successfully'), findsNothing);
  }

  testWidgets(
      'generate saves one PDF and offers Open / Share / Done on the saved '
      'file', (tester) async {
    await pumpPreview(tester);
    expect(find.byIcon(Icons.picture_as_pdf_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.picture_as_pdf_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Exactly one PDF was generated and persisted — no duplicate for sharing.
    expect(storage.saveCalls, 1);
    expect(storage.savedBytes, isNotNull);
    expect(
      String.fromCharCodes(storage.savedBytes!.sublist(0, 4)),
      '%PDF',
    );

    // Success sheet content.
    expect(find.text('Report generated successfully'), findsOneWidget);
    expect(find.text('Saved to: Downloads/RehabTrack'), findsOneWidget);
    expect(find.textContaining('RehabTrack_Health_Summary_'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Open'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Share'), findsOneWidget);

    // Open and Share reuse the same saved result.
    await tester.tap(find.widgetWithText(FilledButton, 'Open'));
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Share'));
    await tester.pump();
    expect(storage.openCalls, 1);
    expect(storage.shareCalls, 1);
    expect(storage.saveCalls, 1);

    // Done closes the flow.
    await tester.tap(find.widgetWithText(TextButton, 'Done'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expectNoPendingSheet();
  });

  testWidgets('save failure shows a controlled error and no success sheet',
      (tester) async {
    storage.failSave = true;
    await pumpPreview(tester);

    await tester.tap(find.byIcon(Icons.picture_as_pdf_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(storage.saveCalls, 0);
    expect(find.text("Couldn't save the report"), findsOneWidget);
    expectNoPendingSheet();
  });
}
