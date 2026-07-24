import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/domain/entities/schedule_config.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/utils/dosage_form_localizer.dart';

class ScheduleFormatter {
  ScheduleFormatter._();

  static String formatScheduleSummary(
    MedicationSchedule schedule, {
    required String dailyAtLabel,
    required String everyNDaysLabel,
    required String perIntakeLabel,
    required AppLocalizations l10n,
  }) {
    final config = schedule.scheduleConfig;
    final timesStr = config.times.join(', ');

    final typeLabel = switch (config) {
      DailySchedule() => dailyAtLabel.replaceAll('{times}', timesStr),
      IntervalDaysSchedule(:final intervalDays) => everyNDaysLabel
          .replaceAll('{count}', intervalDays.toString())
          .replaceAll('{times}', timesStr),
    };

    final intakeLine = perIntakeLabel.replaceAll(
      '{quantity}',
      DosageFormLocalizer.localizeWithQuantity(
        schedule.intakeQuantity,
        schedule.dosageForm,
        l10n,
        customForm: schedule.customDosageForm,
      ),
    );

    return '$typeLabel\n$intakeLine';
  }

  static String formatIntakeQuantity(
    MedicationSchedule schedule,
    AppLocalizations l10n,
  ) {
    return DosageFormLocalizer.localizeWithQuantity(
      schedule.intakeQuantity,
      schedule.dosageForm,
      l10n,
      customForm: schedule.customDosageForm,
    );
  }

  static String formatScheduleTypeLabel(String scheduleType) {
    return switch (scheduleType) {
      'daily' => 'daily',
      'interval_days' => 'interval_days',
      _ => scheduleType,
    };
  }
}
