import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/presentation/utils/measurement_chart_axis.dart';

void main() {
  group('computeMeasurementChartAxis', () {
    void expectEvenlySpaced(MeasurementChartAxis axis) {
      for (var i = 1; i < axis.ticks.length; i++) {
        expect(
          (axis.ticks[i] - axis.ticks[i - 1] - axis.interval).abs(),
          lessThan(1e-9),
          reason: 'ticks must be evenly spaced by the interval',
        );
      }
    }

    test('blood pressure 54..132 produces the clean 40..140 scale', () {
      final axis = computeMeasurementChartAxis(values: [54, 132]);

      expect(axis.minY, 40);
      expect(axis.maxY, 140);
      expect(axis.interval, 20);
      expect(axis.decimals, 0);
      expect(axis.ticks, [40, 60, 80, 100, 120, 140]);
      expect(axis.format(40), '40');
      expect(axis.format(140), '140');
      expect(axis.format(axis.minY), isNot('42.3'));
      expect(axis.format(axis.maxY), isNot('143.7'));
    });

    test('full blood pressure series (58..131) also aligns to 40..140', () {
      final axis = computeMeasurementChartAxis(
        values: const [131, 110, 80, 70, 58, 70],
      );

      expect(axis.minY, 40);
      expect(axis.maxY, 140);
      expect(axis.interval, 20);
      expect(axis.ticks, [40, 60, 80, 100, 120, 140]);
      expect(axis.minY, lessThanOrEqualTo(58.0));
      expect(axis.maxY, greaterThanOrEqualTo(131.0));
    });

    test('integer-like range 80..141 produces clean integer ticks', () {
      final axis = computeMeasurementChartAxis(values: [80, 141]);

      expect(axis.minY, lessThanOrEqualTo(80.0));
      expect(axis.maxY, greaterThanOrEqualTo(141.0));
      expect(axis.decimals, 0);
      expect(axis.interval, 20);
      for (final tick in axis.ticks) {
        expect(tick, tick.roundToDouble(),
            reason: 'every tick of an integer-like range is an integer');
      }
      expect(axis.ticks, [60, 80, 100, 120, 140, 160]);
    });

    test('narrow integer range 118..126 gets a tight clean scale', () {
      final axis = computeMeasurementChartAxis(values: [118, 126]);

      expect(axis.minY, lessThanOrEqualTo(118.0));
      expect(axis.maxY, greaterThanOrEqualTo(126.0));
      expect(axis.interval, 2);
      expect(axis.ticks.length, inInclusiveRange(4, 7));
      expect(axis.decimals, 0);
      expectEvenlySpaced(axis);
    });

    test('small decimal range 36.4..37.2 keeps useful decimal ticks', () {
      final axis = computeMeasurementChartAxis(values: [36.4, 37.2]);

      expect(axis.minY, lessThanOrEqualTo(36.4));
      expect(axis.maxY, greaterThanOrEqualTo(37.2));
      expect(axis.decimals, greaterThanOrEqualTo(1));
      expect(axis.interval, lessThan(1.0));
      expect(axis.ticks.length, lessThanOrEqualTo(7));
      expectEvenlySpaced(axis);
      for (final tick in axis.ticks) {
        final label = axis.format(tick);
        expect(
          double.parse(label),
          closeTo(tick, 1e-6),
          reason: 'labels must round-trip without floating point artifacts',
        );
        expect(label, isNot(contains('99999')));
      }
      expect(axis.ticks, [36.2, 36.4, 36.6, 36.8, 37.0, 37.2, 37.4]);
    });

    test('weight-like decimal range 71.3..74.8 stays useful and clean', () {
      final axis = computeMeasurementChartAxis(values: [71.3, 74.8]);

      expect(axis.minY, lessThanOrEqualTo(71.3));
      expect(axis.maxY, greaterThanOrEqualTo(74.8));
      expect(axis.ticks.length, inInclusiveRange(4, 7));
      expectEvenlySpaced(axis);
      for (final tick in axis.ticks) {
        expect(double.parse(axis.format(tick)), closeTo(tick, 1e-6));
      }
    });

    test('single value 120 gets a non-zero sensible range', () {
      final axis = computeMeasurementChartAxis(values: [120]);

      expect(axis.minY, lessThan(120.0));
      expect(axis.maxY, greaterThan(120.0));
      expect(axis.interval, greaterThan(0));
      expect(axis.ticks.length, inInclusiveRange(4, 7));
      expect(axis.minY, lessThanOrEqualTo(120.0));
      expect(axis.maxY, greaterThanOrEqualTo(120.0));
      expect(axis.minY.isFinite, isTrue);
      expect(axis.maxY.isFinite, isTrue);
    });

    test('constant values 120,120,120 get a sensible range', () {
      final axis = computeMeasurementChartAxis(values: [120, 120, 120]);

      expect(axis.minY, lessThan(120.0));
      expect(axis.maxY, greaterThan(120.0));
      expect(axis.minY, isNot(axis.maxY));
      expect(axis.ticks.length, inInclusiveRange(4, 7));
      expectEvenlySpaced(axis);
    });

    test('zero-containing range 0..10 rounds outward', () {
      final axis = computeMeasurementChartAxis(values: [0, 10]);

      expect(axis.minY, lessThanOrEqualTo(0.0));
      expect(axis.maxY, greaterThanOrEqualTo(10.0));
      expect(axis.ticks.contains(0), isTrue);
      expect(axis.ticks.contains(10), isTrue);
      expect(axis.interval, greaterThan(0));
    });

    test('negative range -5..15 rounds outward', () {
      final axis = computeMeasurementChartAxis(values: [-5, 15]);

      expect(axis.minY, lessThanOrEqualTo(-5.0));
      expect(axis.maxY, greaterThanOrEqualTo(15.0));
      expect(axis.interval, greaterThan(0));
      expectEvenlySpaced(axis);
    });

    test('large range 1000..9000 keeps a sensible interval and tick count', () {
      final axis = computeMeasurementChartAxis(values: [1000, 9000]);

      expect(axis.minY, lessThanOrEqualTo(1000.0));
      expect(axis.maxY, greaterThanOrEqualTo(9000.0));
      expect(axis.ticks.length, inInclusiveRange(4, 7));
      expect(axis.interval, 2000);
      expectEvenlySpaced(axis);
    });

    test('no floating point artifacts are ever exposed', () {
      final axis = computeMeasurementChartAxis(values: const [118, 126]);

      for (final tick in axis.ticks) {
        expect(tick.toStringAsFixed(axis.decimals), axis.format(tick));
        expect(tick.toString(), isNot(contains('99999')));
        expect(tick.toString(), isNot(contains('000001')));
      }
    });
  });
}