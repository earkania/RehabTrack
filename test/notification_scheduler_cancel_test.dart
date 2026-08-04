import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:rehab_track/data/services/notification/notification_scheduler.dart';
import 'package:rehab_track/data/services/notification/notification_service.dart';
import 'package:rehab_track/domain/entities/schedule_config.dart';

class _RecordingNotificationService extends NotificationService {
  final List<Map<String, dynamic>> scheduledNotifications = [];
  final List<int> cancelledIds = [];

  @override
  bool get isInitialized => true;

  @override
  Future<bool> initialize() async => true;

  @override
  Future<void> waitForInitialization() async {}

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
    required String channelId,
    bool includeActions = false,
    bool isMeasurement = false,
    bool isDoctorVisit = false,
    bool playSound = true,
    bool enableVibration = true,
    NotificationVisibility visibility = NotificationVisibility.public,
  }) async {
    scheduledNotifications.add({
      'id': id,
      'scheduledDate': scheduledDate,
      'channelId': channelId,
    });
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    required String channelId,
    bool includeActions = false,
    bool isMeasurement = false,
    bool isDoctorVisit = false,
    bool playSound = true,
    bool enableVibration = true,
    NotificationVisibility visibility = NotificationVisibility.public,
  }) async {}

  @override
  Future<void> cancelNotification(int id) async {
    cancelledIds.add(id);
  }

  @override
  Future<void> cancelNotifications(List<int> ids) async {
    cancelledIds.addAll(ids);
  }

  @override
  Future<void> cancelAllNotifications() async {}

  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async => [];

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async => [];

  @override
  Future<NotificationAppLaunchDetails?> getLaunchDetails() async => null;

  @override
  Future<bool> hasNotificationPermission() async => true;

  @override
  Future<bool> hasExactAlarmPermission() async => true;
}

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  late _RecordingNotificationService service;
  late NotificationScheduler scheduler;

  setUp(() {
    service = _RecordingNotificationService();
    scheduler = NotificationScheduler(notificationService: service);
  });

  DateTime futureStartDate() {
    final base = DateTime.now().add(const Duration(days: 5));
    return DateTime(base.year, base.month, base.day);
  }

  DateTime atTime(DateTime day, int hour, int minute) =>
      DateTime(day.year, day.month, day.day, hour, minute);

  group('dayIndexFromStartDate', () {
    test('is stable regardless of time-of-day on either input', () {
      final startDate = DateTime(2026, 6, 1, 14, 32);
      expect(
        NotificationScheduler.dayIndexFromStartDate(DateTime(2026, 6, 11, 10, 0), startDate),
        10,
      );
      expect(
        NotificationScheduler.dayIndexFromStartDate(DateTime(2026, 6, 1, 0, 0), startDate),
        0,
      );
      expect(
        NotificationScheduler.dayIndexFromStartDate(DateTime(2026, 5, 30, 23, 59), startDate),
        -2,
      );
    });
  });

  group('slotIndexForTime', () {
    test('matches the slot whose time-of-day equals the occurrence', () {
      const times = ['08:00', '20:00'];
      expect(
        NotificationScheduler.slotIndexForTime(times, atTime(DateTime(2026, 6, 1), 8, 0)),
        0,
      );
      expect(
        NotificationScheduler.slotIndexForTime(times, atTime(DateTime(2026, 6, 1), 20, 0)),
        1,
      );
    });

    test('falls back to 0 when no time matches', () {
      expect(
        NotificationScheduler.slotIndexForTime(const ['08:00'], atTime(DateTime(2026, 6, 1), 13, 30)),
        0,
      );
    });
  });

  group('cancelOccurrenceNotification', () {
    test('cancels exactly the notification ID that scheduling produced for a '
        'past-startDate schedule', () async {
      final startDate = DateTime.now().subtract(const Duration(days: 10));
      const scheduleId = 7;

      await scheduler.scheduleOccurrences(
        scheduleId: scheduleId,
        title: 'Medication',
        body: 'Take now',
        config: const DailySchedule(times: ['10:00']),
        channelId: NotificationService.medicationChannelId,
        startDate: startDate,
        isMeasurement: false,
      );

      expect(service.scheduledNotifications, isNotEmpty);

      final firstOccurrence = service.scheduledNotifications
          .toList()
        ..sort((a, b) {
          final aDate = (a['scheduledDate'] as tz.TZDateTime);
          final bDate = (b['scheduledDate'] as tz.TZDateTime);
          return aDate.compareTo(bDate);
        });
      final first = firstOccurrence.first;
      final occurrenceDate = (first['scheduledDate'] as tz.TZDateTime);
      final scheduledId = first['id'] as int;

      // The ID used at scheduling must equal the startDate-anchored formula
      // that cancellation recomputes.
      final expectedId = NotificationService.medicationNotificationId(
        scheduleId: scheduleId,
        dayIndex: NotificationScheduler.dayIndexFromStartDate(occurrenceDate, startDate),
        slotIndex: 0,
      );
      expect(scheduledId, expectedId);

      await scheduler.cancelOccurrenceNotification(
        scheduleId: scheduleId,
        occurrenceDate: occurrenceDate,
        scheduleStartDate: startDate,
        isMeasurement: false,
      );

      expect(service.cancelledIds, contains(scheduledId));
      expect(
        service.cancelledIds,
        contains(NotificationService.snoozeNotificationId(scheduledId)),
      );
    });

    test('does not cancel future occurrences of the same schedule', () async {
      final startDate = futureStartDate();
      const scheduleId = 7;

      await scheduler.scheduleOccurrences(
        scheduleId: scheduleId,
        title: 'Medication',
        body: 'Take now',
        config: const DailySchedule(times: ['10:00']),
        channelId: NotificationService.medicationChannelId,
        startDate: startDate,
        isMeasurement: false,
      );

      final todayId = NotificationService.medicationNotificationId(
        scheduleId: scheduleId,
        dayIndex: 0,
        slotIndex: 0,
      );
      final tomorrowId = NotificationService.medicationNotificationId(
        scheduleId: scheduleId,
        dayIndex: 1,
        slotIndex: 0,
      );
      final dayAfterId = NotificationService.medicationNotificationId(
        scheduleId: scheduleId,
        dayIndex: 2,
        slotIndex: 0,
      );

      await scheduler.cancelOccurrenceNotification(
        scheduleId: scheduleId,
        occurrenceDate: atTime(startDate, 10, 0),
        scheduleStartDate: startDate,
        isMeasurement: false,
      );

      expect(service.cancelledIds, contains(todayId));
      expect(service.cancelledIds, isNot(contains(tomorrowId)));
      expect(service.cancelledIds, isNot(contains(dayAfterId)));
    });

    test('uses the measurement notification ID namespace for measurements', () async {
      final startDate = futureStartDate();
      const scheduleId = 3;

      await scheduler.scheduleOccurrences(
        scheduleId: scheduleId,
        title: 'Blood pressure',
        body: 'Measure now',
        config: const DailySchedule(times: ['08:00']),
        channelId: NotificationService.measurementChannelId,
        startDate: startDate,
        isMeasurement: true,
      );

      final measurementId = NotificationService.measurementNotificationId(
        scheduleId: scheduleId,
        dayIndex: 0,
        slotIndex: 0,
      );
      final medicationId = NotificationService.medicationNotificationId(
        scheduleId: scheduleId,
        dayIndex: 0,
        slotIndex: 0,
      );

      await scheduler.cancelOccurrenceNotification(
        scheduleId: scheduleId,
        occurrenceDate: atTime(startDate, 8, 0),
        scheduleStartDate: startDate,
        isMeasurement: true,
      );

      expect(service.cancelledIds, contains(measurementId));
      expect(service.cancelledIds, isNot(contains(medicationId)));
    });

    test('cancels the correct slot for multi-time schedules', () async {
      final startDate = futureStartDate();
      const scheduleId = 9;

      await scheduler.scheduleOccurrences(
        scheduleId: scheduleId,
        title: 'Medication',
        body: 'Take now',
        config: const DailySchedule(times: ['08:00', '20:00']),
        channelId: NotificationService.medicationChannelId,
        startDate: startDate,
        isMeasurement: false,
      );

      final eveningId = NotificationService.medicationNotificationId(
        scheduleId: scheduleId,
        dayIndex: 0,
        slotIndex: 1,
      );
      final morningId = NotificationService.medicationNotificationId(
        scheduleId: scheduleId,
        dayIndex: 0,
        slotIndex: 0,
      );

      await scheduler.cancelOccurrenceNotification(
        scheduleId: scheduleId,
        occurrenceDate: atTime(startDate, 20, 0),
        scheduleStartDate: startDate,
        isMeasurement: false,
        slotIndex: NotificationScheduler.slotIndexForTime(
          const ['08:00', '20:00'],
          atTime(startDate, 20, 0),
        ),
      );

      expect(service.cancelledIds, contains(eveningId));
      expect(service.cancelledIds, isNot(contains(morningId)));
    });

    test('cancelling an occurrence before the schedule start is a safe no-op',
        () async {
      final startDate = futureStartDate();
      const scheduleId = 11;

      await scheduler.scheduleOccurrences(
        scheduleId: scheduleId,
        title: 'Medication',
        body: 'Take now',
        config: const DailySchedule(times: ['10:00']),
        channelId: NotificationService.medicationChannelId,
        startDate: startDate,
        isMeasurement: false,
      );

      await scheduler.cancelOccurrenceNotification(
        scheduleId: scheduleId,
        occurrenceDate: atTime(startDate.subtract(const Duration(days: 1)), 10, 0),
        scheduleStartDate: startDate,
        isMeasurement: false,
      );

      expect(service.cancelledIds, isEmpty);
    });

    test('cancelling an already cancelled occurrence does not fail', () async {
      final startDate = futureStartDate();
      const scheduleId = 13;

      await scheduler.cancelOccurrenceNotification(
        scheduleId: scheduleId,
        occurrenceDate: atTime(startDate, 10, 0),
        scheduleStartDate: startDate,
        isMeasurement: false,
      );

      await scheduler.cancelOccurrenceNotification(
        scheduleId: scheduleId,
        occurrenceDate: atTime(startDate, 10, 0),
        scheduleStartDate: startDate,
        isMeasurement: false,
      );

      expect(service.cancelledIds.length, 4);
    });
  });
}
