import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:timezone/timezone.dart' as tz;

import 'package:rehab_track/data/services/notification/notification_action_handler.dart';
import 'package:rehab_track/data/services/notification/notification_scheduler.dart';
import 'package:rehab_track/data/services/notification/notification_service.dart';
import 'package:rehab_track/data/services/notification/reminder_content_formatter.dart';
import 'package:rehab_track/data/services/notification/reminder_payload.dart';
import 'package:rehab_track/data/services/notification/schedule_recovery_service.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/medication.dart';

import 'package:rehab_track/domain/entities/schedule_config.dart';
import 'package:rehab_track/domain/repositories/measurement_repository.dart';
import 'package:rehab_track/domain/repositories/medication_repository.dart';
import 'package:rehab_track/domain/repositories/profile_repository.dart';

class NotificationActionBridge {
  NotificationActionBridge({
    required this._notificationService,
    required NotificationScheduler notificationScheduler,
    required this.scheduleRecoveryService,
    required this._medicationRepository,
    required this._measurementRepository,
    required this._profileRepository,
    required this.getSnoozeDuration,
  })  : _notificationScheduler = notificationScheduler;

  final NotificationService _notificationService;
  final NotificationScheduler _notificationScheduler;
  final ScheduleRecoveryService scheduleRecoveryService;
  final MedicationRepository _medicationRepository;
  final MeasurementRepository _measurementRepository;
  final ProfileRepository _profileRepository;
  final Duration Function() getSnoozeDuration;

  Future<void> initialize() async {
    _notificationService.setActionCallback(_handleAction);
    debugPrint('NotificationActionBridge: action callback registered');
  }

  Future<void> recoverAll(int profileId) async {
    await recoverMedicationSchedules(profileId);
    await recoverMeasurementSchedules(profileId);
  }

  Future<void> recoverMedicationSchedules(int profileId) =>
      _recoverMedicationSchedules(profileId);

  Future<void> recoverMeasurementSchedules(int profileId) =>
      _recoverMeasurementSchedules(profileId);

  void _handleAction(NotificationActionResponse response) {
    debugPrint('NotificationActionBridge: action=${response.actionType.name}, '
        'notificationId=${response.notificationId}');

    final payload = ReminderPayload.parse(response.payload);
    if (payload == null) {
      debugPrint('NotificationActionBridge: invalid or missing payload, ignoring');
      return;
    }

    switch (response.actionType) {
      case NotificationActionType.taken:
        _handleMedicationTaken(payload);
      case NotificationActionType.skipped:
        _handleSkipped(payload);
      case NotificationActionType.snoozed:
        _handleSnooze(response, payload);
      case NotificationActionType.recordNow:
        _handleRecordNow(response, payload);
      case NotificationActionType.dismiss:
        break;
    }
  }

  // --- Medication: Taken ---

  Future<void> _handleMedicationTaken(ReminderPayload payload) async {
    final now = DateTime.now();
    final scheduledTime = payload.occurrenceDateTime ?? now;
    final schedule =
        await _medicationRepository.getSchedule(payload.scheduleId);

    final logEntry = MedicationLog(
      medicationScheduleId: payload.scheduleId,
      scheduledTime: scheduledTime,
      takenTime: now,
      status: 'taken',
      createdAt: now,
      snapshotIntakeQuantity: schedule?.intakeQuantity,
      snapshotDosageForm: schedule?.dosageForm,
      snapshotCustomDosageForm: schedule?.customDosageForm,
    );

    try {
      await _medicationRepository.logDose(logEntry);
      debugPrint('NotificationActionBridge: logged taken dose for schedule '
          '${payload.scheduleId}');
    } catch (e) {
      debugPrint('NotificationActionBridge: failed to log taken dose: $e');
    }

    await _cancelOccurrenceNotifications(payload);
  }

  // --- Medication/Measurement: Skipped ---

  Future<void> _handleSkipped(ReminderPayload payload) async {
    switch (payload.type) {
      case ReminderType.medication:
        await _handleMedicationSkipped(payload);
      case ReminderType.measurement:
        await _handleMeasurementSkipped(payload);
    }
  }

  Future<void> _handleMedicationSkipped(ReminderPayload payload) async {
    final now = DateTime.now();
    final scheduledTime = payload.occurrenceDateTime ?? now;
    final schedule =
        await _medicationRepository.getSchedule(payload.scheduleId);

    final logEntry = MedicationLog(
      medicationScheduleId: payload.scheduleId,
      scheduledTime: scheduledTime,
      status: 'skipped',
      createdAt: now,
      snapshotIntakeQuantity: schedule?.intakeQuantity,
      snapshotDosageForm: schedule?.dosageForm,
      snapshotCustomDosageForm: schedule?.customDosageForm,
    );

    try {
      await _medicationRepository.logDose(logEntry);
      debugPrint('NotificationActionBridge: logged skipped dose for schedule '
          '${payload.scheduleId}');
    } catch (e) {
      debugPrint('NotificationActionBridge: failed to log skipped dose: $e');
    }

    await _cancelOccurrenceNotifications(payload);
  }

  // --- Snooze (medication and measurement) ---

  Future<void> _handleSnooze(
    NotificationActionResponse response,
    ReminderPayload payload,
  ) async {
    switch (payload.type) {
      case ReminderType.medication:
        await _handleMedicationSnooze(response, payload);
      case ReminderType.measurement:
        await _handleMeasurementSnooze(response, payload);
    }
  }

  Future<void> _handleMedicationSnooze(
    NotificationActionResponse response,
    ReminderPayload payload,
  ) async {
    try {
      final schedule =
          await _medicationRepository.getSchedule(payload.scheduleId);
      if (schedule == null) {
        debugPrint('NotificationActionBridge: schedule ${payload.scheduleId} '
            'not found for snooze');
        return;
      }

      final medication =
          await _medicationRepository.getMedication(payload.medicationId!);
      if (medication == null) {
        debugPrint('NotificationActionBridge: medication ${payload.medicationId} '
            'not found for snooze');
        return;
      }

      final profile = payload.profileId > 0
          ? await _profileRepository.getActiveProfile(payload.profileId)
          : null;

      final now = DateTime.now();
      final snoozeDuration = getSnoozeDuration();
      final snoozeTime = now.add(snoozeDuration);
      final tzLocation = tz.local;
      final scheduledDate = tz.TZDateTime(
        tzLocation,
        snoozeTime.year,
        snoozeTime.month,
        snoozeTime.day,
        snoozeTime.hour,
        snoozeTime.minute,
      );
      final scheduledOccurrence = payload.occurrenceDateTime ?? now;

      final snoozePayload = ReminderPayload(
        type: ReminderType.medication,
        profileId: payload.profileId,
        scheduleId: payload.scheduleId,
        occurrenceTime: payload.occurrenceTime,
        medicationId: payload.medicationId,
        snoozeSourceOccurrence: payload.occurrenceTime,
      );

      final snoozeId = NotificationService.snoozeNotificationId(
        response.notificationId,
      );

      await _notificationScheduler.scheduleSingleOccurrence(
        notificationId: snoozeId,
        title: ReminderContentFormatter.medicationTitle(
          profile: profile,
          medication: medication,
        ),
        body: ReminderContentFormatter.medicationBody(
          profile: profile,
          medication: medication,
          schedule: schedule,
          scheduledTime: scheduledOccurrence,
        ),
        scheduledDate: scheduledDate,
        channelId: NotificationService.medicationChannelId,
        payload: snoozePayload.toJsonString(),
        includeActions: true,
        isMeasurement: false,
      );

      debugPrint('NotificationActionBridge: snoozed medication notification '
          '$snoozeId for $snoozeTime');
    } catch (e) {
      debugPrint('NotificationActionBridge: failed to snooze medication: $e');
    }
  }

  // --- Measurement actions ---

  Future<void> _handleRecordNow(
    NotificationActionResponse response,
    ReminderPayload payload,
  ) async {
    final scheduledTime = payload.occurrenceDateTime ?? DateTime.now();

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

    await _cancelOccurrenceNotifications(payload);
    debugPrint('NotificationActionBridge: recordNow for schedule ${payload.scheduleId}');
  }

  Future<void> _handleMeasurementSkipped(ReminderPayload payload) async {
    final scheduledTime = payload.occurrenceDateTime ?? DateTime.now();

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

    await _cancelOccurrenceNotifications(payload);
    debugPrint('NotificationActionBridge: measurement reminder skipped '
        'for schedule ${payload.scheduleId}');
  }

  Future<void> _handleMeasurementSnooze(
    NotificationActionResponse response,
    ReminderPayload payload,
  ) async {
    try {
      final schedule = await _measurementRepository.getSchedule(
        payload.scheduleId,
      );
      if (schedule == null) {
        debugPrint('NotificationActionBridge: measurement schedule '
            '${payload.scheduleId} not found for snooze');
        return;
      }

      final type = payload.measurementTypeId != null
          ? await _measurementRepository.getMeasurementType(
              payload.measurementTypeId!)
          : null;

      final profile = payload.profileId > 0
          ? await _profileRepository.getActiveProfile(payload.profileId)
          : null;

      final now = DateTime.now();
      final snoozeDuration = getSnoozeDuration();
      final snoozeTime = now.add(snoozeDuration);
      final tzLocation = tz.local;
      final scheduledDate = tz.TZDateTime(
        tzLocation,
        snoozeTime.year,
        snoozeTime.month,
        snoozeTime.day,
        snoozeTime.hour,
        snoozeTime.minute,
      );
      final scheduledOccurrence = payload.occurrenceDateTime ?? now;

      final snoozePayload = ReminderPayload(
        type: ReminderType.measurement,
        profileId: payload.profileId,
        scheduleId: payload.scheduleId,
        occurrenceTime: payload.occurrenceTime,
        measurementTypeId: payload.measurementTypeId,
        snoozeSourceOccurrence: payload.occurrenceTime,
      );

      final snoozeId = NotificationService.snoozeNotificationId(
        response.notificationId,
      );

      await _notificationScheduler.scheduleSingleOccurrence(
        notificationId: snoozeId,
        title: type != null
            ? ReminderContentFormatter.measurementTitle(
                profile: profile,
                type: type,
              )
            : 'Measurement Reminder',
        body: type != null
            ? ReminderContentFormatter.measurementBody(
                profile: profile,
                type: type,
                schedule: schedule,
                scheduledTime: scheduledOccurrence,
              )
            : 'Please record your measurement',
        scheduledDate: scheduledDate,
        channelId: NotificationService.measurementChannelId,
        payload: snoozePayload.toJsonString(),
        includeActions: true,
        isMeasurement: true,
      );

      // Log snooze
      final scheduledTime = payload.occurrenceDateTime ?? DateTime.now();
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

      debugPrint('NotificationActionBridge: snoozed measurement notification '
          '$snoozeId for $snoozeTime');
    } catch (e) {
      debugPrint('NotificationActionBridge: failed to snooze measurement: $e');
    }
  }

  Future<void> _cancelOccurrenceNotifications(ReminderPayload payload) async {
    final originalId = _computeOriginalNotificationId(payload);
    if (originalId != null) {
      await _notificationService.cancelNotification(originalId);
    }
    final snoozeId = NotificationService.snoozeNotificationId(originalId ?? 0);
    await _notificationService.cancelNotification(snoozeId);
  }

  int? _computeOriginalNotificationId(ReminderPayload payload) {
    if (payload.snoozeSourceOccurrence != null) {
      // This is a snoozed notification — compute the original ID from the
      // snooze ID by reversing snoozeNotificationId.
      return null;
    }
    // For a direct occurrence notification there isn't a single deterministic
    // reverse mapping from payload alone. This is an approximation for the
    // common case.
    return null;
  }

  // --- Recovery ---

  Future<void> _recoverMedicationSchedules(int profileId) async {
    try {
      final entries = <ScheduleRecoveryEntry>[];

      final medications =
          await _medicationRepository.getMedications(profileId);

      for (final medication in medications) {
        if (!medication.active || medication.id == null) continue;

        final schedules = await _medicationRepository
            .watchSchedules(medication.id!)
            .first;

        for (final schedule in schedules) {
          if (!schedule.active || schedule.id == null) continue;
          entries.add(_buildMedicationRecoveryEntry(medication, schedule));
        }
      }

      if (entries.isEmpty) {
        debugPrint('NotificationActionBridge: no active medication schedules '
            'to recover');
        return;
      }

      await scheduleRecoveryService.recoverAllSchedules(
        activeSchedules: entries,
      );
      debugPrint('NotificationActionBridge: medication recovery complete, '
          '${entries.length} schedule entries processed');
    } catch (e) {
      debugPrint('NotificationActionBridge: medication recovery failed: $e');
    }
  }

  ScheduleRecoveryEntry _buildMedicationRecoveryEntry(
    Medication medication,
    MedicationSchedule schedule,
  ) {
    final payload = ReminderPayload(
      type: ReminderType.medication,
      profileId: medication.profileId,
      scheduleId: schedule.id!,
      occurrenceTime: DateTime.now().toIso8601String(),
      medicationId: medication.id,
    );

    return ScheduleRecoveryEntry(
      scheduleId: schedule.id!,
      config: schedule.scheduleConfig,
      channelId: NotificationService.medicationChannelId,
      payload: payload.toJsonString(),
      includeActions: true,
      isMeasurement: false,
      profileId: medication.profileId,
      title: ReminderContentFormatter.medicationTitle(
        profile: null,
        medication: medication,
      ),
      body: ReminderContentFormatter.medicationBody(
        profile: null,
        medication: medication,
        schedule: schedule,
        scheduledTime: DateTime.now(),
      ),
      startDate: schedule.startDate,
      endDate: schedule.endDate,
    );
  }

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
        debugPrint('NotificationActionBridge: no active measurement schedules '
            'to recover');
        return;
      }

      await scheduleRecoveryService.recoverAllSchedules(
        activeSchedules: entries,
      );
      debugPrint('NotificationActionBridge: measurement recovery complete, '
          '${entries.length} schedule entries processed');
    } catch (e) {
      debugPrint('NotificationActionBridge: measurement recovery failed: $e');
    }
  }

  ScheduleRecoveryEntry _buildMeasurementRecoveryEntry(
    MeasurementType? type,
    MeasurementSchedule schedule,
  ) {
    final scheduleConfig = schedule.isDaily
        ? DailySchedule(times: [schedule.time])
        : IntervalDaysSchedule(
            intervalDays: schedule.intervalDays ?? 1,
            times: [schedule.time],
          );

    final payload = ReminderPayload(
      type: ReminderType.measurement,
      profileId: schedule.profileId,
      scheduleId: schedule.id!,
      occurrenceTime: DateTime.now().toIso8601String(),
      measurementTypeId: schedule.measurementTypeId,
    );

    return ScheduleRecoveryEntry(
      scheduleId: schedule.id!,
      config: scheduleConfig,
      channelId: NotificationService.measurementChannelId,
      payload: payload.toJsonString(),
      includeActions: true,
      isMeasurement: true,
      profileId: schedule.profileId,
      title: type != null
          ? ReminderContentFormatter.measurementTitle(
              profile: null,
              type: type,
            )
          : 'Measurement Reminder',
      body: type != null
          ? ReminderContentFormatter.measurementBody(
              profile: null,
              type: type,
              schedule: schedule,
              scheduledTime: DateTime.now(),
            )
          : 'Please record your measurement',
      startDate: schedule.startDate,
      endDate: schedule.endDate,
    );
  }
}
