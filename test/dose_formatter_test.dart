import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/presentation/utils/dose_formatter.dart';

void main() {
  group('DoseFormatter', () {
    test('formats dose with amount and unit', () {
      final medication = Medication(
        id: 1,
        profileId: 1,
        name: 'Aspirin',
        doseAmount: '100',
        doseUnit: 'mg',
        active: true,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      expect(DoseFormatter.format(medication), '100 mg');
    });

    test('formats dose with amount only', () {
      final medication = Medication(
        id: 1,
        profileId: 1,
        name: 'Aspirin',
        doseAmount: '2',
        active: true,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      expect(DoseFormatter.format(medication), '2');
    });

    test('formats dose with unit only', () {
      final medication = Medication(
        id: 1,
        profileId: 1,
        name: 'Aspirin',
        doseUnit: 'tablets',
        active: true,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      expect(DoseFormatter.format(medication), 'tablets');
    });

    test('returns empty string when no dose info', () {
      final medication = Medication(
        id: 1,
        profileId: 1,
        name: 'Aspirin',
        active: true,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      expect(DoseFormatter.format(medication), '');
    });

    test('returns empty string when dose fields are empty strings', () {
      final medication = Medication(
        id: 1,
        profileId: 1,
        name: 'Aspirin',
        doseAmount: '',
        doseUnit: '',
        active: true,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      expect(DoseFormatter.format(medication), '');
    });
  });
}
