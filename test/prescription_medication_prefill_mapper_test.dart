import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/dosage_form.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/domain/entities/schedule_config.dart';
import 'package:rehab_track/domain/mapping/prescription_medication_prefill_mapper.dart';

void main() {
  final now = DateTime(2026, 1, 1);

  Medication medication({String? notes}) => Medication(
        id: 7,
        profileId: 3,
        name: 'Clopidogrel',
        doseAmount: '75',
        doseUnit: 'mg',
        notes: notes,
        active: true,
        createdAt: now,
        updatedAt: now,
      );

  MedicationSchedule dailySchedule({String? instructions}) =>
      MedicationSchedule(
        id: 1,
        medicationId: 7,
        scheduleType: 'daily',
        scheduleConfig: DailySchedule(times: const ['08:00']),
        intakeQuantity: 1,
        dosageForm: DosageForm.tablet,
        instructions: instructions,
        active: true,
      );

  test('maps name, dose, notes and schedule into a fresh snapshot', () {
    final draft = PrescriptionMedicationPrefillMapper.map(
      medication(notes: 'With food'),
      schedule: dailySchedule(instructions: 'After breakfast'),
      prescriptionId: 1,
      profileId: 3,
    );

    expect(draft.id, isNull);
    expect(draft.prescriptionId, 1);
    expect(draft.profileId, 3);
    expect(draft.medicationName, 'Clopidogrel');
    expect(draft.doseAmount, '75');
    expect(draft.doseUnit, 'mg');
    expect(draft.instructions, 'After breakfast');
    expect(draft.notes, 'With food');
    expect(draft.frequency, 'Daily at 08:00');
    expect(draft.timing, '08:00');
  });

  test('maps interval schedule to every-N-days summary', () {
    final draft = PrescriptionMedicationPrefillMapper.map(
      medication(),
      schedule: MedicationSchedule(
        id: 2,
        medicationId: 7,
        scheduleType: 'interval_days',
        scheduleConfig:
            IntervalDaysSchedule(intervalDays: 2, times: const ['20:00']),
        intakeQuantity: 1,
        dosageForm: DosageForm.tablet,
        active: true,
      ),
      prescriptionId: 1,
      profileId: 3,
    );

    expect(draft.frequency, 'Every 2 days at 20:00');
    expect(draft.timing, '20:00');
  });

  test('omits schedule fields when no schedule is supplied', () {
    final draft = PrescriptionMedicationPrefillMapper.map(
      medication(),
      prescriptionId: 1,
      profileId: 3,
    );

    expect(draft.frequency, isNull);
    expect(draft.timing, isNull);
    expect(draft.instructions, isNull);
  });

  test('snapshot is independent of the source medication entity', () {
    final source = medication(notes: 'Initial');
    final draft = PrescriptionMedicationPrefillMapper.map(
      source,
      schedule: dailySchedule(),
      prescriptionId: 1,
      profileId: 3,
    );
    final renamed = source.copyWith(name: 'Renamed', notes: 'Changed');

    expect(draft.medicationName, 'Clopidogrel');
    expect(draft.notes, 'Initial');
    expect(draft.medicationName, isNot(renamed.name));
    expect(draft.notes, isNot(renamed.notes));
  });

  test('trims and normalizes blank values to null', () {
    final draft = PrescriptionMedicationPrefillMapper.map(
      medication(notes: '   '),
      schedule: dailySchedule(instructions: '  '),
      prescriptionId: 1,
      profileId: 3,
    );

    expect(draft.notes, isNull);
    expect(draft.instructions, isNull);
  });
}