import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:timezone/timezone.dart' as tz;

import 'package:rehab_track/data/services/notification/notification_action_handler.dart';
import 'package:rehab_track/data/services/notification/notification_scheduler.dart';
import 'package:rehab_track/data/services/notification/notification_service.dart';
import 'package:rehab_track/data/services/notification/pending_action_store.dart';
import 'package:rehab_track/data/services/notification/reminder_content_formatter.dart';
import 'package:rehab_track/data/services/notification/reminder_payload.dart';
import 'package:rehab_track/data/services/notification/schedule_recovery_service.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/medication.dart';

import 'package:rehab_track/domain/entities/schedule_config.dart';
import 'package:rehab_track/domain/repositories/measurement_repository.dart';
import 'package:rehab_track/domain/repositories/medication_repository.dart';
import 'package:rehab_track/domain/repositories/profile_repository.dart';

enum ActionResult { success, alreadyCompleted, invalidPayload, entityNotFound, databaseError, unexpectedError }

class NotificationActionBridge {
  NotificationActionBridge({
    required NotificationService notificationService,
    required NotificationScheduler notificationScheduler,
    required this.scheduleRecoveryService,
    required this._medicationRepository,
    required this._measurementRepository,
    required this._profileRepository,
    required this.getSnoozeDuration,
    required this.showProfileName,
    required this.showDetailsOnLockScreen,
    this.onActionProcessed,
  })  : _notificationService = notificationService,
        _notificationScheduler = notificationScheduler;

  final NotificationService _notificationService;
  final NotificationScheduler _notificationScheduler;
  final ScheduleRecoveryService scheduleRecoveryService;
  final MedicationRepository _medicationRepository;
  final MeasurementRepository _measurementRepository;
  final ProfileRepository _profileRepository;
  final Duration Function() getSnoozeDuration;
  final bool Function() showProfileName;
  final bool Function() showDetailsOnLockScreen;
  final void Function(NotificationActionType actionType, ReminderPayload payload)? onActionProcessed;

  Future<void> initialize() async {
    _notificationService.setActionCallback(_handleAction);
    _notificationService.setNotificationTapCallback(_onNotificationTap);
    debugPrint('[NotificationActionBridge] action and tap callbacks registered');
  }

  Future<void> recoverAll(int profileId) async {
    await recoverMedicationSchedules(profileId);
    await recoverMeasurementSchedules(profileId);
  }

  Future<void> recoverMedicationSchedules(int profileId) =>
      _recoverMedicationSchedules(profileId);

  Future<void> recoverMeasurementSchedules(int profileId) =>
      _recoverMeasurementSchedules(profileId);

  Future<void> processPendingActions() async {
    final entries = await PendingActionStore.instance.consumeAll();
    if (entries.isEmpty) return;

    debugPrint('[NotificationActionBridge] processing ${entries.length} pending action(s)');

    for (final entry in entries) {
      try {
        await _executeAction(entry.toResponse());
      } catch (e) {
        debugPrint('[NotificationActionBridge] pending action failed: $e');
      }
    }
  }

  /// Check if the app was launched by a notification action (terminated process)
  /// and process it if so. This handles the case where the user taps a
  /// notification action button and the app was not running.
  Future<void> processAppLaunchAction() async {
    try {
      final launchDetails = await _notificationService.getLaunchDetails();
      if (launchDetails == null || !launchDetails.didNotificationLaunchApp) {
        return;
      }

      final response = launchDetails.notificationResponse;
      if (response == null) return;

      final actionId = response.actionId;
      if (actionId == null || actionId.isEmpty) return;

      final actionType = NotificationActionType.values.where(
        (t) => t.name == _actionIdToTypeName(actionId),
      ).firstOrNull;

      if (actionType == null) return;

      await _executeAction(
        NotificationActionResponse(
          notificationId: response.id ?? 0,
          actionId: actionId,
          actionType: actionType,
          payload: response.payload,
        ),
      );
    } catch (_) {
    }
  }

  /// Maps an Android action ID string to the corresponding enum name.
  String _actionIdToTypeName(String actionId) {
    return switch (actionId) {
      'medication_mark_taken' => 'medicationMarkTaken',
      'medication_snooze' => 'medicationSnooze',
      'medication_skip' => 'medicationSkip',
      'measurement_record_now' => 'measurementRecordNow',
      'measurement_snooze' => 'measurementSnooze',
      'measurement_skip' => 'measurementSkip',
      _ => actionId,
    };
  }

  Future<ActionResult> _executeAction(NotificationActionResponse response) async {
    final payload = ReminderPayload.parse(response.payload);
    if (payload == null) {
        return ActionResult.invalidPayload;
    }

    debugPrint('[NotificationActionBridge] action=${response.actionType.name} '
        'notificationId=${response.notificationId} scheduleId=${payload.scheduleId} '
        'type=${payload.type.name}');

    ActionResult result;
    switch (response.actionType) {
      case NotificationActionType.medicationMarkTaken:
        result = await _handleMedicationTaken(payload);
      case NotificationActionType.medicationSkip:
        result = await _handleMedicationSkip(payload);
      case NotificationActionType.medicationSnooze:
        result = await _handleMedicationSnooze(response, payload);
      case NotificationActionType.measurementRecordNow:
        result = await _handleMeasurementRecordNow(payload);
      case NotificationActionType.measurementSnooze:
        result = await _handleMeasurementSnooze(response, payload);
      case NotificationActionType.measurementSkip:
        result = await _handleMeasurementSkip(payload);
      case NotificationActionType.tap:
        result = ActionResult.success;
      case NotificationActionType.dismiss:
        result = ActionResult.success;
    }
    onActionProcessed?.call(response.actionType, payload);
    return result;
  }

  Future<void> _handleAction(NotificationActionResponse response) async {
    await _executeAction(response);
  }

  void _onNotificationTap() {
    debugPrint('[NotificationActionBridge] notification tap');
  }

  // --- Medication: Taken ---

  Future<ActionResult> _handleMedicationTaken(ReminderPayload payload) async {
    final now = DateTime.now();
    final scheduledTime = payload.occurrenceDateTime ?? now;

    try {
      final existing = await _medicationRepository.getLogForOccurrence(
        payload.scheduleId,
        scheduledTime,
      );

      if (existing != null) {
        debugPrint('[NotificationActionBridge] dose already logged for schedule '
            '${payload.scheduleId} at $scheduledTime, skipping duplicate');
        return ActionResult.alreadyCompleted;
      }

      final schedule = await _medicationRepository.getSchedule(payload.scheduleId);

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

      await _medicationRepository.logDose(logEntry);
      debugPrint('[NotificationActionBridge] marked taken schedule ${payload.scheduleId}');

      await _cancelOccurrenceNotifications(payload);
      return ActionResult.success;
    } catch (e) {
      debugPrint('[NotificationActionBridge] mark taken FAILED: $e');
      return ActionResult.databaseError;
    }
  }

  // --- Medication: Skip ---

  Future<ActionResult> _handleMedicationSkip(ReminderPayload payload) async {
    final now = DateTime.now();
    final scheduledTime = payload.occurrenceDateTime ?? now;

    try {
      final existing = await _medicationRepository.getLogForOccurrence(
        payload.scheduleId,
        scheduledTime,
      );

      if (existing != null) {
        debugPrint('[NotificationActionBridge] skip already logged for schedule '
            '${payload.scheduleId} at $scheduledTime');
        return ActionResult.alreadyCompleted;
      }

      final schedule = await _medicationRepository.getSchedule(payload.scheduleId);

      final logEntry = MedicationLog(
        medicationScheduleId: payload.scheduleId,
        scheduledTime: scheduledTime,
        status: 'skipped',
        createdAt: now,
        snapshotIntakeQuantity: schedule?.intakeQuantity,
        snapshotDosageForm: schedule?.dosageForm,
        snapshotCustomDosageForm: schedule?.customDosageForm,
      );

      await _medicationRepository.logDose(logEntry);
      debugPrint('[NotificationActionBridge] skipped schedule ${payload.scheduleId}');

      await _cancelOccurrenceNotifications(payload);
      return ActionResult.success;
    } catch (e) {
      debugPrint('[NotificationActionBridge] skip FAILED: $e');
      return ActionResult.databaseError;
    }
  }

  // --- Medication: Snooze ---

  Future<ActionResult> _handleMedicationSnooze(
    NotificationActionResponse response,
    ReminderPayload payload,
  ) async {
    try {
      final schedule = await _medicationRepository.getSchedule(payload.scheduleId);
      if (schedule == null) {
        debugPrint('[NotificationActionBridge] schedule ${payload.scheduleId} not found for snooze');
        return ActionResult.entityNotFound;
      }

      final medication = await _medicationRepository.getMedication(payload.medicationId!);
      if (medication == null) {
        debugPrint('[NotificationActionBridge] medication ${payload.medicationId} not found for snooze');
        return ActionResult.entityNotFound;
      }

      // Fetch components for dose info in snoozed notification title
      String? doseAmount = medication.doseAmount;
      String? doseUnit = medication.doseUnit;
      if ((doseAmount == null || doseAmount.isEmpty) && medication.id != null) {
        final components = await _medicationRepository.getComponents(medication.id!);
        if (components.isNotEmpty) {
          doseAmount = components.first.doseAmount;
          doseUnit = components.first.doseUnit;
        }
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

      final showName = showProfileName();

      final snoozePayload = ReminderPayload(
        type: ReminderType.medication,
        profileId: payload.profileId,
        scheduleId: payload.scheduleId,
        occurrenceTime: payload.occurrenceTime,
        medicationId: payload.medicationId,
        snoozeSourceOccurrence: payload.occurrenceTime,
        notificationId: NotificationService.snoozeNotificationId(
          response.notificationId,
        ),
      );

      final snoozeId = NotificationService.snoozeNotificationId(
        response.notificationId,
      );

      await _notificationScheduler.scheduleSingleOccurrence(
        notificationId: snoozeId,
        title: ReminderContentFormatter.medicationTitle(
          profile: profile,
          medication: medication,
          showProfileName: showName,
          doseAmount: doseAmount,
          doseUnit: doseUnit,
        ),
        body: ReminderContentFormatter.medicationBody(
          profile: profile,
          medication: medication,
          schedule: schedule,
          scheduledTime: scheduledOccurrence,
          showProfileName: showName,
        ),
        scheduledDate: scheduledDate,
        channelId: NotificationService.medicationChannelId,
        payload: snoozePayload.toJsonString(),
        includeActions: true,
        isMeasurement: false,
      );

      await _notificationService.cancelNotification(response.notificationId);

      debugPrint('[NotificationActionBridge] snoozed medication $snoozeId for $snoozeTime');
      return ActionResult.success;
    } catch (e) {
      debugPrint('[NotificationActionBridge] medication snooze FAILED: $e');
      return ActionResult.unexpectedError;
    }
  }

  // --- Measurement: Record Now ---

  Future<ActionResult> _handleMeasurementRecordNow(ReminderPayload payload) async {
    // Don't mark as completed here — the measurement entry form handles that
    // after the user enters and saves values successfully.
    // Navigation to the entry form happens via the onActionProcessed callback.
    return ActionResult.success;
  }

  // --- Measurement: Skip ---

  Future<ActionResult> _handleMeasurementSkip(ReminderPayload payload) async {
    final scheduledTime = payload.occurrenceDateTime ?? DateTime.now();

    try {
      final existing = await _measurementRepository.getReminderLog(
        payload.scheduleId,
        scheduledTime,
      );

      if (existing != null && existing.id != null) {
        if (existing.status == MeasurementReminderAction.skipped) {
          debugPrint('[NotificationActionBridge] measurement already skipped for schedule ${payload.scheduleId}');
          return ActionResult.alreadyCompleted;
        }
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
      debugPrint('[NotificationActionBridge] measurement skip schedule ${payload.scheduleId}');
      return ActionResult.success;
    } catch (e) {
      debugPrint('[NotificationActionBridge] measurement skip FAILED: $e');
      return ActionResult.databaseError;
    }
  }

  // --- Measurement: Snooze ---

  Future<ActionResult> _handleMeasurementSnooze(
    NotificationActionResponse response,
    ReminderPayload payload,
  ) async {
    try {
      final schedule = await _measurementRepository.getSchedule(payload.scheduleId);
      if (schedule == null) {
        debugPrint('[NotificationActionBridge] measurement schedule ${payload.scheduleId} not found for snooze');
        return ActionResult.entityNotFound;
      }

      final type = payload.measurementTypeId != null
          ? await _measurementRepository.getMeasurementType(payload.measurementTypeId!)
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

      final showName = showProfileName();

      final snoozePayload = ReminderPayload(
        type: ReminderType.measurement,
        profileId: payload.profileId,
        scheduleId: payload.scheduleId,
        occurrenceTime: payload.occurrenceTime,
        measurementTypeId: payload.measurementTypeId,
        snoozeSourceOccurrence: payload.occurrenceTime,
        notificationId: NotificationService.snoozeNotificationId(
          response.notificationId,
        ),
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
                showProfileName: showName,
              )
            : 'Measurement Reminder',
        body: type != null
            ? ReminderContentFormatter.measurementBody(
                profile: profile,
                type: type,
                schedule: schedule,
                scheduledTime: scheduledOccurrence,
                showProfileName: showName,
              )
            : 'Please record your measurement',
        scheduledDate: scheduledDate,
        channelId: NotificationService.measurementChannelId,
        payload: snoozePayload.toJsonString(),
        includeActions: true,
        isMeasurement: true,
      );

      await _notificationService.cancelNotification(response.notificationId);

      debugPrint('[NotificationActionBridge] snoozed measurement $snoozeId for $snoozeTime');
      return ActionResult.success;
    } catch (e) {
      debugPrint('[NotificationActionBridge] measurement snooze FAILED: $e');
      return ActionResult.unexpectedError;
    }
  }

  // --- Notification cancellation ---

  Future<void> _cancelOccurrenceNotifications(ReminderPayload payload) async {
    if (payload.notificationId != null) {
      await _notificationService.cancelNotification(payload.notificationId!);
    }
    final snoozeId = NotificationService.snoozeNotificationId(payload.notificationId ?? 0);
    await _notificationService.cancelNotification(snoozeId);
  }

  // --- Recovery ---

  Future<void> _recoverMedicationSchedules(int profileId) async {
    try {
      final entries = <ScheduleRecoveryEntry>[];

      final medications =
          await _medicationRepository.getMedications(profileId);

      for (final medication in medications) {
        if (!medication.active || medication.id == null) continue;

        // Fetch components to get dose info for notification title
        String? doseAmount = medication.doseAmount;
        String? doseUnit = medication.doseUnit;
        if ((doseAmount == null || doseAmount.isEmpty) && medication.id != null) {
          final components = await _medicationRepository.getComponents(medication.id!);
          if (components.isNotEmpty) {
            doseAmount = components.first.doseAmount;
            doseUnit = components.first.doseUnit;
          }
        }

        final schedules = await _medicationRepository
            .watchSchedules(medication.id!)
            .first;

        for (final schedule in schedules) {
          if (!schedule.active || schedule.id == null) continue;
          entries.add(
            _buildMedicationRecoveryEntry(
              medication,
              schedule,
              doseAmount: doseAmount,
              doseUnit: doseUnit,
            ),
          );
        }
      }

      if (entries.isEmpty) {
        debugPrint('[NotificationActionBridge] no active medication schedules to recover');
        return;
      }

      await scheduleRecoveryService.recoverAllSchedules(
        activeSchedules: entries,
      );
      debugPrint('[NotificationActionBridge] medication recovery complete, '
          '${entries.length} schedule entries processed');
    } catch (e) {
      debugPrint('[NotificationActionBridge] medication recovery FAILED: $e');
    }
  }

  ScheduleRecoveryEntry _buildMedicationRecoveryEntry(
    Medication medication,
    MedicationSchedule schedule, {
    String? doseAmount,
    String? doseUnit,
  }) {
    return ScheduleRecoveryEntry(
      scheduleId: schedule.id!,
      config: schedule.scheduleConfig,
      channelId: NotificationService.medicationChannelId,
      includeActions: true,
      isMeasurement: false,
      profileId: medication.profileId,
      title: ReminderContentFormatter.medicationTitle(
        profile: null,
        medication: medication,
        showProfileName: true,
        doseAmount: doseAmount,
        doseUnit: doseUnit,
      ),
      body: ReminderContentFormatter.medicationBody(
        profile: null,
        medication: medication,
        schedule: schedule,
        scheduledTime: DateTime.now(),
        showProfileName: true,
      ),
      startDate: schedule.startDate,
      endDate: schedule.endDate,
      perOccurrencePayload: (occDateTime) {
        return ReminderPayload(
          type: ReminderType.medication,
          profileId: medication.profileId,
          scheduleId: schedule.id!,
          occurrenceTime: occDateTime.toIso8601String(),
          medicationId: medication.id,
        ).toJsonString();
      },
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
        debugPrint('[NotificationActionBridge] no active measurement schedules to recover');
        return;
      }

      await scheduleRecoveryService.recoverAllSchedules(
        activeSchedules: entries,
      );
      debugPrint('[NotificationActionBridge] measurement recovery complete, '
          '${entries.length} schedule entries processed');
    } catch (e) {
      debugPrint('[NotificationActionBridge] measurement recovery FAILED: $e');
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
              showProfileName: true,
            )
          : 'Measurement Reminder',
      body: type != null
          ? ReminderContentFormatter.measurementBody(
              profile: null,
              type: type,
              schedule: schedule,
              scheduledTime: DateTime.now(),
              showProfileName: true,
            )
          : 'Please record your measurement',
      startDate: schedule.startDate,
      endDate: schedule.endDate,
    );
  }
}
