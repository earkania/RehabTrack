import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/measurement_statistics.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/l10n/app_localizations_en.dart';
import 'package:rehab_track/l10n/app_localizations_ka.dart';
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
}
