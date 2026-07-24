import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/default_reference_ranges.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/domain/services/reading_status_calculator.dart';

void main() {
  group('ReferenceRange', () {
    test('contains value within range', () {
      const range = ReferenceRange(minValue: 60, maxValue: 100);
      expect(range.contains(80), isTrue);
      expect(range.contains(60), isTrue);
      expect(range.contains(100), isTrue);
    });

    test('contains value outside range', () {
      const range = ReferenceRange(minValue: 60, maxValue: 100);
      expect(range.contains(50), isFalse);
      expect(range.contains(110), isFalse);
    });

    test('hasRange returns true when either bound is set', () {
      const rangeMinOnly = ReferenceRange(minValue: 60);
      const rangeMaxOnly = ReferenceRange(maxValue: 100);
      const rangeBoth = ReferenceRange(minValue: 60, maxValue: 100);
      const rangeNone = ReferenceRange();

      expect(rangeMinOnly.hasRange, isTrue);
      expect(rangeMaxOnly.hasRange, isTrue);
      expect(rangeBoth.hasRange, isTrue);
      expect(rangeNone.hasRange, isFalse);
    });

    test('isBelow checks lower bound', () {
      const range = ReferenceRange(minValue: 60, maxValue: 100);
      expect(range.isBelow(50), isTrue);
      expect(range.isBelow(60), isFalse);
      expect(range.isBelow(80), isFalse);
    });

    test('isAbove checks upper bound', () {
      const range = ReferenceRange(minValue: 60, maxValue: 100);
      expect(range.isAbove(110), isTrue);
      expect(range.isAbove(100), isFalse);
      expect(range.isAbove(80), isFalse);
    });

    test('open-ended range below', () {
      const range = ReferenceRange(maxValue: 100);
      expect(range.contains(0), isTrue);
      expect(range.contains(100), isTrue);
      expect(range.isBelow(0), isFalse);
      expect(range.isAbove(110), isTrue);
    });

    test('open-ended range above', () {
      const range = ReferenceRange(minValue: 60);
      expect(range.contains(1000), isTrue);
      expect(range.contains(60), isTrue);
      expect(range.isAbove(1000), isFalse);
      expect(range.isBelow(50), isTrue);
    });
  });

  group('MeasurementRanges', () {
    test('rangeForField returns correct range', () {
      const ranges = MeasurementRanges(fieldRanges: {
        'systolic': ReferenceRange(minValue: 90, maxValue: 120),
        'diastolic': ReferenceRange(minValue: 60, maxValue: 80),
      });

      expect(ranges.rangeForField('systolic')?.minValue, 90);
      expect(ranges.rangeForField('diastolic')?.maxValue, 80);
      expect(ranges.rangeForField('pulse'), isNull);
    });
  });

  group('ReadingStatusCalculator', () {
    group('blood pressure', () {
      test('in range when both systolic and diastolic in range', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'blood_pressure',
          fieldValues: {'systolic': 120, 'diastolic': 80},
          ranges: DefaultReferenceRanges.rangesForType('blood_pressure'),
        );
        expect(result, ReadingStatus.inRange);
      });

      test('above range when systolic above and diastolic in range', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'blood_pressure',
          fieldValues: {'systolic': 150, 'diastolic': 80},
          ranges: DefaultReferenceRanges.rangesForType('blood_pressure'),
        );
        expect(result, ReadingStatus.aboveRange);
      });

      test('above range when diastolic above and systolic in range', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'blood_pressure',
          fieldValues: {'systolic': 120, 'diastolic': 95},
          ranges: DefaultReferenceRanges.rangesForType('blood_pressure'),
        );
        expect(result, ReadingStatus.aboveRange);
      });

      test('above range when both above', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'blood_pressure',
          fieldValues: {'systolic': 150, 'diastolic': 95},
          ranges: DefaultReferenceRanges.rangesForType('blood_pressure'),
        );
        expect(result, ReadingStatus.aboveRange);
      });

      test('below range when systolic below and diastolic in range', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'blood_pressure',
          fieldValues: {'systolic': 85, 'diastolic': 70},
          ranges: DefaultReferenceRanges.rangesForType('blood_pressure'),
        );
        expect(result, ReadingStatus.belowRange);
      });

      test('below range when diastolic below and systolic in range', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'blood_pressure',
          fieldValues: {'systolic': 110, 'diastolic': 50},
          ranges: DefaultReferenceRanges.rangesForType('blood_pressure'),
        );
        expect(result, ReadingStatus.belowRange);
      });

      test('below range when both below', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'blood_pressure',
          fieldValues: {'systolic': 85, 'diastolic': 50},
          ranges: DefaultReferenceRanges.rangesForType('blood_pressure'),
        );
        expect(result, ReadingStatus.belowRange);
      });

      test('above takes priority when systolic above and diastolic below', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'blood_pressure',
          fieldValues: {'systolic': 150, 'diastolic': 50},
          ranges: DefaultReferenceRanges.rangesForType('blood_pressure'),
        );
        expect(result, ReadingStatus.aboveRange);
      });

      test('unknown when systolic missing', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'blood_pressure',
          fieldValues: {'diastolic': 80},
          ranges: DefaultReferenceRanges.rangesForType('blood_pressure'),
        );
        expect(result, ReadingStatus.unknown);
      });

      test('unknown when diastolic missing', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'blood_pressure',
          fieldValues: {'systolic': 120},
          ranges: DefaultReferenceRanges.rangesForType('blood_pressure'),
        );
        expect(result, ReadingStatus.unknown);
      });

      test('unknown when both missing', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'blood_pressure',
          fieldValues: {},
          ranges: DefaultReferenceRanges.rangesForType('blood_pressure'),
        );
        expect(result, ReadingStatus.unknown);
      });
    });

    group('pulse', () {
      test('in range', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'pulse',
          fieldValues: {'pulse': 72},
          ranges: DefaultReferenceRanges.rangesForType('pulse'),
        );
        expect(result, ReadingStatus.inRange);
      });

      test('above range', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'pulse',
          fieldValues: {'pulse': 110},
          ranges: DefaultReferenceRanges.rangesForType('pulse'),
        );
        expect(result, ReadingStatus.aboveRange);
      });

      test('below range', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'pulse',
          fieldValues: {'pulse': 50},
          ranges: DefaultReferenceRanges.rangesForType('pulse'),
        );
        expect(result, ReadingStatus.belowRange);
      });

      test('at boundary min', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'pulse',
          fieldValues: {'pulse': 60},
          ranges: DefaultReferenceRanges.rangesForType('pulse'),
        );
        expect(result, ReadingStatus.inRange);
      });

      test('at boundary max', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'pulse',
          fieldValues: {'pulse': 100},
          ranges: DefaultReferenceRanges.rangesForType('pulse'),
        );
        expect(result, ReadingStatus.inRange);
      });
    });

    group('blood glucose', () {
      test('in range', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'blood_glucose',
          fieldValues: {'glucose': 5.6},
          ranges: DefaultReferenceRanges.rangesForType('blood_glucose'),
        );
        expect(result, ReadingStatus.inRange);
      });

      test('above range', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'blood_glucose',
          fieldValues: {'glucose': 10.0},
          ranges: DefaultReferenceRanges.rangesForType('blood_glucose'),
        );
        expect(result, ReadingStatus.aboveRange);
      });

      test('below range', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'blood_glucose',
          fieldValues: {'glucose': 3.0},
          ranges: DefaultReferenceRanges.rangesForType('blood_glucose'),
        );
        expect(result, ReadingStatus.belowRange);
      });
    });

    group('temperature', () {
      test('in range', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'temperature',
          fieldValues: {'temperature': 36.6},
          ranges: DefaultReferenceRanges.rangesForType('temperature'),
        );
        expect(result, ReadingStatus.inRange);
      });

      test('above range', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'temperature',
          fieldValues: {'temperature': 38.0},
          ranges: DefaultReferenceRanges.rangesForType('temperature'),
        );
        expect(result, ReadingStatus.aboveRange);
      });

      test('below range', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'temperature',
          fieldValues: {'temperature': 35.5},
          ranges: DefaultReferenceRanges.rangesForType('temperature'),
        );
        expect(result, ReadingStatus.belowRange);
      });
    });

    group('weight', () {
      test('unknown when no ranges configured', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'weight',
          fieldValues: {'weight': 75},
          ranges: DefaultReferenceRanges.rangesForType('weight'),
        );
        expect(result, ReadingStatus.unknown);
      });
    });

    group('spo2', () {
      test('in range', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'spo2',
          fieldValues: {'spo2': 98},
          ranges: DefaultReferenceRanges.rangesForType('spo2'),
        );
        expect(result, ReadingStatus.inRange);
      });

      test('below range', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'spo2',
          fieldValues: {'spo2': 90},
          ranges: DefaultReferenceRanges.rangesForType('spo2'),
        );
        expect(result, ReadingStatus.belowRange);
      });

      test('above range (above 100 is above)', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'spo2',
          fieldValues: {'spo2': 101},
          ranges: DefaultReferenceRanges.rangesForType('spo2'),
        );
        expect(result, ReadingStatus.aboveRange);
      });
    });

    group('unknown type', () {
      test('returns unknown for unrecognized type key', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'custom_type',
          fieldValues: {'value': 50},
          ranges: const MeasurementRanges(fieldRanges: {
            'value': ReferenceRange(minValue: 0, maxValue: 100),
          }),
        );
        expect(result, ReadingStatus.inRange);
      });
    });

    group('missing values', () {
      test('returns unknown when required field value is missing', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'pulse',
          fieldValues: {},
          ranges: DefaultReferenceRanges.rangesForType('pulse'),
        );
        expect(result, ReadingStatus.unknown);
      });

      test('returns unknown when ranges is null', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'pulse',
          fieldValues: {'pulse': 72},
          ranges: null,
        );
        expect(result, ReadingStatus.unknown);
      });

      test('returns unknown when fieldRanges is empty', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'weight',
          fieldValues: {'weight': 75},
          ranges: const MeasurementRanges(fieldRanges: {}),
        );
        expect(result, ReadingStatus.unknown);
      });
    });

    group('custom range', () {
      test('uses provided range instead of default', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'pulse',
          fieldValues: {'pulse': 55},
          ranges: const MeasurementRanges(fieldRanges: {
            'pulse': ReferenceRange(minValue: 50, maxValue: 90),
          }),
        );
        expect(result, ReadingStatus.inRange);
      });

      test('reports below when custom range min is higher', () {
        final result = ReadingStatusCalculator.calculate(
          typeKey: 'pulse',
          fieldValues: {'pulse': 55},
          ranges: const MeasurementRanges(fieldRanges: {
            'pulse': ReferenceRange(minValue: 60, maxValue: 100),
          }),
        );
        expect(result, ReadingStatus.belowRange);
      });
    });
  });

  group('DefaultReferenceRanges', () {
    test('has ranges for all built-in types', () {
      expect(DefaultReferenceRanges.ranges.containsKey('blood_pressure'), isTrue);
      expect(DefaultReferenceRanges.ranges.containsKey('pulse'), isTrue);
      expect(DefaultReferenceRanges.ranges.containsKey('weight'), isTrue);
      expect(DefaultReferenceRanges.ranges.containsKey('blood_glucose'), isTrue);
      expect(DefaultReferenceRanges.ranges.containsKey('spo2'), isTrue);
      expect(DefaultReferenceRanges.ranges.containsKey('temperature'), isTrue);
    });

    test('rangesForType returns correct ranges', () {
      final bpRanges = DefaultReferenceRanges.rangesForType('blood_pressure');
      expect(bpRanges, isNotNull);
      expect(bpRanges!.rangeForField('systolic')?.minValue, 90);
      expect(bpRanges.rangeForField('systolic')?.maxValue, 120);
      expect(bpRanges.rangeForField('diastolic')?.minValue, 60);
      expect(bpRanges.rangeForField('diastolic')?.maxValue, 80);
    });

    test('rangesForType returns null for unknown type', () {
      expect(DefaultReferenceRanges.rangesForType('unknown'), isNull);
    });

    test('weight has empty field ranges (no default range)', () {
      final weightRanges = DefaultReferenceRanges.rangesForType('weight');
      expect(weightRanges, isNotNull);
      expect(weightRanges!.fieldRanges.isEmpty, isTrue);
    });
  });
}
