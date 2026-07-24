import 'dart:convert';
import 'dart:developer';

import 'package:timezone/timezone.dart' as tz;

import 'package:rehab_track/data/services/notification/notification_action_handler.dart';
import 'package:rehab_track/data/services/notification/notification_service.dart';
import 'package:rehab_track/data/services/notification/schedule_recovery_service.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/domain/entities/schedule_config.dart';
import 'package:rehab_track/domain/repositories/medication_repository.dart';
import 'package:rehab_track/presentation/utils/dose_formatter.dart';

class NotificationActionBridge {
  NotificationActionBridge({
    required this._notificationService,
    required ScheduleRecoveryService scheduleRecoveryService,
    required this._medicationRepository,
  }) : _scheduleRecoveryService = scheduleRecoveryService;

  final NotificationService _notificationService;
  final ScheduleRecoveryService _scheduleRecoveryService;
  final MedicationRepository _medicationRepository;

  Future<void> initialize({required int profileId}) async {
    _notificationService.setActionCallback(_handleAction);
    log('NotificationActionBridge: action callback registered');

    await _recoverSchedules(profileId);
  }

  void _handleAction(NotificationActionResponse response) {
    log('NotificationActionBridge: action=${response.actionType.name}, '
        'notificationId=${response.notificationId}');

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
