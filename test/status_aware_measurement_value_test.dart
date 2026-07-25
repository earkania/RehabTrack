import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/default_reference_ranges.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/utils/reading_status_color.dart';
import 'package:rehab_track/presentation/widgets/measurements/status_aware_measurement_value.dart';

Widget _buildTestWidget({
  required Widget child,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(
        child: child,
      ),
    ),
  );
}

void main() {
  group('StatusAwareMeasurementValue', () {
    testWidgets('value span uses status colour, unit remains normal',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        child: StatusAwareMeasurementValue(
          parts: const [
            MeasurementValuePart(
              value: '72',
              unit: ' bpm',
              status: ReadingStatus.inRange,
            ),
          ],
        ),
      ));

      final richText = tester.widget<RichText>(find.byType(RichText));
      final span = richText.text as TextSpan;
      expect(span.children, hasLength(2));

      final valueSpan = span.children![0] as TextSpan;
      expect(valueSpan.text, '72');
      final unitSpan = span.children![1] as TextSpan;
      expect(unitSpan.text, ' bpm');

      final colorScheme = Theme.of(
        tester.element(find.byType(RichText)),
      ).colorScheme;
      expect(
        valueSpan.style?.color,
        ReadingStatusColor.forStatus(ReadingStatus.inRange, colorScheme),
      );
      expect(unitSpan.style?.color, isNull);
    });

    testWidgets('label remains normal, value uses status colour',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        child: StatusAwareMeasurementValue(
          parts: const [
            MeasurementValuePart(
              label: 'pulse ',
              value: '72',
              unit: ' bpm',
              status: ReadingStatus.belowRange,
            ),
          ],
        ),
      ));

      final richText = tester.widget<RichText>(find.byType(RichText));
      final span = richText.text as TextSpan;
      expect(span.children, hasLength(3));

      final labelSpan = span.children![0] as TextSpan;
      expect(labelSpan.text, 'pulse ');
      expect(labelSpan.style?.color, isNull);

      final valueSpan = span.children![1] as TextSpan;
      expect(valueSpan.text, '72');
      expect(valueSpan.style?.color, isNotNull);

      final unitSpan = span.children![2] as TextSpan;
      expect(unitSpan.text, ' bpm');
      expect(unitSpan.style?.color, isNull);
    });

    testWidgets('multi-part: SpO2 value coloured, pulse value independently coloured',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        child: StatusAwareMeasurementValue(
          parts: const [
            MeasurementValuePart(
              value: '98',
              unit: '%',
              status: ReadingStatus.inRange,
            ),
            MeasurementValuePart(
              label: 'pulse ',
              value: '72',
              unit: ' bpm',
              status: ReadingStatus.belowRange,
            ),
          ],
        ),
      ));

      final richText = tester.widget<RichText>(find.byType(RichText));
      final outerSpan = richText.text as TextSpan;

      // Part1: value=98, unit=%  -> 2 spans
      // Separator: ', '
      // Part2: label=pulse , value=72, unit= bpm -> 3 spans
      // Total: 2 + 1 + 3 = 6
      expect(outerSpan.children, hasLength(6));

      final spo2ValueSpan = outerSpan.children![0] as TextSpan;
      expect(spo2ValueSpan.text, '98');
      final spo2UnitSpan = outerSpan.children![1] as TextSpan;
      expect(spo2UnitSpan.text, '%');

      final separatorSpan = outerSpan.children![2] as TextSpan;
      expect(separatorSpan.text, ', ');

      final pulseLabelSpan = outerSpan.children![3] as TextSpan;
      expect(pulseLabelSpan.text, 'pulse ');
      expect(pulseLabelSpan.style?.color, isNull);

      final pulseValueSpan = outerSpan.children![4] as TextSpan;
      expect(pulseValueSpan.text, '72');
      final pulseUnitSpan = outerSpan.children![5] as TextSpan;
      expect(pulseUnitSpan.text, ' bpm');
      expect(pulseUnitSpan.style?.color, isNull);

      final colorScheme = Theme.of(
        tester.element(find.byType(RichText)),
      ).colorScheme;
      expect(
        spo2ValueSpan.style?.color,
        ReadingStatusColor.forStatus(ReadingStatus.inRange, colorScheme),
      );
      expect(
        pulseValueSpan.style?.color,
        ReadingStatusColor.forStatus(ReadingStatus.belowRange, colorScheme),
      );
    });

    testWidgets('aboveRange value uses error colour', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        child: StatusAwareMeasurementValue(
          parts: const [
            MeasurementValuePart(
              value: '160',
              unit: ' mmHg',
              status: ReadingStatus.aboveRange,
            ),
          ],
        ),
      ));

      final richText = tester.widget<RichText>(find.byType(RichText));
      final span = richText.text as TextSpan;
      final valueSpan = span.children![0] as TextSpan;

      final colorScheme = Theme.of(
        tester.element(find.byType(RichText)),
      ).colorScheme;
      expect(
        valueSpan.style?.color,
        ReadingStatusColor.forStatus(ReadingStatus.aboveRange, colorScheme),
      );
    });

    testWidgets('unknown value uses outline colour', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        child: StatusAwareMeasurementValue(
          parts: const [
            MeasurementValuePart(
              value: '--',
              status: ReadingStatus.unknown,
            ),
          ],
        ),
      ));

      final richText = tester.widget<RichText>(find.byType(RichText));
      final span = richText.text as TextSpan;
      final valueSpan = span.children![0] as TextSpan;

      final colorScheme = Theme.of(
        tester.element(find.byType(RichText)),
      ).colorScheme;
      expect(
        valueSpan.style?.color,
        ReadingStatusColor.forStatus(ReadingStatus.unknown, colorScheme),
      );
    });

    testWidgets('applies custom style to all spans', (tester) async {
      const customStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

      await tester.pumpWidget(_buildTestWidget(
        child: StatusAwareMeasurementValue(
          parts: const [
            MeasurementValuePart(
              label: 'pulse ',
              value: '72',
              unit: ' bpm',
              status: ReadingStatus.inRange,
            ),
          ],
          style: customStyle,
        ),
      ));

      final richText = tester.widget<RichText>(find.byType(RichText));
      final span = richText.text as TextSpan;
      final valueSpan = span.children![1] as TextSpan;
      expect(valueSpan.style?.fontSize, 20);
      expect(valueSpan.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('semantics label is applied', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        child: StatusAwareMeasurementValue(
          parts: const [
            MeasurementValuePart(
              value: '98',
              unit: '%',
              status: ReadingStatus.inRange,
            ),
          ],
          semanticsLabel: 'SpO2 98%, within configured range',
        ),
      ));

      final handle = tester.ensureSemantics();
      final semantics = tester.getSemantics(
        find.byType(StatusAwareMeasurementValue),
      );
      expect(
        semantics.label,
        contains('SpO2 98%, within configured range'),
      );
      handle.dispose();
    });

    testWidgets('plain text output is correct', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        child: StatusAwareMeasurementValue(
          parts: const [
            MeasurementValuePart(
              value: '5.6',
              unit: ' mmol/L',
              status: ReadingStatus.inRange,
            ),
          ],
        ),
      ));

      final richText = tester.widget<RichText>(find.byType(RichText));
      expect(richText.text.toPlainText(), '5.6 mmol/L');
    });

    testWidgets('SpO2 with pulse plain text', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        child: StatusAwareMeasurementValue(
          parts: const [
            MeasurementValuePart(
              value: '98',
              unit: '%',
              status: ReadingStatus.inRange,
            ),
            MeasurementValuePart(
              label: 'pulse ',
              value: '72',
              unit: ' bpm',
              status: ReadingStatus.inRange,
            ),
          ],
        ),
      ));

      final richText = tester.widget<RichText>(find.byType(RichText));
      final flatText = richText.text.toPlainText();
      expect(flatText, contains('98'));
      expect(flatText, contains('%'));
      expect(flatText, contains(', '));
      expect(flatText, contains('pulse '));
      expect(flatText, contains('72'));
      expect(flatText, contains(' bpm'));
    });

    testWidgets('no layout overflow on narrow screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: StatusAwareMeasurementValue(
                parts: const [
                  MeasurementValuePart(
                    value: '36',
                    unit: ' °C',
                    status: ReadingStatus.inRange,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('temperature: value coloured, degree-C unit normal',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        child: StatusAwareMeasurementValue(
          parts: const [
            MeasurementValuePart(
              value: '36',
              unit: ' °C',
              status: ReadingStatus.inRange,
            ),
          ],
        ),
      ));

      final richText = tester.widget<RichText>(find.byType(RichText));
      final span = richText.text as TextSpan;
      final valueSpan = span.children![0] as TextSpan;
      final unitSpan = span.children![1] as TextSpan;

      expect(valueSpan.text, '36');
      expect(unitSpan.text, ' °C');
      expect(unitSpan.style?.color, isNull);

      final colorScheme = Theme.of(
        tester.element(find.byType(RichText)),
      ).colorScheme;
      expect(
        valueSpan.style?.color,
        ReadingStatusColor.forStatus(ReadingStatus.inRange, colorScheme),
      );
    });

    testWidgets('weight: value coloured, kg normal', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        child: StatusAwareMeasurementValue(
          parts: const [
            MeasurementValuePart(
              value: '82.5',
              unit: ' kg',
              status: ReadingStatus.inRange,
            ),
          ],
        ),
      ));

      final richText = tester.widget<RichText>(find.byType(RichText));
      final span = richText.text as TextSpan;
      final valueSpan = span.children![0] as TextSpan;
      final unitSpan = span.children![1] as TextSpan;

      expect(valueSpan.text, '82.5');
      expect(unitSpan.text, ' kg');
      expect(unitSpan.style?.color, isNull);
    });

    testWidgets('blood glucose: value coloured, mmol/L normal',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        child: StatusAwareMeasurementValue(
          parts: const [
            MeasurementValuePart(
              value: '5.6',
              unit: ' mmol/L',
              status: ReadingStatus.inRange,
            ),
          ],
        ),
      ));

      final richText = tester.widget<RichText>(find.byType(RichText));
      final span = richText.text as TextSpan;
      final valueSpan = span.children![0] as TextSpan;
      final unitSpan = span.children![1] as TextSpan;

      expect(valueSpan.text, '5.6');
      expect(unitSpan.text, ' mmol/L');
      expect(unitSpan.style?.color, isNull);
    });

    testWidgets('standalone pulse: value coloured, bpm normal',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        child: StatusAwareMeasurementValue(
          parts: const [
            MeasurementValuePart(
              value: '65',
              unit: ' bpm',
              status: ReadingStatus.inRange,
            ),
          ],
        ),
      ));

      final richText = tester.widget<RichText>(find.byType(RichText));
      final span = richText.text as TextSpan;
      final valueSpan = span.children![0] as TextSpan;
      final unitSpan = span.children![1] as TextSpan;

      expect(valueSpan.text, '65');
      expect(unitSpan.text, ' bpm');
      expect(unitSpan.style?.color, isNull);
    });
  });

  group('DefaultReferenceRanges', () {
    test('spo2 includes pulse range', () {
      final ranges = DefaultReferenceRanges.rangesForType('spo2');
      expect(ranges, isNotNull);

      final pulseRange = ranges!.rangeForField('pulse');
      expect(pulseRange, isNotNull);
      expect(pulseRange!.minValue, 60);
      expect(pulseRange.maxValue, 100);
    });

    test('spo2 spo2 range unchanged', () {
      final ranges = DefaultReferenceRanges.rangesForType('spo2');
      final spo2Range = ranges!.rangeForField('spo2');
      expect(spo2Range!.minValue, 95);
      expect(spo2Range.maxValue, 100);
    });

    test('spo2 has two field ranges', () {
      final ranges = DefaultReferenceRanges.rangesForType('spo2');
      expect(ranges!.fieldRanges.length, 2);
      expect(ranges.fieldRanges.containsKey('spo2'), isTrue);
      expect(ranges.fieldRanges.containsKey('pulse'), isTrue);
    });

    test('blood_pressure includes pulse range', () {
      final ranges = DefaultReferenceRanges.rangesForType('blood_pressure');
      final pulseRange = ranges!.rangeForField('pulse');
      expect(pulseRange, isNotNull);
      expect(pulseRange!.minValue, 60);
      expect(pulseRange.maxValue, 100);
    });

    test('standalone pulse range unchanged', () {
      final ranges = DefaultReferenceRanges.rangesForType('pulse');
      final pulseRange = ranges!.rangeForField('pulse');
      expect(pulseRange!.minValue, 60);
      expect(pulseRange.maxValue, 100);
    });
  });
}
