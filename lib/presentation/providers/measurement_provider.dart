import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/measurement_chart.dart';
import 'package:rehab_track/domain/entities/measurement_data_point.dart';
import 'package:rehab_track/domain/entities/measurement_period.dart';
import 'package:rehab_track/domain/entities/measurement_statistics.dart';
import 'package:rehab_track/domain/entities/measurement_time_of_day_filter.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/domain/entities/reading_status_summary.dart';
import 'package:rehab_track/domain/services/measurement_chart_builder.dart';
import 'package:rehab_track/domain/services/measurement_time_of_day_classifier.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';

final activeMeasurementTypesProvider =
    StreamProvider.autoDispose<List<MeasurementType>>((ref) {
  final profileId = ref.watch(currentActiveProfileIdProvider);
  final repo = ref.watch(measurementRepositoryProvider);
  return repo.watchActiveMeasurementTypes(profileId);
});

final measurementTypeProvider =
    FutureProvider.autoDispose.family<MeasurementType?, int>(
      (ref, id) async {
        final repo = ref.watch(measurementRepositoryProvider);
        return repo.getMeasurementType(id);
      },
    );

final measurementTypeByKeyProvider =
    FutureProvider.autoDispose.family<MeasurementType?, String>(
      (ref, key) async {
        final repo = ref.watch(measurementRepositoryProvider);
        return repo.getMeasurementTypeByKey(key);
      },
    );

final measurementTypeFieldsProvider =
    StreamProvider.autoDispose.family<List<MeasurementTypeField>, int>(
      (ref, typeId) {
        final repo = ref.watch(measurementRepositoryProvider);
        return repo.watchFieldsForType(typeId);
      },
    );

final measurementRecordsProvider = StreamProvider.autoDispose
    .family<List<MeasurementRecord>, ({int typeId, DateTime? from, DateTime? to})>(
      (ref, params) {
        final profileId = ref.watch(currentActiveProfileIdProvider);
        if (profileId == null) {
          return const Stream.empty();
        }
        final repo = ref.watch(measurementRepositoryProvider);
        return repo.watchRecords(
          profileId,
          typeId: params.typeId,
          from: params.from,
          to: params.to,
        );
      },
    );

final measurementRecordProvider =
    FutureProvider.autoDispose.family<MeasurementRecord?, int>(
      (ref, id) async {
        final repo = ref.watch(measurementRepositoryProvider);
        return repo.getRecord(id);
      },
    );

final measurementRecordValuesProvider =
    FutureProvider.autoDispose.family<List<MeasurementRecordValue>, int>(
      (ref, recordId) async {
        final repo = ref.watch(measurementRepositoryProvider);
        return repo.getValuesForRecord(recordId);
      },
    );

// --- Trend / Chart providers ---

/// The selected time-of-day dimension for the Measurement Trends screen.
///
/// Auto-disposed so a brand-new Trends screen (after the previous one was
/// fully removed) starts at [MeasurementTimeOfDayFilter.all], while the
/// selection survives normal rebuilds for the current screen session.
final measurementTrendTimeOfDayFilterProvider =
    StateProvider.autoDispose<MeasurementTimeOfDayFilter>(
  (ref) => MeasurementTimeOfDayFilter.all,
);

typedef TrendParams = ({
  int measurementTypeId,
  MeasurementPeriod period,
  MeasurementTimeOfDayFilter timeOfDay,
});

class TrendData {
  final List<MeasurementDataPoint> dataPoints;
  final List<MeasurementChartSeries> chartSeries;
  final Map<String, MeasurementStatistics> fieldStatistics;
  final ReadingStatusSummary statusSummary;
  final MeasurementRanges? ranges;

  const TrendData({
    required this.dataPoints,
    required this.chartSeries,
    required this.fieldStatistics,
    required this.statusSummary,
    this.ranges,
  });

  static const empty = TrendData(
    dataPoints: [],
    chartSeries: [],
    fieldStatistics: {},
    statusSummary: ReadingStatusSummary.empty,
  );
}

final trendDataProvider =
    FutureProvider.autoDispose.family<TrendData, TrendParams>(
      (ref, params) async {
        final profileId = ref.watch(currentActiveProfileIdProvider);
        if (profileId == null) return TrendData.empty;

        final repo = ref.watch(measurementRepositoryProvider);
        final period = params.period;

        final records = await repo.getRecords(
          profileId,
          typeId: params.measurementTypeId,
          from: period.from,
          ascending: true,
        );

        if (records.isEmpty) return TrendData.empty;

        final recordIds = records.map((r) => r.id!).toList();
        final allValues = await repo.getValuesForRecords(recordIds);

        final dataPoints = MeasurementTimeOfDayClassifier.filterDataPoints(
          dataPoints: records
              .map(
                (r) => MeasurementDataPoint(
                  record: r,
                  values: allValues[r.id!] ?? [],
                ),
              )
              .toList(),
          timeOfDay: params.timeOfDay,
        );

        if (dataPoints.isEmpty) return TrendData.empty;

        final type = await repo.getMeasurementType(
          params.measurementTypeId,
        );
        if (type == null) return TrendData.empty;

        final fields = await repo.getFieldsForType(
          params.measurementTypeId,
        );

        final typeKey = type.key ?? '';
        final rangesRepo = ref.read(referenceRangeRepositoryProvider);
        final ranges = await rangesRepo.getEffectiveRanges(
          profileId,
          typeKey,
        );

        final chartSeries = MeasurementChartBuilder.buildSeries(
          typeKey: typeKey,
          dataPoints: dataPoints,
          fields: fields,
          ranges: ranges,
        );

        final fieldStatistics =
            MeasurementChartBuilder.computeFieldStatistics(
          series: chartSeries,
        );

        final statusSummary =
            MeasurementChartBuilder.computeStatusSummary(
          series: chartSeries,
        );

        return TrendData(
          dataPoints: dataPoints,
          chartSeries: chartSeries,
          fieldStatistics: fieldStatistics,
          statusSummary: statusSummary,
          ranges: ranges,
        );
      },
    );

final trendTypeProvider =
    FutureProvider.autoDispose.family<MeasurementType?, int>(
      (ref, typeId) async {
        final repo = ref.watch(measurementRepositoryProvider);
        return repo.getMeasurementType(typeId);
      },
    );

// --- Measurement Schedule providers ---

final measurementSchedulesForTypeProvider =
    StreamProvider.autoDispose.family<List<MeasurementSchedule>, int>(
      (ref, typeId) {
        final repo = ref.watch(measurementRepositoryProvider);
        return repo.watchSchedulesForType(typeId);
      },
    );

final measurementScheduleProvider =
    FutureProvider.autoDispose.family<MeasurementSchedule?, int>(
      (ref, scheduleId) async {
        final repo = ref.watch(measurementRepositoryProvider);
        return repo.getSchedule(scheduleId);
      },
    );

final activeMeasurementSchedulesProvider =
    StreamProvider.autoDispose<List<MeasurementSchedule>>((ref) {
      final profileId = ref.watch(currentActiveProfileIdProvider);
      if (profileId == null) return const Stream.empty();
      final repo = ref.watch(measurementRepositoryProvider);
      return repo.watchActiveSchedules(profileId);
    });

// --- Measurement Reminder Log providers ---

final measurementReminderLogsProvider =
    StreamProvider.autoDispose.family<List<MeasurementReminderLog>, int>(
      (ref, scheduleId) {
        final repo = ref.watch(measurementRepositoryProvider);
        return repo.watchReminderLogsForSchedule(scheduleId);
      },
    );

final todayMeasurementRemindersProvider =
    FutureProvider.autoDispose<List<_TodayMeasurementReminder>>(
      (ref) async {
        final profileId = ref.watch(currentActiveProfileIdProvider);
        if (profileId == null) return [];

        final repo = ref.watch(measurementRepositoryProvider);
        final logs = await repo.getTodayReminderLogs(profileId);
        final activeSchedules = await repo.getActiveSchedules(profileId);

        if (activeSchedules.isEmpty) return [];

        final scheduleMap = <int, MeasurementSchedule>{};
        for (final s in activeSchedules) {
          if (s.id != null) scheduleMap[s.id!] = s;
        }

        final typeIds = activeSchedules
            .map((s) => s.measurementTypeId)
            .toSet()
            .toList();
        final types = <int, MeasurementType>{};
        for (final tid in typeIds) {
          final type = await repo.getMeasurementType(tid);
          if (type != null) types[tid] = type;
        }

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));

        final reminders = <_TodayMeasurementReminder>[];

        for (final schedule in activeSchedules) {
          if (schedule.id == null) continue;
          final timeStr = schedule.time;
          final type = types[schedule.measurementTypeId];

          final parts = timeStr.split(':');
          if (parts.length != 2) continue;
          final hour = int.tryParse(parts[0]);
          final minute = int.tryParse(parts[1]);
          if (hour == null || minute == null) continue;

          final scheduledTime = DateTime(
            today.year,
            today.month,
            today.day,
            hour,
            minute,
          );

          if (scheduledTime.isBefore(tomorrow) == false) continue;

          final logEntry = logs.where((l) =>
              l.measurementScheduleId == schedule.id &&
              l.scheduledTime.year == scheduledTime.year &&
              l.scheduledTime.month == scheduledTime.month &&
              l.scheduledTime.day == scheduledTime.day &&
              l.scheduledTime.hour == scheduledTime.hour &&
              l.scheduledTime.minute == scheduledTime.minute).firstOrNull;

          reminders.add(_TodayMeasurementReminder(
            schedule: schedule,
            typeName: type?.name ?? 'Measurement',
            typeKey: type?.key ?? '',
            scheduledTime: scheduledTime,
            logEntry: logEntry,
          ));
        }

        reminders.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
        return reminders;
      },
    );

class _TodayMeasurementReminder {
  final MeasurementSchedule schedule;
  final String typeName;
  final String typeKey;
  final DateTime scheduledTime;
  final MeasurementReminderLog? logEntry;

  const _TodayMeasurementReminder({
    required this.schedule,
    required this.typeName,
    required this.typeKey,
    required this.scheduledTime,
    this.logEntry,
  });

  bool get isCompleted =>
      logEntry?.status == MeasurementReminderAction.completed;
  bool get isSkipped =>
      logEntry?.status == MeasurementReminderAction.skipped;
  bool get isSnoozed =>
      logEntry?.status == MeasurementReminderAction.snoozed;
  bool get isPending => logEntry == null;
  bool get isOverdue =>
      !isCompleted &&
      !isSkipped &&
      DateTime.now().isAfter(scheduledTime);
}
