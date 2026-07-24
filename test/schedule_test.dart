import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/dosage_form.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/domain/entities/schedule_config.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/utils/dosage_form_localizer.dart';
import 'package:rehab_track/presentation/utils/schedule_formatter.dart';
import 'package:rehab_track/presentation/widgets/medication/medication_schedule_form.dart';
import 'package:rehab_track/presentation/widgets/medication/schedule_type_selector.dart';

Widget _wrapWithL10n(Widget child, {Locale? locale}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('ScheduleFormatter', () {
    testWidgets('formats daily schedule', (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithL10n(SizedBox.shrink()));
      final l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)))!;

      const schedule = MedicationSchedule(
        medicationId: 1,
        scheduleType: 'daily',
        scheduleConfig: DailySchedule(times: ['08:30']),
        intakeQuantity: 1,
        dosageForm: DosageForm.tablet,
      );
      final result = ScheduleFormatter.formatScheduleSummary(
        schedule,
        dailyAtLabel: 'Daily at {times}',
        everyNDaysLabel: 'Every {count} days at {times}',
        perIntakeLabel: '{quantity} per intake',
        l10n: l10n,
      );
      expect(result, 'Daily at 08:30\n1 tablet per intake');
    });

    testWidgets('formats interval days schedule', (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithL10n(SizedBox.shrink()));
      final l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)))!;

      const schedule = MedicationSchedule(
        medicationId: 1,
        scheduleType: 'interval_days',
        scheduleConfig: IntervalDaysSchedule(intervalDays: 3, times: ['09:00']),
        intakeQuantity: 2,
        dosageForm: DosageForm.capsule,
      );
      final result = ScheduleFormatter.formatScheduleSummary(
        schedule,
        dailyAtLabel: 'Daily at {times}',
        everyNDaysLabel: 'Every {count} days at {times}',
        perIntakeLabel: '{quantity} per intake',
        l10n: l10n,
      );
      expect(result, 'Every 3 days at 09:00\n2 capsules per intake');
    });

    testWidgets('formats daily schedule with multiple times',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithL10n(SizedBox.shrink()));
      final l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)))!;

      const schedule = MedicationSchedule(
        medicationId: 1,
        scheduleType: 'daily',
        scheduleConfig: DailySchedule(times: ['08:00', '14:00', '20:00']),
        intakeQuantity: 0.5,
        dosageForm: DosageForm.ml,
      );
      final result = ScheduleFormatter.formatScheduleSummary(
        schedule,
        dailyAtLabel: 'Daily at {times}',
        everyNDaysLabel: 'Every {count} days at {times}',
        perIntakeLabel: '{quantity} per intake',
        l10n: l10n,
      );
      expect(result, 'Daily at 08:00, 14:00, 20:00\n0.5 mls per intake');
    });
  });

  group('ScheduleConfig serialization', () {
    test('DailySchedule roundtrips through JSON', () {
      const original = DailySchedule(times: ['08:30']);
      final json = original.toJson();
      final restored = ScheduleConfig.fromJson(json);
      expect(restored, original);
    });

    test('IntervalDaysSchedule roundtrips through JSON', () {
      const original = IntervalDaysSchedule(intervalDays: 3, times: ['14:00']);
      final json = original.toJson();
      final restored = ScheduleConfig.fromJson(json);
      expect(restored, original);
    });

    test('DailySchedule with multiple times roundtrips', () {
      const original = DailySchedule(times: ['08:00', '20:00']);
      final json = original.toJson();
      final restored = ScheduleConfig.fromJson(json);
      expect(restored, original);
    });
  });

  group('ScheduleConfig.validateTimes', () {
    test('throws for empty times', () {
      expect(
        () => ScheduleConfig.validateTimes([]),
        throwsArgumentError,
      );
    });

    test('does not throw for valid times', () {
      expect(
        () => ScheduleConfig.validateTimes(['08:00', '14:00']),
        returnsNormally,
      );
    });

    test('throws for duplicate times', () {
      expect(
        () => ScheduleConfig.validateTimes(['08:00', '08:00']),
        throwsArgumentError,
      );
    });

    test('throws for invalid format', () {
      expect(
        () => ScheduleConfig.validateTimes(['8:00']),
        throwsArgumentError,
      );
    });
  });

  group('ScheduleFormData', () {
    test('daily schedule produces correct config', () {
      final data = ScheduleFormData(
        scheduleType: ScheduleType.daily,
        times: ['09:00'],
      );
      final config = data.toScheduleConfig();
      expect(config, isA<DailySchedule>());
      expect((config as DailySchedule).times, ['09:00']);
      expect(data.scheduleTypeString, 'daily');
    });

    test('interval days schedule produces sorted config', () {
      final data = ScheduleFormData(
        scheduleType: ScheduleType.intervalDays,
        times: ['20:00', '08:00', '14:00'],
        intervalDays: 7,
      );
      final config = data.toScheduleConfig();
      expect(config, isA<IntervalDaysSchedule>());
      final interval = config as IntervalDaysSchedule;
      expect(interval.intervalDays, 7);
      expect(interval.times, ['08:00', '14:00', '20:00']);
      expect(data.scheduleTypeString, 'interval_days');
    });

    test('fromSchedule creates correct daily form data', () {
      const schedule = MedicationSchedule(
        id: 1,
        medicationId: 1,
        scheduleType: 'daily',
        scheduleConfig: DailySchedule(times: ['08:00']),
        intakeQuantity: 1,
        dosageForm: DosageForm.tablet,
        active: true,
        instructions: 'After breakfast',
      );
      final data = ScheduleFormData.fromSchedule(schedule);
      expect(data.scheduleType, ScheduleType.daily);
      expect(data.times, ['08:00']);
      expect(data.intakeQuantity, 1);
      expect(data.dosageForm, DosageForm.tablet);
      expect(data.active, true);
      expect(data.instructions, 'After breakfast');
    });

    test('fromSchedule creates correct interval form data', () {
      const schedule = MedicationSchedule(
        id: 3,
        medicationId: 1,
        scheduleType: 'interval_days',
        scheduleConfig: IntervalDaysSchedule(intervalDays: 5, times: ['14:00']),
        intakeQuantity: 2,
        dosageForm: DosageForm.capsule,
        active: false,
        instructions: 'Before meal',
      );
      final data = ScheduleFormData.fromSchedule(schedule);
      expect(data.scheduleType, ScheduleType.intervalDays);
      expect(data.intervalDays, 5);
      expect(data.times, ['14:00']);
      expect(data.intakeQuantity, 2);
      expect(data.dosageForm, DosageForm.capsule);
      expect(data.active, false);
      expect(data.instructions, 'Before meal');
    });
  });

  group('ScheduleTypeSelector', () {
    testWidgets('renders two options', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithL10n(
          ScheduleTypeSelector(
            selectedType: ScheduleType.daily,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(ScheduleTypeSelector), findsOneWidget);
      expect(find.byIcon(Icons.today), findsOneWidget);
      expect(find.byIcon(Icons.date_range), findsOneWidget);
    });

    testWidgets('calls onChanged when option is tapped',
        (WidgetTester tester) async {
      ScheduleType? selectedType;

      await tester.pumpWidget(
        _wrapWithL10n(
          ScheduleTypeSelector(
            selectedType: ScheduleType.daily,
            onChanged: (type) => selectedType = type,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.date_range));
      await tester.pumpAndSettle();

      expect(selectedType, ScheduleType.intervalDays);
    });
  });

  group('MedicationScheduleForm', () {
    testWidgets('renders with daily type by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithL10n(
          MedicationScheduleForm(
            initialData: ScheduleFormData(),
            onSave: (_) {},
            saveButtonLabel: 'Save',
          ),
        ),
      );

      expect(find.byType(MedicationScheduleForm), findsOneWidget);
    });

    testWidgets('calls onSave with daily config',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithL10n(
          MedicationScheduleForm(
            initialData: ScheduleFormData(
              scheduleType: ScheduleType.daily,
              times: ['09:00'],
            ),
            onSave: (_) {},
            saveButtonLabel: 'Save',
          ),
        ),
      );

      expect(find.byType(ScheduleTypeSelector), findsOneWidget);

      final data = ScheduleFormData(
        scheduleType: ScheduleType.daily,
        times: ['09:00'],
      );
      final config = data.toScheduleConfig();
      expect(config, isA<DailySchedule>());
      expect((config as DailySchedule).times, ['09:00']);
    });
  });

  group('DosageForm', () {
    test('DosageForm enum has all expected values', () {
      expect(DosageForm.values.length, 11);
      expect(DosageForm.tablet, DosageForm.tablet);
      expect(DosageForm.topical, DosageForm.topical);
      expect(DosageForm.other, DosageForm.other);
    });

    test('DosageForm storage mapping works', () {
      expect(DosageForm.tablet.toStorageString(), 'tablet');
      expect(DosageForm.topical.toStorageString(), 'topical');
      expect(DosageFormExtension.fromStorageString('tablet'), DosageForm.tablet);
      expect(DosageFormExtension.fromStorageString('topical'), DosageForm.topical);
      expect(DosageFormExtension.fromStorageString('unknown'), isNull);
      expect(DosageFormExtension.fromStorageString(null), isNull);
    });
  });

  group('DosageFormLocalizer', () {
    testWidgets('localizes dosage form names', (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithL10n(SizedBox.shrink()));
      final l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)))!;

      expect(DosageFormLocalizer.localize(DosageForm.tablet, l10n), l10n.tablet);
      expect(DosageFormLocalizer.localize(DosageForm.capsule, l10n), l10n.capsule);
      expect(DosageFormLocalizer.localize(DosageForm.drop, l10n), l10n.drop);
      expect(DosageFormLocalizer.localize(DosageForm.ml, l10n), l10n.ml);
      expect(DosageFormLocalizer.localize(DosageForm.puff, l10n), l10n.puff);
      expect(DosageFormLocalizer.localize(DosageForm.unit, l10n), l10n.unit);
      expect(DosageFormLocalizer.localize(DosageForm.sachet, l10n), l10n.sachet);
      expect(DosageFormLocalizer.localize(DosageForm.spoon, l10n), l10n.spoon);
      expect(DosageFormLocalizer.localize(DosageForm.injection, l10n), l10n.injection);
      expect(DosageFormLocalizer.localize(DosageForm.topical, l10n), l10n.topical);
      expect(DosageFormLocalizer.localize(DosageForm.other, l10n), l10n.other);
    });

    testWidgets('localizeWithQuantity formats quantity and form',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithL10n(SizedBox.shrink()));
      final l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)))!;

      expect(
        DosageFormLocalizer.localizeWithQuantity(1, DosageForm.tablet, l10n),
        '1 ${l10n.tablet}',
      );
      expect(
        DosageFormLocalizer.localizeWithQuantity(2, DosageForm.capsule, l10n),
        '2 ${l10n.capsule}s',
      );
      expect(
        DosageFormLocalizer.localizeWithQuantity(0.5, DosageForm.ml, l10n),
        '0.5 ${l10n.ml}s',
      );
    });

    testWidgets('localizeSnapshot returns empty for null values',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithL10n(SizedBox.shrink()));
      final l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)))!;

      expect(
        DosageFormLocalizer.localizeSnapshot(quantity: null, form: null, l10n: l10n),
        '',
      );
      expect(
        DosageFormLocalizer.localizeSnapshot(quantity: 0, form: DosageForm.tablet, l10n: l10n),
        '',
      );
      expect(
        DosageFormLocalizer.localizeSnapshot(quantity: 1, form: null, l10n: l10n),
        '',
      );
    });

    testWidgets('English pluralization appends s for non-1 quantities',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithL10n(SizedBox.shrink()));
      final l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)))!;

      expect(
        DosageFormLocalizer.localizeWithQuantity(1, DosageForm.tablet, l10n),
        '1 tablet',
      );
      expect(
        DosageFormLocalizer.localizeWithQuantity(2, DosageForm.tablet, l10n),
        '2 tablets',
      );
      expect(
        DosageFormLocalizer.localizeWithQuantity(10, DosageForm.tablet, l10n),
        '10 tablets',
      );
      expect(
        DosageFormLocalizer.localizeWithQuantity(1, DosageForm.capsule, l10n),
        '1 capsule',
      );
      expect(
        DosageFormLocalizer.localizeWithQuantity(2, DosageForm.capsule, l10n),
        '2 capsules',
      );
      expect(
        DosageFormLocalizer.localizeWithQuantity(1, DosageForm.drop, l10n),
        '1 drop',
      );
      expect(
        DosageFormLocalizer.localizeWithQuantity(10, DosageForm.drop, l10n),
        '10 drops',
      );
    });

    testWidgets('Georgian never appends English s suffix',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithL10n(SizedBox.shrink(), locale: const Locale('ka')),
      );
      final l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)))!;

      // tablet: აბი — never აბიs
      expect(
        DosageFormLocalizer.localizeWithQuantity(1, DosageForm.tablet, l10n),
        '1 აბი',
      );
      expect(
        DosageFormLocalizer.localizeWithQuantity(2, DosageForm.tablet, l10n),
        '2 აბი',
      );
      expect(
        DosageFormLocalizer.localizeWithQuantity(10, DosageForm.tablet, l10n),
        '10 აბი',
      );

      // capsule: კაფსულა
      expect(
        DosageFormLocalizer.localizeWithQuantity(1, DosageForm.capsule, l10n),
        '1 კაფსულა',
      );
      expect(
        DosageFormLocalizer.localizeWithQuantity(2, DosageForm.capsule, l10n),
        '2 კაფსულა',
      );

      // drop: წვეთი
      expect(
        DosageFormLocalizer.localizeWithQuantity(1, DosageForm.drop, l10n),
        '1 წვეთი',
      );
      expect(
        DosageFormLocalizer.localizeWithQuantity(10, DosageForm.drop, l10n),
        '10 წვეთი',
      );

      // ml: მლ
      expect(
        DosageFormLocalizer.localizeWithQuantity(5, DosageForm.ml, l10n),
        '5 მლ',
      );

      // topical: წასმა
      expect(
        DosageFormLocalizer.localizeWithQuantity(1, DosageForm.topical, l10n),
        '1 წასმა',
      );
      expect(
        DosageFormLocalizer.localizeWithQuantity(3, DosageForm.topical, l10n),
        '3 წასმა',
      );
    });

    testWidgets('Georgian localizeSnapshot never appends s',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithL10n(SizedBox.shrink(), locale: const Locale('ka')),
      );
      final l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)))!;

      expect(
        DosageFormLocalizer.localizeSnapshot(
          quantity: 2,
          form: DosageForm.tablet,
          l10n: l10n,
        ),
        '2 აბი',
      );
      expect(
        DosageFormLocalizer.localizeSnapshot(
          quantity: 10,
          form: DosageForm.capsule,
          l10n: l10n,
        ),
        '10 კაფსულა',
      );
    });
  });
}
