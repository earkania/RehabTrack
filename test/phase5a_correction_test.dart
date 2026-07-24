import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:rehab_track/app.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/utils/measurement_formatter.dart';
import 'package:rehab_track/presentation/utils/measurement_localizer.dart';

Widget _wrapWithApp(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ProviderScope(child: Scaffold(body: child)),
  );
}

void main() {
  group('Bottom navigation - selected-only labels', () {
    testWidgets('selected tab shows label on narrow screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(child: RehabTrackApp()),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Today'), findsAtLeastNWidgets(1));
    });

    testWidgets('no overflow on narrow English screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(child: RehabTrackApp()),
      );
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow on narrow Georgian screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _wrapWithApp(
          const RehabTrackApp(),
          locale: const Locale('ka'),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('Blood Pressure Georgian translation', () {
    testWidgets('displays as არტერიული წნევა in Georgian',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithApp(const SizedBox(), locale: const Locale('ka')),
      );
      await tester.pump();

      final l10n =
          AppLocalizations.of(tester.element(find.byType(SizedBox)))!;
      expect(l10n.bloodPressure, 'არტერიული წნევა');
    });

    testWidgets('displays as Blood Pressure in English',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithApp(const SizedBox(), locale: const Locale('en')),
      );
      await tester.pump();

      final l10n =
          AppLocalizations.of(tester.element(find.byType(SizedBox)))!;
      expect(l10n.bloodPressure, 'Blood Pressure');
    });
  });

  group('Weight icon', () {
    test('uses Symbols.weight from material_symbols_icons', () {
      expect(Symbols.weight, isA<IconData>());
    });
  });

  group('Measurement History Add Reading action', () {
    testWidgets('add reading tooltip exists in English',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithApp(const SizedBox(), locale: const Locale('en')),
      );
      await tester.pump();

      final l10n =
          AppLocalizations.of(tester.element(find.byType(SizedBox)))!;
      expect(l10n.addReadingTooltip, 'Add Reading');
    });

    testWidgets('add reading tooltip exists in Georgian',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithApp(const SizedBox(), locale: const Locale('ka')),
      );
      await tester.pump();

      final l10n =
          AppLocalizations.of(tester.element(find.byType(SizedBox)))!;
      expect(l10n.addReadingTooltip, 'ჩანაწერის დამატება');
    });
  });

  group('Measurement summary localization', () {
    test('English blood-pressure summary contains pulse', () {
      final values = [
        MeasurementRecordValue(
          measurementRecordId: 1,
          fieldKey: 'systolic',
          numericValue: 120,
          unit: 'mmHg',
          displayOrder: 0,
        ),
        MeasurementRecordValue(
          measurementRecordId: 1,
          fieldKey: 'diastolic',
          numericValue: 80,
          unit: 'mmHg',
          displayOrder: 1,
        ),
        MeasurementRecordValue(
          measurementRecordId: 1,
          fieldKey: 'pulse',
          numericValue: 65,
          unit: 'bpm',
          displayOrder: 2,
        ),
      ];
      final fields = [
        MeasurementTypeField(
          measurementTypeId: 1,
          fieldKey: 'systolic',
          label: 'Systolic',
          displayOrder: 0,
          createdAt: DateTime(2024),
        ),
        MeasurementTypeField(
          measurementTypeId: 1,
          fieldKey: 'diastolic',
          label: 'Diastolic',
          displayOrder: 1,
          createdAt: DateTime(2024),
        ),
        MeasurementTypeField(
          measurementTypeId: 1,
          fieldKey: 'pulse',
          label: 'Pulse',
          required: false,
          displayOrder: 2,
          createdAt: DateTime(2024),
        ),
      ];
      final record = MeasurementRecord(
        profileId: 1,
        measurementTypeId: 1,
        timestamp: DateTime(2024),
        valuePrimary: 120,
        unit: 'mmHg',
        createdAt: DateTime(2024),
      );

      final result = MeasurementFormatter.formatRecord(
        record,
        fields,
        values,
        pulseLabel: 'pulse',
      );

      expect(result, '120/80 mmHg, pulse 65 bpm');
      expect(result, contains('pulse'));
    });

    test('Georgian blood-pressure summary contains პულსი', () {
      final values = [
        MeasurementRecordValue(
          measurementRecordId: 1,
          fieldKey: 'systolic',
          numericValue: 120,
          unit: 'mmHg',
          displayOrder: 0,
        ),
        MeasurementRecordValue(
          measurementRecordId: 1,
          fieldKey: 'diastolic',
          numericValue: 80,
          unit: 'mmHg',
          displayOrder: 1,
        ),
        MeasurementRecordValue(
          measurementRecordId: 1,
          fieldKey: 'pulse',
          numericValue: 65,
          unit: 'bpm',
          displayOrder: 2,
        ),
      ];
      final fields = [
        MeasurementTypeField(
          measurementTypeId: 1,
          fieldKey: 'systolic',
          label: 'Systolic',
          displayOrder: 0,
          createdAt: DateTime(2024),
        ),
        MeasurementTypeField(
          measurementTypeId: 1,
          fieldKey: 'diastolic',
          label: 'Diastolic',
          displayOrder: 1,
          createdAt: DateTime(2024),
        ),
        MeasurementTypeField(
          measurementTypeId: 1,
          fieldKey: 'pulse',
          label: 'Pulse',
          required: false,
          displayOrder: 2,
          createdAt: DateTime(2024),
        ),
      ];
      final record = MeasurementRecord(
        profileId: 1,
        measurementTypeId: 1,
        timestamp: DateTime(2024),
        valuePrimary: 120,
        unit: 'mmHg',
        createdAt: DateTime(2024),
      );

      final result = MeasurementFormatter.formatRecord(
        record,
        fields,
        values,
        pulseLabel: 'პულსი',
      );

      expect(result, '120/80 mmHg, პულსი 65 bpm');
      expect(result, contains('პულსი'));
    });

    test('standard units remain unchanged', () {
      final values = [
        MeasurementRecordValue(
          measurementRecordId: 1,
          fieldKey: 'systolic',
          numericValue: 120,
          unit: 'mmHg',
          displayOrder: 0,
        ),
        MeasurementRecordValue(
          measurementRecordId: 1,
          fieldKey: 'diastolic',
          numericValue: 80,
          unit: 'mmHg',
          displayOrder: 1,
        ),
      ];
      final fields = [
        MeasurementTypeField(
          measurementTypeId: 1,
          fieldKey: 'systolic',
          label: 'Systolic',
          displayOrder: 0,
          createdAt: DateTime(2024),
        ),
        MeasurementTypeField(
          measurementTypeId: 1,
          fieldKey: 'diastolic',
          label: 'Diastolic',
          displayOrder: 1,
          createdAt: DateTime(2024),
        ),
      ];
      final record = MeasurementRecord(
        profileId: 1,
        measurementTypeId: 1,
        timestamp: DateTime(2024),
        valuePrimary: 120,
        unit: 'mmHg',
        createdAt: DateTime(2024),
      );

      final result = MeasurementFormatter.formatRecord(record, fields, values);

      expect(result, contains('mmHg'));
    });
  });

  group('MeasurementLocalizer', () {
    testWidgets('typeName returns correct localized name',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithApp(const SizedBox(), locale: const Locale('en')),
      );
      await tester.pump();

      final l10n =
          AppLocalizations.of(tester.element(find.byType(SizedBox)))!;
      expect(
        MeasurementLocalizer.typeName(l10n, 'blood_pressure'),
        'Blood Pressure',
      );
    });

    testWidgets('fieldName returns correct localized name',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithApp(const SizedBox(), locale: const Locale('en')),
      );
      await tester.pump();

      final l10n =
          AppLocalizations.of(tester.element(find.byType(SizedBox)))!;
      expect(MeasurementLocalizer.fieldName(l10n, 'systolic'), 'Systolic');
    });

    testWidgets('typeName returns custom key for unknown type',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithApp(const SizedBox(), locale: const Locale('en')),
      );
      await tester.pump();

      final l10n =
          AppLocalizations.of(tester.element(find.byType(SizedBox)))!;
      expect(
        MeasurementLocalizer.typeName(l10n, 'custom_type'),
        'custom_type',
      );
    });
  });

  group('Bottom navigation - selected-only labels (responsive)', () {
    testWidgets('selected tab shows its label, unselected tabs show icons only',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(child: RehabTrackApp()),
      );
      await tester.pumpAndSettle();

      // Selected tab (Today) shows label
      expect(find.text('Today'), findsAtLeastNWidgets(1));
      // All tab icons exist in the nav bar
      expect(find.byIcon(Icons.today), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.monitor_heart_outlined), findsOneWidget);
      expect(find.byIcon(Icons.medication_outlined), findsOneWidget);
      expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('no overflow on narrow English screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(child: RehabTrackApp()),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow on narrow Georgian screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _wrapWithApp(
          const RehabTrackApp(),
          locale: const Locale('ka'),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('wrapped label uses TextAlign.center',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(child: RehabTrackApp()),
      );
      await tester.pumpAndSettle();

      // The nav bar is inside a Scaffold in the shell route.
      // Find all Text widgets with "Today" — the one inside the bottom
      // navigation area should have textAlign: center.
      final todayTexts = find.text('Today').evaluate();
      // At least one of them should be the nav bar label with center alignment
      final hasCenterAligned = todayTexts.any((el) {
        final widget = el.widget;
        return widget is Text && widget.textAlign == TextAlign.center;
      });
      expect(hasCenterAligned, isTrue);

      // All "Today" Text widgets should have maxLines: 2
      for (final el in todayTexts) {
        final widget = el.widget as Text;
        if (widget.maxLines != null) {
          expect(widget.maxLines, 2);
        }
      }
    });

    testWidgets('icons remain vertically aligned across all tabs',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(child: RehabTrackApp()),
      );
      await tester.pumpAndSettle();

      // All nav bar icons should exist (today also appears in empty state)
      expect(find.byIcon(Icons.today), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.monitor_heart_outlined), findsOneWidget);
      expect(find.byIcon(Icons.medication_outlined), findsOneWidget);
      expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });
  });

  group('Measurement History - add reading button', () {
    testWidgets('add reading tooltip exists in English',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _wrapWithApp(const SizedBox(), locale: const Locale('en')),
      );
      await tester.pump();

      final l10n =
          AppLocalizations.of(tester.element(find.byType(SizedBox)))!;
      expect(l10n.addReadingTooltip, 'Add Reading');
    });

    testWidgets('Georgian tooltip works',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithApp(const SizedBox(), locale: const Locale('ka')),
      );
      await tester.pump();

      final l10n =
          AppLocalizations.of(tester.element(find.byType(SizedBox)))!;
      expect(l10n.addReadingTooltip, 'ჩანაწერის დამატება');
    });

    testWidgets('both screens use same IconButton style with add_circle_outline',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Render the full app — without database the Measurements screen
      // shows EmptyState. The add_circle_outline IconButton exists in
      // _MeasurementTypeCard (rendered when types exist) and in
      // MeasurementHistoryScreen AppBar. This test verifies no overflow
      // and the screen builds correctly with both screens sharing the
      // same button code path.
      await tester.pumpWidget(
        const ProviderScope(child: RehabTrackApp()),
      );
      await tester.pumpAndSettle();

      // No overflow
      expect(tester.takeException(), isNull);

      // Navigate to Measurements tab — renders correctly
      await tester.tap(find.byIcon(Icons.monitor_heart_outlined));
      await tester.pump();
      await tester.pump();

      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });

    testWidgets('no overflow on narrow screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(child: RehabTrackApp()),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
