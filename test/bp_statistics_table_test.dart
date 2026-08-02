import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/default_reference_ranges.dart';
import 'package:rehab_track/domain/entities/measurement_chart.dart';
import 'package:rehab_track/domain/entities/measurement_statistics.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/l10n/app_localizations_en.dart';
import 'package:rehab_track/l10n/app_localizations_ka.dart';
import 'package:rehab_track/presentation/utils/reading_status_color.dart';
import 'package:rehab_track/presentation/widgets/measurements/measurement_statistics_comparison_table.dart';
import 'package:rehab_track/presentation/widgets/measurements/measurement_statistics_card.dart';

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

Color _expectedColor(ReadingStatus status, ColorScheme colorScheme) =>
    ReadingStatusColor.forStatus(status, colorScheme);

Color _cellColor(WidgetTester tester, String text, {int index = 0}) {
  final widgets = tester.widgetList<Text>(find.text(text)).toList();
  return widgets[index].style!.color!;
}

void main() {
  group('MeasurementStatisticsComparisonTable', () {
    testWidgets('shows Systolic, Diastolic, and Pulse as column headers',
        (tester) async {
      final stats = {
        'systolic': const MeasurementStatistics(
          count: 5,
          latest: 125,
          minimum: 118,
          maximum: 145,
          average: 128,
        ),
        'diastolic': const MeasurementStatistics(
          count: 5,
          latest: 80,
          minimum: 75,
          maximum: 94,
          average: 82,
        ),
        'pulse': const MeasurementStatistics(
          count: 5,
          latest: 65,
          minimum: 60,
          maximum: 78,
          average: 67,
        ),
      };

      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsComparisonTable.fromBloodPressure(
          fieldStatistics: stats,
          l10n: AppLocalizationsEn(),
        ),
      ));

      expect(find.text('Systolic'), findsOneWidget);
      expect(find.text('Diastolic'), findsOneWidget);
      expect(find.text('Pulse'), findsOneWidget);
    });

    testWidgets('shows Latest, Average, Minimum, Maximum as row labels',
        (tester) async {
      final stats = {
        'systolic': const MeasurementStatistics(
          count: 5,
          latest: 125,
          minimum: 118,
          maximum: 145,
          average: 128,
        ),
        'diastolic': const MeasurementStatistics(
          count: 5,
          latest: 80,
          minimum: 75,
          maximum: 94,
          average: 82,
        ),
      };

      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsComparisonTable.fromBloodPressure(
          fieldStatistics: stats,
          l10n: AppLocalizationsEn(),
        ),
      ));

      expect(find.text('Latest'), findsOneWidget);
      expect(find.text('Average'), findsOneWidget);
      expect(find.text('Minimum'), findsOneWidget);
      expect(find.text('Maximum'), findsOneWidget);
    });

    testWidgets('displays values in correct cells', (tester) async {
      final stats = {
        'systolic': const MeasurementStatistics(
          count: 5,
          latest: 125,
          minimum: 118,
          maximum: 145,
          average: 128,
        ),
        'diastolic': const MeasurementStatistics(
          count: 5,
          latest: 80,
          minimum: 75,
          maximum: 94,
          average: 82,
        ),
      };

      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsComparisonTable.fromBloodPressure(
          fieldStatistics: stats,
          l10n: AppLocalizationsEn(),
        ),
      ));

      expect(find.text('125'), findsOneWidget);
      expect(find.text('128'), findsOneWidget);
      expect(find.text('118'), findsOneWidget);
      expect(find.text('145'), findsOneWidget);
      expect(find.text('80'), findsOneWidget);
      expect(find.text('82'), findsOneWidget);
      expect(find.text('75'), findsOneWidget);
      expect(find.text('94'), findsOneWidget);
    });

    testWidgets('units appear in column headers', (tester) async {
      final stats = {
        'systolic': const MeasurementStatistics(
          count: 1,
          latest: 120,
          minimum: 120,
          maximum: 120,
          average: 120,
        ),
        'diastolic': const MeasurementStatistics(
          count: 1,
          latest: 80,
          minimum: 80,
          maximum: 80,
          average: 80,
        ),
        'pulse': const MeasurementStatistics(
          count: 1,
          latest: 70,
          minimum: 70,
          maximum: 70,
          average: 70,
        ),
      };

      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsComparisonTable.fromBloodPressure(
          fieldStatistics: stats,
          l10n: AppLocalizationsEn(),
        ),
      ));

      expect(find.text('mmHg'), findsNWidgets(2));
      expect(find.text('bpm'), findsOneWidget);
    });

    testWidgets('missing pulse displays em dash', (tester) async {
      final stats = {
        'systolic': const MeasurementStatistics(
          count: 5,
          latest: 125,
          minimum: 118,
          maximum: 145,
          average: 128,
        ),
        'diastolic': const MeasurementStatistics(
          count: 5,
          latest: 80,
          minimum: 75,
          maximum: 94,
          average: 82,
        ),
      };

      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsComparisonTable.fromBloodPressure(
          fieldStatistics: stats,
          l10n: AppLocalizationsEn(),
        ),
      ));

      expect(find.text('Pulse'), findsOneWidget);
      expect(find.text('\u2014'), findsNWidgets(4));
    });

    testWidgets('zero is not shown for missing pulse values', (tester) async {
      final stats = {
        'systolic': const MeasurementStatistics(
          count: 5,
          latest: 125,
          minimum: 118,
          maximum: 145,
          average: 128,
        ),
        'diastolic': const MeasurementStatistics(
          count: 5,
          latest: 80,
          minimum: 75,
          maximum: 94,
          average: 82,
        ),
      };

      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsComparisonTable.fromBloodPressure(
          fieldStatistics: stats,
          l10n: AppLocalizationsEn(),
        ),
      ));

      final zeroFinder = find.text('0');
      expect(zeroFinder, findsNothing);
    });

    testWidgets('Georgian labels render correctly', (tester) async {
      final stats = {
        'systolic': const MeasurementStatistics(
          count: 5,
          latest: 125,
          minimum: 118,
          maximum: 145,
          average: 128,
        ),
        'diastolic': const MeasurementStatistics(
          count: 5,
          latest: 80,
          minimum: 75,
          maximum: 94,
          average: 82,
        ),
        'pulse': const MeasurementStatistics(
          count: 5,
          latest: 65,
          minimum: 60,
          maximum: 78,
          average: 67,
        ),
      };

      await tester.pumpWidget(_buildTestWidget(
        locale: const Locale('ka'),
        child: MeasurementStatisticsComparisonTable.fromBloodPressure(
          fieldStatistics: stats,
          l10n: AppLocalizationsKa(),
        ),
      ));

      expect(find.text('სისტ.'), findsOneWidget);
      expect(find.text('დიასტ.'), findsOneWidget);
      expect(find.text('პულსი'), findsOneWidget);
      expect(find.text('უახლესი'), findsOneWidget);
      expect(find.text('საშუალო'), findsOneWidget);
      expect(find.text('მინიმუმი'), findsOneWidget);
      expect(find.text('მაქსიმუმი'), findsOneWidget);
    });

    testWidgets('narrow-screen layout does not overflow', (tester) async {
      final stats = {
        'systolic': const MeasurementStatistics(
          count: 5,
          latest: 125,
          minimum: 118,
          maximum: 145,
          average: 128,
        ),
        'diastolic': const MeasurementStatistics(
          count: 5,
          latest: 80,
          minimum: 75,
          maximum: 94,
          average: 82,
        ),
        'pulse': const MeasurementStatistics(
          count: 5,
          latest: 65,
          minimum: 60,
          maximum: 78,
          average: 67,
        ),
      };

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(size: Size(320, 600)),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: MeasurementStatisticsComparisonTable.fromBloodPressure(
                  fieldStatistics: stats,
                  l10n: AppLocalizationsEn(),
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('accessibility semantics include row and column context',
        (tester) async {
      final stats = {
        'systolic': const MeasurementStatistics(
          count: 5,
          latest: 125,
          minimum: 118,
          maximum: 145,
          average: 128,
        ),
        'diastolic': const MeasurementStatistics(
          count: 5,
          latest: 80,
          minimum: 75,
          maximum: 94,
          average: 82,
        ),
      };

      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsComparisonTable.fromBloodPressure(
          fieldStatistics: stats,
          l10n: AppLocalizationsEn(),
        ),
      ));

      final SemanticsHandle handle = tester.ensureSemantics();

      final latestSystolic = tester.getSemantics(find.text('125'));
      expect(latestSystolic.label, contains('Latest Systolic: 125'));

      final avgDiastolic = tester.getSemantics(find.text('82'));
      expect(avgDiastolic.label, contains('Average Diastolic: 82'));

      handle.dispose();
    });
  });

  group('MeasurementStatisticsCard - blood pressure', () {
    testWidgets('renders comparison table for blood pressure type',
        (tester) async {
      final stats = {
        'systolic': const MeasurementStatistics(
          count: 5,
          latest: 125,
          minimum: 118,
          maximum: 145,
          average: 128,
        ),
        'diastolic': const MeasurementStatistics(
          count: 5,
          latest: 80,
          minimum: 75,
          maximum: 94,
          average: 82,
        ),
      };

      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsCard(
          fieldStatistics: stats,
          series: const [],
          typeKey: 'blood_pressure',
        ),
      ));

      expect(find.text('Systolic'), findsOneWidget);
      expect(find.text('Diastolic'), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);
    });

    testWidgets('single-value type still uses row layout', (tester) async {
      final stats = {
        'weight': const MeasurementStatistics(
          count: 3,
          latest: 75,
          minimum: 74,
          maximum: 76,
          average: 75,
        ),
      };

      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsCard(
          fieldStatistics: stats,
          series: const [],
          typeKey: 'weight',
        ),
      ));

      expect(find.text('Latest'), findsOneWidget);
      expect(find.text('Average'), findsOneWidget);
      expect(find.text('Minimum'), findsOneWidget);
      expect(find.text('Maximum'), findsOneWidget);
      expect(find.text('Readings'), findsOneWidget);
    });

    testWidgets('empty statistics returns empty widget', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        child: const MeasurementStatisticsCard(
          fieldStatistics: {},
          series: [],
          typeKey: 'blood_pressure',
        ),
      ));

      expect(find.byType(SizedBox), findsOneWidget);
    });
  });

  group('MeasurementStatisticsComparisonTable - status colors', () {
    final bpRanges = DefaultReferenceRanges.rangesForType('blood_pressure');

    Map<String, MeasurementStatistics> mixedStats() => {
          'systolic': const MeasurementStatistics(
            count: 3,
            latest: 131,
            minimum: 125,
            maximum: 131,
            average: 128,
          ),
          'diastolic': const MeasurementStatistics(
            count: 3,
            latest: 80,
            minimum: 75,
            maximum: 82,
            average: 79,
          ),
          'pulse': const MeasurementStatistics(
            count: 3,
            latest: 58,
            minimum: 58,
            maximum: 72,
            average: 65,
          ),
        };

    testWidgets('Latest row mixes per-component status colors',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsComparisonTable.fromBloodPressure(
          fieldStatistics: mixedStats(),
          l10n: AppLocalizationsEn(),
          ranges: bpRanges,
        ),
      ));

      final colorScheme = Theme.of(
        tester.element(find.byType(MeasurementStatisticsComparisonTable)),
      ).colorScheme;

      expect(
        _cellColor(tester, '131'),
        _expectedColor(ReadingStatus.aboveRange, colorScheme),
      );
      expect(
        _cellColor(tester, '80'),
        _expectedColor(ReadingStatus.inRange, colorScheme),
      );
      expect(
        _cellColor(tester, '58'),
        _expectedColor(ReadingStatus.belowRange, colorScheme),
      );
    });

    testWidgets('Average, Minimum, Maximum classify independently',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsComparisonTable.fromBloodPressure(
          fieldStatistics: mixedStats(),
          l10n: AppLocalizationsEn(),
          ranges: bpRanges,
        ),
      ));

      final colorScheme = Theme.of(
        tester.element(find.byType(MeasurementStatisticsComparisonTable)),
      ).colorScheme;
      final above = _expectedColor(ReadingStatus.aboveRange, colorScheme);
      final within = _expectedColor(ReadingStatus.inRange, colorScheme);

      expect(_cellColor(tester, '128'), above);
      expect(_cellColor(tester, '79'), within);
      expect(_cellColor(tester, '65'), within);

      expect(_cellColor(tester, '125'), above);
      expect(_cellColor(tester, '75'), within);

      expect(_cellColor(tester, '82'), above);
      expect(_cellColor(tester, '72'), within);
    });

    testWidgets('overall status does not override cell colors',
        (tester) async {
      final stats = {
        'systolic': const MeasurementStatistics(
          count: 1,
          latest: 131,
          minimum: 131,
          maximum: 131,
          average: 131,
        ),
        'diastolic': const MeasurementStatistics(
          count: 1,
          latest: 75,
          minimum: 75,
          maximum: 75,
          average: 75,
        ),
      };

      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsComparisonTable.fromBloodPressure(
          fieldStatistics: stats,
          l10n: AppLocalizationsEn(),
          ranges: bpRanges,
        ),
      ));

      final colorScheme = Theme.of(
        tester.element(find.byType(MeasurementStatisticsComparisonTable)),
      ).colorScheme;

      expect(
        _cellColor(tester, '131'),
        _expectedColor(ReadingStatus.aboveRange, colorScheme),
      );
      expect(
        _cellColor(tester, '75'),
        _expectedColor(ReadingStatus.inRange, colorScheme),
      );
    });

    testWidgets('missing reference ranges render neutral outline',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsComparisonTable.fromBloodPressure(
          fieldStatistics: mixedStats(),
          l10n: AppLocalizationsEn(),
          ranges: const MeasurementRanges(fieldRanges: {}),
        ),
      ));

      final colorScheme = Theme.of(
        tester.element(find.byType(MeasurementStatisticsComparisonTable)),
      ).colorScheme;

      expect(
        _cellColor(tester, '131'),
        _expectedColor(ReadingStatus.unknown, colorScheme),
      );
      expect(
        _cellColor(tester, '80'),
        _expectedColor(ReadingStatus.unknown, colorScheme),
      );
    });

    testWidgets('dark theme uses color scheme colors', (tester) async {
      final theme = ThemeData(brightness: Brightness.dark);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: MeasurementStatisticsComparisonTable.fromBloodPressure(
                fieldStatistics: mixedStats(),
                l10n: AppLocalizationsEn(),
                ranges: bpRanges,
              ),
            ),
          ),
        ),
      );

      final colorScheme = Theme.of(
        tester.element(find.byType(MeasurementStatisticsComparisonTable)),
      ).colorScheme;
      expect(theme.brightness, Brightness.dark);

      expect(
        _cellColor(tester, '131'),
        _expectedColor(ReadingStatus.aboveRange, colorScheme),
      );
      expect(
        _cellColor(tester, '80'),
        _expectedColor(ReadingStatus.inRange, colorScheme),
      );
    });

    testWidgets('em dash cells keep default colour', (tester) async {
      final stats = {
        'systolic': const MeasurementStatistics(
          count: 3,
          latest: 131,
          minimum: 125,
          maximum: 131,
          average: 128,
        ),
        'diastolic': const MeasurementStatistics(
          count: 3,
          latest: 80,
          minimum: 75,
          maximum: 82,
          average: 79,
        ),
      };

      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsComparisonTable.fromBloodPressure(
          fieldStatistics: stats,
          l10n: AppLocalizationsEn(),
          ranges: bpRanges,
        ),
      ));

      final dash = tester.widget<Text>(find.text('\u2014').first);
      final defaultBodyColor = Theme.of(
        tester.element(find.byType(MeasurementStatisticsComparisonTable)),
      ).textTheme.bodyMedium!.color;
      expect(dash.style?.color, defaultBodyColor);
    });

    testWidgets('narrow layout with colored cells does not overflow',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(size: Size(320, 600)),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: MeasurementStatisticsComparisonTable.fromBloodPressure(
                  fieldStatistics: mixedStats(),
                  l10n: AppLocalizationsEn(),
                  ranges: bpRanges,
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('accessibility semantics include unit and status',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsComparisonTable.fromBloodPressure(
          fieldStatistics: mixedStats(),
          l10n: AppLocalizationsEn(),
          ranges: bpRanges,
        ),
      ));

      final handle = tester.ensureSemantics();

      final latestSystolic = tester.getSemantics(find.text('131').first);
      expect(latestSystolic.label, contains('Latest Systolic: 131 mmHg'));
      expect(latestSystolic.label, contains('Above range'));

      final latestDiastolic = tester.getSemantics(find.text('80'));
      expect(latestDiastolic.label, contains('Latest Diastolic: 80 mmHg'));
      expect(latestDiastolic.label, contains('Within range'));

      final latestPulse = tester.getSemantics(find.text('58').first);
      expect(latestPulse.label, contains('Latest Pulse: 58 bpm'));
      expect(latestPulse.label, contains('Below range'));

      final avgSystolic = tester.getSemantics(find.text('128'));
      expect(avgSystolic.label, contains('Average Systolic: 128 mmHg'));
      expect(avgSystolic.label, contains('Above range'));

      handle.dispose();
    });

    testWidgets('Georgian semantics include status text', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        locale: const Locale('ka'),
        child: MeasurementStatisticsComparisonTable.fromBloodPressure(
          fieldStatistics: mixedStats(),
          l10n: AppLocalizationsKa(),
          ranges: bpRanges,
        ),
      ));

      final handle = tester.ensureSemantics();

      final latestSystolic = tester.getSemantics(find.text('131').first);
      expect(latestSystolic.label, contains('ნორმაზე მაღალი'));

      final latestDiastolic = tester.getSemantics(find.text('80'));
      expect(latestDiastolic.label, contains('ნორმის ფარგლებში'));

      final latestPulse = tester.getSemantics(find.text('58').first);
      expect(latestPulse.label, contains('ნორმაზე დაბალი'));

      handle.dispose();
    });
  });

  group('MeasurementStatisticsCard - status colors', () {
    testWidgets('single-component values color by own range', (tester) async {
      final stats = {
        'pulse': const MeasurementStatistics(
          count: 3,
          latest: 72,
          minimum: 58,
          maximum: 72,
          average: 65,
        ),
      };

      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsCard(
          fieldStatistics: stats,
          series: const [
            MeasurementChartSeries(
              fieldKey: 'pulse',
              label: 'Pulse',
              unit: 'bpm',
              points: [],
            ),
          ],
          typeKey: 'pulse',
          ranges: DefaultReferenceRanges.rangesForType('pulse'),
        ),
      ));

      final colorScheme = Theme.of(
        tester.element(find.byType(MeasurementStatisticsCard)),
      ).colorScheme;

      expect(
        tester.widget<Text>(find.text('72').first).style?.color,
        _expectedColor(ReadingStatus.inRange, colorScheme),
      );
      expect(
        tester.widget<Text>(find.text('58')).style?.color,
        _expectedColor(ReadingStatus.belowRange, colorScheme),
      );

      final defaultBodyColor = Theme.of(
        tester.element(find.byType(MeasurementStatisticsCard)),
      ).textTheme.bodyMedium!.color;
      final countText = tester.widget<Text>(find.text('3'));
      expect(countText.style?.color, defaultBodyColor);
    });

    testWidgets('single-component without range is neutral outline',
        (tester) async {
      final stats = {
        'weight': const MeasurementStatistics(
          count: 3,
          latest: 75,
          minimum: 74,
          maximum: 76,
          average: 75,
        ),
      };

      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsCard(
          fieldStatistics: stats,
          series: const [
            MeasurementChartSeries(
              fieldKey: 'weight',
              label: 'Weight',
              unit: 'kg',
              points: [],
            ),
          ],
          typeKey: 'weight',
          ranges: DefaultReferenceRanges.rangesForType('weight'),
        ),
      ));

      final colorScheme = Theme.of(
        tester.element(find.byType(MeasurementStatisticsCard)),
      ).colorScheme;
      final outline = _expectedColor(ReadingStatus.unknown, colorScheme);

      expect(tester.widget<Text>(find.text('75.0').first).style?.color, outline);
      expect(tester.widget<Text>(find.text('74.0')).style?.color, outline);
    });
  });

  group('displayed value and status color agree after rounding', () {
    final bpRanges = DefaultReferenceRanges.rangesForType('blood_pressure');

    ColorScheme schemeOf(WidgetTester tester) => Theme.of(
          tester.element(find.byType(MeasurementStatisticsComparisonTable)),
        ).colorScheme;

    testWidgets('diastolic average 80.4 displays 80 in Within range color',
        (tester) async {
      final stats = {
        'systolic': const MeasurementStatistics(
          count: 3,
          latest: 112,
          minimum: 110,
          maximum: 115,
          average: 112,
        ),
        'diastolic': const MeasurementStatistics(
          count: 3,
          latest: 82,
          minimum: 76,
          maximum: 84,
          average: 80.4,
        ),
      };

      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsComparisonTable.fromBloodPressure(
          fieldStatistics: stats,
          l10n: AppLocalizationsEn(),
          ranges: bpRanges,
        ),
      ));

      expect(find.text('80'), findsOneWidget);
      final colorScheme = schemeOf(tester);
      expect(
        _cellColor(tester, '80'),
        _expectedColor(ReadingStatus.inRange, colorScheme),
      );
    });

    testWidgets('diastolic average 80.5 displays 81 in Above range color',
        (tester) async {
      final stats = {
        'systolic': const MeasurementStatistics(
          count: 3,
          latest: 112,
          minimum: 110,
          maximum: 115,
          average: 112,
        ),
        'diastolic': const MeasurementStatistics(
          count: 3,
          latest: 82,
          minimum: 76,
          maximum: 84,
          average: 80.5,
        ),
      };

      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsComparisonTable.fromBloodPressure(
          fieldStatistics: stats,
          l10n: AppLocalizationsEn(),
          ranges: bpRanges,
        ),
      ));

      expect(find.text('81'), findsOneWidget);
      final colorScheme = schemeOf(tester);
      expect(
        _cellColor(tester, '81'),
        _expectedColor(ReadingStatus.aboveRange, colorScheme),
      );
    });

    testWidgets('diastolic average 80.6 displays 81 in Above range color',
        (tester) async {
      final stats = {
        'systolic': const MeasurementStatistics(
          count: 3,
          latest: 112,
          minimum: 110,
          maximum: 115,
          average: 112,
        ),
        'diastolic': const MeasurementStatistics(
          count: 3,
          latest: 82,
          minimum: 76,
          maximum: 84,
          average: 80.6,
        ),
      };

      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsComparisonTable.fromBloodPressure(
          fieldStatistics: stats,
          l10n: AppLocalizationsEn(),
          ranges: bpRanges,
        ),
      ));

      expect(find.text('81'), findsOneWidget);
      final colorScheme = schemeOf(tester);
      expect(
        _cellColor(tester, '81'),
        _expectedColor(ReadingStatus.aboveRange, colorScheme),
      );
    });

    testWidgets('lower-bound systolic rounds into range for minimum and average',
        (tester) async {
      final stats = {
        'systolic': const MeasurementStatistics(
          count: 3,
          latest: 95,
          minimum: 89.4,
          maximum: 95,
          average: 89.6,
        ),
        'diastolic': const MeasurementStatistics(
          count: 3,
          latest: 76,
          minimum: 74,
          maximum: 78,
          average: 76,
        ),
      };

      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsComparisonTable.fromBloodPressure(
          fieldStatistics: stats,
          l10n: AppLocalizationsEn(),
          ranges: bpRanges,
        ),
      ));

      final colorScheme = schemeOf(tester);
      expect(find.text('89'), findsOneWidget);
      expect(
        _cellColor(tester, '89'),
        _expectedColor(ReadingStatus.belowRange, colorScheme),
      );
      expect(find.text('90'), findsOneWidget);
      expect(
        _cellColor(tester, '90'),
        _expectedColor(ReadingStatus.inRange, colorScheme),
      );
    });

    testWidgets('single-component glucose card colors the rounded average',
        (tester) async {
      final stats = {
        'glucose': const MeasurementStatistics(
          count: 3,
          latest: 8.2,
          minimum: 3.84,
          maximum: 8.2,
          average: 7.84,
        ),
      };

      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsCard(
          fieldStatistics: stats,
          series: const [
            MeasurementChartSeries(
              fieldKey: 'glucose',
              label: 'Glucose',
              unit: 'mmol/L',
              points: [],
            ),
          ],
          typeKey: 'blood_glucose',
          ranges: DefaultReferenceRanges.rangesForType('blood_glucose'),
        ),
      ));

      final colorScheme = Theme.of(
        tester.element(find.byType(MeasurementStatisticsCard)),
      ).colorScheme;

      expect(find.text('7.8'), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('7.8')).style?.color,
        _expectedColor(ReadingStatus.inRange, colorScheme),
      );
      expect(find.text('3.8'), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('3.8')).style?.color,
        _expectedColor(ReadingStatus.belowRange, colorScheme),
      );
    });

    testWidgets('pulse average 100.5 displays 101 in Above range color',
        (tester) async {
      final stats = {
        'pulse': const MeasurementStatistics(
          count: 3,
          latest: 88,
          minimum: 84,
          maximum: 96,
          average: 100.5,
        ),
      };

      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsCard(
          fieldStatistics: stats,
          series: const [
            MeasurementChartSeries(
              fieldKey: 'pulse',
              label: 'Pulse',
              unit: 'bpm',
              points: [],
            ),
          ],
          typeKey: 'pulse',
          ranges: DefaultReferenceRanges.rangesForType('pulse'),
        ),
      ));

      final colorScheme = Theme.of(
        tester.element(find.byType(MeasurementStatisticsCard)),
      ).colorScheme;

      expect(find.text('101'), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('101')).style?.color,
        _expectedColor(ReadingStatus.aboveRange, colorScheme),
      );
    });
  });
}
