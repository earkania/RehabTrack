import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/patient_profile_summary.dart';
import 'package:rehab_track/domain/entities/profile.dart';

Profile _testProfile({DateTime? birthDate}) {
  return Profile(
    id: 1,
    firstName: 'John',
    lastName: 'Doe',
    birthDate: birthDate,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

void main() {
  group('PatientProfileSummary', () {
    group('age', () {
      test('returns null when birthDate is null', () {
        final summary = PatientProfileSummary(profile: _testProfile());
        expect(summary.age, null);
      });

      test('calculates age correctly when birthday has passed this year', () {
        final now = DateTime.now();
        final birthDate = DateTime(now.year - 30, now.month - 1, now.day);
        final summary = PatientProfileSummary(
          profile: _testProfile(birthDate: birthDate),
        );
        expect(summary.age, 30);
      });

      test('calculates age correctly when birthday is today', () {
        final now = DateTime.now();
        final birthDate = DateTime(now.year - 25, now.month, now.day);
        final summary = PatientProfileSummary(
          profile: _testProfile(birthDate: birthDate),
        );
        expect(summary.age, 25);
      });

      test('subtracts one when birthday has not occurred yet this year', () {
        final now = DateTime.now();
        final birthDate = DateTime(now.year - 30, now.month + 1, now.day);
        final summary = PatientProfileSummary(
          profile: _testProfile(birthDate: birthDate),
        );
        expect(summary.age, 29);
      });
    });

    group('medicationAdherenceRate', () {
      test('returns 0 when no medications', () {
        final summary = PatientProfileSummary(
          profile: _testProfile(),
          completedMedicationsLast7Days: 0,
          missedMedicationsLast7Days: 0,
        );
        expect(summary.medicationAdherenceRate, 0);
      });

      test('returns 1.0 when all medications completed', () {
        final summary = PatientProfileSummary(
          profile: _testProfile(),
          completedMedicationsLast7Days: 10,
          missedMedicationsLast7Days: 0,
        );
        expect(summary.medicationAdherenceRate, 1.0);
      });

      test('returns 0.5 when half completed', () {
        final summary = PatientProfileSummary(
          profile: _testProfile(),
          completedMedicationsLast7Days: 5,
          missedMedicationsLast7Days: 5,
        );
        expect(summary.medicationAdherenceRate, 0.5);
      });

      test('returns correct fractional rate', () {
        final summary = PatientProfileSummary(
          profile: _testProfile(),
          completedMedicationsLast7Days: 1,
          missedMedicationsLast7Days: 3,
        );
        expect(summary.medicationAdherenceRate, closeTo(0.25, 0.001));
      });
    });

    group('copyWith', () {
      test('preserves all fields when no arguments provided', () {
        final now = DateTime.now();
        final profile = _testProfile();
        final summary = PatientProfileSummary(
          profile: profile,
          activeMedicationCount: 5,
          activeMeasurementScheduleCount: 3,
          totalMeasurementsLast30Days: 42,
          completedMedicationsLast7Days: 8,
          missedMedicationsLast7Days: 2,
          lastActivityDate: now,
        );

        final copy = summary.copyWith();
        expect(copy.profile, profile);
        expect(copy.activeMedicationCount, 5);
        expect(copy.activeMeasurementScheduleCount, 3);
        expect(copy.totalMeasurementsLast30Days, 42);
        expect(copy.completedMedicationsLast7Days, 8);
        expect(copy.missedMedicationsLast7Days, 2);
        expect(copy.lastActivityDate, now);
      });

      test('overrides specified fields', () {
        final summary = PatientProfileSummary(
          profile: _testProfile(),
          activeMedicationCount: 5,
        );

        final copy = summary.copyWith(activeMedicationCount: 10);
        expect(copy.activeMedicationCount, 10);
        expect(copy.profile.firstName, 'John');
      });
    });

    group('constructor defaults', () {
      test('defaults to zero counts', () {
        final summary = PatientProfileSummary(profile: _testProfile());
        expect(summary.activeMedicationCount, 0);
        expect(summary.activeMeasurementScheduleCount, 0);
        expect(summary.totalMeasurementsLast30Days, 0);
        expect(summary.completedMedicationsLast7Days, 0);
        expect(summary.missedMedicationsLast7Days, 0);
        expect(summary.lastActivityDate, null);
      });
    });
  });
}
