import 'package:rehab_track/domain/entities/schedule_config.dart';

class ScheduleFormatter {
  ScheduleFormatter._();

  static String formatScheduleSummary(
    ScheduleConfig config, {
    required String dailyAtLabel,
    required String fixedTimesLabel,
    required String everyNDaysLabel,
  }) {
    return switch (config) {
      DailySchedule(:final time) => dailyAtLabel.replaceAll('{time}', time),
      FixedTimesSchedule(:final times) =>
        fixedTimesLabel.replaceAll('{times}', times.join(', ')),
      IntervalDaysSchedule(:final interval, :final time) => everyNDaysLabel
          .replaceAll('{count}', interval.toString())
          .replaceAll('{time}', time),
    };
  }

  static String formatScheduleTypeLabel(String scheduleType) {
    return switch (scheduleType) {
      'daily' => 'daily',
      'fixed_times' => 'fixed_times',
      'interval_days' => 'interval_days',
      _ => scheduleType,
    };
  }
}
