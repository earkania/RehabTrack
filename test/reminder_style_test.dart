import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:rehab_track/data/services/notification/notification_scheduler.dart';
import 'package:rehab_track/data/services/notification/notification_service.dart';
import 'package:rehab_track/domain/entities/reminder_style.dart';
import 'package:rehab_track/domain/entities/schedule_config.dart';

class _RecordingNotificationService extends NotificationService {
  final List<Map<String, dynamic>> scheduledNotifications = [];

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
    bool fullScreenIntent = false,
  }) async {
    scheduledNotifications.add({
      'id': id,
      'scheduledDate': scheduledDate,
      'channelId': channelId,
      'fullScreenIntent': fullScreenIntent,
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
    bool fullScreenIntent = false,
  }) async {}

  @override
  Future<void> cancelNotification(int id) async {}

  @override
  Future<void> cancelNotifications(List<int> ids) async {}

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

  DateTime futureStartDate() {
    final base = DateTime.now().add(const Duration(days: 5));
    return DateTime(base.year, base.month, base.day);
  }

  group('ReminderStyle storage', () {
    test('persists stable values, not localized labels', () {
      expect(ReminderStyle.standard.storageValue, 'standard');
      expect(ReminderStyle.prominent.storageValue, 'prominent');
      expect(ReminderStyle.alarmStyle.storageValue, 'alarmStyle');
    });

    test('parses persisted values', () {
      expect(ReminderStyle.fromStorageValue('standard'), ReminderStyle.standard);
      expect(ReminderStyle.fromStorageValue('prominent'), ReminderStyle.prominent);
      expect(ReminderStyle.fromStorageValue('alarmStyle'), ReminderStyle.alarmStyle);
    });

    test('unknown or missing values fall back to standard', () {
      expect(ReminderStyle.fromStorageValue(null), ReminderStyle.standard);
      expect(ReminderStyle.fromStorageValue('alarm'), ReminderStyle.standard);
      expect(ReminderStyle.fromStorageValue(''), ReminderStyle.standard);
    });
  });

  group('channelForReminderStyle', () {
    test('standard style keeps the per-event channel', () {
      expect(
        NotificationService.channelForReminderStyle(
          style: ReminderStyle.standard,
          eventChannelId: NotificationService.medicationChannelId,
        ),
        NotificationService.medicationChannelId,
      );
      expect(
        NotificationService.channelForReminderStyle(
          style: ReminderStyle.standard,
          eventChannelId: NotificationService.measurementChannelId,
        ),
        NotificationService.measurementChannelId,
      );
      expect(
        NotificationService.channelForReminderStyle(
          style: ReminderStyle.standard,
          eventChannelId: NotificationService.doctorVisitChannelId,
        ),
        NotificationService.doctorVisitChannelId,
      );
    });

    test('prominent style routes all event types to the prominent channel', () {
      const eventChannels = [
        NotificationService.medicationChannelId,
        NotificationService.measurementChannelId,
        NotificationService.doctorVisitChannelId,
      ];
      for (final eventChannel in eventChannels) {
        expect(
          NotificationService.channelForReminderStyle(
            style: ReminderStyle.prominent,
            eventChannelId: eventChannel,
          ),
          NotificationService.prominentChannelId,
        );
      }
    });

    test('alarm style routes all event types to the alarm channel', () {
      const eventChannels = [
        NotificationService.medicationChannelId,
        NotificationService.measurementChannelId,
        NotificationService.doctorVisitChannelId,
      ];
      for (final eventChannel in eventChannels) {
        expect(
          NotificationService.channelForReminderStyle(
            style: ReminderStyle.alarmStyle,
            eventChannelId: eventChannel,
          ),
          NotificationService.alarmChannelId,
        );
      }
    });
  });

  group('NotificationScheduler style-aware channel selection', () {
    test('standard style schedules occurrences on the event channel', () async {
      final service = _RecordingNotificationService();
      final scheduler = NotificationScheduler(
        notificationService: service,
        reminderStyle: ReminderStyle.standard,
      );

      await scheduler.scheduleOccurrences(
        scheduleId: 1,
        title: 'Medication',
        body: 'Take now',
        config: const DailySchedule(times: ['10:00']),
        channelId: NotificationService.medicationChannelId,
        startDate: futureStartDate(),
        isMeasurement: false,
      );

      expect(service.scheduledNotifications, isNotEmpty);
      final channels = service.scheduledNotifications
          .map((e) => e['channelId'] as String)
          .toSet();
      expect(channels, {NotificationService.medicationChannelId});
    });

    test('prominent style schedules occurrences on the prominent channel', () async {
      final service = _RecordingNotificationService();
      final scheduler = NotificationScheduler(
        notificationService: service,
        reminderStyle: ReminderStyle.prominent,
      );

      await scheduler.scheduleOccurrences(
        scheduleId: 1,
        title: 'Medication',
        body: 'Take now',
        config: const DailySchedule(times: ['10:00']),
        channelId: NotificationService.medicationChannelId,
        startDate: futureStartDate(),
        isMeasurement: false,
      );

      expect(service.scheduledNotifications, isNotEmpty);
      final channels = service.scheduledNotifications
          .map((e) => e['channelId'] as String)
          .toSet();
      expect(channels, {NotificationService.prominentChannelId});
    });

    test('scheduleSingleOccurrence selects prominent channel in prominent mode',
        () async {
      final service = _RecordingNotificationService();
      final scheduler = NotificationScheduler(
        notificationService: service,
        reminderStyle: ReminderStyle.prominent,
      );

      final date = futureStartDate();
      final tzDate = tz.TZDateTime(tz.local, date.year, date.month, date.day, 9, 0);
      await scheduler.scheduleSingleOccurrence(
        notificationId: 123,
        title: 'Doctor visit',
        body: 'You have an appointment',
        scheduledDate: tzDate,
        channelId: NotificationService.doctorVisitChannelId,
        isDoctorVisit: true,
      );

      expect(
        service.scheduledNotifications.single['channelId'],
        NotificationService.prominentChannelId,
      );
    });

    test('notification IDs are identical across styles', () async {
      final standardService = _RecordingNotificationService();
      final prominentService = _RecordingNotificationService();
      final startDate = futureStartDate();

      final standardScheduler = NotificationScheduler(
        notificationService: standardService,
        reminderStyle: ReminderStyle.standard,
      );
      final prominentScheduler = NotificationScheduler(
        notificationService: prominentService,
        reminderStyle: ReminderStyle.prominent,
      );

      await standardScheduler.scheduleOccurrences(
        scheduleId: 5,
        title: 'BP',
        body: 'Measure',
        config: const DailySchedule(times: ['08:00']),
        channelId: NotificationService.measurementChannelId,
        startDate: startDate,
        isMeasurement: true,
      );
      await prominentScheduler.scheduleOccurrences(
        scheduleId: 5,
        title: 'BP',
        body: 'Measure',
        config: const DailySchedule(times: ['08:00']),
        channelId: NotificationService.measurementChannelId,
        startDate: startDate,
        isMeasurement: true,
      );

      final standardIds = standardService.scheduledNotifications
          .map((e) => e['id'] as int)
          .toSet();
      final prominentIds = prominentService.scheduledNotifications
          .map((e) => e['id'] as int)
          .toSet();
      expect(standardIds, prominentIds);
      expect(standardIds, isNotEmpty);
    });

    test('alarm style requests full-screen intent only when capability allows',
        () async {
      final fsiService = _RecordingNotificationService();
      final fallbackService = _RecordingNotificationService();
      final startDate = futureStartDate();

      final fsiScheduler = NotificationScheduler(
        notificationService: fsiService,
        reminderStyle: ReminderStyle.alarmStyle,
        fullScreenIntentForAlarm: true,
      );
      final fallbackScheduler = NotificationScheduler(
        notificationService: fallbackService,
        reminderStyle: ReminderStyle.alarmStyle,
        fullScreenIntentForAlarm: false,
      );

      Future<void> schedule(NotificationScheduler scheduler) =>
          scheduler.scheduleOccurrences(
            scheduleId: 7,
            title: 'Medication',
            body: 'Take now',
            config: const DailySchedule(times: ['10:00']),
            channelId: NotificationService.medicationChannelId,
            startDate: startDate,
            isMeasurement: false,
          );

      await schedule(fsiScheduler);
      await schedule(fallbackScheduler);

      expect(
        fsiService.scheduledNotifications
            .every((e) => e['fullScreenIntent'] == true),
        isTrue,
      );
      expect(fsiService.scheduledNotifications, isNotEmpty);
      expect(
        fallbackService.scheduledNotifications
            .every((e) => e['fullScreenIntent'] == false),
        isTrue,
      );
      expect(fallbackService.scheduledNotifications, isNotEmpty);
    });

    test('alarm style schedules on the alarm channel with full-screen intent',
        () async {
      final service = _RecordingNotificationService();
      final scheduler = NotificationScheduler(
        notificationService: service,
        reminderStyle: ReminderStyle.alarmStyle,
        fullScreenIntentForAlarm: true,
      );

      await scheduler.scheduleOccurrences(
        scheduleId: 9,
        title: 'Medication',
        body: 'Take now',
        config: const DailySchedule(times: ['10:00']),
        channelId: NotificationService.medicationChannelId,
        startDate: futureStartDate(),
        isMeasurement: false,
      );

      expect(service.scheduledNotifications, isNotEmpty);
      expect(
        service.scheduledNotifications.map((e) => e['channelId']).toSet(),
        {NotificationService.alarmChannelId},
      );
      expect(
        service.scheduledNotifications
            .every((e) => e['fullScreenIntent'] == true),
        isTrue,
      );
    });

    test('non-alarm styles never request full-screen intent', () async {
      for (final style in [ReminderStyle.standard, ReminderStyle.prominent]) {
        final service = _RecordingNotificationService();
        final scheduler = NotificationScheduler(
          notificationService: service,
          reminderStyle: style,
          fullScreenIntentForAlarm: true,
        );
        await scheduler.scheduleOccurrences(
          scheduleId: 11,
          title: 'Medication',
          body: 'Take now',
          config: const DailySchedule(times: ['10:00']),
          channelId: NotificationService.medicationChannelId,
          startDate: futureStartDate(),
          isMeasurement: false,
        );
        expect(service.scheduledNotifications, isNotEmpty);
        expect(
          service.scheduledNotifications
              .every((e) => e['fullScreenIntent'] == false),
          isTrue,
        );
      }
    });
  });

  group('Test notification IDs', () {
    test('stable test IDs never collide with real notification ID ranges', () {
      expect(NotificationService.testMedicationNotificationId, isNot(
        NotificationService.testMeasurementNotificationId,
      ));
      expect(NotificationService.testAlarmNotificationId, isNot(
        NotificationService.testMedicationNotificationId,
      ));
      expect(NotificationService.testAlarmNotificationId, isNot(
        NotificationService.testMeasurementNotificationId,
      ));

      // Higher than the doctor visit offset (5M), far above all real ranges.
      expect(
        NotificationService.testMedicationNotificationId,
        greaterThan(NotificationService.doctorVisitNotificationId(1)),
      );
      expect(
        NotificationService.testMeasurementNotificationId,
        greaterThan(NotificationService.snoozeNotificationId(
          NotificationService.doctorVisitNotificationId(1),
        )),
      );
      expect(
        NotificationService.testAlarmNotificationId,
        greaterThan(NotificationService.snoozeNotificationId(
          NotificationService.doctorVisitNotificationId(1),
        )),
      );
    });
  });
}