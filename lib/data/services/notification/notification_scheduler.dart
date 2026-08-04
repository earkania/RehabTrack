import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../domain/entities/schedule_config.dart';
import 'notification_service.dart';

class NotificationScheduler {
  NotificationScheduler({
    required this._notificationService,
    this.playSound = true,
    this.enableVibration = true,
    this.notificationVisibility = NotificationVisibility.public,
  });

  final NotificationService _notificationService;
  final bool playSound;
  final bool enableVibration;
  final NotificationVisibility notificationVisibility;

  static const _schedulingHorizonDays = 30;

  Future<List<int>> scheduleOccurrences({
    required int scheduleId,
    required String title,
    required String body,
    required ScheduleConfig config,
    required String channelId,
    String? payload,
    String Function(tz.TZDateTime occDateTime)? perOccurrencePayload,
    bool includeActions = false,
    bool isMeasurement = false,
    DateTime? startDate,
    DateTime? endDate,
    bool? playSound,
    bool? enableVibration,
    tz.Location? location,
    NotificationVisibility? visibility,
  }) async {
    final tzLocation = location ?? tz.local;
    final now = tz.TZDateTime.now(tzLocation);
    final effectiveStart = _effectiveStart(now, startDate);
    final effectiveEnd = _effectiveEnd(endDate);

    final occurrences = _computeOccurrences(
      config: config,
      start: effectiveStart,
      end: effectiveEnd,
      now: now,
      tzLocation: tzLocation,
    );

    final scheduledIds = <int>[];

    for (final occ in occurrences) {
      // dayIndex must be anchored to the schedule's canonical startDate so
      // that scheduling and cancellation produce the same notification ID.
      // Using max(now, startDate) as the anchor here would make the ID for a
      // given calendar occurrence shift across days and break cancellation.
      final dayIndex = startDate != null
          ? dayIndexFromStartDate(occ.dateTime, startDate)
          : occ.dayIndex;
      final slotIndex = occ.slotIndex;

      final notificationId = isMeasurement
          ? NotificationService.measurementNotificationId(
              scheduleId: scheduleId,
              dayIndex: dayIndex,
              slotIndex: slotIndex,
            )
          : NotificationService.medicationNotificationId(
              scheduleId: scheduleId,
              dayIndex: dayIndex,
              slotIndex: slotIndex,
            );

      final occPayload = perOccurrencePayload != null
          ? perOccurrencePayload(occ.dateTime)
          : payload;

      try {
        await _notificationService.scheduleNotification(
          id: notificationId,
          title: title,
          body: body,
          scheduledDate: occ.dateTime,
          payload: occPayload,
          channelId: channelId,
          includeActions: includeActions,
          isMeasurement: isMeasurement,
          playSound: playSound ?? this.playSound,
          enableVibration: enableVibration ?? this.enableVibration,
          visibility: visibility ?? notificationVisibility,
        );
        scheduledIds.add(notificationId);
      } catch (_) {}
    }

    return scheduledIds;
  }

  Future<int> scheduleSingleOccurrence({
    required int notificationId,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required String channelId,
    String? payload,
    bool includeActions = false,
    bool isMeasurement = false,
    bool isDoctorVisit = false,
    bool? playSound,
    bool? enableVibration,
    NotificationVisibility? visibility,
  }) async {
    await _notificationService.scheduleNotification(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: payload,
      channelId: channelId,
      includeActions: includeActions,
      isMeasurement: isMeasurement,
      isDoctorVisit: isDoctorVisit,
      playSound: playSound ?? this.playSound,
      enableVibration: enableVibration ?? this.enableVibration,
      visibility: visibility ?? notificationVisibility,
    );
    return notificationId;
  }

  /// Cancel a single occurrence notification for a specific scheduled time.
  ///
  /// [scheduleStartDate] must be the schedule's canonical start date so the
  /// computed [dayIndex] matches the one used when the notification was
  /// scheduled. [slotIndex] identifies which daily slot of the schedule the
  /// occurrence belongs to (0 for the first time of day, 1 for the second, ...).
  Future<void> cancelOccurrenceNotification({
    required int scheduleId,
    required DateTime occurrenceDate,
    required DateTime scheduleStartDate,
    bool isMeasurement = false,
    int slotIndex = 0,
  }) async {
    final dayIndex = dayIndexFromStartDate(occurrenceDate, scheduleStartDate);
    if (dayIndex < 0) return;

    final notificationId = isMeasurement
        ? NotificationService.measurementNotificationId(
            scheduleId: scheduleId,
            dayIndex: dayIndex,
            slotIndex: slotIndex,
          )
        : NotificationService.medicationNotificationId(
            scheduleId: scheduleId,
            dayIndex: dayIndex,
            slotIndex: slotIndex,
          );

    debugPrint('[NotificationScheduler] cancelOccurrence '
        'scheduleId=$scheduleId occurrence=$occurrenceDate '
        'isMeasurement=$isMeasurement dayIndex=$dayIndex slotIndex=$slotIndex '
        'notificationId=$notificationId');

    try {
      await _notificationService.cancelNotification(notificationId);
      final snoozeId = NotificationService.snoozeNotificationId(notificationId);
      await _notificationService.cancelNotification(snoozeId);
      debugPrint('[NotificationScheduler] cancelled notificationId=$notificationId '
          'snoozeId=$snoozeId result=success');
    } catch (e) {
      debugPrint('[NotificationScheduler] cancelled notificationId=$notificationId '
          'result=failed error=$e');
      rethrow;
    }
  }

  /// Cancel all notifications in the given range.
  Future<void> cancelNotificationsInRange({
    required int scheduleId,
    required ScheduleConfig config,
    bool isMeasurement = false,
  }) async {
    final maxSlots = config.times.length;
    for (var dayIndex = 0; dayIndex < _schedulingHorizonDays; dayIndex++) {
      for (var slotIndex = 0; slotIndex < maxSlots; slotIndex++) {
        final notificationId = isMeasurement
            ? NotificationService.measurementNotificationId(
                scheduleId: scheduleId,
                dayIndex: dayIndex,
                slotIndex: slotIndex,
              )
            : NotificationService.medicationNotificationId(
                scheduleId: scheduleId,
                dayIndex: dayIndex,
                slotIndex: slotIndex,
              );
        try {
          await _notificationService.cancelNotification(notificationId);
        } catch (_) {}
      }
    }
  }

  /// Day offset of [occurrenceDate] relative to [scheduleStartDate], using
  /// date-only values so the result is stable regardless of the time-of-day
  /// stored on either DateTime. This is the single source of truth for the
  /// dayIndex used in occurrence notification IDs and must be identical for
  /// both scheduling and cancellation.
  @visibleForTesting
  static int dayIndexFromStartDate(
    DateTime occurrenceDate,
    DateTime scheduleStartDate,
  ) {
    final occDate = DateTime(
      occurrenceDate.year,
      occurrenceDate.month,
      occurrenceDate.day,
    );
    final startDate = DateTime(
      scheduleStartDate.year,
      scheduleStartDate.month,
      scheduleStartDate.day,
    );
    return occDate.difference(startDate).inDays;
  }

  /// Index of the daily slot whose "HH:MM" time matches [occurrenceDate]'s
  /// time-of-day. Slots are ordered as the times appear in the schedule config,
  /// matching the order used by [scheduleOccurrences]. Returns 0 when no time
  /// matches (callers should then skip relying on a specific slot).
  static int slotIndexForTime(List<String> times, DateTime occurrenceDate) {
    for (var i = 0; i < times.length; i++) {
      final parts = times[i].split(':');
      if (parts.length != 2) continue;
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == occurrenceDate.hour && minute == occurrenceDate.minute) {
        return i;
      }
    }
    return 0;
  }

  tz.TZDateTime _effectiveStart(tz.TZDateTime now, DateTime? startDate) {
    if (startDate == null) return now;
    final tzStart = _toTZ(now.location, startDate);
    return tzStart.isAfter(now) ? tzStart : now;
  }

  tz.TZDateTime _effectiveEnd(DateTime? endDate) {
    if (endDate == null) {
      final location = tz.local;
      return tz.TZDateTime(location, 2099, 12, 31);
    }
    return _toTZ(tz.local, endDate);
  }

  tz.TZDateTime _toTZ(tz.Location location, DateTime date) {
    return tz.TZDateTime(
      location,
      date.year,
      date.month,
      date.day,
      date.hour,
      date.minute,
    );
  }

  List<_Occurrence> _computeOccurrences({
    required ScheduleConfig config,
    required tz.TZDateTime start,
    required tz.TZDateTime end,
    required tz.TZDateTime now,
    required tz.Location tzLocation,
  }) {
    final results = <_Occurrence>[];

    switch (config) {
      case DailySchedule(:final times):
        for (var dayOffset = 0; dayOffset < _schedulingHorizonDays; dayOffset++) {
          final day = start.add(Duration(days: dayOffset));
          if (day.isAfter(end)) break;
          for (var slotIndex = 0; slotIndex < times.length; slotIndex++) {
            final time = times[slotIndex];
            final parsed = _parseTime(time, day, tzLocation);
            if (parsed == null) continue;
            if (parsed.isBefore(now)) continue;
            if (parsed.isAfter(end)) continue;
            results.add(_Occurrence(
              dateTime: parsed,
              dayIndex: dayOffset,
              slotIndex: slotIndex,
            ));
          }
        }

      case IntervalDaysSchedule(:final intervalDays, :final times):
        var dayOffset = 0;
        var currentDay = start;
        while (dayOffset < _schedulingHorizonDays &&
            !currentDay.isAfter(end)) {
          for (var slotIndex = 0; slotIndex < times.length; slotIndex++) {
            final time = times[slotIndex];
            final parsed = _parseTime(time, currentDay, tzLocation);
            if (parsed == null) continue;
            if (parsed.isBefore(now)) continue;
            if (parsed.isAfter(end)) continue;
            results.add(_Occurrence(
              dateTime: parsed,
              dayIndex: dayOffset,
              slotIndex: slotIndex,
            ));
          }
          dayOffset += intervalDays;
          currentDay = start.add(Duration(days: dayOffset));
        }
    }

    return results;
  }

  tz.TZDateTime? _parseTime(
    String time,
    tz.TZDateTime day,
    tz.Location location,
  ) {
    final parts = time.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return tz.TZDateTime(location, day.year, day.month, day.day, hour, minute);
  }
}

class _Occurrence {
  final tz.TZDateTime dateTime;
  final int dayIndex;
  final int slotIndex;

  const _Occurrence({
    required this.dateTime,
    required this.dayIndex,
    required this.slotIndex,
  });
}
