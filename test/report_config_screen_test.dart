import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/app.dart';
import 'package:rehab_track/data/database/app_database.dart' show AppDatabase;
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/widgets/dashboard/module_grid_tile.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase.test();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        currentActiveProfileIdProvider.overrideWith((ref) => 1),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    database.close();
  });

  Future<void> flushTimers(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> goToReportsConfig(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: RehabTrackApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byIcon(Icons.folder_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ModuleGridTile, 'Reports'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
  }

  testWidgets('reports configuration screen opens from the records dashboard',
      (tester) async {
    await goToReportsConfig(tester);

    expect(find.text('Report Name'), findsOneWidget);
    expect(find.text('Date Range'), findsOneWidget);
    expect(find.text('Last 30 days'), findsOneWidget);
    expect(find.text('Sections to include'), findsOneWidget);
    // All eight sections listed in canonical order.
    for (final label in [
      'Patient Summary',
      'Medications',
      'Measurements',
      'Doctor Visits',
      'Doctor Prescriptions',
      'Lab Analyses',
      'Diet',
      'Activities',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.widgetWithText(FilledButton, 'Preview'), findsOneWidget);

    await flushTimers(tester);
  });

  testWidgets('preview without any selected section shows validation error',
      (tester) async {
    await goToReportsConfig(tester);

    // Uncheck every section (scroll each into view first).
    for (var i = 0; i < 8; i++) {
      await tester.ensureVisible(find.byType(CheckboxListTile).at(i));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(CheckboxListTile).at(i),
          matching: find.byType(Checkbox),
        ),
      );
      await tester.pump();
    }
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Preview'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Preview'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Select at least one section'), findsOneWidget);

    await flushTimers(tester);
  });

  testWidgets('custom range reveals From/To date pickers', (tester) async {
    await goToReportsConfig(tester);

    await tester.tap(find.text('Last 30 days'));
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Custom range').last);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.widgetWithText(OutlinedButton, 'From'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'To'), findsOneWidget);

    await flushTimers(tester);
  });
}
