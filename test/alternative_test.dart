import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/domain/entities/medication_alternative.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/widgets/medication/medication_alternative_card.dart';
import 'package:rehab_track/presentation/widgets/medication/medication_alternative_form.dart';

Widget _wrapWithL10n(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ProviderScope(child: Scaffold(body: child)),
  );
}

void main() {
  group('MedicationAlternativeCard', () {
    testWidgets('renders alternative name', (WidgetTester tester) async {
      final alternative = MedicationAlternative(
        id: 1,
        medicationId: 1,
        name: 'Bisoprolol',
        doctorApproved: true,
        createdAt: DateTime(2026),
      );

      await tester.pumpWidget(
        _wrapWithL10n(MedicationAlternativeCard(alternative: alternative)),
      );

      expect(find.text('Bisoprolol'), findsOneWidget);
    });

    testWidgets('renders doctor approved badge when approved',
        (WidgetTester tester) async {
      final alternative = MedicationAlternative(
        id: 1,
        medicationId: 1,
        name: 'Bisoprolol',
        doctorApproved: true,
        createdAt: DateTime(2026),
      );

      await tester.pumpWidget(
        _wrapWithL10n(MedicationAlternativeCard(alternative: alternative)),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('does not render doctor approved badge when not approved',
        (WidgetTester tester) async {
      final alternative = MedicationAlternative(
        id: 1,
        medicationId: 1,
        name: 'Bisoprolol',
        doctorApproved: false,
        createdAt: DateTime(2026),
      );

      await tester.pumpWidget(
        _wrapWithL10n(MedicationAlternativeCard(alternative: alternative)),
      );

      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('renders notes preview when present',
        (WidgetTester tester) async {
      final alternative = MedicationAlternative(
        id: 1,
        medicationId: 1,
        name: 'Bisoprolol',
        notes: 'Generic substitute for Concor',
        doctorApproved: false,
        createdAt: DateTime(2026),
      );

      await tester.pumpWidget(
        _wrapWithL10n(MedicationAlternativeCard(alternative: alternative)),
      );

      expect(find.text('Generic substitute for Concor'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;
      final alternative = MedicationAlternative(
        id: 1,
        medicationId: 1,
        name: 'Bisoprolol',
        doctorApproved: false,
        createdAt: DateTime(2026),
      );

      await tester.pumpWidget(
        _wrapWithL10n(
          MedicationAlternativeCard(
            alternative: alternative,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Bisoprolol'));
      expect(tapped, isTrue);
    });
  });

  group('MedicationAlternativeForm', () {
    testWidgets('shows validation error when name is empty',
        (WidgetTester tester) async {
      bool saved = false;

      await tester.pumpWidget(
        _wrapWithL10n(
          MedicationAlternativeForm(
            initialData: MedicationAlternativeFormData(),
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
      MedicationAlternativeFormData? savedData;

      await tester.pumpWidget(
        _wrapWithL10n(
          MedicationAlternativeForm(
            initialData: MedicationAlternativeFormData(),
            onSave: (data) => savedData = data,
            saveButtonLabel: 'Save',
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'Bisoprolol');
      await tester.pump();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedData, isNotNull);
      expect(savedData!.name, 'Bisoprolol');
    });

    testWidgets('pre-populates fields from initial data',
        (WidgetTester tester) async {
      final data = MedicationAlternativeFormData(
        name: 'Metformin',
        doctorApproved: true,
        notes: 'Generic substitute',
      );

      await tester.pumpWidget(
        _wrapWithL10n(
          MedicationAlternativeForm(
            initialData: data,
            onSave: (_) {},
            saveButtonLabel: 'Save',
          ),
        ),
      );

      expect(find.text('Metformin'), findsOneWidget);
      expect(find.text('Generic substitute'), findsOneWidget);
    });

    testWidgets('trims whitespace from name', (WidgetTester tester) async {
      MedicationAlternativeFormData? savedData;

      await tester.pumpWidget(
        _wrapWithL10n(
          MedicationAlternativeForm(
            initialData: MedicationAlternativeFormData(),
            onSave: (data) => savedData = data,
            saveButtonLabel: 'Save',
          ),
        ),
      );

      await tester.enterText(
          find.byType(TextFormField).first, '  Bisoprolol  ');
      await tester.pump();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedData, isNotNull);
      expect(savedData!.name, 'Bisoprolol');
    });

    testWidgets('fromAlternative creates correct form data',
        (WidgetTester tester) async {
      final alternative = MedicationAlternative(
        id: 1,
        medicationId: 1,
        name: 'Bisoprolol',
        doseAmount: '5',
        doseUnit: 'mg',
        doctorApproved: true,
        notes: 'Generic substitute',
        createdAt: DateTime(2026),
      );

      final formData =
          MedicationAlternativeFormData.fromAlternative(alternative);

      expect(formData.name, 'Bisoprolol');
      expect(formData.doctorApproved, isTrue);
      expect(formData.notes, 'Generic substitute');
    });

    testWidgets('fromAlternative handles null optional fields',
        (WidgetTester tester) async {
      final alternative = MedicationAlternative(
        id: 1,
        medicationId: 1,
        name: 'Aspirin',
        doctorApproved: false,
        createdAt: DateTime(2026),
      );

      final formData =
          MedicationAlternativeFormData.fromAlternative(alternative);

      expect(formData.name, 'Aspirin');
      expect(formData.doctorApproved, isFalse);
      expect(formData.notes, '');
    });
  });
}
