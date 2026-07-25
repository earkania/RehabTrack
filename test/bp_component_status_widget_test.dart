import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/blood_pressure_component_status.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/measurement_statistics.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/l10n/app_localizations_en.dart';
import 'package:rehab_track/l10n/app_localizations_ka.dart';
import 'package:rehab_track/presentation/widgets/measurements/blood_pressure_summary_text.dart';
import 'package:rehab_track/presentation/widgets/measurements/measurement_statistics_comparison_table.dart';

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

List<MeasurementRecordValue> _bpValues({
  double systolic = 120,
  double diastolic = 80,
  double? pulse,
}) {
  return [
    MeasurementRecordValue(
      measurementRecordId: 1,
      fieldKey: 'systolic',
      numericValue: systolic,
      unit: 'mmHg',
      displayOrder: 0,
    ),
    MeasurementRecordValue(
      measurementRecordId: 1,
      fieldKey: 'diastolic',
      numericValue: diastolic,
      unit: 'mmHg',
      displayOrder: 1,
    ),
    if (pulse != null)
      MeasurementRecordValue(
        measurementRecordId: 1,
        fieldKey: 'pulse',
        numericValue: pulse,
        unit: 'bpm',
        displayOrder: 2,
      ),
  ];
}

void main() {
  group('MeasurementStatisticsComparisonTable - compact headers', () {
    testWidgets('Georgian uses short labels: სისტ., დიასტ., პულსი',
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
        locale: const Locale('ka'),
        child: MeasurementStatisticsComparisonTable.fromBloodPressure(
          fieldStatistics: stats,
          l10n: AppLocalizationsKa(),
        ),
      ));

      expect(find.text('სისტ.'), findsOneWidget);
      expect(find.text('დიასტ.'), findsOneWidget);
      expect(find.text('პულსი'), findsWidgets);
    });

    testWidgets('Georgian compact headers do not wrap on narrow screen',
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

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ka'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: MeasurementStatisticsComparisonTable.fromBloodPressure(
                fieldStatistics: stats,
                l10n: AppLocalizationsKa(),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('full labels remain in Semantics', (tester) async {
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
        locale: const Locale('ka'),
        child: MeasurementStatisticsComparisonTable.fromBloodPressure(
          fieldStatistics: stats,
          l10n: AppLocalizationsKa(),
        ),
      ));

      final handle = tester.ensureSemantics();
      final sysNode = tester.getSemantics(find.text('სისტ.'));
      expect(sysNode.label, contains('სისტოლური'));
      final diaNode = tester.getSemantics(find.text('დიასტ.'));
      expect(diaNode.label, contains('დიასტოლური'));
      handle.dispose();
    });

    testWidgets('English compact headers match full labels', (tester) async {
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
      };

      await tester.pumpWidget(_buildTestWidget(
        child: MeasurementStatisticsComparisonTable.fromBloodPressure(
          fieldStatistics: stats,
          l10n: AppLocalizationsEn(),
        ),
      ));

      expect(find.text('Systolic'), findsWidgets);
      expect(find.text('Diastolic'), findsWidgets);
    });
  });

  group('BloodPressureSummaryText', () {
    testWidgets('systolic number uses systolic status color', (tester) async {
      const componentStatus = BloodPressureComponentStatus(
        overallStatus: ReadingStatus.aboveRange,
        systolicStatus: ReadingStatus.aboveRange,
        diastolicStatus: ReadingStatus.inRange,
        pulseStatus: ReadingStatus.inRange,
      );

      await tester.pumpWidget(_buildTestWidget(
        child: BloodPressureSummaryText(
          values: _bpValues(systolic: 150, diastolic: 75, pulse: 70),
          componentStatus: componentStatus,
        ),
      ));

      final richText = tester.widget<RichText>(find.byType(RichText));
      final outerSpan = richText.text as TextSpan;
      final sysSpan = outerSpan.children![0] as TextSpan;
      expect(sysSpan.text, '150');

      final sysColor = sysSpan.style?.color;
      final diaValueSpan = sysSpan.children![1] as TextSpan;
      expect(diaValueSpan.text, '75');

      expect(sysColor, isNotNull);
      expect(diaValueSpan.style?.color, isNotNull);
      expect(sysColor, isNot(equals(diaValueSpan.style?.color)));
    });

    testWidgets('separators and units keep normal text colour',
        (tester) async {
      const componentStatus = BloodPressureComponentStatus(
        overallStatus: ReadingStatus.inRange,
        systolicStatus: ReadingStatus.inRange,
        diastolicStatus: ReadingStatus.inRange,
      );

      await tester.pumpWidget(_buildTestWidget(
        child: BloodPressureSummaryText(
          values: _bpValues(systolic: 120, diastolic: 80),
          componentStatus: componentStatus,
        ),
      ));

      final richText = tester.widget<RichText>(find.byType(RichText));
      final outerSpan = richText.text as TextSpan;
      final sysSpan = outerSpan.children![0] as TextSpan;
      final unitSpan = sysSpan.children![2] as TextSpan;
      expect(unitSpan.text, ' mmHg');
      expect(unitSpan.style?.color, isNull);
    });

    testWidgets('pulse is omitted when absent', (tester) async {
      const componentStatus = BloodPressureComponentStatus(
        overallStatus: ReadingStatus.inRange,
        systolicStatus: ReadingStatus.inRange,
        diastolicStatus: ReadingStatus.inRange,
      );

      await tester.pumpWidget(_buildTestWidget(
        child: BloodPressureSummaryText(
          values: _bpValues(systolic: 120, diastolic: 80),
          componentStatus: componentStatus,
        ),
      ));

      final richText = tester.widget<RichText>(find.byType(RichText));
      final flatText = richText.text.toPlainText();
      expect(flatText, contains('120/80'));
      expect(flatText, isNot(contains('pulse')));
      expect(flatText, isNot(contains('bpm')));
    });

    testWidgets('pulse number uses pulse status colour', (tester) async {
      const componentStatus = BloodPressureComponentStatus(
        overallStatus: ReadingStatus.aboveRange,
        systolicStatus: ReadingStatus.aboveRange,
        diastolicStatus: ReadingStatus.inRange,
        pulseStatus: ReadingStatus.belowRange,
      );

      await tester.pumpWidget(_buildTestWidget(
        child: BloodPressureSummaryText(
          values: _bpValues(systolic: 150, diastolic: 75, pulse: 50),
          componentStatus: componentStatus,
        ),
      ));

      final richText = tester.widget<RichText>(find.byType(RichText));
      final outerSpan = richText.text as TextSpan;
      final pulseValueSpan = outerSpan.children![3] as TextSpan;
      expect(pulseValueSpan.text, contains('50'));
      expect(pulseValueSpan.style?.color, isNotNull);
    });

    testWidgets('accessibility semantics include component status',
        (tester) async {
      const componentStatus = BloodPressureComponentStatus(
        overallStatus: ReadingStatus.aboveRange,
        systolicStatus: ReadingStatus.aboveRange,
        diastolicStatus: ReadingStatus.inRange,
        pulseStatus: ReadingStatus.inRange,
      );

      await tester.pumpWidget(_buildTestWidget(
        child: BloodPressureSummaryText(
          values: _bpValues(systolic: 150, diastolic: 80, pulse: 70),
          componentStatus: componentStatus,
        ),
      ));

      final semantics = tester.getSemantics(find.byType(BloodPressureSummaryText));
      expect(semantics.label, contains('above configured range'));
      expect(semantics.label, contains('within configured range'));
    });

    testWidgets('English summary remains correct', (tester) async {
      const componentStatus = BloodPressureComponentStatus(
        overallStatus: ReadingStatus.inRange,
        systolicStatus: ReadingStatus.inRange,
        diastolicStatus: ReadingStatus.inRange,
        pulseStatus: ReadingStatus.inRange,
      );

      await tester.pumpWidget(_buildTestWidget(
        child: BloodPressureSummaryText(
          values: _bpValues(systolic: 120, diastolic: 80, pulse: 72),
          componentStatus: componentStatus,
          pulseLabel: 'pulse',
        ),
      ));

      final richText = tester.widget<RichText>(find.byType(RichText));
      final flatText = richText.text.toPlainText();
      expect(flatText, contains('120'));
      expect(flatText, contains('/'));
      expect(flatText, contains('80'));
      expect(flatText, contains('mmHg'));
      expect(flatText, contains('pulse'));
      expect(flatText, contains('72'));
      expect(flatText, contains('bpm'));
    });

    testWidgets('Georgian summary remains correct', (tester) async {
      const componentStatus = BloodPressureComponentStatus(
        overallStatus: ReadingStatus.inRange,
        systolicStatus: ReadingStatus.inRange,
        diastolicStatus: ReadingStatus.inRange,
        pulseStatus: ReadingStatus.inRange,
      );

      await tester.pumpWidget(_buildTestWidget(
        locale: const Locale('ka'),
        child: BloodPressureSummaryText(
          values: _bpValues(systolic: 120, diastolic: 80, pulse: 72),
          componentStatus: componentStatus,
          pulseLabel: 'პულსი',
        ),
      ));

      final richText = tester.widget<RichText>(find.byType(RichText));
      final flatText = richText.text.toPlainText();
      expect(flatText, contains('120'));
      expect(flatText, contains('80'));
      expect(flatText, contains('პულსი'));
      expect(flatText, contains('72'));
    });

    testWidgets('no layout overflow on narrow screen', (tester) async {
      const componentStatus = BloodPressureComponentStatus(
        overallStatus: ReadingStatus.inRange,
        systolicStatus: ReadingStatus.inRange,
        diastolicStatus: ReadingStatus.inRange,
        pulseStatus: ReadingStatus.inRange,
      );

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
              child: BloodPressureSummaryText(
                values: _bpValues(systolic: 120, diastolic: 80, pulse: 72),
                componentStatus: componentStatus,
                pulseLabel: 'pulse',
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
