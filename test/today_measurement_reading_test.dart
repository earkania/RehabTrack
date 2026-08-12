import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/reference_range_provider.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';
import 'package:rehab_track/presentation/widgets/today/today_agenda_item.dart';
import 'package:rehab_track/presentation/widgets/today/today_measurement_reading.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      effectiveRangesForCurrentProfileProvider
          .overrideWith((_, _) async => null),
      currentMinuteProvider.overrideWith((ref) => DateTime(2000, 1, 1)),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

MeasurementRecordValue _bpSys(double v) => MeasurementRecordValue(
      measurementRecordId: 1, fieldKey: 'systolic', numericValue: v, unit: 'mmHg');
MeasurementRecordValue _bpDia(double v) => MeasurementRecordValue(
      measurementRecordId: 1, fieldKey: 'diastolic', numericValue: v, unit: 'mmHg');
MeasurementRecordValue _bpPulse(double v) => MeasurementRecordValue(
      measurementRecordId: 1, fieldKey: 'pulse', numericValue: v, unit: 'bpm');
MeasurementRecordValue _weight(double v) => MeasurementRecordValue(
      measurementRecordId: 2, fieldKey: 'weight', numericValue: v, unit: 'kg');
MeasurementRecordValue _glucose(double v) => MeasurementRecordValue(
      measurementRecordId: 3, fieldKey: 'glucose', numericValue: v, unit: 'mmol/L');
MeasurementRecordValue _pulse(double v) => MeasurementRecordValue(
      measurementRecordId: 4, fieldKey: 'pulse', numericValue: v, unit: 'bpm');
MeasurementRecordValue _spo2(double v) => MeasurementRecordValue(
      measurementRecordId: 5, fieldKey: 'spo2', numericValue: v, unit: '%');
MeasurementRecordValue _temp(double v) => MeasurementRecordValue(
      measurementRecordId: 6, fieldKey: 'temperature', numericValue: v, unit: '°C');

TodayAgendaItem _completedMeasurement({
  required String typeKey,
  required List<MeasurementRecordValue> values,
  bool? irregularHeartbeat,
}) {
  return TodayAgendaItem(
    id: 'meas_1_0900',
    type: TodayAgendaItemType.measurement,
    sourceScheduleId: 1,
    scheduledDateTime: DateTime(2026, 7, 26, 9, 0),
    title: 'Blood Pressure',
    status: TodayAgendaItemStatus.completed,
    completedAt: DateTime(2026, 7, 26, 9, 5),
    measurementTypeId: 1,
    measurementTypeKey: typeKey,
    measurementRecordId: 1,
    irregularHeartbeatDetected: irregularHeartbeat,
    readingValues: values,
  );
}

void main() {
  group('TodayAgendaItem.readingValues', () {
    test('defaults to empty list', () {
      final item = TodayAgendaItem(
        id: '1', type: TodayAgendaItemType.medication,
        sourceScheduleId: 1, scheduledDateTime: DateTime(2026, 7, 26),
        title: 'Aspirin', status: TodayAgendaItemStatus.due,
      );
      expect(item.readingValues, isEmpty);
    });

    test('copyWith replaces readingValues', () {
      final item = TodayAgendaItem(
        id: '1', type: TodayAgendaItemType.measurement,
        sourceScheduleId: 1, scheduledDateTime: DateTime(2026, 7, 26),
        title: 'BP', status: TodayAgendaItemStatus.completed,
      );
      final values = [_bpSys(120)];
      final updated = item.copyWith(readingValues: values);
      expect(updated.readingValues, hasLength(1));
      expect(updated.readingValues.first.numericValue, 120);
      expect(item.readingValues, isEmpty);
    });
  });

  group('TodayMeasurementReading widget', () {
    testWidgets('renders BP reading', (tester) async {
      final item = _completedMeasurement(
        typeKey: 'blood_pressure',
        values: [_bpSys(120), _bpDia(80), _bpPulse(66)],
      );
      await tester.pumpWidget(_wrap(TodayMeasurementReading(item: item)));
      await tester.pumpAndSettle();

      // BP is rendered via RichText in BloodPressureSummaryText
      final richTexts = find.byType(RichText);
      expect(richTexts, findsAtLeastNWidgets(1));
      final plainTexts = <String>[];
      for (final rt in tester.widgetList<RichText>(richTexts)) {
        plainTexts.add(rt.text.toPlainText());
      }
      expect(plainTexts.any((t) => t.contains('120')), isTrue);
      expect(plainTexts.any((t) => t.contains('80')), isTrue);
      expect(plainTexts.any((t) => t.contains('66')), isTrue);
    });

    testWidgets('renders weight reading', (tester) async {
      final item = _completedMeasurement(
        typeKey: 'weight', values: [_weight(72.5)],
      );
      await tester.pumpWidget(_wrap(TodayMeasurementReading(item: item)));
      await tester.pumpAndSettle();

      final richTexts = find.byType(RichText);
      expect(richTexts, findsAtLeastNWidgets(1));
      final allText = tester.widgetList<RichText>(richTexts)
          .map((rt) => rt.text.toPlainText())
          .join(' ');
      expect(allText, contains('72.5'));
    });

    testWidgets('renders glucose reading', (tester) async {
      final item = _completedMeasurement(
        typeKey: 'blood_glucose', values: [_glucose(5.4)],
      );
      await tester.pumpWidget(_wrap(TodayMeasurementReading(item: item)));
      await tester.pumpAndSettle();

      final allText = find.byType(RichText)
          .evaluate()
          .map((e) => (e.widget as RichText).text.toPlainText())
          .join(' ');
      expect(allText, contains('5.4'));
    });

    testWidgets('renders pulse reading', (tester) async {
      final item = _completedMeasurement(
        typeKey: 'pulse', values: [_pulse(72)],
      );
      await tester.pumpWidget(_wrap(TodayMeasurementReading(item: item)));
      await tester.pumpAndSettle();

      final allText = find.byType(RichText)
          .evaluate()
          .map((e) => (e.widget as RichText).text.toPlainText())
          .join(' ');
      expect(allText, contains('72'));
    });

    testWidgets('renders SpO2 reading with pulse', (tester) async {
      final item = _completedMeasurement(
        typeKey: 'spo2', values: [_spo2(97), _pulse(68)],
      );
      await tester.pumpWidget(_wrap(TodayMeasurementReading(item: item)));
      await tester.pumpAndSettle();

      final allText = find.byType(RichText)
          .evaluate()
          .map((e) => (e.widget as RichText).text.toPlainText())
          .join(' ');
      expect(allText, contains('97'));
      expect(allText, contains('68'));
    });

    testWidgets('renders temperature reading', (tester) async {
      final item = _completedMeasurement(
        typeKey: 'temperature', values: [_temp(36.6)],
      );
      await tester.pumpWidget(_wrap(TodayMeasurementReading(item: item)));
      await tester.pumpAndSettle();

      final allText = find.byType(RichText)
          .evaluate()
          .map((e) => (e.widget as RichText).text.toPlainText())
          .join(' ');
      expect(allText, contains('36.6'));
    });

    testWidgets('shows irregular heartbeat indicator', (tester) async {
      final item = _completedMeasurement(
        typeKey: 'blood_pressure',
        values: [_bpSys(130), _bpDia(85), _bpPulse(70)],
        irregularHeartbeat: true,
      );
      await tester.pumpWidget(_wrap(TodayMeasurementReading(item: item)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.heart_broken), findsOneWidget);
    });

    testWidgets('hides irregular heartbeat when false', (tester) async {
      final item = _completedMeasurement(
        typeKey: 'blood_pressure',
        values: [_bpSys(120), _bpDia(80), _bpPulse(66)],
        irregularHeartbeat: false,
      );
      await tester.pumpWidget(_wrap(TodayMeasurementReading(item: item)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.heart_broken), findsNothing);
    });

    testWidgets('renders nothing for empty values', (tester) async {
      final item = TodayAgendaItem(
        id: 'meas_empty', type: TodayAgendaItemType.measurement,
        sourceScheduleId: 1, scheduledDateTime: DateTime(2026, 7, 26, 9, 0),
        title: 'Custom', status: TodayAgendaItemStatus.completed,
        measurementTypeId: 99, measurementTypeKey: 'unknown_type',
        measurementRecordId: 1, readingValues: [],
      );
      await tester.pumpWidget(_wrap(TodayMeasurementReading(item: item)));
      await tester.pumpAndSettle();

      expect(find.byType(RichText), findsNothing);
    });
  });

  group('TodayAgendaItemWidget integration', () {
    testWidgets('shows reading for completed measurement', (tester) async {
      final item = _completedMeasurement(
        typeKey: 'weight', values: [_weight(72.5)],
      );
      await tester.pumpWidget(_wrap(TodayAgendaItemWidget(item: item)));
      await tester.pumpAndSettle();

      expect(find.byType(TodayMeasurementReading), findsOneWidget);
      final allText = find.byType(RichText)
          .evaluate()
          .map((e) => (e.widget as RichText).text.toPlainText())
          .join(' ');
      expect(allText, contains('72.5'));
    });

    testWidgets('hides reading for non-completed measurement', (tester) async {
      final item = TodayAgendaItem(
        id: 'meas_1_0900', type: TodayAgendaItemType.measurement,
        sourceScheduleId: 1, scheduledDateTime: DateTime(2026, 7, 26, 9, 0),
        title: 'Blood Pressure', status: TodayAgendaItemStatus.due,
        measurementTypeId: 1, measurementTypeKey: 'blood_pressure',
        readingValues: [_bpSys(120), _bpDia(80)],
      );
      await tester.pumpWidget(_wrap(TodayAgendaItemWidget(item: item)));
      await tester.pumpAndSettle();

      expect(find.byType(TodayMeasurementReading), findsNothing);
    });

    testWidgets('hides reading for completed with no values', (tester) async {
      final item = TodayAgendaItem(
        id: 'meas_1_0900', type: TodayAgendaItemType.measurement,
        sourceScheduleId: 1, scheduledDateTime: DateTime(2026, 7, 26, 9, 0),
        title: 'Blood Pressure', status: TodayAgendaItemStatus.completed,
        measurementTypeId: 1, measurementTypeKey: 'blood_pressure',
        measurementRecordId: 1, readingValues: [],
      );
      await tester.pumpWidget(_wrap(TodayAgendaItemWidget(item: item)));
      await tester.pumpAndSettle();

      expect(find.byType(TodayMeasurementReading), findsNothing);
    });

    testWidgets('hides reading for medication items', (tester) async {
      final item = TodayAgendaItem(
        id: 'med_1_0800', type: TodayAgendaItemType.medication,
        sourceScheduleId: 1, scheduledDateTime: DateTime(2026, 7, 26, 8, 0),
        title: 'Aspirin', status: TodayAgendaItemStatus.completed,
        readingValues: [_weight(72.5)],
      );
      await tester.pumpWidget(_wrap(TodayAgendaItemWidget(item: item)));
      await tester.pumpAndSettle();

      expect(find.byType(TodayMeasurementReading), findsNothing);
    });

    testWidgets('skipped measurement hides reading', (tester) async {
      final item = TodayAgendaItem(
        id: 'meas_1_0900', type: TodayAgendaItemType.measurement,
        sourceScheduleId: 1, scheduledDateTime: DateTime(2026, 7, 26, 9, 0),
        title: 'Blood Pressure', status: TodayAgendaItemStatus.skipped,
        measurementTypeId: 1, measurementTypeKey: 'blood_pressure',
        readingValues: [_bpSys(120), _bpDia(80)],
      );
      await tester.pumpWidget(_wrap(TodayAgendaItemWidget(item: item)));
      await tester.pumpAndSettle();

      expect(find.byType(TodayMeasurementReading), findsNothing);
    });

    testWidgets('shows reading between title and instructions', (tester) async {
      final item = TodayAgendaItem(
        id: 'meas_1_0900', type: TodayAgendaItemType.measurement,
        sourceScheduleId: 1, scheduledDateTime: DateTime(2026, 7, 26, 9, 0),
        title: 'Blood Pressure', instructions: 'Before breakfast',
        status: TodayAgendaItemStatus.completed,
        measurementTypeId: 1, measurementTypeKey: 'blood_pressure',
        measurementRecordId: 1,
        readingValues: [_bpSys(120), _bpDia(80), _bpPulse(66)],
      );
      await tester.pumpWidget(_wrap(TodayAgendaItemWidget(item: item)));
      await tester.pumpAndSettle();

      expect(find.byType(TodayMeasurementReading), findsOneWidget);
      expect(find.text('Before breakfast'), findsOneWidget);
    });

    testWidgets('shows BP reading on completed item', (tester) async {
      final item = _completedMeasurement(
        typeKey: 'blood_pressure',
        values: [_bpSys(125), _bpDia(82), _bpPulse(70)],
      );
      await tester.pumpWidget(_wrap(TodayAgendaItemWidget(item: item)));
      await tester.pumpAndSettle();

      expect(find.byType(TodayMeasurementReading), findsOneWidget);
      final allText = find.byType(RichText)
          .evaluate()
          .map((e) => (e.widget as RichText).text.toPlainText())
          .join(' ');
      expect(allText, contains('125'));
      expect(allText, contains('82'));
      expect(allText, contains('70'));
    });
  });
}
