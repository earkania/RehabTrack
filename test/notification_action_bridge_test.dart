import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:rehab_track/data/services/notification/notification_action_bridge.dart';
import 'package:rehab_track/data/services/notification/notification_action_handler.dart';
import 'package:rehab_track/data/services/notification/notification_scheduler.dart';
import 'package:rehab_track/data/services/notification/notification_service.dart';
import 'package:rehab_track/data/services/notification/schedule_recovery_service.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/domain/entities/medication_alternative.dart';
import 'package:rehab_track/domain/entities/schedule_config.dart';
import 'package:rehab_track/domain/repositories/medication_repository.dart';

class FakeMedicationRepository implements MedicationRepository {
  final List<MedicationLog> loggedDoses = [];
  final Map<int, Medication> medications = {};
  final Map<int, MedicationSchedule> schedules = {};
  final Map<int, List<MedicationSchedule>> schedulesByMedicationId = {};

  @override
  Future<int> logDose(MedicationLog log) async {
    loggedDoses.add(log);
    return loggedDoses.length;
  }

  @override
  Future<Medication?> getMedication(int id) async => medications[id];

  @override
  Future<MedicationSchedule?> getSchedule(int id) async => schedules[id];

  @override
  Future<List<Medication>> getMedications(int profileId) async =>
      medications.values.where((m) => m.profileId == profileId).toList();

  @override
  Stream<List<MedicationSchedule>> watchSchedules(int medicationId) async* {
    yield schedulesByMedicationId[medicationId] ?? [];
  }

  @override
  Stream<List<Medication>> watchMedications(int profileId) => const Stream.empty();

  @override
  Stream<List<Medication>> watchActiveMedications(int profileId) => const Stream.empty();

  @override
  Future<int> createMedication(Medication medication) async => 1;

  @override
  Future<void> updateMedication(Medication medication) async {}

  @override
  Future<void> deleteMedication(int id) async {}

  @override
  Future<int> createSchedule(MedicationSchedule schedule) async => 1;

  @override
  Future<void> updateSchedule(MedicationSchedule schedule) async {}

  @override
  Future<void> deleteSchedule(int id) async {}

  @override
  Stream<List<MedicationLog>> watchLogs(int scheduleId, {DateTime? from, DateTime? to}) => const Stream.empty();

  @override
  Future<List<MedicationLog>> getLogs(int scheduleId, {DateTime? from, DateTime? to}) async => [];

  @override
  Future<void> updateLog(MedicationLog log) async {}

  @override
  Stream<List<MedicationAlternative>> watchAlternatives(int medicationId) => const Stream.empty();

  @override
  Future<List<MedicationAlternative>> getAlternatives(int medicationId) async => [];

  @override
  Future<MedicationAlternative?> getAlternative(int id) async => null;

  @override
  Future<int> createAlternative(MedicationAlternative alternative) async => 1;

  @override
  Future<void> updateAlternative(MedicationAlternative alternative) async {}

  @override
  Future<void> deleteAlternative(int id) async {}
}

class FakeNotificationService implements NotificationService {
  NotificationActionCallback? actionCallback;
  final List<Map<String, dynamic>> scheduledNotifications = [];

  @override
  bool get isInitialized => true;

  @override
  void setActionCallback(NotificationActionCallback callback) {
    actionCallback = callback;
  }

  @override
  Future<bool> initialize() async => true;

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
    NotificationChannelType channelType = NotificationChannelType.general,
    bool includeActions = false,
  }) async {
    scheduledNotifications.add({
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate,
      'channelType': channelType,
      'payload': payload,
      'includeActions': includeActions,
    });
  }

  @override
  Future<void> scheduleRecurringNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required DateTimeComponents matchComponents,
    String? payload,
    NotificationChannelType channelType = NotificationChannelType.general,
    bool includeActions = false,
  }) async {}

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationChannelType channelType = NotificationChannelType.general,
    bool includeActions = false,
  }) async {}

  @override
  Future<void> cancelNotification(int id) async {}

  @override
  Future<void> cancelAllNotifications() async {}

  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async => [];

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async => [];

  @override
  Future<NotificationAppLaunchDetails?> getLaunchDetails() async => null;
}

class FakeNotificationScheduler extends NotificationScheduler {
  FakeNotificationScheduler() : super(notificationService: FakeNotificationService());
}

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('NotificationPayload parsing', () {
    test('parsePayload returns valid payload from correct JSON', () {
      final json = jsonEncode({'medicationId': 42, 'scheduleId': 7});
      final payload = NotificationActionBridge.parsePayload(json);
      expect(payload, isNotNull);
      expect(payload!.medicationId, 42);
      expect(payload.scheduleId, 7);
    });

    test('parsePayload returns null for null input', () {
      expect(NotificationActionBridge.parsePayload(null), isNull);
    });

    test('parsePayload returns null for empty string', () {
      expect(NotificationActionBridge.parsePayload(''), isNull);
    });

    test('parsePayload returns null for invalid JSON', () {
      expect(NotificationActionBridge.parsePayload('not json'), isNull);
    });

    test('parsePayload returns null when medicationId is missing', () {
      final json = jsonEncode({'scheduleId': 7});
      expect(NotificationActionBridge.parsePayload(json), isNull);
    });

    test('parsePayload returns null when scheduleId is missing', () {
      final json = jsonEncode({'medicationId': 42});
      expect(NotificationActionBridge.parsePayload(json), isNull);
    });
  });

  group('computeNotificationIds', () {
    test('DailySchedule returns single ID', () {
      final ids = NotificationActionBridge.computeNotificationIds(
        scheduleId: 10,
        config: const DailySchedule(time: '08:00'),
      );
      expect(ids, [10]);
    });

    test('FixedTimesSchedule returns sequential IDs', () {
      final ids = NotificationActionBridge.computeNotificationIds(
        scheduleId: 10,
        config: const FixedTimesSchedule(times: ['08:00', '14:00', '20:00']),
      );
      expect(ids, [10, 11, 12]);
    });

    test('IntervalDaysSchedule returns single ID', () {
      final ids = NotificationActionBridge.computeNotificationIds(
        scheduleId: 10,
        config: const IntervalDaysSchedule(interval: 3, time: '09:00'),
      );
      expect(ids, [10]);
    });
  });

  group('buildNotificationBody', () {
    test('includes dose amount and unit', () {
      final medication = Medication(
        profileId: 1,
        name: 'Ibuprofen',
        doseAmount: '200',
        doseUnit: 'mg',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      const schedule = MedicationSchedule(
        medicationId: 1,
        scheduleType: 'daily',
        scheduleConfig: DailySchedule(time: '08:00'),
      );
      final body = NotificationActionBridge.buildNotificationBody(medication, schedule);
      expect(body, '200 mg');
    });

    test('includes instructions', () {
      final medication = Medication(
        profileId: 1,
        name: 'Vitamin D',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      const schedule = MedicationSchedule(
        medicationId: 1,
        scheduleType: 'daily',
        scheduleConfig: DailySchedule(time: '08:00'),
        instructions: 'Take with food',
      );
      final body = NotificationActionBridge.buildNotificationBody(medication, schedule);
      expect(body, 'Take with food');
    });

    test('combines dose and instructions with dash separator', () {
      final medication = Medication(
        profileId: 1,
        name: 'Ibuprofen',
        doseAmount: '200',
        doseUnit: 'mg',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      const schedule = MedicationSchedule(
        medicationId: 1,
        scheduleType: 'daily',
        scheduleConfig: DailySchedule(time: '08:00'),
        instructions: 'After meals',
      );
      final body = NotificationActionBridge.buildNotificationBody(medication, schedule);
      expect(body, '200 mg — After meals');
    });

    test('returns empty string when no dose or instructions', () {
      final medication = Medication(
        profileId: 1,
        name: 'Vitamin D',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      const schedule = MedicationSchedule(
        medicationId: 1,
        scheduleType: 'daily',
        scheduleConfig: DailySchedule(time: '08:00'),
      );
      final body = NotificationActionBridge.buildNotificationBody(medication, schedule);
      expect(body, '');
    });
  });

  group('Action handling', () {
    late FakeMedicationRepository repo;
    late FakeNotificationService notificationService;
    late NotificationActionBridge bridge;

    setUp(() {
      repo = FakeMedicationRepository();
      notificationService = FakeNotificationService();
      final recoveryService = ScheduleRecoveryService(
        notificationService: notificationService,
        notificationScheduler: FakeNotificationScheduler(),
      );
      bridge = NotificationActionBridge(
        notificationService: notificationService,
        scheduleRecoveryService: recoveryService,
        medicationRepository: repo,
      );
    });

    test('initialize registers action callback', () async {
      await bridge.initialize(profileId: 1);
      expect(notificationService.actionCallback, isNotNull);
    });

    test('taken action logs dose with status taken', () async {
      await bridge.initialize(profileId: 1);

      final response = NotificationActionResponse(
        notificationId: 10,
        actionId: 'taken',
        actionType: NotificationActionType.taken,
        payload: jsonEncode({'medicationId': 1, 'scheduleId': 10}),
      );

      notificationService.actionCallback!(response);

      await Future<void>.delayed(Duration.zero);

      expect(repo.loggedDoses, hasLength(1));
      expect(repo.loggedDoses.first.status, 'taken');
      expect(repo.loggedDoses.first.medicationScheduleId, 10);
      expect(repo.loggedDoses.first.takenTime, isNotNull);
    });

    test('skipped action logs dose with status skipped', () async {
      await bridge.initialize(profileId: 1);

      final response = NotificationActionResponse(
        notificationId: 10,
        actionId: 'skipped',
        actionType: NotificationActionType.skipped,
        payload: jsonEncode({'medicationId': 1, 'scheduleId': 10}),
      );

      notificationService.actionCallback!(response);

      await Future<void>.delayed(Duration.zero);

      expect(repo.loggedDoses, hasLength(1));
      expect(repo.loggedDoses.first.status, 'skipped');
      expect(repo.loggedDoses.first.takenTime, isNull);
    });

    test('snooze action schedules notification 10 minutes later', () async {
      final schedule = MedicationSchedule(
        id: 10,
        medicationId: 1,
        scheduleType: 'daily',
        scheduleConfig: const DailySchedule(time: '08:00'),
      );
      repo.schedules[10] = schedule;
      repo.medications[1] = Medication(
        id: 1,
        profileId: 1,
        name: 'Ibuprofen',
        doseAmount: '200',
        doseUnit: 'mg',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );

      await bridge.initialize(profileId: 1);

      final response = NotificationActionResponse(
        notificationId: 10,
        actionId: 'snoozed',
        actionType: NotificationActionType.snoozed,
        payload: jsonEncode({'medicationId': 1, 'scheduleId': 10}),
      );

      notificationService.actionCallback!(response);

      // Multiple delays to allow chained async operations to complete
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(notificationService.scheduledNotifications, hasLength(1));
      expect(notificationService.scheduledNotifications.first['id'], 10);
      expect(
        notificationService.scheduledNotifications.first['title'],
        'Time to take Ibuprofen',
      );
      expect(
        notificationService.scheduledNotifications.first['body'],
        '200 mg',
      );
      expect(notificationService.scheduledNotifications.first['includeActions'], true);
    });

    test('action with null payload is ignored', () async {
      await bridge.initialize(profileId: 1);

      final response = NotificationActionResponse(
        notificationId: 10,
        actionId: 'taken',
        actionType: NotificationActionType.taken,
        payload: null,
      );

      notificationService.actionCallback!(response);

      await Future<void>.delayed(Duration.zero);

      expect(repo.loggedDoses, isEmpty);
    });
  });

  group('Schedule recovery', () {
    late FakeMedicationRepository repo;
    late FakeNotificationService notificationService;
    late NotificationActionBridge bridge;

    setUp(() {
      repo = FakeMedicationRepository();
      notificationService = FakeNotificationService();
      final recoveryService = ScheduleRecoveryService(
        notificationService: notificationService,
        notificationScheduler: FakeNotificationScheduler(),
      );
      bridge = NotificationActionBridge(
        notificationService: notificationService,
        scheduleRecoveryService: recoveryService,
        medicationRepository: repo,
      );
    });

    test('recoverSchedules runs without errors with active schedules', () async {
      final now = DateTime(2025);
      repo.medications[1] = Medication(
        id: 1,
        profileId: 1,
        name: 'Aspirin',
        active: true,
        createdAt: now,
        updatedAt: now,
      );
      repo.schedulesByMedicationId[1] = [
        MedicationSchedule(
          id: 10,
          medicationId: 1,
          scheduleType: 'daily',
          scheduleConfig: const DailySchedule(time: '08:00'),
          active: true,
        ),
      ];

      await bridge.initialize(profileId: 1);

      expect(notificationService.actionCallback, isNotNull);
    });

    test('recoverSchedules handles empty active schedules', () async {
      await bridge.initialize(profileId: 1);
      expect(notificationService.actionCallback, isNotNull);
    });

    test('recoverSchedules skips inactive medications', () async {
      final now = DateTime(2025);
      repo.medications[1] = Medication(
        id: 1,
        profileId: 1,
        name: 'Aspirin',
        active: false,
        createdAt: now,
        updatedAt: now,
      );
      repo.schedulesByMedicationId[1] = [
        MedicationSchedule(
          id: 10,
          medicationId: 1,
          scheduleType: 'daily',
          scheduleConfig: const DailySchedule(time: '08:00'),
          active: true,
        ),
      ];

      await bridge.initialize(profileId: 1);
      expect(notificationService.actionCallback, isNotNull);
    });

    test('recoverSchedules skips inactive schedules', () async {
      final now = DateTime(2025);
      repo.medications[1] = Medication(
        id: 1,
        profileId: 1,
        name: 'Aspirin',
        active: true,
        createdAt: now,
        updatedAt: now,
      );
      repo.schedulesByMedicationId[1] = [
        MedicationSchedule(
          id: 10,
          medicationId: 1,
          scheduleType: 'daily',
          scheduleConfig: const DailySchedule(time: '08:00'),
          active: false,
        ),
      ];

      await bridge.initialize(profileId: 1);
      expect(notificationService.actionCallback, isNotNull);
    });
  });
}
