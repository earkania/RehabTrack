import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/services/bmi.dart';

void main() {
  group('calculateBmi', () {
    test('170 cm and 70 kg → approximately 24.2', () {
      final bmi = calculateBmi(heightCm: 170, weightKg: 70);
      expect(bmi, isNotNull);
      expect(bmi!, closeTo(70 / (1.70 * 1.70), 0.01));
      expect(formatBmi(bmi), '24.2');
    });

    test('180 cm and 81 kg → 25.0', () {
      final bmi = calculateBmi(heightCm: 180, weightKg: 81);
      expect(bmi, isNotNull);
      expect(bmi!, closeTo(81 / (1.8 * 1.8), 0.01));
      expect(formatBmi(bmi), '25.0');
    });

    test('160 cm and 64 kg → 25.0', () {
      final bmi = calculateBmi(heightCm: 160, weightKg: 64);
      expect(bmi, isNotNull);
      expect(bmi!, closeTo(64 / (1.6 * 1.6), 0.01));
      expect(formatBmi(bmi), '25.0');
    });

    test('returns null when height is missing', () {
      expect(calculateBmi(heightCm: null, weightKg: 70), isNull);
    });

    test('returns null when weight is missing', () {
      expect(calculateBmi(heightCm: 170, weightKg: null), isNull);
    });

    test('returns null when height is zero', () {
      expect(calculateBmi(heightCm: 0, weightKg: 70), isNull);
    });

    test('returns null when weight is zero', () {
      expect(calculateBmi(heightCm: 170, weightKg: 0), isNull);
    });

    test('returns null when height is negative', () {
      expect(calculateBmi(heightCm: -170, weightKg: 70), isNull);
    });

    test('returns null when weight is negative', () {
      expect(calculateBmi(heightCm: 170, weightKg: -70), isNull);
    });

    test('returns null for non-finite values', () {
      expect(calculateBmi(heightCm: double.nan, weightKg: 70), isNull);
      expect(
        calculateBmi(heightCm: double.infinity, weightKg: 70),
        isNull,
      );
      expect(calculateBmi(heightCm: 170, weightKg: double.nan), isNull);
      expect(
        calculateBmi(heightCm: 170, weightKg: double.infinity),
        isNull,
      );
    });
  });

  group('formatBmi', () {
    test('uses one decimal place', () {
      expect(formatBmi(18.53), '18.5');
      expect(formatBmi(24.96), '25.0');
      expect(formatBmi(31.04), '31.0');
    });
  });
}
