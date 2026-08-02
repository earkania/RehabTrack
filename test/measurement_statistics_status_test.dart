import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/default_reference_ranges.dart';
import 'package:rehab_track/domain/entities/measurement_statistics.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/domain/services/reading_status_calculator.dart';

void main() {
  final bpRanges = DefaultReferenceRanges.rangesForType('blood_pressure')!;

  ReadingStatus statusOf(String fieldKey, double? value) {
    return ReadingStatusCalculator.calculateFieldValue(
      fieldKey: fieldKey,
      value: value,
      ranges: bpRanges,
    );
  }

  group('statistics values classify per component', () {
    test('each metric is classified from its own precise value', () {
      final systolic = MeasurementStatistics.compute([131, 128, 125]);
      final diastolic = MeasurementStatistics.compute([80, 82, 75]);
      final pulse = MeasurementStatistics.compute([58, 65, 72]);

      expect(statusOf('systolic', systolic.latest),
          ReadingStatus.aboveRange);
      expect(statusOf('systolic', systolic.average),
          ReadingStatus.aboveRange);
      expect(statusOf('systolic', systolic.minimum),
          ReadingStatus.aboveRange);
      expect(statusOf('systolic', systolic.maximum),
          ReadingStatus.aboveRange);

      expect(statusOf('diastolic', diastolic.latest), ReadingStatus.inRange);
      expect(statusOf('diastolic', diastolic.average), ReadingStatus.inRange);
      expect(statusOf('diastolic', diastolic.minimum), ReadingStatus.inRange);
      expect(statusOf('diastolic', diastolic.maximum),
          ReadingStatus.aboveRange);

      expect(statusOf('pulse', pulse.latest), ReadingStatus.inRange);
      expect(statusOf('pulse', pulse.average), ReadingStatus.inRange);
      expect(statusOf('pulse', pulse.minimum), ReadingStatus.belowRange);
      expect(statusOf('pulse', pulse.maximum), ReadingStatus.inRange);
    });

    test('average keeps precision before classification', () {
      final values = [131.0, 128.0, 125.0];
      final stats = MeasurementStatistics.compute(values);
      final average = stats.average!;
      expect(average, 128);
      expect(average.isFinite, isTrue);
      expect(statusOf('systolic', average), ReadingStatus.aboveRange);
    });

    test('single reading classifies its own value', () {
      final stats = MeasurementStatistics.compute([131]);
      expect(statusOf('systolic', stats.latest), ReadingStatus.aboveRange);
      expect(statusOf('systolic', stats.average), ReadingStatus.aboveRange);
      expect(statusOf('systolic', stats.minimum), ReadingStatus.aboveRange);
      expect(statusOf('systolic', stats.maximum), ReadingStatus.aboveRange);
    });

    test('overall status does not override component status', () {
      final overall = ReadingStatusCalculator.calculate(
        typeKey: 'blood_pressure',
        fieldValues: {'systolic': 131, 'diastolic': 75, 'pulse': 72},
        ranges: bpRanges,
      );
      expect(overall, ReadingStatus.aboveRange);

      expect(statusOf('systolic', 131), ReadingStatus.aboveRange);
      expect(statusOf('diastolic', 75), ReadingStatus.inRange);
      expect(statusOf('pulse', 72), ReadingStatus.inRange);
    });

    test('missing range for a field stays unknown', () {
      final stats = MeasurementStatistics.compute([75]);
      final weightRanges = DefaultReferenceRanges.rangesForType('weight');
      expect(weightRanges, isNotNull);

      final status = ReadingStatusCalculator.calculateFieldValue(
        fieldKey: 'weight',
        value: stats.latest,
        ranges: weightRanges,
      );
      expect(status, ReadingStatus.unknown);
    });
  });
}
