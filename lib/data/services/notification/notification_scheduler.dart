import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../domain/entities/schedule_config.dart';
import 'notification_service.dart';

class NotificationScheduler {
  NotificationScheduler({required this._notificationService});

  final NotificationService _notificationService;

  Future<void> scheduleFromConfig({
    required int notificationId,
    required String title,
    required String body,
    required ScheduleConfig config,
    required NotificationChannelType channelType,
    String? payload,
    bool includeActions = false,
    tz.Location? location,
  }) async {
    final tzLocation = location ?? tz.local;

    switch (config) {
      case DailySchedule():
        await _scheduleDaily(
          notificationId: notificationId,
          title: title,
          body: body,
          time: config.time,
          channelType: channelType,
          payload: payload,
          includeActions: includeActions,
          location: tzLocation,
        );
      case FixedTimesSchedule():
        await _scheduleFixedTimes(
          baseNotificationId: notificationId,
          title: title,
          body: body,
          times: config.times,
          channelType: channelType,
          payload: payload,
          includeActions: includeActions,
          location: tzLocation,
        );
      case IntervalDaysSchedule():
        await _scheduleIntervalDays(
          notificationId: notificationId,
          title: title,
          body: body,
          interval: config.interval,
          time: config.time,
          channelType: channelType,
          payload: payload,
          includeActions: includeActions,
          location: tzLocation,
        );
    }
  }

  Future<void> _scheduleDaily({
    required int notificationId,
    required String title,
    required String body,
    required String time,
    required NotificationChannelType channelType,
    String? payload,
    bool includeActions = false,
    tz.Location? location,
  }) async {
    final scheduledDate = _nextOccurrence(time, location: location);
    if (scheduledDate == null) return;

    await _notificationService.scheduleRecurringNotification(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      matchComponents: DateTimeComponents.time,
      channelType: channelType,
      payload: payload,
      includeActions: includeActions,
    );
  }

  Future<void> _scheduleFixedTimes({
    required int baseNotificationId,
    required String title,
    required String body,
    required List<String> times,
    required NotificationChannelType channelType,
    String? payload,
    bool includeActions = false,
    tz.Location? location,
  }) async {
    for (var i = 0; i < times.length; i++) {
      final notificationId = baseNotificationId + i;
      final scheduledDate = _nextOccurrence(times[i], location: location);
      if (scheduledDate == null) continue;

      await _notificationService.scheduleRecurringNotification(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        matchComponents: DateTimeComponents.time,
        channelType: channelType,
        payload: payload,
        includeActions: includeActions,
      );
    }
  }

  Future<void> _scheduleIntervalDays({
    required int notificationId,
    required String title,
    required String body,
    required int interval,
    required String time,
    required NotificationChannelType channelType,
    String? payload,
    bool includeActions = false,
    tz.Location? location,
  }) async {
    final scheduledDate = _nextOccurrence(
      time,
      interval: interval,
      location: location,
    );
    if (scheduledDate == null) return;

    await _notificationService.scheduleNotification(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      channelType: channelType,
      payload: payload,
      includeActions: includeActions,
    );
  }

  tz.TZDateTime? _nextOccurrence(
    String time, {
    int interval = 1,
    tz.Location? location,
  }) {
    final parts = time.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    final tzLocation = location ?? tz.local;
    final now = tz.TZDateTime.now(tzLocation);
    var scheduled = tz.TZDateTime(tzLocation, now.year, now.month, now.day,
        hour, minute);

    if (interval <= 1) {
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
    } else {
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(Duration(days: interval));
      }
    }

    return scheduled;
  }

  Future<void> cancelNotification(int id) async {
    await _notificationService.cancelNotification(id);
  }

  Future<void> cancelNotificationsForSchedule({
    required int baseNotificationId,
    required ScheduleConfig config,
  }) async {
    switch (config) {
      case DailySchedule():
        await _notificationService.cancelNotification(baseNotificationId);
      case FixedTimesSchedule():
        for (var i = 0; i < config.times.length; i++) {
          await _notificationService
              .cancelNotification(baseNotificationId + i);
        }
      case IntervalDaysSchedule():
        await _notificationService.cancelNotification(baseNotificationId);
    }
  }
}
