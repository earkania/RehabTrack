import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/domain/entities/profile.dart';

class ReminderContentFormatter {
  ReminderContentFormatter._();

  static String medicationTitle({
    required Profile? profile,
    required Medication medication,
    bool showProfileName = true,
    String? doseAmount,
    String? doseUnit,
  }) {
    final nameWithStrength = _formatMedicationName(
      medication.name,
      doseAmount: doseAmount ?? medication.doseAmount,
      doseUnit: doseUnit ?? medication.doseUnit,
    );
    return nameWithStrength;
  }

  static String medicationBody({
    required Profile? profile,
    required Medication medication,
    required MedicationSchedule schedule,
    required DateTime scheduledTime,
    bool showProfileName = true,
  }) {
    final parts = <String>[];

    if (showProfileName &&
        profile != null &&
        profile.fullName.isNotEmpty) {
      parts.add(profile.fullName);
    }

    final intakeText = _formatIntakeQuantity(schedule);
    if (intakeText.isNotEmpty) parts.add(intakeText);

    if (schedule.instructions != null &&
        schedule.instructions!.isNotEmpty) {
      parts.add(schedule.instructions!);
    }

    return parts.join(' \u2014 ');
  }

  static String medicationSubtext({
    required Profile? profile,
    bool showProfileName = true,
  }) {
    if (showProfileName &&
        profile != null &&
        profile.fullName.isNotEmpty) {
      return profile.fullName;
    }
    return '';
  }

  static String measurementTitle({
    required Profile? profile,
    required MeasurementType type,
    bool showProfileName = true,
  }) {
    return type.name;
  }

  static String measurementBody({
    required Profile? profile,
    required MeasurementType type,
    required MeasurementSchedule schedule,
    required DateTime scheduledTime,
    bool showProfileName = true,
  }) {
    final parts = <String>[];

    if (showProfileName &&
        profile != null &&
        profile.fullName.isNotEmpty) {
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

  static String _formatMedicationName(
    String name, {
    String? doseAmount,
    String? doseUnit,
  }) {
    if (doseAmount != null && doseAmount.isNotEmpty) {
      final dose = doseAmount;
      final unit = (doseUnit != null && doseUnit.isNotEmpty)
          ? ' $doseUnit'
          : '';
      return '$name $dose$unit';
    }
    return name;
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
