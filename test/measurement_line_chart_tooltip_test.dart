import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/domain/entities/measurement_chart.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/utils/measurement_chart_axis.dart';
import 'package:rehab_track/presentation/widgets/charts/measurement_line_chart.dart';

const _leftPad = 8.0;
const _rightPad = 16.0;
const _topPad = 16.0;
const _bottomPad = 8.0;
const _chartHeight = 250.0;
const _leftReserved = 40.0;
const _bottomReserved = 30.0;

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

MeasurementChartSeries _series(
  String label,
  List<double> values, {
  String unit = 'mmHg',
  String fieldKey = 'systolic',
  ReadingStatus status = ReadingStatus.inRange,
}) {
  final now = DateTime(2026, 7, 1, 9, 0);
  return MeasurementChartSeries(
    fieldKey: fieldKey,
    label: label,
    unit: unit,
    points: List.generate(
      values.length,
      (i) => MeasurementChartPoint(
        recordId: i + 1,
        measuredAt: now.add(Duration(days: i)),
        numericValue: values[i],
        unit: unit,
        readingStatus: status,
      ),
    ),
  );
}

Future<void> _pumpChart(
  WidgetTester tester, {
  required List<MeasurementChartSeries> series,
  String typeKey = '',
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

Rect _chartBox(WidgetTester tester) {
  return tester.getRect(
    find.byWidgetPredicate((w) => w is SizedBox && w.height == _chartHeight),
  );
}

Size _canvasSize(WidgetTester tester) {
  final box = _chartBox(tester);
  final leafW = box.width - _leftPad - _rightPad;
  final leafH = _chartHeight - _topPad - _bottomPad;
  return Size(leafW - _leftReserved, leafH - _bottomReserved);
}

Offset _spotPixel(
  WidgetTester tester, {
  required List<double> values,
  required int index,
}) {
  final size = _canvasSize(tester);

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

/// Expects [needles] to appear in [haystack] in exactly the given order.
void _expectRowOrder(String haystack, List<String> needles) {
  var last = -1;
  var previous = 'tooltip start';
  for (final needle in needles) {
    final index = haystack.indexOf(needle);
    expect(index, greaterThan(last),
        reason: '"$needle" must appear after "$previous" '
            'but was found at $index (text: $haystack)');
    last = index;
    previous = needle;
  }
}

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

void main() {
  const singleSeriesValues = <double>[140, 130, 125, 120, 118, 116, 112, 108];

  setUpAll(_loadRobotoFonts);

  group('MeasurementLineChart overlay tooltip', () {
    testWidgets('config restores above-chart placement and disables the '
        'built-in card', (tester) async {
      await _pumpChart(
        tester,
        series: [_series('Systolic', singleSeriesValues)],
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final tooltip = lineChart.data.lineTouchData.touchTooltipData;

      expect(tooltip.fitInsideHorizontally, isFalse,
          reason: 'tooltip must keep the original above-chart placement');
      expect(tooltip.fitInsideVertically, isFalse,
          reason: 'tooltip must not be forced back inside the chart');
      expect(tooltip.tooltipMargin, 8);
      expect(
        tooltip.tooltipPadding,
        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      );

      final spots = [
        LineBarSpot(
          lineChart.data.lineBarsData.first,
          0,
          const FlSpot(0, 120),
        ),
      ];
      expect(tooltip.getTooltipItems(spots), everyElement(isNull),
          reason: 'the built-in fl_chart card is disabled; the overlay '
              'renders the tooltip');
    });

    testWidgets('pressing a point shows a single overlay tooltip above the '
        'point and not under the tap', (tester) async {
      await _pumpChart(
        tester,
        series: [_series('Systolic', singleSeriesValues)],
      );

      final tap = _spotPixel(
        tester,
        values: singleSeriesValues,
        index: singleSeriesValues.length - 1,
      );
      final gesture = await tester.startGesture(tap);
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull,
          reason: 'showing the overlay tooltip must not throw or overflow');
      expect(_tooltip, findsOneWidget,
          reason: 'exactly one overlay tooltip must be shown');
      expect(
        find.descendant(of: find.byType(Overlay), matching: _tooltip),
        findsOneWidget,
      );

      final tooltipRect = tester.getRect(_tooltip);
      expect(tooltipRect.bottom, lessThan(tap.dy),
          reason: 'tooltip must appear above the selected point');
      expect(tooltipRect.contains(tap), isFalse,
          reason: 'tooltip must not sit under the tap point');

      await _release(tester, gesture);
      expect(_tooltip, findsNothing,
          reason: 'releasing the finger must dismiss the tooltip');
    });

    testWidgets('tooltip is painted in the app Overlay so the filter strip '
        'cannot cover it', (tester) async {
      await _pumpChart(
        tester,
        series: [_series('Systolic', singleSeriesValues)],
      );

      final gesture = await _holdPoint(
        tester,
        values: singleSeriesValues,
        index: 3,
      );
      expect(
        find.ancestor(of: _tooltip, matching: find.byType(Overlay)),
        findsOneWidget,
        reason: 'the tooltip must be hosted in the Overlay, above every '
            'scrollable sliver such as the date filter strip',
      );

      await _release(tester, gesture);
    });

    testWidgets('tooltip for the first point stays within horizontal bounds',
        (tester) async {
      await _pumpChart(
        tester,
        series: [_series('Systolic', singleSeriesValues)],
      );

      final gesture = await _holdPoint(
        tester,
        values: singleSeriesValues,
        index: 0,
      );
      final rect = tester.getRect(_tooltip);
      expect(rect.left, greaterThanOrEqualTo(0),
          reason: 'first point tooltip must not clip the left edge');
      expect(rect.right, lessThanOrEqualTo(400));

      await _release(tester, gesture);
    });

    testWidgets('tooltip for the last point stays within horizontal bounds',
        (tester) async {
      await _pumpChart(
        tester,
        series: [_series('Systolic', singleSeriesValues)],
      );

      final gesture = await _holdPoint(
        tester,
        values: singleSeriesValues,
        index: singleSeriesValues.length - 1,
      );
      final rect = tester.getRect(_tooltip);
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(400),
          reason: 'last point tooltip must not clip the right edge');

      await _release(tester, gesture);
    });

    testWidgets('a top-most point flips the tooltip below to stay on screen',
        (tester) async {
      const values = <double>[200, 150, 130, 120, 110, 100, 90];
      await _pumpChart(tester, series: [_series('Systolic', values)]);

      final gesture = await _holdPoint(tester, values: values, index: 0);
      final rect = tester.getRect(_tooltip);
      expect(rect.top, greaterThanOrEqualTo(0),
          reason: 'near the top edge the tooltip must flip below instead of '
              'leaving the screen');
      expect(rect.bottom, lessThanOrEqualTo(800));

      await _release(tester, gesture);
    });

    testWidgets('dragging to another point replaces the tooltip content',
        (tester) async {
      await _pumpChart(
        tester,
        series: [_series('Systolic', singleSeriesValues)],
      );

      final gesture = await tester.startGesture(
        _spotPixel(tester, values: singleSeriesValues, index: 0),
      );
      await gesture.moveTo(
        _spotPixel(tester, values: singleSeriesValues, index: 5),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(_tooltipText(tester), contains('116'),
          reason: 'the tooltip must follow the finger to the new point');
      expect(_tooltipText(tester), isNot(contains('140')),
          reason: 'the tooltip content must be replaced, not duplicated');

      await _release(tester, gesture);
      expect(_tooltip, findsNothing);
    });

    testWidgets('multi-series tooltip lists every series and stays on screen',
        (tester) async {
      final series = [
        _series('Systolic', singleSeriesValues),
        _series('Diastolic', [90, 88, 85, 82, 80, 78, 76, 74]),
        _series('Pulse', [70, 69, 68, 67, 66, 65, 64, 63],
            unit: 'bpm', fieldKey: 'pulse'),
      ];
      await _pumpChart(tester, series: series);

      final gesture = await _holdPoint(
        tester,
        values: singleSeriesValues,
        index: 3,
      );
      expect(tester.takeException(), isNull);
      expect(_tooltipText(tester), contains('Systolic'));
      expect(_tooltipText(tester), contains('Diastolic'));
      expect(_tooltipText(tester), contains('Pulse'));
      expect('04.07.2026 09:00'.allMatches(_tooltipText(tester)).length, 1,
          reason: 'the shared reading timestamp is shown once, not once per '
              'series');

      final rect = tester.getRect(_tooltip);
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(400));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(800));

      await _release(tester, gesture);
    });

    testWidgets(
        'blood pressure tooltip rows always follow the canonical component '
        'order: Systolic, Diastolic, Pulse (120/80/60)', (tester) async {
      const systolic = <double>[120, 122];
      const diastolic = <double>[80, 82];
      const pulse = <double>[60, 62];
      await _pumpChart(tester, series: [
        _series('Systolic', systolic),
        _series('Diastolic', diastolic),
        _series('Pulse', pulse, unit: 'bpm', fieldKey: 'pulse'),
      ]);

      final gesture = await _holdPoint(tester, values: systolic, index: 0);

      final text = _tooltipText(tester);
      _expectRowOrder(text, ['Systolic', 'Diastolic', 'Pulse']);
      // Values and units stay attached to their own component row.
      expect(text, contains('120 mmHg'));
      expect(text, contains('80 mmHg'));
      expect(text, contains('60 bpm'));

      await _release(tester, gesture);
    });

    testWidgets(
        'blood pressure tooltip keeps canonical order when pulse exceeds '
        'diastolic (120/68/70)', (tester) async {
      const systolic = <double>[120, 121];
      const diastolic = <double>[68, 66];
      const pulse = <double>[70, 72];
      await _pumpChart(tester, series: [
        _series('Systolic', systolic,
            status: ReadingStatus.aboveRange),
        _series('Diastolic', diastolic),
        _series('Pulse', pulse, unit: 'bpm', fieldKey: 'pulse',
            status: ReadingStatus.belowRange),
      ]);

      final gesture = await _holdPoint(tester, values: systolic, index: 0);

      final text = _tooltipText(tester);
      // Y-descending order would render Pulse between Systolic and Diastolic.
      _expectRowOrder(text, ['Systolic', 'Diastolic', 'Pulse']);

      // Each status stays attached to its own component block.
      final systolicBlock =
          text.substring(text.indexOf('Systolic'), text.indexOf('Diastolic'));
      final diastolicBlock =
          text.substring(text.indexOf('Diastolic'), text.indexOf('Pulse'));
      final pulseBlock = text.substring(text.indexOf('Pulse'));
      expect(systolicBlock, contains('Above range'));
      expect(systolicBlock, isNot(contains('Within range')));
      expect(diastolicBlock, contains('Within range'));
      expect(diastolicBlock, contains('68 mmHg'));
      expect(pulseBlock, contains('Below range'));
      expect(pulseBlock, contains('70 bpm'));

      await _release(tester, gesture);
    });

    testWidgets(
        'blood pressure tooltip keeps canonical order when pulse is the '
        'highest value (100/90/120)', (tester) async {
      const systolic = <double>[100, 102];
      const diastolic = <double>[90, 91];
      const pulse = <double>[120, 118];
      await _pumpChart(tester, series: [
        _series('Systolic', systolic),
        _series('Diastolic', diastolic),
        _series('Pulse', pulse, unit: 'bpm', fieldKey: 'pulse'),
      ]);

      final gesture = await _holdPoint(tester, values: systolic, index: 0);

      _expectRowOrder(_tooltipText(tester),
          ['Systolic', 'Diastolic', 'Pulse']);

      await _release(tester, gesture);
    });

    testWidgets(
        'blood pressure tooltip keeps canonical order when values are '
        'value-descending already (160/100/50)', (tester) async {
      const systolic = <double>[160, 158];
      const diastolic = <double>[100, 99];
      const pulse = <double>[50, 52];
      await _pumpChart(tester, series: [
        _series('Systolic', systolic),
        _series('Diastolic', diastolic),
        _series('Pulse', pulse, unit: 'bpm', fieldKey: 'pulse'),
      ]);

      final gesture = await _holdPoint(tester, values: systolic, index: 0);

      _expectRowOrder(_tooltipText(tester),
          ['Systolic', 'Diastolic', 'Pulse']);

      await _release(tester, gesture);
    });

    testWidgets(
        'blood pressure tooltip canonical order holds in Georgian '
        '(120/68/70)', (tester) async {
      const systolic = <double>[120, 121];
      const diastolic = <double>[68, 66];
      const pulse = <double>[70, 72];
      await _pumpChart(
        tester,
        series: [
          _series('სისტოლური', systolic, status: ReadingStatus.aboveRange),
          _series('დიასტოლური', diastolic),
          _series('პულსი', pulse,
              unit: 'bpm',
              fieldKey: 'pulse',
              status: ReadingStatus.belowRange),
        ],
        locale: const Locale('ka'),
      );

      final gesture = await _holdPoint(tester, values: systolic, index: 0);

      final text = _tooltipText(tester);
      _expectRowOrder(text, ['სისტოლური', 'დიასტოლური', 'პულსი']);
      expect(text, contains('ნორმაზე მაღალი'));
      expect(text, contains('ნორმის ფარგლებში'));
      expect(text, contains('ნორმაზე დაბალი'));

      final systolicBlock = text.substring(
          text.indexOf('სისტოლური'), text.indexOf('დიასტოლური'));
      final pulseBlock = text.substring(text.indexOf('პულსი'));
      expect(systolicBlock, contains('ნორმაზე მაღალი'));
      expect(pulseBlock, contains('ნორმაზე დაბალი'));

      await _release(tester, gesture);
    });

    testWidgets('a data change (period switch) dismisses the tooltip',
        (tester) async {
      const firstValues = <double>[120, 130, 125];
      await _pumpChart(
        tester,
        series: [_series('Systolic', firstValues)],
      );

      final gesture = await _holdPoint(
        tester,
        values: firstValues,
        index: 1,
      );
      expect(_tooltip, findsOneWidget);

      await _pumpChart(
        tester,
        series: [_series('Systolic', const [130, 135, 140])],
      );
      expect(_tooltip, findsNothing,
          reason: 'a new period (new chart data) must dismiss the tooltip');

      await _release(tester, gesture);
    });

    testWidgets('navigating away removes the overlay without exceptions',
        (tester) async {
      await _pumpChart(
        tester,
        series: [_series('Systolic', singleSeriesValues)],
      );

      final gesture = await _holdPoint(
        tester,
        values: singleSeriesValues,
        index: 3,
      );
      expect(_tooltip, findsOneWidget);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
      expect(tester.takeException(), isNull,
          reason: 'disposing the chart must remove the overlay cleanly');
      expect(_tooltip, findsNothing);

      await _release(tester, gesture);
    });

    testWidgets('Georgian locale renders the tooltip without overflow',
        (tester) async {
      await _pumpChart(
        tester,
        series: [
          _series('სისტოლური წნევა', singleSeriesValues,
              status: ReadingStatus.unknown),
        ],
        locale: const Locale('ka'),
      );

      final gesture = await _holdPoint(
        tester,
        values: singleSeriesValues,
        index: 3,
      );
      expect(tester.takeException(), isNull);
      expect(_tooltipText(tester), contains('სისტოლური წნევა'));

      final rect = tester.getRect(_tooltip);
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(400));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(800));

      await _release(tester, gesture);
    });

    testWidgets('narrow portrait keeps the tooltip within horizontal bounds',
        (tester) async {
      await _pumpChart(
        tester,
        series: [_series('Systolic', singleSeriesValues)],
        size: const Size(320, 700),
      );

      final gesture = await _holdPoint(
        tester,
        values: singleSeriesValues,
        index: singleSeriesValues.length - 1,
      );
      expect(tester.takeException(), isNull);
      final rect = tester.getRect(_tooltip);
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(320),
          reason: 'narrow portrait must still clamp the tooltip on screen');

      await _release(tester, gesture);
    });
  });
}
