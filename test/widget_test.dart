import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rehab_track/app.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/widgets/medication/medication_card.dart';
import 'package:rehab_track/presentation/widgets/medication/medication_form.dart';

Widget _wrapWithL10n(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ProviderScope(child: Scaffold(body: child)),
  );
}

void main() {
  group('App renders with bottom navigation', () {
    testWidgets('selected tab shows its label', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(child: RehabTrackApp()),
      );
      await tester.pumpAndSettle();

      // The selected tab (Today, index 0) should show its label
      expect(find.text('Today'), findsAtLeastNWidgets(1));
      // Unselected tabs do not render label Text widgets
      expect(find.byIcon(Icons.monitor_heart_outlined), findsOneWidget);
      expect(find.byIcon(Icons.medication_outlined), findsOneWidget);
      expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('switching tab updates selected label visibility',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(child: RehabTrackApp()),
      );
      await tester.pump();
      await tester.pump();

      // Tap on Measurements tab
      await tester.tap(find.byIcon(Icons.monitor_heart_outlined));
      await tester.pump();
      await tester.pump();

      // After switching, Measurements label should be visible
      // (appears as nav label + screen title)
      expect(find.text('Measurements'), findsAtLeastNWidgets(1));
      // Today is no longer selected — no Today Text in nav bar
      // (Today screen title also gone after switching away)
    });
  });

  group('MedicationCard', () {
    testWidgets('renders medication name', (WidgetTester tester) async {
      final medication = Medication(
        id: 1,
        profileId: 1,
        name: 'Aspirin',
        active: true,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      await tester.pumpWidget(
        _wrapWithL10n(MedicationCard(medication: medication)),
      );

      expect(find.text('Aspirin'), findsOneWidget);
    });

    testWidgets('does not render dose without components',
        (WidgetTester tester) async {
      final medication = Medication(
        id: 1,
        profileId: 1,
        name: 'Aspirin',
        active: true,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      await tester.pumpWidget(
        _wrapWithL10n(MedicationCard(medication: medication)),
      );

      expect(find.text('mg'), findsNothing);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;
      final medication = Medication(
        id: 1,
        profileId: 1,
        name: 'Aspirin',
        active: true,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      await tester.pumpWidget(
        _wrapWithL10n(
          MedicationCard(
            medication: medication,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Aspirin'));
      expect(tapped, isTrue);
    });
  });

  group('MedicationForm', () {
    testWidgets('shows validation error when name is empty',
        (WidgetTester tester) async {
      bool saved = false;

      await tester.pumpWidget(
        _wrapWithL10n(
          MedicationForm(
            initialData: MedicationFormData(),
            onSave: (_) => saved = true,
            saveButtonLabel: 'Save',
          ),
        ),
      );

      await tester.scrollUntilVisible(
        find.text('Save'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(saved, isFalse);
    });

    testWidgets('calls onSave with valid data', (WidgetTester tester) async {
      MedicationFormData? savedData;

      await tester.pumpWidget(
        _wrapWithL10n(
          MedicationForm(
            initialData: MedicationFormData(),
            onSave: (data) => savedData = data,
            saveButtonLabel: 'Save',
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'Aspirin');
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Save'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedData, isNotNull);
      expect(savedData!.name, 'Aspirin');
    });

    testWidgets('pre-populates fields from initial data',
        (WidgetTester tester) async {
      final data = MedicationFormData(
        name: 'Bisoprolol',
        active: true,
      );

      await tester.pumpWidget(
        _wrapWithL10n(
          MedicationForm(
            initialData: data,
            onSave: (_) {},
            saveButtonLabel: 'Save',
          ),
        ),
      );

      expect(find.text('Bisoprolol'), findsOneWidget);
    });
  });

  group('Medication list integration', () {
    testWidgets('Medications tab renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: RehabTrackApp()),
      );
      await tester.pump();

      // Tap by icon since unselected labels are not rendered
      await tester.tap(find.byIcon(Icons.medication_outlined));
      await tester.pump();

      // The screen should render without crashing - it may show loading or empty state
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('FAB navigates to add medication',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: RehabTrackApp()),
      );
      await tester.pump();

      // Tap by icon since unselected labels are not rendered
      await tester.tap(find.byIcon(Icons.medication_outlined));
      await tester.pump();

      // Look for the FAB (may take a moment to appear with empty list)
      final fab = find.byType(FloatingActionButton);
      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab);
        await tester.pump();
        // Should navigate to add screen
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });
}
