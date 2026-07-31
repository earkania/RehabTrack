import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../domain/entities/schedule_config.dart';
import 'notification_service.dart';

class NotificationScheduler {
  NotificationScheduler({
    required NotificationService notificationService,
    this.playSound = true,
    this.enableVibration = true,
    this.notificationVisibility = NotificationVisibility.public,
  }) : _notificationService = notificationService;

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
      final dayIndex = occ.dayIndex;
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
      playSound: playSound ?? this.playSound,
      enableVibration: enableVibration ?? this.enableVibration,
      visibility: visibility ?? notificationVisibility,
    );
    return notificationId;
  }

  /// Cancel a single occurrence notification for a specific scheduled time.
  Future<void> cancelOccurrenceNotification({
    required int scheduleId,
    required DateTime occurrenceDate,
    required DateTime scheduleStartDate,
    bool isMeasurement = false,
  }) async {
    final dayIndex = occurrenceDate.difference(scheduleStartDate).inDays;
    if (dayIndex < 0) return;

    final notificationId = isMeasurement
        ? NotificationService.measurementNotificationId(
            scheduleId: scheduleId,
            dayIndex: dayIndex,
            slotIndex: 0,
          )
        : NotificationService.medicationNotificationId(
            scheduleId: scheduleId,
            dayIndex: dayIndex,
            slotIndex: 0,
          );

    await _notificationService.cancelNotification(notificationId);
    final snoozeId = NotificationService.snoozeNotificationId(notificationId);
    await _notificationService.cancelNotification(snoozeId);
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
