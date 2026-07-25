import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/measurement_chart.dart';
import 'package:rehab_track/domain/entities/measurement_data_point.dart';
import 'package:rehab_track/domain/entities/measurement_statistics.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/domain/entities/reading_status_summary.dart';
import 'package:rehab_track/domain/services/measurement_chart_builder.dart';

MeasurementRecord _record({
  required int id,
  required DateTime timestamp,
  bool irregularHeartbeat = false,
}) {
  return MeasurementRecord(
    id: id,
    profileId: 1,
    measurementTypeId: 1,
    timestamp: timestamp,
    valuePrimary: 0,
    unit: 'mmHg',
    irregularHeartbeatDetected: irregularHeartbeat,
    createdAt: timestamp,
  );
}

MeasurementRecordValue _value({
  required String fieldKey,
  required double numericValue,
  required String unit,
}) {
  return MeasurementRecordValue(
    measurementRecordId: 0,
    fieldKey: fieldKey,
    numericValue: numericValue,
    unit: unit,
  );
}

MeasurementTypeField _field({
  required String fieldKey,
  required String label,
  int displayOrder = 0,
}) {
  return MeasurementTypeField(
    measurementTypeId: 1,
    fieldKey: fieldKey,
    label: label,
    createdAt: DateTime(2026),
    displayOrder: displayOrder,
  );
}

void main() {
  group('MeasurementStatistics', () {
    test('empty list returns empty stats', () {
      final stats = MeasurementStatistics.compute([]);
      expect(stats.count, 0);
      expect(stats.latest, isNull);
      expect(stats.minimum, isNull);
      expect(stats.maximum, isNull);
      expect(stats.average, isNull);
      expect(stats.first, isNull);
      expect(stats.change, isNull);
      expect(stats.percentageChange, isNull);
    });

    test('single value returns same for all fields', () {
      final stats = MeasurementStatistics.compute([42.0]);
      expect(stats.count, 1);
      expect(stats.latest, 42.0);
      expect(stats.minimum, 42.0);
      expect(stats.maximum, 42.0);
      expect(stats.average, 42.0);
      expect(stats.first, 42.0);
      expect(stats.change, isNull);
      expect(stats.percentageChange, isNull);
    });

    test('multiple values computes correctly', () {
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

    test('identical values', () {
      final stats = MeasurementStatistics.compute([5.0, 5.0, 5.0]);
      expect(stats.count, 3);
      expect(stats.first, 5.0);
      expect(stats.latest, 5.0);
      expect(stats.minimum, 5.0);
      expect(stats.maximum, 5.0);
      expect(stats.average, 5.0);
      expect(stats.change, 0.0);
      expect(stats.percentageChange, 0.0);
    });

    test('first value is zero produces null percentage', () {
      final stats = MeasurementStatistics.compute([0.0, 10.0]);
      expect(stats.percentageChange, isNull);
      expect(stats.change, 10.0);
    });

    test('handles decimal precision', () {
      final stats = MeasurementStatistics.compute([1.1, 2.2, 3.3]);
      expect(stats.average, closeTo(2.2, 0.01));
      expect(stats.minimum, 1.1);
      expect(stats.maximum, 3.3);
    });

    test('preserves order for first/latest from original list', () {
      final stats = MeasurementStatistics.compute([30.0, 10.0, 20.0]);
      expect(stats.first, 30.0);
      expect(stats.latest, 20.0);
    });
  });

  group('ReadingStatusSummary', () {
    test('empty summary', () {
      const summary = ReadingStatusSummary.empty;
      expect(summary.total, 0);
      expect(summary.hasIrregularHeartbeat, isFalse);
    });

    test('total calculates correctly', () {
      const summary = ReadingStatusSummary(
        belowCount: 2,
        withinCount: 5,
        aboveCount: 1,
        unknownCount: 3,
        irregularHeartbeatCount: 1,
      );
      expect(summary.total, 11);
      expect(summary.hasIrregularHeartbeat, isTrue);
    });

    test('no irregular heartbeat when count is 0', () {
      const summary = ReadingStatusSummary(
        belowCount: 0,
        withinCount: 0,
        aboveCount: 0,
        unknownCount: 0,
      );
      expect(summary.hasIrregularHeartbeat, isFalse);
    });
  });

  group('MeasurementChartBuilder.buildSeries', () {
    test('empty data points returns empty series', () {
      final series = MeasurementChartBuilder.buildSeries(
        typeKey: 'pulse',
        dataPoints: [],
        fields: [_field(fieldKey: 'pulse', label: 'Pulse')],
      );
      expect(series, isEmpty);
    });

    test('empty fields returns empty series', () {
      final dp = MeasurementDataPoint(
        record: _record(id: 1, timestamp: DateTime(2026)),
        values: [_value(fieldKey: 'pulse', numericValue: 72, unit: 'bpm')],
      );
      final series = MeasurementChartBuilder.buildSeries(
        typeKey: 'pulse',
        dataPoints: [dp],
        fields: [],
      );
      expect(series, isEmpty);
    });

    test('single-value type creates one series', () {
      final now = DateTime(2026);
      final dp = MeasurementDataPoint(
        record: _record(id: 1, timestamp: now),
        values: [_value(fieldKey: 'pulse', numericValue: 72, unit: 'bpm')],
      );
      final series = MeasurementChartBuilder.buildSeries(
        typeKey: 'pulse',
        dataPoints: [dp],
        fields: [_field(fieldKey: 'pulse', label: 'Pulse')],
      );
      expect(series.length, 1);
      expect(series.first.fieldKey, 'pulse');
      expect(series.first.points.length, 1);
      expect(series.first.points.first.numericValue, 72.0);
    });

    test('points are ordered oldest-first', () {
      final t1 = DateTime(2026, 1, 1);
      final t2 = DateTime(2026, 1, 2);
      final t3 = DateTime(2026, 1, 3);

      final dp1 = MeasurementDataPoint(
        record: _record(id: 1, timestamp: t3),
        values: [_value(fieldKey: 'weight', numericValue: 80, unit: 'kg')],
      );
      final dp2 = MeasurementDataPoint(
        record: _record(id: 2, timestamp: t1),
        values: [_value(fieldKey: 'weight', numericValue: 78, unit: 'kg')],
      );
      final dp3 = MeasurementDataPoint(
        record: _record(id: 3, timestamp: t2),
        values: [_value(fieldKey: 'weight', numericValue: 79, unit: 'kg')],
      );

      final series = MeasurementChartBuilder.buildSeries(
        typeKey: 'weight',
        dataPoints: [dp1, dp2, dp3],
        fields: [_field(fieldKey: 'weight', label: 'Weight')],
      );

      expect(series.first.points[0].measuredAt, t1);
      expect(series.first.points[1].measuredAt, t2);
      expect(series.first.points[2].measuredAt, t3);
    });

    test('blood pressure creates 2-3 series', () {
      final dp = MeasurementDataPoint(
        record: _record(id: 1, timestamp: DateTime(2026)),
        values: [
          _value(fieldKey: 'systolic', numericValue: 120, unit: 'mmHg'),
          _value(fieldKey: 'diastolic', numericValue: 80, unit: 'mmHg'),
        ],
      );
      final series = MeasurementChartBuilder.buildSeries(
        typeKey: 'blood_pressure',
        dataPoints: [dp],
        fields: [
          _field(fieldKey: 'systolic', label: 'Systolic', displayOrder: 0),
          _field(fieldKey: 'diastolic', label: 'Diastolic', displayOrder: 1),
        ],
      );

      expect(series.length, 2);
      expect(series[0].fieldKey, 'systolic');
      expect(series[1].fieldKey, 'diastolic');
    });

    test('blood pressure with pulse creates 3 series', () {
      final dp = MeasurementDataPoint(
        record: _record(id: 1, timestamp: DateTime(2026)),
        values: [
          _value(fieldKey: 'systolic', numericValue: 120, unit: 'mmHg'),
          _value(fieldKey: 'diastolic', numericValue: 80, unit: 'mmHg'),
          _value(fieldKey: 'pulse', numericValue: 72, unit: 'bpm'),
        ],
      );
      final series = MeasurementChartBuilder.buildSeries(
        typeKey: 'blood_pressure',
        dataPoints: [dp],
        fields: [
          _field(fieldKey: 'systolic', label: 'Systolic', displayOrder: 0),
          _field(fieldKey: 'diastolic', label: 'Diastolic', displayOrder: 1),
          _field(fieldKey: 'pulse', label: 'Pulse', displayOrder: 2),
        ],
      );

      expect(series.length, 3);
      expect(series[2].fieldKey, 'pulse');
    });

    test('irregular heartbeat flag is preserved', () {
      final dp = MeasurementDataPoint(
        record: _record(
          id: 1,
          timestamp: DateTime(2026),
          irregularHeartbeat: true,
        ),
        values: [
          _value(fieldKey: 'systolic', numericValue: 120, unit: 'mmHg'),
          _value(fieldKey: 'diastolic', numericValue: 80, unit: 'mmHg'),
        ],
      );
      final series = MeasurementChartBuilder.buildSeries(
        typeKey: 'blood_pressure',
        dataPoints: [dp],
        fields: [
          _field(fieldKey: 'systolic', label: 'Systolic', displayOrder: 0),
          _field(fieldKey: 'diastolic', label: 'Diastolic', displayOrder: 1),
        ],
      );

      expect(series[0].points.first.irregularHeartbeatDetected, isTrue);
      expect(series[1].points.first.irregularHeartbeatDetected, isTrue);
    });

    test('null values in series are skipped', () {
      final dp = MeasurementDataPoint(
        record: _record(id: 1, timestamp: DateTime(2026)),
        values: [
          _value(fieldKey: 'systolic', numericValue: 120, unit: 'mmHg'),
          _value(fieldKey: 'diastolic', numericValue: 80, unit: 'mmHg'),
        ],
      );
      final series = MeasurementChartBuilder.buildSeries(
        typeKey: 'blood_pressure',
        dataPoints: [dp],
        fields: [
          _field(fieldKey: 'systolic', label: 'Systolic', displayOrder: 0),
          _field(fieldKey: 'diastolic', label: 'Diastolic', displayOrder: 1),
          _field(fieldKey: 'pulse', label: 'Pulse', displayOrder: 2),
        ],
      );

      // pulse series should not exist since no pulse values
      expect(series.length, 2);
    });

    test('custom type with multiple fields creates multiple series', () {
      final dp = MeasurementDataPoint(
        record: _record(id: 1, timestamp: DateTime(2026)),
        values: [
          _value(fieldKey: 'sleep_hours', numericValue: 7.5, unit: 'hours'),
          _value(fieldKey: 'quality', numericValue: 8, unit: 'score'),
        ],
      );
      final series = MeasurementChartBuilder.buildSeries(
        typeKey: 'custom_sleep',
        dataPoints: [dp],
        fields: [
          _field(fieldKey: 'sleep_hours', label: 'Sleep Hours', displayOrder: 0),
          _field(fieldKey: 'quality', label: 'Quality', displayOrder: 1),
        ],
      );

      expect(series.length, 2);
      expect(series[0].fieldKey, 'sleep_hours');
      expect(series[1].fieldKey, 'quality');
    });
  });

  group('MeasurementChartBuilder.computeFieldStatistics', () {
    test('computes statistics per series', () {
      final series = [
        MeasurementChartSeries(
          fieldKey: 'systolic',
          label: 'Systolic',
          unit: 'mmHg',
          points: [
            MeasurementChartPoint(
              recordId: 1,
              measuredAt: DateTime(2026, 1, 1),
              numericValue: 120,
              unit: 'mmHg',
              readingStatus: ReadingStatus.inRange,
            ),
            MeasurementChartPoint(
              recordId: 2,
              measuredAt: DateTime(2026, 1, 2),
              numericValue: 130,
              unit: 'mmHg',
              readingStatus: ReadingStatus.aboveRange,
            ),
          ],
        ),
      ];

      final stats = MeasurementChartBuilder.computeFieldStatistics(
        series: series,
      );

      expect(stats.containsKey('systolic'), isTrue);
      expect(stats['systolic']!.count, 2);
      expect(stats['systolic']!.minimum, 120.0);
      expect(stats['systolic']!.maximum, 130.0);
    });
  });

  group('MeasurementChartBuilder.computeStatusSummary', () {
    test('counts statuses correctly', () {
      final series = [
        MeasurementChartSeries(
          fieldKey: 'systolic',
          label: 'Systolic',
          unit: 'mmHg',
          points: [
            MeasurementChartPoint(
              recordId: 1,
              measuredAt: DateTime(2026),
              numericValue: 120,
              unit: 'mmHg',
              readingStatus: ReadingStatus.inRange,
            ),
            MeasurementChartPoint(
              recordId: 2,
              measuredAt: DateTime(2026),
              numericValue: 140,
              unit: 'mmHg',
              readingStatus: ReadingStatus.aboveRange,
            ),
            MeasurementChartPoint(
              recordId: 3,
              measuredAt: DateTime(2026),
              numericValue: 85,
              unit: 'mmHg',
              readingStatus: ReadingStatus.belowRange,
            ),
          ],
        ),
      ];

      final summary = MeasurementChartBuilder.computeStatusSummary(
        series: series,
      );

      expect(summary.withinCount, 1);
      expect(summary.aboveCount, 1);
      expect(summary.belowCount, 1);
      expect(summary.unknownCount, 0);
      expect(summary.irregularHeartbeatCount, 0);
    });

    test('counts irregular heartbeat correctly', () {
      final series = [
        MeasurementChartSeries(
          fieldKey: 'systolic',
          label: 'Systolic',
          unit: 'mmHg',
          points: [
            MeasurementChartPoint(
              recordId: 1,
              measuredAt: DateTime(2026),
              numericValue: 120,
              unit: 'mmHg',
              readingStatus: ReadingStatus.inRange,
              irregularHeartbeatDetected: true,
            ),
            MeasurementChartPoint(
              recordId: 2,
              measuredAt: DateTime(2026),
              numericValue: 130,
              unit: 'mmHg',
              readingStatus: ReadingStatus.aboveRange,
              irregularHeartbeatDetected: false,
            ),
          ],
        ),
      ];

      final summary = MeasurementChartBuilder.computeStatusSummary(
        series: series,
      );

      expect(summary.irregularHeartbeatCount, 1);
      expect(summary.total, 2);
    });

    test('does not double-count across series for same record', () {
      final series = [
        MeasurementChartSeries(
          fieldKey: 'systolic',
          label: 'Systolic',
          unit: 'mmHg',
          points: [
            MeasurementChartPoint(
              recordId: 1,
              measuredAt: DateTime(2026),
              numericValue: 120,
              unit: 'mmHg',
              readingStatus: ReadingStatus.inRange,
            ),
          ],
        ),
        MeasurementChartSeries(
          fieldKey: 'diastolic',
          label: 'Diastolic',
          unit: 'mmHg',
          points: [
            MeasurementChartPoint(
              recordId: 1,
              measuredAt: DateTime(2026),
              numericValue: 80,
              unit: 'mmHg',
              readingStatus: ReadingStatus.inRange,
            ),
          ],
        ),
      ];

      final summary = MeasurementChartBuilder.computeStatusSummary(
        series: series,
      );

      // Should count record 1 only once
      expect(summary.total, 1);
      expect(summary.withinCount, 1);
    });
  });
}
