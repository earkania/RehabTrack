import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/measurement_chart.dart';
import 'package:rehab_track/domain/entities/measurement_statistics.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/domain/entities/reading_status_summary.dart';

void main() {
  group('MeasurementChartPoint', () {
    test('stores all fields correctly', () {
      final point = MeasurementChartPoint(
        recordId: 42,
        measuredAt: DateTime(2026, 7, 25, 14, 30),
        numericValue: 120.5,
        unit: 'mmHg',
        readingStatus: ReadingStatus.inRange,
        irregularHeartbeatDetected: true,
      );

      expect(point.recordId, 42);
      expect(point.measuredAt, DateTime(2026, 7, 25, 14, 30));
      expect(point.numericValue, 120.5);
      expect(point.unit, 'mmHg');
      expect(point.readingStatus, ReadingStatus.inRange);
      expect(point.irregularHeartbeatDetected, isTrue);
    });

    test('irregularHeartbeatDetected defaults to false', () {
      final point = MeasurementChartPoint(
        recordId: 1,
        measuredAt: DateTime(2026),
        numericValue: 100,
        unit: 'bpm',
        readingStatus: ReadingStatus.unknown,
      );
      expect(point.irregularHeartbeatDetected, isFalse);
    });
  });

  group('MeasurementChartSeries', () {
    test('isEmpty when no points', () {
      const series = MeasurementChartSeries(
        fieldKey: 'pulse',
        label: 'Pulse',
        unit: 'bpm',
        points: [],
      );
      expect(series.isEmpty, isTrue);
      expect(series.length, 0);
    });

    test('length returns point count', () {
      final series = MeasurementChartSeries(
        fieldKey: 'pulse',
        label: 'Pulse',
        unit: 'bpm',
        points: [
          MeasurementChartPoint(
            recordId: 1,
            measuredAt: DateTime(2026),
            numericValue: 72,
            unit: 'bpm',
            readingStatus: ReadingStatus.inRange,
          ),
        ],
      );
      expect(series.isEmpty, isFalse);
      expect(series.length, 1);
    });
  });

  group('MeasurementStatistics', () {
    test('empty', () {
      const stats = MeasurementStatistics.empty;
      expect(stats.count, 0);
      expect(stats.latest, isNull);
      expect(stats.minimum, isNull);
      expect(stats.maximum, isNull);
      expect(stats.average, isNull);
    });

    test('compute with single value', () {
      final stats = MeasurementStatistics.compute([42.0]);
      expect(stats.count, 1);
      expect(stats.latest, 42.0);
      expect(stats.minimum, 42.0);
      expect(stats.maximum, 42.0);
      expect(stats.average, 42.0);
      expect(stats.change, isNull);
      expect(stats.percentageChange, isNull);
    });

    test('compute with multiple values', () {
      final stats = MeasurementStatistics.compute([10.0, 20.0, 30.0]);
      expect(stats.count, 3);
      expect(stats.first, 10.0);
      expect(stats.latest, 30.0);
      expect(stats.minimum, 10.0);
      expect(stats.maximum, 30.0);
      expect(stats.average, 20.0);
      expect(stats.change, 20.0);
      expect(stats.percentageChange, 200.0);
    });

    test('compute with identical values', () {
      final stats = MeasurementStatistics.compute([5.0, 5.0, 5.0]);
      expect(stats.change, 0.0);
      expect(stats.percentageChange, 0.0);
    });

    test('compute with zero first value', () {
      final stats = MeasurementStatistics.compute([0.0, 10.0]);
      expect(stats.change, 10.0);
      expect(stats.percentageChange, isNull);
    });

    test('compute with negative values', () {
      final stats = MeasurementStatistics.compute([-5.0, 5.0]);
      expect(stats.change, 10.0);
      expect(stats.percentageChange, -200.0);
    });
  });

  group('ReadingStatusSummary', () {
    test('empty', () {
      const summary = ReadingStatusSummary.empty;
      expect(summary.total, 0);
      expect(summary.hasIrregularHeartbeat, isFalse);
    });

    test('total sums all counts', () {
      const summary = ReadingStatusSummary(
        belowCount: 2,
        withinCount: 5,
        aboveCount: 1,
        unknownCount: 3,
      );
      expect(summary.total, 11);
    });

    test('hasIrregularHeartbeat is true when count > 0', () {
      const summary = ReadingStatusSummary(
        belowCount: 0,
        withinCount: 0,
        aboveCount: 0,
        unknownCount: 0,
        irregularHeartbeatCount: 1,
      );
      expect(summary.hasIrregularHeartbeat, isTrue);
    });

    test('irregularHeartbeatCount defaults to 0', () {
      const summary = ReadingStatusSummary(
        belowCount: 0,
        withinCount: 0,
        aboveCount: 0,
        unknownCount: 0,
      );
      expect(summary.irregularHeartbeatCount, 0);
    });
  });
}
