import 'package:rehab_track/domain/entities/doctor_prescription.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/domain/entities/schedule_config.dart';
import 'package:rehab_track/l10n/app_localizations.dart';

/// Builds a [DoctorPrescriptionMedication] draft from an existing [Medication].
///
/// The selected [Medication] is only ever a *source* of snapshot values: the
/// returned draft carries plain copied strings and never references the active
/// Medication record. Later edits, deactivation or deletion of the source
/// Medication therefore cannot affect the prescription entry.
class PrescriptionMedicationPrefillMapper {
  PrescriptionMedicationPrefillMapper._();

  /// Maps a [Medication] (and optionally its [MedicationSchedule]) onto a
  /// prescription medication draft.
  ///
  /// Only fields with a clear equivalent are copied:
  ///   Medication.name                  -> medicationName
  ///   Medication.doseAmount            -> doseAmount
  ///   Medication.doseUnit              -> doseUnit
  ///   Medication.notes                 -> notes
  ///   MedicationSchedule.instructions  -> instructions
  ///   MedicationSchedule cadence/times -> frequency / timing
  ///
  /// [l10n] is optional: when null a non-localized English cadence summary is
  /// produced so the mapper remains unit-testable without a locale scope.
  static DoctorPrescriptionMedication map(
    Medication medication, {
    MedicationSchedule? schedule,
    required int prescriptionId,
    required int profileId,
    AppLocalizations? l10n,
  }) {
    final now = DateTime.now();
    return DoctorPrescriptionMedication(
      id: null,
      prescriptionId: prescriptionId,
      profileId: profileId,
      medicationName: medication.name,
      doseAmount: _normalize(medication.doseAmount),
      doseUnit: _normalize(medication.doseUnit),
      frequency: _scheduleSummary(schedule, l10n),
      timing: _times(schedule),
      instructions: _normalize(schedule?.instructions),
      duration: null,
      notes: _normalize(medication.notes),
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  static String? _normalize(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  /// A short human-readable cadence summary (e.g. "Daily at 08:00, 20:00").
  static String? _scheduleSummary(
      MedicationSchedule? schedule, AppLocalizations? l10n) {
    if (schedule == null) return null;
    final config = schedule.scheduleConfig;
    final times = config.times.join(', ');
    return switch (config) {
      DailySchedule() => l10n == null
          ? 'Daily at $times'
          : l10n.dailyAt(times),
      IntervalDaysSchedule(:final intervalDays) => l10n == null
          ? 'Every $intervalDays days at $times'
          : l10n.everyNDays(intervalDays, times),
    };
  }

  /// Comma separated dosing times (e.g. "08:00, 20:00").
  static String? _times(MedicationSchedule? schedule) {
    if (schedule == null) return null;
    final times = schedule.scheduleConfig.times;
    return times.isEmpty ? null : times.join(', ');
  }
}