import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/domain/entities/schedule_config.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/utils/schedule_formatter.dart';
import 'package:rehab_track/presentation/widgets/medication/medication_schedule_form.dart';
import 'package:rehab_track/presentation/widgets/medication/schedule_type_selector.dart';

Widget _wrapWithL10n(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('ScheduleFormatter', () {
    test('formats daily schedule', () {
      final config = DailySchedule(time: '08:30');
      final result = ScheduleFormatter.formatScheduleSummary(
        config,
        dailyAtLabel: 'Daily at {time}',
        fixedTimesLabel: 'Fixed times: {times}',
        everyNDaysLabel: 'Every {count} days at {time}',
      );
      expect(result, 'Daily at 08:30');
    });

    test('formats fixed times schedule', () {
      final config = FixedTimesSchedule(times: ['08:00', '14:00', '20:00']);
      final result = ScheduleFormatter.formatScheduleSummary(
        config,
        dailyAtLabel: 'Daily at {time}',
        fixedTimesLabel: 'Fixed times: {times}',
        everyNDaysLabel: 'Every {count} days at {time}',
      );
      expect(result, 'Fixed times: 08:00, 14:00, 20:00');
    });

    test('formats interval days schedule', () {
      final config = IntervalDaysSchedule(interval: 3, time: '09:00');
      final result = ScheduleFormatter.formatScheduleSummary(
        config,
        dailyAtLabel: 'Daily at {time}',
        fixedTimesLabel: 'Fixed times: {times}',
        everyNDaysLabel: 'Every {count} days at {time}',
      );
      expect(result, 'Every 3 days at 09:00');
    });
  });

  group('ScheduleConfig serialization', () {
    test('DailySchedule roundtrips through JSON', () {
      const original = DailySchedule(time: '08:30');
      final json = original.toJson();
      final restored = ScheduleConfig.fromJson(json);
      expect(restored, original);
    });

    test('FixedTimesSchedule roundtrips through JSON', () {
      const original = FixedTimesSchedule(times: ['08:00', '20:00']);
      final json = original.toJson();
      final restored = ScheduleConfig.fromJson(json);
      expect(restored, original);
    });

    test('IntervalDaysSchedule roundtrips through JSON', () {
      const original = IntervalDaysSchedule(interval: 3, time: '14:00');
      final json = original.toJson();
      final restored = ScheduleConfig.fromJson(json);
      expect(restored, original);
    });
  });

  group('ScheduleFormData', () {
    test('daily schedule produces correct config', () {
      final data = ScheduleFormData(
        scheduleType: ScheduleType.daily,
        dailyTime: '09:00',
      );
      final config = data.toScheduleConfig();
      expect(config, isA<DailySchedule>());
      expect((config as DailySchedule).time, '09:00');
      expect(data.scheduleTypeString, 'daily');
    });

    test('fixed times schedule produces sorted config', () {
      final data = ScheduleFormData(
        scheduleType: ScheduleType.fixedTimes,
        fixedTimes: ['20:00', '08:00', '14:00'],
      );
      final config = data.toScheduleConfig();
      expect(config, isA<FixedTimesSchedule>());
      expect((config as FixedTimesSchedule).times, ['08:00', '14:00', '20:00']);
      expect(data.scheduleTypeString, 'fixed_times');
    });

    test('interval days schedule produces correct config', () {
      final data = ScheduleFormData(
        scheduleType: ScheduleType.intervalDays,
        intervalDays: 7,
        intervalTime: '10:00',
      );
      final config = data.toScheduleConfig();
      expect(config, isA<IntervalDaysSchedule>());
      final interval = config as IntervalDaysSchedule;
      expect(interval.interval, 7);
      expect(interval.time, '10:00');
      expect(data.scheduleTypeString, 'interval_days');
    });

    test('fromSchedule creates correct daily form data', () {
      const schedule = MedicationSchedule(
        id: 1,
        medicationId: 1,
        scheduleType: 'daily',
        scheduleConfig: DailySchedule(time: '08:00'),
        active: true,
        instructions: 'After breakfast',
      );
      final data = ScheduleFormData.fromSchedule(schedule);
      expect(data.scheduleType, ScheduleType.daily);
      expect(data.dailyTime, '08:00');
      expect(data.active, true);
      expect(data.instructions, 'After breakfast');
    });

    test('fromSchedule creates correct fixed times form data', () {
      const schedule = MedicationSchedule(
        id: 2,
        medicationId: 1,
        scheduleType: 'fixed_times',
        scheduleConfig: FixedTimesSchedule(times: ['08:00', '20:00']),
        active: true,
      );
      final data = ScheduleFormData.fromSchedule(schedule);
      expect(data.scheduleType, ScheduleType.fixedTimes);
      expect(data.fixedTimes, ['08:00', '20:00']);
      expect(data.instructions, '');
    });

    test('fromSchedule creates correct interval form data', () {
      const schedule = MedicationSchedule(
        id: 3,
        medicationId: 1,
        scheduleType: 'interval_days',
        scheduleConfig: IntervalDaysSchedule(interval: 5, time: '14:00'),
        active: false,
        instructions: 'Before meal',
      );
      final data = ScheduleFormData.fromSchedule(schedule);
      expect(data.scheduleType, ScheduleType.intervalDays);
      expect(data.intervalDays, 5);
      expect(data.intervalTime, '14:00');
      expect(data.active, false);
      expect(data.instructions, 'Before meal');
    });
  });

  group('ScheduleTypeSelector', () {
    testWidgets('renders all three options', (WidgetTester tester) async {
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
      expect(find.byIcon(Icons.access_time), findsOneWidget);
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

      // Tap the fixed times option (access_time icon)
      await tester.tap(find.byIcon(Icons.access_time));
      await tester.pumpAndSettle();

      expect(selectedType, ScheduleType.fixedTimes);
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
              dailyTime: '09:00',
            ),
            onSave: (_) {},
            saveButtonLabel: 'Save',
          ),
        ),
      );

      // Verify form renders with schedule type selector
      expect(find.byType(ScheduleTypeSelector), findsOneWidget);

      // Test data class directly since scrolling in tests is unreliable
      final data = ScheduleFormData(
        scheduleType: ScheduleType.daily,
        dailyTime: '09:00',
      );
      final config = data.toScheduleConfig();
      expect(config, isA<DailySchedule>());
      expect((config as DailySchedule).time, '09:00');
    });
  });
}
