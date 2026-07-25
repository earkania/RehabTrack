import 'dart:convert';
import 'dart:developer';

import 'package:timezone/timezone.dart' as tz;

import 'package:rehab_track/data/services/notification/measurement_notification_helper.dart';
import 'package:rehab_track/data/services/notification/notification_action_handler.dart';
import 'package:rehab_track/data/services/notification/notification_service.dart';
import 'package:rehab_track/data/services/notification/schedule_recovery_service.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/domain/entities/schedule_config.dart';
import 'package:rehab_track/domain/repositories/measurement_repository.dart';
import 'package:rehab_track/domain/repositories/medication_repository.dart';
import 'package:rehab_track/presentation/utils/dose_formatter.dart';

class NotificationActionBridge {
  NotificationActionBridge({
    required this._notificationService,
    required ScheduleRecoveryService scheduleRecoveryService,
    required this._medicationRepository,
    required this._measurementRepository,
  }) : _scheduleRecoveryService = scheduleRecoveryService;

  final NotificationService _notificationService;
  final ScheduleRecoveryService _scheduleRecoveryService;
  final MedicationRepository _medicationRepository;
  final MeasurementRepository _measurementRepository;

  Future<void> initialize({required int profileId}) async {
    _notificationService.setActionCallback(_handleAction);
    log('NotificationActionBridge: action callback registered');

    await _recoverSchedules(profileId);
    await _recoverMeasurementSchedules(profileId);
  }

  void _handleAction(NotificationActionResponse response) {
    log('NotificationActionBridge: action=${response.actionType.name}, '
        'notificationId=${response.notificationId}');

    final measurementPayload =
        MeasurementNotificationHelper.parsePayload(response.payload);
    if (measurementPayload != null && measurementPayload.isValid) {
      _handleMeasurementAction(response, measurementPayload);
      return;
    }

    final payload = _parsePayload(response.payload);
    if (payload == null) {
      log('NotificationActionBridge: invalid or missing payload, ignoring');
      return;
    }

    switch (response.actionType) {
      case NotificationActionType.taken:
        _handleTaken(payload);
      case NotificationActionType.skipped:
        _handleSkipped(payload);
      case NotificationActionType.snoozed:
        _handleSnooze(response, payload);
    }
  }

  static NotificationPayload? parsePayload(String? payload) {
    return _parsePayload(payload);
  }

  static NotificationPayload? _parsePayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;

    try {
      final json = jsonDecode(payload) as Map<String, dynamic>;
      final medicationId = json['medicationId'] as int?;
      final scheduleId = json['scheduleId'] as int?;

      if (medicationId == null || scheduleId == null) return null;

      return NotificationPayload(
        medicationId: medicationId,
        scheduleId: scheduleId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleTaken(NotificationPayload payload) async {
    final now = DateTime.now();
    final schedule =
        await _medicationRepository.getSchedule(payload.scheduleId);

    final logEntry = MedicationLog(
      medicationScheduleId: payload.scheduleId,
      scheduledTime: now,
      takenTime: now,
      status: 'taken',
      createdAt: now,
      snapshotIntakeQuantity: schedule?.intakeQuantity,
      snapshotDosageForm: schedule?.dosageForm,
      snapshotCustomDosageForm: schedule?.customDosageForm,
    );

    try {
      await _medicationRepository.logDose(logEntry);
      log('NotificationActionBridge: logged taken dose for schedule '
          '${payload.scheduleId}');
    } catch (e) {
      log('NotificationActionBridge: failed to log taken dose: $e');
    }
  }

  Future<void> _handleSkipped(NotificationPayload payload) async {
    final now = DateTime.now();
    final schedule =
        await _medicationRepository.getSchedule(payload.scheduleId);

    final logEntry = MedicationLog(
      medicationScheduleId: payload.scheduleId,
      scheduledTime: now,
      status: 'skipped',
      createdAt: now,
      snapshotIntakeQuantity: schedule?.intakeQuantity,
      snapshotDosageForm: schedule?.dosageForm,
      snapshotCustomDosageForm: schedule?.customDosageForm,
    );

    try {
      await _medicationRepository.logDose(logEntry);
      log('NotificationActionBridge: logged skipped dose for schedule '
          '${payload.scheduleId}');
    } catch (e) {
      log('NotificationActionBridge: failed to log skipped dose: $e');
    }
  }

  Future<void> _handleSnooze(
    NotificationActionResponse response,
    NotificationPayload payload,
  ) async {
    try {
      final schedule =
          await _medicationRepository.getSchedule(payload.scheduleId);
      if (schedule == null) {
        log('NotificationActionBridge: schedule ${payload.scheduleId} '
            'not found for snooze');
        return;
      }

      final medication =
          await _medicationRepository.getMedication(payload.medicationId);
      if (medication == null) {
        log('NotificationActionBridge: medication ${payload.medicationId} '
            'not found for snooze');
        return;
      }

      final title = 'Time to take ${medication.name}';
      final body = buildNotificationBody(medication, schedule);
      final snoozePayload = jsonEncode({
        'medicationId': payload.medicationId,
        'scheduleId': payload.scheduleId,
      });

      final now = DateTime.now();
      final snoozeTime = now.add(const Duration(minutes: 10));
      final tzLocation = tz.local;
      final scheduledDate = tz.TZDateTime(
        tzLocation,
        snoozeTime.year,
        snoozeTime.month,
        snoozeTime.day,
        snoozeTime.hour,
        snoozeTime.minute,
      );

      await _notificationService.scheduleNotification(
        id: response.notificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        channelType: NotificationChannelType.medication,
        payload: snoozePayload,
        includeActions: true,
      );

      log('NotificationActionBridge: snoozed notification '
          '${response.notificationId} for $snoozeTime');
    } catch (e) {
      log('NotificationActionBridge: failed to snooze: $e');
    }
  }

  // --- Measurement notification actions ---

  void _handleMeasurementAction(
    NotificationActionResponse response,
    MeasurementNotificationPayload payload,
  ) {
    switch (response.actionType) {
      case NotificationActionType.taken:
        _handleMeasurementCompleted(response, payload);
      case NotificationActionType.skipped:
        _handleMeasurementSkipped(response, payload);
      case NotificationActionType.snoozed:
        _handleMeasurementSnooze(response, payload);
    }
  }

  Future<void> _handleMeasurementCompleted(
    NotificationActionResponse response,
    MeasurementNotificationPayload payload,
  ) async {
    final scheduledTime = payload.scheduledTime != null
        ? DateTime.tryParse(payload.scheduledTime!)
        : DateTime.now();

    if (scheduledTime == null) return;

    final existing = await _measurementRepository.getReminderLog(
      payload.scheduleId,
      scheduledTime,
    );

    if (existing != null && existing.id != null) {
      await _measurementRepository.updateReminderLog(
        existing.copyWith(
          status: MeasurementReminderAction.completed,
          actionTime: DateTime.now(),
        ),
      );
    } else {
      await _measurementRepository.logReminder(
        MeasurementReminderLog(
          measurementScheduleId: payload.scheduleId,
          scheduledTime: scheduledTime,
          actionTime: DateTime.now(),
          status: MeasurementReminderAction.completed,
          createdAt: DateTime.now(),
        ),
      );
    }
    log('NotificationActionBridge: measurement reminder completed '
        'for schedule ${payload.scheduleId}');
  }

  Future<void> _handleMeasurementSkipped(
    NotificationActionResponse response,
    MeasurementNotificationPayload payload,
  ) async {
    final scheduledTime = payload.scheduledTime != null
        ? DateTime.tryParse(payload.scheduledTime!)
        : DateTime.now();

    if (scheduledTime == null) return;

    final existing = await _measurementRepository.getReminderLog(
      payload.scheduleId,
      scheduledTime,
    );

    if (existing != null && existing.id != null) {
      await _measurementRepository.updateReminderLog(
        existing.copyWith(
          status: MeasurementReminderAction.skipped,
          actionTime: DateTime.now(),
        ),
      );
    } else {
      await _measurementRepository.logReminder(
        MeasurementReminderLog(
          measurementScheduleId: payload.scheduleId,
          scheduledTime: scheduledTime,
          actionTime: DateTime.now(),
          status: MeasurementReminderAction.skipped,
          createdAt: DateTime.now(),
        ),
      );
    }
    log('NotificationActionBridge: measurement reminder skipped '
        'for schedule ${payload.scheduleId}');
  }

  Future<void> _handleMeasurementSnooze(
    NotificationActionResponse response,
    MeasurementNotificationPayload payload,
  ) async {
    try {
      final schedule = await _measurementRepository.getSchedule(
        payload.scheduleId,
      );
      if (schedule == null) {
        log('NotificationActionBridge: measurement schedule '
            '${payload.scheduleId} not found for snooze');
        return;
      }

      final type = await _measurementRepository.getMeasurementType(
        payload.measurementTypeId,
      );
      final typeName = type?.name ?? 'Measurement';

      final title = 'Time to record $typeName';
      final body = _buildMeasurementBody(type, schedule);
      final snoozePayload = MeasurementNotificationHelper.buildPayload(
        scheduleId: payload.scheduleId,
        measurementTypeId: payload.measurementTypeId,
        profileId: payload.profileId,
        scheduledTime: payload.scheduledTime,
      );

      final now = DateTime.now();
      final snoozeTime = now.add(const Duration(minutes: 10));
      final tzLocation = tz.local;
      final scheduledDate = tz.TZDateTime(
        tzLocation,
        snoozeTime.year,
        snoozeTime.month,
        snoozeTime.day,
        snoozeTime.hour,
        snoozeTime.minute,
      );

      final notifId = MeasurementNotificationHelper.baseNotificationId(
        payload.scheduleId,
      );

      await _notificationService.scheduleNotification(
        id: notifId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        channelType: NotificationChannelType.measurement,
        payload: snoozePayload,
        includeActions: true,
      );

      // Log snooze
      final scheduledTime = payload.scheduledTime != null
          ? DateTime.tryParse(payload.scheduledTime!)
          : DateTime.now();
      if (scheduledTime != null) {
        final existing = await _measurementRepository.getReminderLog(
          payload.scheduleId,
          scheduledTime,
        );
        if (existing != null && existing.id != null) {
          await _measurementRepository.updateReminderLog(
            existing.copyWith(
              status: MeasurementReminderAction.snoozed,
              actionTime: DateTime.now(),
            ),
          );
        }
      }

      log('NotificationActionBridge: snoozed measurement notification '
          '$notifId for $snoozeTime');
    } catch (e) {
      log('NotificationActionBridge: failed to snooze measurement: $e');
    }
  }

  // --- Measurement schedule recovery ---

  Future<void> _recoverMeasurementSchedules(int profileId) async {
    try {
      final schedules =
          await _measurementRepository.getActiveSchedules(profileId);

      final entries = <ScheduleRecoveryEntry>[];

      for (final schedule in schedules) {
        if (!schedule.active || schedule.id == null) continue;

        final type = await _measurementRepository.getMeasurementType(
          schedule.measurementTypeId,
        );

        entries.add(_buildMeasurementRecoveryEntry(type, schedule));
      }

      if (entries.isEmpty) {
        log('NotificationActionBridge: no active measurement schedules '
            'to recover');
        return;
      }

      await _scheduleRecoveryService.recoverAllSchedules(
        activeSchedules: entries,
      );
      log('NotificationActionBridge: measurement recovery complete, '
          '${entries.length} schedule entries processed');
    } catch (e) {
      log('NotificationActionBridge: measurement recovery failed: $e');
    }
  }

  ScheduleRecoveryEntry _buildMeasurementRecoveryEntry(
    MeasurementType? type,
    MeasurementSchedule schedule,
  ) {
    final notificationIds = MeasurementNotificationHelper.computeNotificationIds(
      scheduleId: schedule.id!,
      config: schedule.scheduleConfig,
    );

    final typeName = type?.name ?? 'Measurement';
    final payload = MeasurementNotificationHelper.buildPayload(
      scheduleId: schedule.id!,
      measurementTypeId: schedule.measurementTypeId,
      profileId: schedule.profileId,
    );

    return ScheduleRecoveryEntry(
      notificationIds: notificationIds,
      title: 'Time to record $typeName',
      body: _buildMeasurementBody(type, schedule),
      config: schedule.scheduleConfig,
      channelType: NotificationChannelType.measurement,
      payload: payload,
      includeActions: true,
    );
  }

  static String _buildMeasurementBody(
    MeasurementType? type,
    MeasurementSchedule schedule,
  ) {
    final parts = <String>[];
    parts.add('Please record your ${type?.name.toLowerCase() ?? 'measurement'}');
    if (schedule.instructions != null &&
        schedule.instructions!.isNotEmpty) {
      parts.add(schedule.instructions!);
    }
    return parts.join(' — ');
  }

  Future<void> _recoverSchedules(int profileId) async {
    try {
      final medications =
          await _medicationRepository.getMedications(profileId);

      final entries = <ScheduleRecoveryEntry>[];

      for (final medication in medications) {
        if (!medication.active || medication.id == null) continue;

        final schedules = await _medicationRepository
            .watchSchedules(medication.id!)
            .first;

        for (final schedule in schedules) {
          if (!schedule.active || schedule.id == null) continue;
          entries.add(_buildRecoveryEntry(medication, schedule));
        }
      }

      if (entries.isEmpty) {
        log('NotificationActionBridge: no active schedules to recover');
        return;
      }

      await _scheduleRecoveryService.recoverAllSchedules(
        activeSchedules: entries,
      );
      log('NotificationActionBridge: recovery complete, '
          '${entries.length} schedule entries processed');
    } catch (e) {
      log('NotificationActionBridge: recovery failed: $e');
    }
  }

  ScheduleRecoveryEntry _buildRecoveryEntry(
    Medication medication,
    MedicationSchedule schedule,
  ) {
    final notificationIds = computeNotificationIds(
      scheduleId: schedule.id!,
      config: schedule.scheduleConfig,
    );

    final payload = jsonEncode({
      'medicationId': medication.id,
      'scheduleId': schedule.id,
    });

    return ScheduleRecoveryEntry(
      notificationIds: notificationIds,
      title: 'Time to take ${medication.name}',
      body: buildNotificationBody(medication, schedule),
      config: schedule.scheduleConfig,
      channelType: NotificationChannelType.medication,
      payload: payload,
      includeActions: true,
    );
  }

  static List<int> computeNotificationIds({
    required int scheduleId,
    required ScheduleConfig config,
  }) {
    return List.generate(config.times.length, (i) => scheduleId + i);
  }

  static String buildNotificationBody(
    Medication medication,
    MedicationSchedule schedule,
  ) {
    final parts = <String>[];

    final dose = DoseFormatter.format(medication);
    if (dose.isNotEmpty) parts.add(dose);

    final intakeQty = schedule.intakeQuantity;
    final form = schedule.customDosageForm?.isNotEmpty == true
        ? schedule.customDosageForm!
        : schedule.dosageForm.name;
    final qtyStr = intakeQty == intakeQty.roundToDouble()
        ? intakeQty.toInt().toString()
        : intakeQty.toString();
    final pluralized = intakeQty == 1 ? form : '${form}s';
    parts.add('take $qtyStr $pluralized');

    if (schedule.instructions != null && schedule.instructions!.isNotEmpty) {
      parts.add(schedule.instructions!);
    }

    return parts.isEmpty ? '' : parts.join(' — ');
  }
}

class NotificationPayload {
  const NotificationPayload({
    required this.medicationId,
    required this.scheduleId,
  });

  final int medicationId;
  final int scheduleId;
}
