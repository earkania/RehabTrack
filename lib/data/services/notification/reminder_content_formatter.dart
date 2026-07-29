import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/domain/entities/profile.dart';
import 'package:rehab_track/presentation/utils/dose_formatter.dart';

class ReminderContentFormatter {
  ReminderContentFormatter._();

  static String medicationTitle({
    required Profile? profile,
    required Medication medication,
  }) {
    if (profile != null && profile.fullName.isNotEmpty) {
      return medication.name;
    }
    return medication.name;
  }

  static String medicationBody({
    required Profile? profile,
    required Medication medication,
    required MedicationSchedule schedule,
    required DateTime scheduledTime,
  }) {
    final parts = <String>[];

    if (profile != null && profile.fullName.isNotEmpty) {
      parts.add(profile.fullName);
    }

    final dose = DoseFormatter.format(medication);
    if (dose.isNotEmpty) parts.add(dose);

    final intakeText = _formatIntakeQuantity(schedule);
    if (intakeText.isNotEmpty) parts.add(intakeText);

    if (schedule.instructions != null &&
        schedule.instructions!.isNotEmpty) {
      parts.add(schedule.instructions!);
    }

    final timeStr =
        '${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}';
    parts.add('Scheduled for $timeStr');

    return parts.join(' \u2014 ');
  }

  static String measurementTitle({
    required Profile? profile,
    required MeasurementType type,
  }) {
    return type.name;
  }

  static String measurementBody({
    required Profile? profile,
    required MeasurementType type,
    required MeasurementSchedule schedule,
    required DateTime scheduledTime,
  }) {
    final parts = <String>[];

    if (profile != null && profile.fullName.isNotEmpty) {
      parts.add(profile.fullName);
    }

    parts.add('Please record your ${type.name.toLowerCase()}');

    if (schedule.instructions != null &&
        schedule.instructions!.isNotEmpty) {
      parts.add(schedule.instructions!);
    }

    final timeStr =
        '${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}';
    parts.add('Scheduled for $timeStr');

    return parts.join(' \u2014 ');
  }

  static String _formatIntakeQuantity(MedicationSchedule schedule) {
    final qty = schedule.intakeQuantity;
    final qtyStr = qty == qty.roundToDouble()
        ? qty.toInt().toString()
        : qty.toString();
    final form = schedule.customDosageForm?.isNotEmpty == true
        ? schedule.customDosageForm!
        : schedule.dosageForm.name;
    final pluralized = qty == 1 ? form : '${form}s';
    return '$qtyStr $pluralized';
  }
}
