import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/domain/entities/schedule_config.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';
import 'package:rehab_track/domain/repositories/medication_repository.dart';
import 'package:rehab_track/domain/repositories/measurement_repository.dart';
import 'package:rehab_track/presentation/utils/component_formatter.dart';
import 'package:rehab_track/presentation/utils/dose_formatter.dart';

class TodayAgendaService {
  final MedicationRepository _medicationRepository;
  final MeasurementRepository _measurementRepository;

  static const Duration _graceWindow = Duration(minutes: 30);

  TodayAgendaService(this._medicationRepository, this._measurementRepository);

  static Duration get graceWindow => _graceWindow;

  Future<TodayAgenda> generateAgenda(
    int profileId, {
    DateTime? now,
  }) async {
    final currentTime = now ?? DateTime.now();
    final today = DateTime(currentTime.year, currentTime.month, currentTime.day);
    final dayEnd = today.add(const Duration(days: 1));

    final medicationItems = await _generateMedicationItems(profileId, today, dayEnd, currentTime);
    final measurementItems = await _generateMeasurementItems(profileId, today, dayEnd, currentTime);

    final allItems = [...medicationItems, ...measurementItems];
    allItems.sort((a, b) {
      final cmp = a.effectiveTime.compareTo(b.effectiveTime);
      if (cmp != 0) return cmp;
      return a.id.compareTo(b.id);
    });

    final summary = _computeSummary(medicationItems, measurementItems);

    return TodayAgenda(
      date: today,
      items: allItems,
      summary: summary,
    );
  }

  TodaySummary buildSummary(List<TodayAgendaItem> allItems) {
    final medicationItems =
        allItems.where((i) => i.type == TodayAgendaItemType.medication).toList();
    final measurementItems =
        allItems.where((i) => i.type == TodayAgendaItemType.measurement).toList();
    return _computeSummary(medicationItems, measurementItems);
  }

  Future<List<TodayAgendaItem>> _generateMedicationItems(
    int profileId,
    DateTime today,
    DateTime dayEnd,
    DateTime currentTime,
  ) async {
    final medications =
        await _medicationRepository.getActiveMedications(profileId);

    final items = <TodayAgendaItem>[];

    for (final medication in medications) {
      if (medication.id == null) continue;
      final schedules =
          await _medicationRepository.getSchedulesForMedication(medication.id!);

      for (final schedule in schedules) {
        if (!schedule.active) continue;
        if (!_scheduleAppliesOnDate(schedule.scheduleConfig, today)) continue;

        final times = schedule.scheduleConfig.times;
        final logs = await _medicationRepository.getLogs(
          schedule.id!,
          from: today,
          to: dayEnd,
        );

        for (final timeStr in times) {
          final scheduledDateTime = _parseTimeForDate(timeStr, today);
          final log = _findLogForTime(logs, scheduledDateTime);

          items.add(await _buildMedicationItem(
            schedule: schedule,
            medication: medication,
            scheduledDateTime: scheduledDateTime,
            log: log,
            currentTime: currentTime,
          ));
        }
      }
    }

    return items;
  }

  Future<List<TodayAgendaItem>> _generateMeasurementItems(
    int profileId,
    DateTime today,
    DateTime dayEnd,
    DateTime currentTime,
  ) async {
    final schedules =
        await _measurementRepository.getActiveSchedules(profileId);

    final typeMap = <int, MeasurementType>{};
    final items = <TodayAgendaItem>[];

    for (final schedule in schedules) {
      if (!schedule.active || schedule.id == null) continue;
      if (!_measurementScheduleAppliesOnDate(schedule, today)) continue;

      final typeId = schedule.measurementTypeId;
      if (!typeMap.containsKey(typeId)) {
        final type = await _measurementRepository.getMeasurementType(typeId);
        if (type != null) typeMap[typeId] = type;
      }
      final type = typeMap[typeId];

      final scheduledDateTime = _parseTimeForDate(schedule.time, today);

      final logs = await _measurementRepository.getReminderLogsForSchedule(
        schedule.id!,
      );

      final todayLogs = logs.where((log) {
        final logDate = log.scheduledTime;
        return logDate.isAfter(today.subtract(const Duration(seconds: 1))) &&
            logDate.isBefore(dayEnd);
      }).toList();

      final log = _findMeasurementLogForTime(todayLogs, scheduledDateTime);

      items.add(_buildMeasurementItem(
        schedule: schedule,
        type: type,
        scheduledDateTime: scheduledDateTime,
        log: log,
        currentTime: currentTime,
        typeName: type?.name ?? 'Measurement',
      ));
    }

    return _attachLinkedReadings(items);
  }

  Future<List<TodayAgendaItem>> _attachLinkedReadings(
    List<TodayAgendaItem> items,
  ) async {
    final recordIds = <int>[];
    for (final item in items) {
      if (item.type == TodayAgendaItemType.measurement &&
          item.measurementRecordId != null &&
          (item.status == TodayAgendaItemStatus.completed ||
           item.status == TodayAgendaItemStatus.skipped)) {
        recordIds.add(item.measurementRecordId!);
      }
    }

    if (recordIds.isEmpty) return items;

    final valuesMap =
        await _measurementRepository.getValuesForRecords(recordIds);

    final recordCache = <int, MeasurementRecord>{};
    for (final id in recordIds) {
      final record = await _measurementRepository.getRecord(id);
      if (record != null) recordCache[id] = record;
    }

    return items.map((item) {
      if (item.measurementRecordId == null) return item;
      final recordId = item.measurementRecordId!;
      final values = valuesMap[recordId];
      final record = recordCache[recordId];
      if (values == null || values.isEmpty) return item;
      return item.copyWith(
        readingValues: values,
        irregularHeartbeatDetected: record?.irregularHeartbeatDetected,
      );
    }).toList();
  }

  static bool scheduleAppliesOnDate(ScheduleConfig config, DateTime date) {
    return switch (config) {
      DailySchedule() => true,
      IntervalDaysSchedule(:final intervalDays) =>
        _intervalScheduleAppliesOnDate(intervalDays, date),
    };
  }

  static bool _scheduleAppliesOnDate(ScheduleConfig config, DateTime date) {
    return scheduleAppliesOnDate(config, date);
  }

  static bool _measurementScheduleAppliesOnDate(
    MeasurementSchedule schedule,
    DateTime date,
  ) {
    if (schedule.isDaily) return true;
    if (schedule.intervalDays == null || schedule.intervalDays! <= 0) return false;
    return _intervalScheduleAppliesOnDate(schedule.intervalDays!, date);
  }

  static bool _intervalScheduleAppliesOnDate(
    int intervalDays,
    DateTime date,
  ) {
    if (intervalDays <= 0) return false;

    final now = DateTime.now();
    final scheduleStartDate = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final diff = targetDate.difference(scheduleStartDate).inDays;
    return diff % intervalDays == 0;
  }

  static DateTime _parseTimeForDate(String timeStr, DateTime date) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  Future<TodayAgendaItem> _buildMedicationItem({
    required MedicationSchedule schedule,
    required Medication medication,
    required DateTime scheduledDateTime,
    required MedicationLog? log,
    required DateTime currentTime,
  }) async {
    final status =
        _determineMedicationStatus(scheduledDateTime, log, currentTime);
    final effectiveId =
        'med_${schedule.id}_${scheduledDateTime.hour}${scheduledDateTime.minute}';

    final strength = await _resolveMedicationStrength(medication);

    return TodayAgendaItem(
      id: effectiveId,
      type: TodayAgendaItemType.medication,
      sourceScheduleId: schedule.id!,
      scheduledDateTime: scheduledDateTime,
      title: medication.name,
      subtitle: medication.description,
      instructions: schedule.instructions,
      status: status,
      completedAt: log?.takenTime,
      medicationId: medication.id,
      medicationName: medication.name,
      strength: strength,
      intakeQuantity: schedule.intakeQuantity,
      dosageForm: schedule.dosageForm,
      customDosageForm: schedule.customDosageForm,
    );
  }

  Future<String?> _resolveMedicationStrength(Medication medication) async {
    if (medication.id == null) return null;
    final components =
        await _medicationRepository.getComponents(medication.id!);
    if (components.isNotEmpty) {
      return ComponentFormatter.formatComponents(components);
    }
    final dose = DoseFormatter.format(medication);
    return dose.isNotEmpty ? dose : null;
  }

  TodayAgendaItem _buildMeasurementItem({
    required MeasurementSchedule schedule,
    required MeasurementType? type,
    required DateTime scheduledDateTime,
    required MeasurementReminderLog? log,
    required DateTime currentTime,
    required String typeName,
  }) {
    final status =
        _determineMeasurementStatus(scheduledDateTime, log, currentTime);
    final effectiveId =
        'meas_${schedule.id}_${scheduledDateTime.hour}${scheduledDateTime.minute}';

    return TodayAgendaItem(
      id: effectiveId,
      type: TodayAgendaItemType.measurement,
      sourceScheduleId: schedule.id!,
      scheduledDateTime: scheduledDateTime,
      title: typeName,
      subtitle: schedule.instructions,
      instructions: schedule.instructions,
      status: status,
      completedAt: log?.actionTime,
      snoozedUntil: status == TodayAgendaItemStatus.snoozed
          ? scheduledDateTime.add(const Duration(minutes: 10))
          : null,
      measurementTypeId: type?.id,
      measurementTypeKey: type?.key,
      measurementRecordId: log?.measurementRecordId,
    );
  }

  static TodayAgendaItemStatus determineMedicationStatus(
    DateTime scheduledDateTime,
    MedicationLog? log,
    DateTime currentTime, {
    Duration graceWindow = const Duration(minutes: 30),
  }) {
    if (log != null) {
      return switch (log.status) {
        'taken' => TodayAgendaItemStatus.completed,
        'skipped' => TodayAgendaItemStatus.skipped,
        'missed' => TodayAgendaItemStatus.overdue,
        _ => TodayAgendaItemStatus.upcoming,
      };
    }

    final diff = currentTime.difference(scheduledDateTime);
    if (diff.isNegative) return TodayAgendaItemStatus.upcoming;
    if (diff <= graceWindow) return TodayAgendaItemStatus.due;
    return TodayAgendaItemStatus.overdue;
  }

  static TodayAgendaItemStatus determineMeasurementStatus(
    DateTime scheduledDateTime,
    MeasurementReminderLog? log,
    DateTime currentTime, {
    Duration graceWindow = const Duration(minutes: 30),
  }) {
    if (log != null) {
      return switch (log.status) {
        MeasurementReminderAction.completed =>
          TodayAgendaItemStatus.completed,
        MeasurementReminderAction.skipped =>
          TodayAgendaItemStatus.skipped,
        MeasurementReminderAction.snoozed =>
          TodayAgendaItemStatus.snoozed,
        MeasurementReminderAction.expired =>
          TodayAgendaItemStatus.overdue,
      };
    }

    final diff = currentTime.difference(scheduledDateTime);
    if (diff.isNegative) return TodayAgendaItemStatus.upcoming;
    if (diff <= graceWindow) return TodayAgendaItemStatus.due;
    return TodayAgendaItemStatus.overdue;
  }

  TodayAgendaItemStatus _determineMedicationStatus(
    DateTime scheduledDateTime,
    MedicationLog? log,
    DateTime currentTime,
  ) {
    return determineMedicationStatus(scheduledDateTime, log, currentTime,
        graceWindow: _graceWindow);
  }

  TodayAgendaItemStatus _determineMeasurementStatus(
    DateTime scheduledDateTime,
    MeasurementReminderLog? log,
    DateTime currentTime,
  ) {
    return determineMeasurementStatus(scheduledDateTime, log, currentTime,
        graceWindow: _graceWindow);
  }

  MedicationLog? _findLogForTime(
    List<MedicationLog> logs,
    DateTime scheduledDateTime,
  ) {
    for (final log in logs) {
      if (log.scheduledTime.year == scheduledDateTime.year &&
          log.scheduledTime.month == scheduledDateTime.month &&
          log.scheduledTime.day == scheduledDateTime.day &&
          log.scheduledTime.hour == scheduledDateTime.hour &&
          log.scheduledTime.minute == scheduledDateTime.minute) {
        return log;
      }
    }
    return null;
  }

  MeasurementReminderLog? _findMeasurementLogForTime(
    List<MeasurementReminderLog> logs,
    DateTime scheduledDateTime,
  ) {
    for (final log in logs) {
      if (log.scheduledTime.year == scheduledDateTime.year &&
          log.scheduledTime.month == scheduledDateTime.month &&
          log.scheduledTime.day == scheduledDateTime.day &&
          log.scheduledTime.hour == scheduledDateTime.hour &&
          log.scheduledTime.minute == scheduledDateTime.minute) {
        return log;
      }
    }
    return null;
  }

  TodaySummary _computeSummary(
    List<TodayAgendaItem> medicationItems,
    List<TodayAgendaItem> measurementItems,
  ) {
    return TodaySummary(
      medicationTotal: medicationItems.length,
      medicationCompleted: medicationItems
          .where((i) => i.status == TodayAgendaItemStatus.completed)
          .length,
      medicationSkipped: medicationItems
          .where((i) => i.status == TodayAgendaItemStatus.skipped)
          .length,
      medicationOverdue: medicationItems
          .where((i) => i.status == TodayAgendaItemStatus.overdue)
          .length,
      measurementTotal: measurementItems.length,
      measurementCompleted: measurementItems
          .where((i) => i.status == TodayAgendaItemStatus.completed)
          .length,
      measurementSkipped: measurementItems
          .where((i) => i.status == TodayAgendaItemStatus.skipped)
          .length,
      measurementOverdue: measurementItems
          .where((i) => i.status == TodayAgendaItemStatus.overdue)
          .length,
    );
  }
}
