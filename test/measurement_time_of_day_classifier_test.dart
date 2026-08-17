import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/measurement_data_point.dart';
import 'package:rehab_track/domain/entities/measurement_statistics.dart';
import 'package:rehab_track/domain/entities/measurement_time_of_day_filter.dart';
import 'package:rehab_track/domain/services/measurement_chart_builder.dart';
import 'package:rehab_track/domain/services/measurement_time_of_day_classifier.dart';
import 'package:rehab_track/presentation/utils/measurement_chart_axis.dart';

MeasurementRecord _record({required int id, required DateTime timestamp}) {
  return MeasurementRecord(
    id: id,
    profileId: 1,
    measurementTypeId: 1,
    timestamp: timestamp,
    valuePrimary: 0,
    unit: 'kg',
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

/// A single-value (generic) measurement data point.
MeasurementDataPoint _point({
  required int id,
  required DateTime timestamp,
  required double value,
}) {
  return MeasurementDataPoint(
    record: _record(id: id, timestamp: timestamp),
    values: [
      _value(fieldKey: 'weight', numericValue: value, unit: 'kg'),
    ],
  );
}

/// A blood-pressure data point with all three components.
MeasurementDataPoint _bpPoint({
  required int id,
  required DateTime timestamp,
  required double systolic,
  required double diastolic,
  required double pulse,
}) {
  return MeasurementDataPoint(
    record: _record(id: id, timestamp: timestamp),
    values: [
      _value(fieldKey: 'systolic', numericValue: systolic, unit: 'mmHg'),
      _value(fieldKey: 'diastolic', numericValue: diastolic, unit: 'mmHg'),
      _value(fieldKey: 'pulse', numericValue: pulse, unit: 'bpm'),
    ],
  );
}

List<MeasurementTypeField> _bpFields() {
  final t = DateTime(2026);
  return [
    MeasurementTypeField(
      measurementTypeId: 1,
      fieldKey: 'systolic',
      label: 'Systolic',
      createdAt: t,
      displayOrder: 0,
    ),
    MeasurementTypeField(
      measurementTypeId: 1,
      fieldKey: 'diastolic',
      label: 'Diastolic',
      createdAt: t,
      displayOrder: 1,
    ),
    MeasurementTypeField(
      measurementTypeId: 1,
      fieldKey: 'pulse',
      label: 'Pulse',
      createdAt: t,
      displayOrder: 2,
    ),
  ];
}

void main() {
  group('classify / matches boundaries', () {
    DateTime time(int hour, int minute) => DateTime(2026, 8, 17, hour, minute);

    group('Morning (06:00 .. 12:00)', () {
      final cases = <(int, int, bool)>[
        (5, 59, false),
        (6, 0, true),
        (8, 0, true),
        (11, 59, true),
        (12, 0, false),
      ];
      for (final (hour, minute, expected) in cases) {
        test('${hour.toString().padLeft(2, '0')}:'
            '${minute.toString().padLeft(2, '0')} -> $expected', () {
          expect(
            MeasurementTimeOfDayClassifier.matches(
              time(hour, minute),
              MeasurementTimeOfDayFilter.morning,
            ),
            expected,
          );
        });
      }
    });

    group('Midday (12:00 .. 17:00)', () {
      final cases = <(int, int, bool)>[
        (11, 59, false),
        (12, 0, true),
        (13, 0, true),
        (16, 59, true),
        (17, 0, false),
      ];
      for (final (hour, minute, expected) in cases) {
        test('${hour.toString().padLeft(2, '0')}:'
            '${minute.toString().padLeft(2, '0')} -> $expected', () {
          expect(
            MeasurementTimeOfDayClassifier.matches(
              time(hour, minute),
              MeasurementTimeOfDayFilter.midday,
            ),
            expected,
          );
        });
      }
    });

    group('Evening (17:00 .. 22:00)', () {
      final cases = <(int, int, bool)>[
        (16, 59, false),
        (17, 0, true),
        (19, 0, true),
        (21, 59, true),
        (22, 0, false),
      ];
      for (final (hour, minute, expected) in cases) {
        test('${hour.toString().padLeft(2, '0')}:'
            '${minute.toString().padLeft(2, '0')} -> $expected', () {
          expect(
            MeasurementTimeOfDayClassifier.matches(
              time(hour, minute),
              MeasurementTimeOfDayFilter.evening,
            ),
            expected,
          );
        });
      }
    });

    group('Night (22:00 .. 06:00, wraps midnight)', () {
      final cases = <(int, int, bool)>[
        (21, 59, false),
        (22, 0, true),
        (23, 0, true),
        (23, 59, true),
        (0, 0, true),
        (1, 30, true),
        (5, 59, true),
        (6, 0, false),
      ];
      for (final (hour, minute, expected) in cases) {
        test('${hour.toString().padLeft(2, '0')}:'
            '${minute.toString().padLeft(2, '0')} -> $expected', () {
          expect(
            MeasurementTimeOfDayClassifier.matches(
              time(hour, minute),
              MeasurementTimeOfDayFilter.night,
            ),
            expected,
          );
        });
      }
    });

    test('All matches every valid reading', () {
      for (final hour in [0, 5, 6, 11, 12, 16, 17, 21, 22, 23]) {
        for (final minute in [0, 30, 59]) {
          expect(
            MeasurementTimeOfDayClassifier.matches(
              time(hour, minute),
              MeasurementTimeOfDayFilter.all,
            ),
            isTrue,
          );
        }
      }
    });

    test('classify returns the expected filter for each boundary', () {
      expect(
        MeasurementTimeOfDayClassifier.classify(time(6, 0)),
        MeasurementTimeOfDayFilter.morning,
      );
      expect(
        MeasurementTimeOfDayClassifier.classify(time(11, 59)),
        MeasurementTimeOfDayFilter.morning,
      );
      expect(
        MeasurementTimeOfDayClassifier.classify(time(12, 0)),
        MeasurementTimeOfDayFilter.midday,
      );
      expect(
        MeasurementTimeOfDayClassifier.classify(time(16, 59)),
        MeasurementTimeOfDayFilter.midday,
      );
      expect(
        MeasurementTimeOfDayClassifier.classify(time(17, 0)),
        MeasurementTimeOfDayFilter.evening,
      );
      expect(
        MeasurementTimeOfDayClassifier.classify(time(21, 59)),
        MeasurementTimeOfDayFilter.evening,
      );
      expect(
        MeasurementTimeOfDayClassifier.classify(time(22, 0)),
        MeasurementTimeOfDayFilter.night,
      );
      expect(
        MeasurementTimeOfDayClassifier.classify(time(0, 0)),
        MeasurementTimeOfDayFilter.night,
      );
      expect(
        MeasurementTimeOfDayClassifier.classify(time(5, 59)),
        MeasurementTimeOfDayFilter.night,
      );
    });
  });

  group('timezone / local-time classification', () {
    test('classifies by local wall clock, not UTC components', () {
      // 23:00 on the device's local clock.
      final localNight = DateTime(2026, 8, 17, 23, 0);
      // The exact same instant persisted as a UTC-marked timestamp, as Drift
      // may return a UTC value even though the app stores local wall clocks.
      final utcStored = DateTime.fromMicrosecondsSinceEpoch(
        localNight.microsecondsSinceEpoch,
        isUtc: true,
      );
      expect(utcStored.isUtc, isTrue);
      // Regardless of the machine's zone, .toLocal() recovers the 23:00 clock.
      expect(utcStored.toLocal().hour, 23);
      expect(
        MeasurementTimeOfDayClassifier.classify(utcStored),
        MeasurementTimeOfDayFilter.night,
      );
      expect(
        MeasurementTimeOfDayClassifier.matches(
          utcStored,
          MeasurementTimeOfDayFilter.night,
        ),
        isTrue,
      );
    });

    test('an early-morning local 06:00 stored as UTC is Morning', () {
      final localMorning = DateTime(2026, 8, 17, 6, 0);
      final utcStored = DateTime.fromMicrosecondsSinceEpoch(
        localMorning.microsecondsSinceEpoch,
        isUtc: true,
      );
      expect(
        MeasurementTimeOfDayClassifier.classify(utcStored),
        MeasurementTimeOfDayFilter.morning,
      );
    });

    test('a local DateTime is classified by its own components (no offset)', () {
      expect(
        MeasurementTimeOfDayClassifier.classify(DateTime(2026, 8, 17, 23, 0)),
        MeasurementTimeOfDayFilter.night,
      );
      expect(
        MeasurementTimeOfDayClassifier.classify(DateTime(2026, 8, 17, 8, 0)),
        MeasurementTimeOfDayFilter.morning,
      );
    });
  });

  group('filterDataPoints', () {
    final now = DateTime(2026, 8, 17, 12, 0);

    // The example dataset from the task (ten readings across two days). Day 1
    // is the earlier of the two so the filtered output stays chronological.
    List<MeasurementDataPoint> dataset() {
      final day1 = now.subtract(const Duration(days: 2));
      final day2 = now.subtract(const Duration(days: 1));
      return [
        _point(id: 1, timestamp: DateTime(day1.year, day1.month, day1.day, 5, 30), value: 110),
        _point(id: 2, timestamp: DateTime(day1.year, day1.month, day1.day, 8, 0), value: 118),
        _point(id: 3, timestamp: DateTime(day1.year, day1.month, day1.day, 13, 0), value: 125),
        _point(id: 4, timestamp: DateTime(day1.year, day1.month, day1.day, 19, 0), value: 135),
        _point(id: 5, timestamp: DateTime(day1.year, day1.month, day1.day, 23, 0), value: 128),
        _point(id: 6, timestamp: DateTime(day2.year, day2.month, day2.day, 1, 30), value: 126),
        _point(id: 7, timestamp: DateTime(day2.year, day2.month, day2.day, 8, 30), value: 116),
        _point(id: 8, timestamp: DateTime(day2.year, day2.month, day2.day, 13, 30), value: 127),
        _point(id: 9, timestamp: DateTime(day2.year, day2.month, day2.day, 20, 0), value: 138),
        _point(id: 10, timestamp: DateTime(day2.year, day2.month, day2.day, 23, 15), value: 129),
      ];
    }

    List<int> ids(List<MeasurementDataPoint> points) =>
        points.map((p) => p.record.id!).toList();

    final from7 = now.subtract(const Duration(days: 7));

    test('All returns every reading (respecting the date range)', () {
      final result = MeasurementTimeOfDayClassifier.filterDataPoints(
        dataPoints: dataset(),
        timeOfDay: MeasurementTimeOfDayFilter.all,
        from: from7,
      );
      expect(result.length, 10);
      expect(ids(result), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    });

    test('Morning keeps only 06:00-11:59 readings in chronological order', () {
      final result = MeasurementTimeOfDayClassifier.filterDataPoints(
        dataPoints: dataset(),
        timeOfDay: MeasurementTimeOfDayFilter.morning,
        from: from7,
      );
      expect(ids(result), [2, 7]);
      expect(result.map((p) => p.record.timestamp.hour).toList(), [8, 8]);
    });

    test('Midday keeps only 12:00-16:59 readings', () {
      final result = MeasurementTimeOfDayClassifier.filterDataPoints(
        dataPoints: dataset(),
        timeOfDay: MeasurementTimeOfDayFilter.midday,
        from: from7,
      );
      expect(ids(result), [3, 8]);
    });

    test('Evening keeps only 17:00-21:59 readings', () {
      final result = MeasurementTimeOfDayClassifier.filterDataPoints(
        dataPoints: dataset(),
        timeOfDay: MeasurementTimeOfDayFilter.evening,
        from: from7,
      );
      expect(ids(result), [4, 9]);
    });

    test('Night keeps 22:00-23:59 and 00:00-05:59, in real chronological order',
        () {
      final result = MeasurementTimeOfDayClassifier.filterDataPoints(
        dataPoints: dataset(),
        timeOfDay: MeasurementTimeOfDayFilter.night,
        from: from7,
      );
      // The 05:30 (early morning, after midnight on day1) is Night, as are the
      // two pre-midnight readings and the 01:30 (after midnight on day2).
      expect(ids(result), [1, 5, 6, 10]);
      // Real timestamps stay chronologically ordered, not "synthetic night dates".
      final timestamps =
          result.map((p) => p.record.timestamp).toList();
      for (var i = 1; i < timestamps.length; i++) {
        expect(
          timestamps[i].isBefore(timestamps[i - 1]),
          isFalse,
          reason: 'Night readings must stay in chronological order',
        );
      }
    });

    test('combines date range and time-of-day (Last 30 days + Night)', () {
      final now = DateTime(2026, 8, 17, 12, 0);
      final from30 = now.subtract(const Duration(days: 30));

      final data = [
        // Within the last 30 days.
        _point(id: 1, timestamp: DateTime(2026, 8, 10, 23, 0), value: 128),
        _point(id: 2, timestamp: DateTime(2026, 8, 15, 5, 30), value: 110),
        // Older than 30 days.
        _point(id: 3, timestamp: DateTime(2026, 6, 20, 23, 0), value: 140),
        _point(id: 4, timestamp: DateTime(2026, 6, 20, 5, 30), value: 120),
        // Within 30 days but wrong time of day.
        _point(id: 5, timestamp: DateTime(2026, 8, 12, 8, 0), value: 118),
      ];

      final night30 = MeasurementTimeOfDayClassifier.filterDataPoints(
        dataPoints: data,
        timeOfDay: MeasurementTimeOfDayFilter.night,
        from: from30,
      );
      expect(ids(night30), [1, 2]);

      // All time + Night restores all historical night readings.
      final nightAll = MeasurementTimeOfDayClassifier.filterDataPoints(
        dataPoints: data,
        timeOfDay: MeasurementTimeOfDayFilter.night,
      );
      expect(ids(nightAll), [1, 2, 3, 4]);
    });

    test('does not average same-day readings: every point survives', () {
      final result = MeasurementTimeOfDayClassifier.filterDataPoints(
        dataPoints: [
          _point(id: 1, timestamp: DateTime(2026, 8, 10, 8, 0), value: 118),
          _point(id: 2, timestamp: DateTime(2026, 8, 10, 10, 30), value: 120),
        ],
        timeOfDay: MeasurementTimeOfDayFilter.morning,
      );
      expect(result.length, 2);
    });
  });

  group('statistics follow the filtered dataset', () {
    final now = DateTime(2026, 8, 17, 12, 0);

    List<MeasurementDataPoint> dataset() {
      final day1 = now.subtract(const Duration(days: 2));
      final day2 = now.subtract(const Duration(days: 1));
      return [
        _bpPoint(id: 1, timestamp: DateTime(day1.year, day1.month, day1.day, 5, 30), systolic: 110, diastolic: 75, pulse: 60),
        _bpPoint(id: 2, timestamp: DateTime(day1.year, day1.month, day1.day, 8, 0), systolic: 118, diastolic: 80, pulse: 65),
        _bpPoint(id: 3, timestamp: DateTime(day1.year, day1.month, day1.day, 13, 0), systolic: 125, diastolic: 82, pulse: 70),
        _bpPoint(id: 4, timestamp: DateTime(day1.year, day1.month, day1.day, 19, 0), systolic: 135, diastolic: 88, pulse: 74),
        _bpPoint(id: 5, timestamp: DateTime(day1.year, day1.month, day1.day, 23, 0), systolic: 128, diastolic: 84, pulse: 72),
        _bpPoint(id: 6, timestamp: DateTime(day2.year, day2.month, day2.day, 1, 30), systolic: 126, diastolic: 80, pulse: 68),
        _bpPoint(id: 7, timestamp: DateTime(day2.year, day2.month, day2.day, 8, 30), systolic: 116, diastolic: 78, pulse: 66),
        _bpPoint(id: 8, timestamp: DateTime(day2.year, day2.month, day2.day, 13, 30), systolic: 127, diastolic: 83, pulse: 71),
        _bpPoint(id: 9, timestamp: DateTime(day2.year, day2.month, day2.day, 20, 0), systolic: 138, diastolic: 90, pulse: 76),
        _bpPoint(id: 10, timestamp: DateTime(day2.year, day2.month, day2.day, 23, 15), systolic: 129, diastolic: 85, pulse: 73),
      ];
    }

    Map<String, MeasurementStatistics> statsFor(
      MeasurementTimeOfDayFilter filter,
    ) {
      final filtered = MeasurementTimeOfDayClassifier.filterDataPoints(
        dataPoints: dataset(),
        timeOfDay: filter,
      );
      final series = MeasurementChartBuilder.buildSeries(
        typeKey: 'blood_pressure',
        dataPoints: filtered,
        fields: _bpFields(),
      );
      return MeasurementChartBuilder.computeFieldStatistics(series: series);
    }

    test('Morning systolic statistics match the visible morning readings', () {
      final stats = statsFor(MeasurementTimeOfDayFilter.morning);
      final systolic = stats['systolic']!;
      expect(systolic.count, 2);
      expect(systolic.minimum, 116);
      expect(systolic.maximum, 118);
      expect(systolic.average, 117);
    });

    test('Night diastolic statistics match the visible night readings', () {
      final stats = statsFor(MeasurementTimeOfDayFilter.night);
      final diastolic = stats['diastolic']!;
      expect(diastolic.count, 4);
      expect(diastolic.minimum, 75);
      expect(diastolic.maximum, 85);
    });

    test('All time statistics cover every reading', () {
      final stats = statsFor(MeasurementTimeOfDayFilter.all);
      final systolic = stats['systolic']!;
      expect(systolic.count, 10);
      expect(systolic.minimum, 110);
      expect(systolic.maximum, 138);
    });

    test('every component is derived from the same filtered dataset', () {
      final filtered = MeasurementTimeOfDayClassifier.filterDataPoints(
        dataPoints: dataset(),
        timeOfDay: MeasurementTimeOfDayFilter.evening,
      );
      final series = MeasurementChartBuilder.buildSeries(
        typeKey: 'blood_pressure',
        dataPoints: filtered,
        fields: _bpFields(),
      );
      // Two evening readings are plotted for systolic, diastolic and pulse.
      for (final s in series) {
        expect(s.points.length, 2);
      }
    });
  });

  group('Y-axis rescales to the filtered dataset', () {
    test('hidden night values do not expand the morning scale', () {
      final now = DateTime(2026, 8, 17, 12, 0);
      final day = now.subtract(const Duration(days: 1));
      final data = <MeasurementDataPoint>[
        for (final (i, v) in [110, 115, 120].indexed)
          _bpPoint(
            id: i + 1,
            timestamp: DateTime(day.year, day.month, day.day, 8, 0),
            systolic: v.toDouble(),
            diastolic: 75,
            pulse: 60,
          ),
        for (final (i, v) in [150, 155, 160].indexed)
          _bpPoint(
            id: 10 + i + 1,
            timestamp: DateTime(day.year, day.month, day.day, 23, 0),
            systolic: v.toDouble(),
            diastolic: 85,
            pulse: 72,
          ),
      ];

      final morning = MeasurementTimeOfDayClassifier.filterDataPoints(
        dataPoints: data,
        timeOfDay: MeasurementTimeOfDayFilter.morning,
      );
      final morningSeries = MeasurementChartBuilder.buildSeries(
        typeKey: 'blood_pressure',
        dataPoints: morning,
        fields: _bpFields(),
      );
      final systolic = morningSeries
          .firstWhere((s) => s.fieldKey == 'systolic');
      final axis = computeMeasurementChartAxis(
        values: systolic.points.map((p) => p.numericValue.toDouble()).toList(),
      );

      // Bounds come from the morning values only.
      expect(axis.maxY, lessThan(160));
      expect(axis.minY, lessThanOrEqualTo(110));
      // Clean human-friendly ticks: integer labels, evenly spaced on the
      // chosen interval, no duplicated/overlapping ticks.
      expect(axis.decimals, 0);
      expect(axis.interval % 1, 0);
      final seen = <double>{};
      for (final tick in axis.ticks) {
        expect(tick % axis.interval == 0, isTrue,
            reason: 'tick $tick should sit on the ${axis.interval} interval');
        expect(seen.add(tick), isTrue, reason: 'duplicate tick $tick');
      }
    });

    test('with All, the axis expands to include the night value', () {
      final now = DateTime(2026, 8, 17, 12, 0);
      final day = now.subtract(const Duration(days: 1));
      final data = [
        _bpPoint(id: 1, timestamp: DateTime(day.year, day.month, day.day, 8, 0), systolic: 110, diastolic: 75, pulse: 60),
        _bpPoint(id: 2, timestamp: DateTime(day.year, day.month, day.day, 23, 0), systolic: 160, diastolic: 85, pulse: 72),
      ];
      final series = MeasurementChartBuilder.buildSeries(
        typeKey: 'blood_pressure',
        dataPoints: data,
        fields: _bpFields(),
      );
      final systolic = series.firstWhere((s) => s.fieldKey == 'systolic');
      final axis = computeMeasurementChartAxis(
        values: systolic.points.map((p) => p.numericValue.toDouble()).toList(),
      );
      expect(axis.maxY, greaterThanOrEqualTo(160));
    });
  });
}