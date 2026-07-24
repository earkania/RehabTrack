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
  })  : _scheduleRecoveryService = scheduleRecoveryService;

  final NotificationService _notificationService;
  final ScheduleRecoveryService _scheduleRecoveryService;
  final MedicationRepository _medicationRepository;

  /// Initialize the bridge: register action callback and recover schedules.
  Future<void> initialize({required int profileId}) async {
    _notificationService.setActionCallback(_handleAction);
    log('NotificationActionBridge: action callback registered');

    await _recoverSchedules(profileId);
  }

  /// Handle notification action from the user.
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

  /// Parse notification payload JSON.
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

  /// Handle Taken action: create MedicationLog with status 'taken'.
  Future<void> _handleTaken(NotificationPayload payload) async {
    final now = DateTime.now();
    final logEntry = MedicationLog(
      medicationScheduleId: payload.scheduleId,
      scheduledTime: now,
      takenTime: now,
      status: 'taken',
      createdAt: now,
    );

    try {
      await _medicationRepository.logDose(logEntry);
      log('NotificationActionBridge: logged taken dose for schedule '
          '${payload.scheduleId}');
    } catch (e) {
      log('NotificationActionBridge: failed to log taken dose: $e');
    }
  }

  /// Handle Skip action: create MedicationLog with status 'skipped'.
  Future<void> _handleSkipped(NotificationPayload payload) async {
    final now = DateTime.now();
    final logEntry = MedicationLog(
      medicationScheduleId: payload.scheduleId,
      scheduledTime: now,
      status: 'skipped',
      createdAt: now,
    );

    try {
      await _medicationRepository.logDose(logEntry);
      log('NotificationActionBridge: logged skipped dose for schedule '
          '${payload.scheduleId}');
    } catch (e) {
      log('NotificationActionBridge: failed to log skipped dose: $e');
    }
  }

  /// Handle Snooze action: reschedule notification for 10 minutes later.
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

  /// Recover all active medication schedules at app startup.
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

  /// Build a recovery entry for a medication schedule.
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

  /// Compute notification IDs for a schedule based on its config type.
  static List<int> computeNotificationIds({
    required int scheduleId,
    required ScheduleConfig config,
  }) {
    return switch (config) {
      DailySchedule() => [scheduleId],
      FixedTimesSchedule(:final times) =>
        List.generate(times.length, (i) => scheduleId + i),
      IntervalDaysSchedule() => [scheduleId],
    };
  }

  /// Build notification body from medication and schedule.
  static String buildNotificationBody(
    Medication medication,
    MedicationSchedule schedule,
  ) {
    final parts = <String>[];
    final dose = DoseFormatter.format(medication);
    if (dose.isNotEmpty) parts.add(dose);
    if (schedule.instructions != null && schedule.instructions!.isNotEmpty) {
      parts.add(schedule.instructions!);
    }
    return parts.isEmpty ? '' : parts.join(' — ');
  }

}

/// Parsed notification payload containing medication and schedule IDs.
class NotificationPayload {
  const NotificationPayload({
    required this.medicationId,
    required this.scheduleId,
  });

  final int medicationId;
  final int scheduleId;
}
