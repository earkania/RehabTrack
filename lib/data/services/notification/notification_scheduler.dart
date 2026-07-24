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
      case DailySchedule(:final times):
        await _scheduleDaily(
          baseNotificationId: notificationId,
          title: title,
          body: body,
          times: times,
          channelType: channelType,
          payload: payload,
          includeActions: includeActions,
          location: tzLocation,
        );
      case IntervalDaysSchedule(:final intervalDays, :final times):
        await _scheduleIntervalDays(
          baseNotificationId: notificationId,
          title: title,
          body: body,
          intervalDays: intervalDays,
          times: times,
          channelType: channelType,
          payload: payload,
          includeActions: includeActions,
          location: tzLocation,
        );
    }
  }

  Future<void> _scheduleDaily({
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
    required int baseNotificationId,
    required String title,
    required String body,
    required int intervalDays,
    required List<String> times,
    required NotificationChannelType channelType,
    String? payload,
    bool includeActions = false,
    tz.Location? location,
  }) async {
    for (var i = 0; i < times.length; i++) {
      final notificationId = baseNotificationId + i;
      final scheduledDate = _nextOccurrence(
        times[i],
        interval: intervalDays,
        location: location,
      );
      if (scheduledDate == null) continue;

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
    final times = config.times;
    for (var i = 0; i < times.length; i++) {
      await _notificationService.cancelNotification(baseNotificationId + i);
    }
  }
}
