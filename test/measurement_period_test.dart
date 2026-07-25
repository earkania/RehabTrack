import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/measurement_period.dart';

void main() {
  group('MeasurementPeriod', () {
    group('last7Days', () {
      test('from is 7 days ago', () {
        final now = DateTime.now();
        final from = MeasurementPeriod.last7Days.from;
        expect(from, isNotNull);
        final diff = now.difference(from!);
        expect(diff.inDays, closeTo(7, 1));
      });
    });

    group('last30Days', () {
      test('from is 30 days ago', () {
        final now = DateTime.now();
        final from = MeasurementPeriod.last30Days.from;
        expect(from, isNotNull);
        final diff = now.difference(from!);
        expect(diff.inDays, closeTo(30, 1));
      });
    });

    group('last90Days', () {
      test('from is 90 days ago', () {
        final now = DateTime.now();
        final from = MeasurementPeriod.last90Days.from;
        expect(from, isNotNull);
        final diff = now.difference(from!);
        expect(diff.inDays, closeTo(90, 1));
      });
    });

    group('allTime', () {
      test('from is null', () {
        expect(MeasurementPeriod.allTime.from, isNull);
      });
    });

    group('enum values', () {
      test('has 4 values', () {
        expect(MeasurementPeriod.values.length, 4);
      });

      test('last7Days from is before last30Days from', () {
        expect(
          MeasurementPeriod.last7Days.from!.isAfter(
            MeasurementPeriod.last30Days.from!,
          ),
          isTrue,
        );
      });

      test('last30Days from is before last90Days from', () {
        expect(
          MeasurementPeriod.last30Days.from!.isAfter(
            MeasurementPeriod.last90Days.from!,
          ),
          isTrue,
        );
      });
    });
  });
}
