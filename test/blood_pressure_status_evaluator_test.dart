import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/domain/services/blood_pressure_status_evaluator.dart';

void main() {
  group('BloodPressureStatusEvaluator', () {
    const defaultRanges = MeasurementRanges(fieldRanges: {
      'systolic': ReferenceRange(minValue: 90, maxValue: 120),
      'diastolic': ReferenceRange(minValue: 60, maxValue: 80),
      'pulse': ReferenceRange(minValue: 60, maxValue: 100),
    });

    test('systolic below, diastolic within', () {
      final result = BloodPressureStatusEvaluator.evaluate(
        fieldValues: {'systolic': 85, 'diastolic': 75, 'pulse': 70},
        ranges: defaultRanges,
      );
      expect(result.systolicStatus, ReadingStatus.belowRange);
      expect(result.diastolicStatus, ReadingStatus.inRange);
      expect(result.overallStatus, ReadingStatus.belowRange);
    });

    test('systolic above, diastolic within', () {
      final result = BloodPressureStatusEvaluator.evaluate(
        fieldValues: {'systolic': 140, 'diastolic': 75, 'pulse': 70},
        ranges: defaultRanges,
      );
      expect(result.systolicStatus, ReadingStatus.aboveRange);
      expect(result.diastolicStatus, ReadingStatus.inRange);
      expect(result.overallStatus, ReadingStatus.aboveRange);
    });

    test('systolic within, diastolic above', () {
      final result = BloodPressureStatusEvaluator.evaluate(
        fieldValues: {'systolic': 110, 'diastolic': 95, 'pulse': 70},
        ranges: defaultRanges,
      );
      expect(result.systolicStatus, ReadingStatus.inRange);
      expect(result.diastolicStatus, ReadingStatus.aboveRange);
      expect(result.overallStatus, ReadingStatus.aboveRange);
    });

    test('both within', () {
      final result = BloodPressureStatusEvaluator.evaluate(
        fieldValues: {'systolic': 110, 'diastolic': 70, 'pulse': 70},
        ranges: defaultRanges,
      );
      expect(result.systolicStatus, ReadingStatus.inRange);
      expect(result.diastolicStatus, ReadingStatus.inRange);
      expect(result.overallStatus, ReadingStatus.inRange);
    });

    test('both above', () {
      final result = BloodPressureStatusEvaluator.evaluate(
        fieldValues: {'systolic': 150, 'diastolic': 95, 'pulse': 110},
        ranges: defaultRanges,
      );
      expect(result.systolicStatus, ReadingStatus.aboveRange);
      expect(result.diastolicStatus, ReadingStatus.aboveRange);
      expect(result.overallStatus, ReadingStatus.aboveRange);
    });

    test('missing systolic returns unknown for component and overall', () {
      final result = BloodPressureStatusEvaluator.evaluate(
        fieldValues: {'diastolic': 70},
        ranges: defaultRanges,
      );
      expect(result.systolicStatus, ReadingStatus.unknown);
      expect(result.overallStatus, ReadingStatus.unknown);
    });

    test('missing diastolic returns unknown for component and overall', () {
      final result = BloodPressureStatusEvaluator.evaluate(
        fieldValues: {'systolic': 110},
        ranges: defaultRanges,
      );
      expect(result.diastolicStatus, ReadingStatus.unknown);
      expect(result.overallStatus, ReadingStatus.unknown);
    });

    test('pulse below range', () {
      final result = BloodPressureStatusEvaluator.evaluate(
        fieldValues: {'systolic': 110, 'diastolic': 70, 'pulse': 50},
        ranges: defaultRanges,
      );
      expect(result.pulseStatus, ReadingStatus.belowRange);
    });

    test('pulse within range', () {
      final result = BloodPressureStatusEvaluator.evaluate(
        fieldValues: {'systolic': 110, 'diastolic': 70, 'pulse': 70},
        ranges: defaultRanges,
      );
      expect(result.pulseStatus, ReadingStatus.inRange);
    });

    test('pulse above range', () {
      final result = BloodPressureStatusEvaluator.evaluate(
        fieldValues: {'systolic': 110, 'diastolic': 70, 'pulse': 120},
        ranges: defaultRanges,
      );
      expect(result.pulseStatus, ReadingStatus.aboveRange);
    });

    test('pulse missing returns null pulse status', () {
      final result = BloodPressureStatusEvaluator.evaluate(
        fieldValues: {'systolic': 110, 'diastolic': 70},
        ranges: defaultRanges,
      );
      expect(result.pulseStatus, isNull);
    });

    test('unknown range returns unknown for all', () {
      final result = BloodPressureStatusEvaluator.evaluate(
        fieldValues: {'systolic': 110, 'diastolic': 70},
        ranges: const MeasurementRanges(fieldRanges: {}),
      );
      expect(result.systolicStatus, ReadingStatus.unknown);
      expect(result.diastolicStatus, ReadingStatus.unknown);
      expect(result.overallStatus, ReadingStatus.unknown);
    });

    test('profile range override changes component status', () {
      const customRanges = MeasurementRanges(fieldRanges: {
        'systolic': ReferenceRange(minValue: 100, maxValue: 130),
        'diastolic': ReferenceRange(minValue: 70, maxValue: 90),
        'pulse': ReferenceRange(minValue: 50, maxValue: 90),
      });

      final result = BloodPressureStatusEvaluator.evaluate(
        fieldValues: {'systolic': 95, 'diastolic': 85, 'pulse': 45},
        ranges: customRanges,
      );

      expect(result.systolicStatus, ReadingStatus.belowRange);
      expect(result.diastolicStatus, ReadingStatus.inRange);
      expect(result.pulseStatus, ReadingStatus.belowRange);
      expect(result.overallStatus, ReadingStatus.belowRange);
    });

    test('overall status remains consistent with existing rules', () {
      final result = BloodPressureStatusEvaluator.evaluate(
        fieldValues: {'systolic': 150, 'diastolic': 55, 'pulse': 70},
        ranges: defaultRanges,
      );
      expect(result.systolicStatus, ReadingStatus.aboveRange);
      expect(result.diastolicStatus, ReadingStatus.belowRange);
      expect(result.overallStatus, ReadingStatus.aboveRange);
    });
  });
}
