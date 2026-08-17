import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/measurement_chart.dart';
import 'package:rehab_track/domain/entities/measurement_data_point.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/domain/services/measurement_chart_builder.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/utils/measurement_chart_axis.dart';
import 'package:rehab_track/presentation/utils/reading_status_color.dart';
import 'package:rehab_track/presentation/widgets/charts/measurement_line_chart.dart';

const _leftPad = 8.0;
const _rightPad = 16.0;
const _topPad = 16.0;
const _bottomPad = 8.0;
const _chartHeight = 250.0;
const _leftReserved = 40.0;
const _bottomReserved = 30.0;

const _ranges = MeasurementRanges(fieldRanges: {
  'systolic': ReferenceRange(minValue: 90, maxValue: 120),
  'diastolic': ReferenceRange(minValue: 60, maxValue: 80),
  'pulse': ReferenceRange(minValue: 60, maxValue: 100),
});

Future<void> _loadRobotoFonts() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null) {
    return;
  }
  final fontDir = '$flutterRoot/bin/cache/artifacts/material_fonts';
  Future<ByteData> font(String name) async {
    final bytes = await File('$fontDir/$name.ttf').readAsBytes();
    return ByteData.view(bytes.buffer, bytes.offsetInBytes, bytes.lengthInBytes);
  }

  for (final name in ['Roboto-Regular', 'Roboto-Bold', 'Roboto-Medium']) {
    final loader = FontLoader('Roboto')..addFont(font(name));
    await loader.load();
  }
}

MeasurementRecord _record({
  required int id,
  required DateTime timestamp,
}) {
  return MeasurementRecord(
    id: id,
    profileId: 1,
    measurementTypeId: 1,
    timestamp: timestamp,
    valuePrimary: 0,
    unit: 'mmHg',
    createdAt: timestamp,
  );
}

MeasurementRecordValue _value({
  required String fieldKey,
  required double numericValue,
  required String unit,
}) {
  return MeasurementRecordValue(
    measurementRecordId: 0,
    fieldKey: fieldKey,
    numericValue: numericValue,
    unit: unit,
  );
}

/// Builds the blood pressure chart series for two readings:
/// reading 1 = 131 / 80 / 58 (above / within / below),
/// reading 2 = 110 / 70 / 70 (within / within / within).
List<MeasurementChartSeries> _bloodPressureSeries() {
  final t1 = DateTime(2026, 7, 1, 9, 0);
  final t2 = DateTime(2026, 7, 2, 9, 0);

  final dp1 = MeasurementDataPoint(
    record: _record(id: 1, timestamp: t1),
    values: [
      _value(fieldKey: 'systolic', numericValue: 131, unit: 'mmHg'),
      _value(fieldKey: 'diastolic', numericValue: 80, unit: 'mmHg'),
      _value(fieldKey: 'pulse', numericValue: 58, unit: 'bpm'),
    ],
  );
  final dp2 = MeasurementDataPoint(
    record: _record(id: 2, timestamp: t2),
    values: [
      _value(fieldKey: 'systolic', numericValue: 110, unit: 'mmHg'),
      _value(fieldKey: 'diastolic', numericValue: 70, unit: 'mmHg'),
      _value(fieldKey: 'pulse', numericValue: 70, unit: 'bpm'),
    ],
  );

  return MeasurementChartBuilder.buildSeries(
    typeKey: 'blood_pressure',
    dataPoints: [dp1, dp2],
    fields: [
      MeasurementTypeField(
        measurementTypeId: 1,
        fieldKey: 'systolic',
        label: 'Systolic',
        createdAt: t1,
        displayOrder: 0,
      ),
      MeasurementTypeField(
        measurementTypeId: 1,
        fieldKey: 'diastolic',
        label: 'Diastolic',
        createdAt: t1,
        displayOrder: 1,
      ),
      MeasurementTypeField(
        measurementTypeId: 1,
        fieldKey: 'pulse',
        label: 'Pulse',
        createdAt: t1,
        displayOrder: 2,
      ),
    ],
    ranges: _ranges,
  );
}

List<MeasurementChartSeries> _singleSeries({
  required String typeKey,
  required String fieldKey,
  required String label,
  required String unit,
  required List<double> values,
}) {
  final t1 = DateTime(2026, 7, 1, 9, 0);
  final dataPoints = [
    for (var i = 0; i < values.length; i++)
      MeasurementDataPoint(
        record: _record(id: i + 1, timestamp: t1.add(Duration(days: i))),
        values: [_value(fieldKey: fieldKey, numericValue: values[i], unit: unit)],
      ),
  ];
  return MeasurementChartBuilder.buildSeries(
    typeKey: typeKey,
    dataPoints: dataPoints,
    fields: [
      MeasurementTypeField(
        measurementTypeId: 1,
        fieldKey: fieldKey,
        label: label,
        createdAt: t1,
      ),
    ],
  );
}

/// Collects the left (Y) axis labels from the rendered chart. Bottom date
/// labels never match the pure-numeric pattern, so this only picks up the
/// numeric tick texts.
List<String> _yAxisLabels(WidgetTester tester) {
  final numeric = RegExp(r'^-?\d+(\.\d+)?$');
  return tester
      .widgetList<Text>(
        find.descendant(of: find.byType(LineChart), matching: find.byType(Text)),
      )
      .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
      .where(numeric.hasMatch)
      .toList();
}

Future<void> _pumpChart(
  WidgetTester tester, {
  required List<MeasurementChartSeries> series,
  String typeKey = 'blood_pressure',
  Locale? locale,
  Size size = const Size(400, 800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: MeasurementLineChart(series: series, typeKey: typeKey),
        ),
      ),
    ),
  );
  await tester.pump();
}

ColorScheme _colorScheme(WidgetTester tester) {
  return Theme.of(tester.element(find.byType(MeasurementLineChart)))
      .colorScheme;
}

Color _dotColor(
  WidgetTester tester, {
  required int seriesIndex,
  required int pointIndex,
}) {
  final chart = tester.widget<LineChart>(find.byType(LineChart));
  final bar = chart.data.lineBarsData[seriesIndex];
  final spot = bar.spots[pointIndex];
  final painter = bar.dotData.getDotPainter(spot, 1.0, bar, pointIndex);
  return (painter as FlDotCirclePainter).color;
}

Offset _spotPixel(
  WidgetTester tester, {
  required List<double> values,
  required int index,
}) {
  final box = tester.getRect(
    find.byWidgetPredicate((w) => w is SizedBox && w.height == _chartHeight),
  );
  final leafW = box.width - _leftPad - _rightPad;
  final leafH = _chartHeight - _topPad - _bottomPad;
  final size = Size(leafW - _leftReserved, leafH - _bottomReserved);

  final chart = tester.widget<LineChart>(find.byType(LineChart));
  final allValues = <double>[
    for (final bar in chart.data.lineBarsData)
      for (final spot in bar.spots) spot.y,
  ];
  var maxPoints = 0;
  for (final bar in chart.data.lineBarsData) {
    if (bar.spots.length > maxPoints) maxPoints = bar.spots.length;
  }
  final axis = computeMeasurementChartAxis(values: allValues);

  final x = maxPoints <= 1 ? 0.0 : index / (maxPoints - 1) * size.width;
  final y = (1 - (values[index] - axis.minY) / (axis.maxY - axis.minY)) *
      size.height;

  final leafFinder = find.byWidgetPredicate(
    (w) => w.runtimeType.toString() == 'LineChartLeaf',
  );
  final renderBox = tester.element(leafFinder).renderObject! as RenderBox;
  return renderBox.localToGlobal(
    Offset(
      x.clamp(2.0, size.width - 2.0),
      y.clamp(2.0, size.height - 2.0),
    ),
  );
}

Finder get _tooltip => find.byKey(MeasurementLineChart.tooltipKey);

Future<TestGesture> _holdPoint(
  WidgetTester tester, {
  required List<double> values,
  required int index,
}) async {
  final point = _spotPixel(tester, values: values, index: index);
  final gesture = await tester.startGesture(point);
  await tester.pump(const Duration(milliseconds: 300));
  return gesture;
}

Future<void> _release(WidgetTester tester, TestGesture gesture) async {
  await gesture.up();
  await tester.pump(const Duration(milliseconds: 100));
}

String _tooltipText(WidgetTester tester) {
  final texts = tester.widgetList<Text>(
    find.descendant(of: _tooltip, matching: find.byType(Text)),
  );
  return texts
      .map((t) => t.textSpan?.toPlainText() ?? t.data ?? '')
      .join(' | ');
}

List<({String text, TextStyle? style})> _tooltipSpans(WidgetTester tester) {
  final texts = tester.widgetList<Text>(
    find.descendant(of: _tooltip, matching: find.byType(Text)),
  );
  final spans = <({String text, TextStyle? style})>[];
  void walk(InlineSpan? span) {
    if (span is TextSpan) {
      spans.add((text: span.text ?? '', style: span.style));
      for (final child in span.children ?? const <InlineSpan>[]) {
        walk(child);
      }
    }
  }

  for (final t in texts) {
    walk(t.textSpan);
  }
  return spans;
}

void main() {
  setUpAll(_loadRobotoFonts);

  const systolicValues = <double>[131, 110];
  const diastolicValues = <double>[80, 70];

  group('per-component point colors', () {
    testWidgets('systolic, diastolic and pulse dots use their own status color',
        (tester) async {
      final series = _bloodPressureSeries();
      expect(series.length, 3);

      await _pumpChart(tester, series: series);

      final colorScheme = _colorScheme(tester);
      final sysColor = _dotColor(tester, seriesIndex: 0, pointIndex: 0);
      final diaColor = _dotColor(tester, seriesIndex: 1, pointIndex: 0);
      final pulseColor = _dotColor(tester, seriesIndex: 2, pointIndex: 0);

      expect(
        sysColor,
        ReadingStatusColor.forStatus(ReadingStatus.aboveRange, colorScheme),
        reason: 'systolic 131 is above range and must be colored as such',
      );
      expect(
        diaColor,
        ReadingStatusColor.forStatus(ReadingStatus.inRange, colorScheme),
        reason: 'diastolic 80 is within range and must not inherit the '
            'overall (above) status',
      );
      expect(
        pulseColor,
        ReadingStatusColor.forStatus(ReadingStatus.belowRange, colorScheme),
        reason: 'pulse 58 is below range and must be colored as such',
      );
      expect(sysColor, isNot(diaColor),
          reason: 'the three points of one reading use different colors');
      expect(diaColor, isNot(pulseColor));
    });

    testWidgets('the overall reading status does not override component colors',
        (tester) async {
      final series = _bloodPressureSeries();
      await _pumpChart(tester, series: series);

      final colorScheme = _colorScheme(tester);
      final overall = series.first.points.first.readingStatus;
      expect(overall, ReadingStatus.aboveRange,
          reason: 'systolic 131 makes the overall reading status above range');

      final diaColor = _dotColor(tester, seriesIndex: 1, pointIndex: 0);
      expect(diaColor, ReadingStatusColor.forStatus(ReadingStatus.inRange, colorScheme),
          reason: 'diastolic is within range even though the overall reading '
              'is above range');
    });

    testWidgets('missing component range renders the neutral unknown color',
        (tester) async {
      final t1 = DateTime(2026, 7, 1, 9, 0);
      final dp = MeasurementDataPoint(
        record: _record(id: 1, timestamp: t1),
        values: [
          _value(fieldKey: 'systolic', numericValue: 131, unit: 'mmHg'),
          _value(fieldKey: 'diastolic', numericValue: 80, unit: 'mmHg'),
          _value(fieldKey: 'pulse', numericValue: 58, unit: 'bpm'),
        ],
      );
      final series = MeasurementChartBuilder.buildSeries(
        typeKey: 'blood_pressure',
        dataPoints: [dp],
        fields: [
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'systolic',
            label: 'Systolic',
            createdAt: t1,
            displayOrder: 0,
          ),
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'diastolic',
            label: 'Diastolic',
            createdAt: t1,
            displayOrder: 1,
          ),
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'pulse',
            label: 'Pulse',
            createdAt: t1,
            displayOrder: 2,
          ),
        ],
        ranges: const MeasurementRanges(fieldRanges: {
          'systolic': ReferenceRange(minValue: 90, maxValue: 120),
          'diastolic': ReferenceRange(minValue: 60, maxValue: 80),
        }),
      );

      expect(series[2].points.first.componentStatus, ReadingStatus.unknown);

      await _pumpChart(tester, series: series, typeKey: 'blood_pressure');

      final colorScheme = _colorScheme(tester);
      final unknownColor = ReadingStatusColor.forStatus(
        ReadingStatus.unknown,
        colorScheme,
      );
      expect(unknownColor, colorScheme.outline);

      final pulseColor = _dotColor(tester, seriesIndex: 2, pointIndex: 0);
      expect(pulseColor, unknownColor,
          reason: 'a component without a configured range must use the '
              'neutral unknown color and not inherit the systolic status');
    });

    testWidgets('single-value series keeps its own status color', (tester) async {
      final t1 = DateTime(2026, 7, 1, 9, 0);
      final dp = MeasurementDataPoint(
        record: _record(id: 1, timestamp: t1),
        values: [
          _value(fieldKey: 'pulse', numericValue: 58, unit: 'bpm'),
        ],
      );
      final series = MeasurementChartBuilder.buildSeries(
        typeKey: 'pulse',
        dataPoints: [dp],
        fields: [
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'pulse',
            label: 'Pulse',
            createdAt: t1,
          ),
        ],
        ranges: const MeasurementRanges(fieldRanges: {
          'pulse': ReferenceRange(minValue: 60, maxValue: 100),
        }),
      );

      await _pumpChart(tester, series: series, typeKey: 'pulse');

      final colorScheme = _colorScheme(tester);
      final color = _dotColor(tester, seriesIndex: 0, pointIndex: 0);
      expect(
        color,
        ReadingStatusColor.forStatus(ReadingStatus.belowRange, colorScheme),
      );
    });
  });

  group('per-component tooltip statuses', () {
    testWidgets('combined tooltip shows each component with its own status',
        (tester) async {
      final series = _bloodPressureSeries();
      await _pumpChart(tester, series: series);

      final gesture = await _holdPoint(
        tester,
        values: systolicValues,
        index: 0,
      );

      expect(tester.takeException(), isNull);
      final text = _tooltipText(tester);
      expect(text, contains('Systolic'));
      expect(text, contains('Above range'),
          reason: 'the systolic value 131 is above range');
      expect(text, contains('Diastolic'));
      expect(text, contains('Within range'),
          reason: 'the diastolic value 80 is within range');
      expect(text, contains('Pulse'));
      expect(text, contains('Below range'),
          reason: 'the pulse value 58 is below range');
      expect(text, isNot(contains('Within range\nWithin range\nWithin range')));

      await _release(tester, gesture);
    });

    testWidgets('diastolic tooltip does not inherit the overall status',
        (tester) async {
      final series = _bloodPressureSeries();
      await _pumpChart(tester, series: series);

      final gesture = await _holdPoint(
        tester,
        values: diastolicValues,
        index: 0,
      );

      final text = _tooltipText(tester);
      expect(text, contains('Diastolic'));
      expect(text, contains('80'));
      expect(text, contains('Within range'),
          reason: 'the overall reading status is above range, but the '
              'diastolic tooltip must show its own within-range status');

      await _release(tester, gesture);
    });

    testWidgets('the reading timestamp appears exactly once for a '
        'multi-component reading', (tester) async {
      final series = _bloodPressureSeries();
      await _pumpChart(tester, series: series);

      final gesture = await _holdPoint(
        tester,
        values: systolicValues,
        index: 0,
      );

      expect(tester.takeException(), isNull);
      final text = _tooltipText(tester);
      expect('01.07.2026 09:00'.allMatches(text).length, 1,
          reason: 'the timestamp belongs to the reading, not to each '
              'component, so it must not be repeated');
      expect(text, contains('Systolic'),
          reason: 'all components of the reading stay visible');
      expect(text, contains('Diastolic'));
      expect(text, contains('Pulse'));

      await _release(tester, gesture);
    });

    testWidgets('multi-component tooltip groups components under a single '
        'date/time header', (tester) async {
      final series = _bloodPressureSeries();
      await _pumpChart(tester, series: series);

      final gesture = await _holdPoint(
        tester,
        values: systolicValues,
        index: 0,
      );

      final text = _tooltipText(tester);
      expect(text, contains('01.07.2026 09:00\n\nSystolic: 131 mmHg'),
          reason: 'the single header is followed by the first component');
      expect(text, contains('Above range\n\nDiastolic: 80 mmHg'),
          reason: 'components are grouped with blank-line spacing');
      expect(text, contains('Within range\n\nPulse: 58 bpm'));

      await _release(tester, gesture);
    });

    testWidgets('tooltip statuses are colored per component', (tester) async {
      final series = _bloodPressureSeries();
      await _pumpChart(tester, series: series);

      final gesture = await _holdPoint(
        tester,
        values: systolicValues,
        index: 0,
      );

      final colorScheme = _colorScheme(tester);
      final spans = _tooltipSpans(tester);
      Color? colorOf(String needle) {
        for (final s in spans) {
          if (s.text.contains(needle)) {
            return s.style?.color;
          }
        }
        return null;
      }

      expect(
        colorOf('Above range'),
        ReadingStatusColor.forStatus(ReadingStatus.aboveRange, colorScheme),
        reason: 'systolic status keeps its own red color',
      );
      expect(
        colorOf('Within range'),
        ReadingStatusColor.forStatus(ReadingStatus.inRange, colorScheme),
        reason: 'diastolic status keeps its own green color',
      );
      expect(
        colorOf('Below range'),
        ReadingStatusColor.forStatus(ReadingStatus.belowRange, colorScheme),
        reason: 'pulse status keeps its own blue color',
      );

      await _release(tester, gesture);
    });

    testWidgets('tooltip emphasizes the header and component names',
        (tester) async {
      final series = _bloodPressureSeries();
      await _pumpChart(tester, series: series);

      final gesture = await _holdPoint(
        tester,
        values: systolicValues,
        index: 0,
      );

      final spans = _tooltipSpans(tester);
      final header = spans.where((s) => s.text == '01.07.2026 09:00');
      expect(header.length, 1);
      expect(header.single.style?.fontWeight, FontWeight.w600,
          reason: 'the single date/time header is emphasized');

      final name = spans.where((s) => s.text == 'Systolic: ');
      expect(name.single.style?.fontWeight, FontWeight.w500,
          reason: 'component names are slightly bolder than the values');

      await _release(tester, gesture);
    });

    testWidgets('tooltip fits on screen for the three-component reading',
        (tester) async {
      final series = _bloodPressureSeries();
      await _pumpChart(tester, series: series);

      final gesture = await _holdPoint(
        tester,
        values: systolicValues,
        index: 0,
      );

      expect(tester.takeException(), isNull);
      final rect = tester.getRect(_tooltip);
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(400));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(800));

      await _release(tester, gesture);
    });

    testWidgets('Georgian locale shows per-component statuses without overflow',
        (tester) async {
      final series = _bloodPressureSeries();
      await _pumpChart(tester, series: series, locale: const Locale('ka'));

      final gesture = await _holdPoint(
        tester,
        values: systolicValues,
        index: 0,
      );

      expect(tester.takeException(), isNull);
      final text = _tooltipText(tester);
      expect(text, contains('ნორმაზე მაღალი'),
          reason: 'systolic 131 is above range');
      expect(text, contains('ნორმის ფარგლებში'),
          reason: 'diastolic 80 is within range');
      expect(text, contains('ნორმაზე დაბალი'),
          reason: 'pulse 58 is below range');

      final rect = tester.getRect(_tooltip);
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(400));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(800));

      await _release(tester, gesture);
    });

    testWidgets('a single-value type tooltip shows its own status',
        (tester) async {
      final t1 = DateTime(2026, 7, 1, 9, 0);
      final dp1 = MeasurementDataPoint(
        record: _record(id: 1, timestamp: t1),
        values: [
          _value(fieldKey: 'pulse', numericValue: 72, unit: 'bpm'),
        ],
      );
      final dp2 = MeasurementDataPoint(
        record: _record(id: 2, timestamp: t1.add(const Duration(days: 1))),
        values: [
          _value(fieldKey: 'pulse', numericValue: 75, unit: 'bpm'),
        ],
      );
      final series = MeasurementChartBuilder.buildSeries(
        typeKey: 'pulse',
        dataPoints: [dp1, dp2],
        fields: [
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'pulse',
            label: 'Pulse',
            createdAt: t1,
          ),
        ],
        ranges: const MeasurementRanges(fieldRanges: {
          'pulse': ReferenceRange(minValue: 60, maxValue: 100),
        }),
      );

      await _pumpChart(tester, series: series, typeKey: 'pulse');

      final gesture = await _holdPoint(
        tester,
        values: const <double>[72, 75],
        index: 0,
      );

      expect(tester.takeException(), isNull);
      final text = _tooltipText(tester);
      expect(text, contains('Pulse'));
      expect(text, contains('Within range'));
      expect(text, '01.07.2026 09:00\nPulse: 72 bpm\nWithin range',
          reason: 'a single-component reading keeps the timestamp directly '
              'above the value with no repeated header or extra spacing');

      await _release(tester, gesture);
    });
  });

  group('Y-axis scale', () {
    testWidgets('blood pressure shows one clean 40..140 tick sequence',
        (tester) async {
      final series = _bloodPressureSeries();
      await _pumpChart(tester, series: series);

      final data = tester.widget<LineChart>(find.byType(LineChart)).data;
      expect(data.minY, 40);
      expect(data.maxY, 140);

      final labels = _yAxisLabels(tester).toSet();
      expect(labels, {'40', '60', '80', '100', '120', '140'},
          reason: 'the y-axis must show the canonical tick sequence only');
      expect(labels, isNot(contains('42.3')));
      expect(labels, isNot(contains('143.7')));
    });

    testWidgets('readings 54 and 132 stay inside the clean bounds',
        (tester) async {
      final series = _singleSeries(
        typeKey: 'blood_pressure',
        fieldKey: 'systolic',
        label: 'Systolic',
        unit: 'mmHg',
        values: const [54, 132],
      );
      await _pumpChart(tester, series: series);

      final data = tester.widget<LineChart>(find.byType(LineChart)).data;
      expect(data.minY, 40,
          reason: 'bounds are aligned outward to the clean tick boundary');
      expect(data.maxY, 140);
      expect(data.minY, lessThanOrEqualTo(54),
          reason: 'the lowest reading must never be clipped');
      expect(data.maxY, greaterThanOrEqualTo(132),
          reason: 'the highest reading must never be clipped');

      final labels = _yAxisLabels(tester).toSet();
      expect(labels, {'40', '60', '80', '100', '120', '140'});
      expect(labels, isNot(contains('42.3')));
      expect(labels, isNot(contains('143.7')));
    });

    testWidgets('a decimal measurement keeps readable numeric ticks',
        (tester) async {
      final series = _singleSeries(
        typeKey: 'weight',
        fieldKey: 'weight',
        label: 'Weight',
        unit: 'kg',
        values: const [71.3, 74.8],
      );
      await _pumpChart(tester, series: series);

      final labels = _yAxisLabels(tester);
      expect(labels.length, inInclusiveRange(4, 7));
      for (final label in labels) {
        expect(double.tryParse(label), isNotNull,
            reason: 'every y-axis label must be a clean number');
        expect(label, isNot(contains('99999')));
      }
    });
  });
}
