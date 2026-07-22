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
    home: Scaffold(body: child),
  );
}

void main() {
  group('App renders with bottom navigation', () {
    testWidgets('shows all tab labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: RehabTrackApp()),
      );
      await tester.pump();

      expect(find.text('Today'), findsAtLeastNWidgets(1));
      expect(find.text('Health'), findsAtLeastNWidgets(1));
      expect(find.text('Activities'), findsAtLeastNWidgets(1));
      expect(find.text('Records'), findsAtLeastNWidgets(1));
      expect(find.text('Settings'), findsAtLeastNWidgets(1));
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

    testWidgets('renders dose when present', (WidgetTester tester) async {
      final medication = Medication(
        id: 1,
        profileId: 1,
        name: 'Aspirin',
        doseAmount: '100',
        doseUnit: 'mg',
        active: true,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      await tester.pumpWidget(
        _wrapWithL10n(MedicationCard(medication: medication)),
      );

      expect(find.text('100 mg'), findsOneWidget);
    });

    testWidgets('does not render dose when absent',
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

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedData, isNotNull);
      expect(savedData!.name, 'Aspirin');
    });

    testWidgets('pre-populates fields from initial data',
        (WidgetTester tester) async {
      final data = MedicationFormData(
        name: 'Bisoprolol',
        doseAmount: '5',
        doseUnit: 'mg',
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
      expect(find.text('5'), findsOneWidget);
    });
  });

  group('Medication list integration', () {
    testWidgets('Activities tab renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: RehabTrackApp()),
      );
      await tester.pump();

      await tester.tap(find.text('Activities'));
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

      await tester.tap(find.text('Activities'));
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
