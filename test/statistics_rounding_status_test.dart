import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/default_reference_ranges.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/domain/services/reading_status_calculator.dart';
import 'package:rehab_track/presentation/utils/measurement_formatter.dart';

void main() {
  final bpRanges = DefaultReferenceRanges.rangesForType('blood_pressure')!;

  ReadingStatus statusOf(String fieldKey, double value,
      {MeasurementRanges? ranges}) {
    return ReadingStatusCalculator.calculateFieldValue(
      fieldKey: fieldKey,
      value: value,
      ranges: ranges ?? bpRanges,
    );
  }

  StatisticsValue derived(String fieldKey, double value) {
    return MeasurementFormatter.statisticsValue(
      value,
      derived: true,
      fieldKey: fieldKey,
    );
  }

  group('shared statistics rounding helper', () {
    test('derived values round to the component precision', () {
      expect(derived('diastolic', 80.4).numericValue, 80);
      expect(derived('diastolic', 80.4).text, '80');

      expect(derived('diastolic', 80.5).numericValue, 81);
      expect(derived('diastolic', 80.5).text, '81');

      expect(derived('diastolic', 80.6).numericValue, 81);
      expect(derived('diastolic', 80.6).text, '81');
    });

    test('latest keeps the actual recorded value for classification', () {
      final latest = MeasurementFormatter.statisticsValue(
        80.4,
        derived: false,
        fieldKey: 'diastolic',
      );
      expect(latest.numericValue, 80.4);
      expect(latest.text, '80');
    });

    test('respects decimal precision for glucose and weight', () {
      expect(derived('glucose', 7.84).numericValue, 7.8);
      expect(derived('glucose', 7.84).text, '7.8');

      expect(derived('glucose', 7.85).numericValue, 7.9);
      expect(derived('glucose', 7.85).text, '7.9');

      expect(derived('weight', 75.55).numericValue, 75.6);
      expect(derived('weight', 75.55).text, '75.6');
    });
  });

  group('displayed value and classifier agree', () {
    test('precise 80.4 displays 80 and classifies Within range', () {
      final display = derived('diastolic', 80.4);
      expect(display.text, '80');
      expect(statusOf('diastolic', display.numericValue),
          ReadingStatus.inRange);
      expect(statusOf('diastolic', 80.4), ReadingStatus.aboveRange);
    });

    test('precise 80.5 rounds to 81 and classifies Above range', () {
      final display = derived('diastolic', 80.5);
      expect(display.text, '81');
      expect(statusOf('diastolic', display.numericValue),
          ReadingStatus.aboveRange);
    });

    test('precise 80.6 displays 81 and classifies Above range', () {
      final display = derived('diastolic', 80.6);
      expect(display.text, '81');
      expect(statusOf('diastolic', display.numericValue),
          ReadingStatus.aboveRange);
    });
  });

  group('upper-bound rounding cases', () {
    test('diastolic 80.49 rounds to 80 and stays Within range', () {
      final display = derived('diastolic', 80.49);
      expect(display.text, '80');
      expect(statusOf('diastolic', display.numericValue),
          ReadingStatus.inRange);
    });

    test('diastolic 80.50 rounds to 81 and becomes Above range', () {
      final display = derived('diastolic', 80.50);
      expect(display.text, '81');
      expect(statusOf('diastolic', display.numericValue),
          ReadingStatus.aboveRange);
    });

    test('systolic 120.4 displays 120 and stays Within range', () {
      final display = derived('systolic', 120.4);
      expect(display.text, '120');
      expect(statusOf('systolic', display.numericValue),
          ReadingStatus.inRange);
      expect(statusOf('systolic', 120.4), ReadingStatus.aboveRange);
    });

    test('systolic 120.6 displays 121 and becomes Above range', () {
      final display = derived('systolic', 120.6);
      expect(display.text, '121');
      expect(statusOf('systolic', display.numericValue),
          ReadingStatus.aboveRange);
    });

    test('pulse 100.4 displays 100 and stays Within range', () {
      final display = derived('pulse', 100.4);
      expect(display.text, '100');
      expect(statusOf('pulse', display.numericValue), ReadingStatus.inRange);
      expect(statusOf('pulse', 100.4), ReadingStatus.aboveRange);
    });

    test('pulse 100.5 displays 101 and becomes Above range', () {
      final display = derived('pulse', 100.5);
      expect(display.text, '101');
      expect(statusOf('pulse', display.numericValue),
          ReadingStatus.aboveRange);
    });
  });

  group('lower-bound rounding cases', () {
    test('systolic 89.6 displays 90 and stays Within range', () {
      final display = derived('systolic', 89.6);
      expect(display.text, '90');
      expect(statusOf('systolic', display.numericValue),
          ReadingStatus.inRange);
      expect(statusOf('systolic', 89.6), ReadingStatus.belowRange);
    });

    test('systolic 89.4 displays 89 and becomes Below range', () {
      final display = derived('systolic', 89.4);
      expect(display.text, '89');
      expect(statusOf('systolic', display.numericValue),
          ReadingStatus.belowRange);
    });

    test('diastolic 59.6 displays 60 and stays Within range', () {
      final display = derived('diastolic', 59.6);
      expect(display.text, '60');
      expect(statusOf('diastolic', display.numericValue),
          ReadingStatus.inRange);
    });

    test('diastolic 59.4 displays 59 and becomes Below range', () {
      final display = derived('diastolic', 59.4);
      expect(display.text, '59');
      expect(statusOf('diastolic', display.numericValue),
          ReadingStatus.belowRange);
    });
  });

  group('single-component decimal measurements', () {
    final glucoseRanges =
        DefaultReferenceRanges.rangesForType('blood_glucose')!;

    test('glucose 7.84 displays 7.8 and stays Within range', () {
      final display = derived('glucose', 7.84);
      expect(display.text, '7.8');
      expect(
        statusOf('glucose', display.numericValue, ranges: glucoseRanges),
        ReadingStatus.inRange,
      );
      expect(
        statusOf('glucose', 7.84, ranges: glucoseRanges),
        ReadingStatus.aboveRange,
      );
    });

    test('glucose 7.85 displays 7.9 and becomes Above range', () {
      final display = derived('glucose', 7.85);
      expect(display.text, '7.9');
      expect(
        statusOf('glucose', display.numericValue, ranges: glucoseRanges),
        ReadingStatus.aboveRange,
      );
    });

    test('glucose 3.84 displays 3.8 and becomes Below range', () {
      final display = derived('glucose', 3.84);
      expect(display.text, '3.8');
      expect(
        statusOf('glucose', display.numericValue, ranges: glucoseRanges),
        ReadingStatus.belowRange,
      );
    });
  });
}
