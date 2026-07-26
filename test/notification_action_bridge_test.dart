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
import 'package:rehab_track/domain/entities/dosage_form.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/domain/entities/medication_alternative.dart';
import 'package:rehab_track/domain/entities/medication_alternative_component.dart';
import 'package:rehab_track/domain/entities/medication_component.dart';
import 'package:rehab_track/domain/entities/schedule_config.dart';
import 'package:rehab_track/domain/repositories/measurement_repository.dart';
import 'package:rehab_track/domain/repositories/medication_repository.dart';

class FakeMeasurementRepository implements MeasurementRepository {
  final List<MeasurementReminderLog> logs = [];
  final Map<int, MeasurementSchedule> schedules = {};
  final Map<int, List<MeasurementSchedule>> schedulesByType = {};
  final Map<int, MeasurementType> types = {};

  @override
  Stream<List<MeasurementType>> watchActiveMeasurementTypes(int? profileId) => const Stream.empty();
  @override
  Stream<List<MeasurementType>> watchMeasurementTypes(int? profileId) => const Stream.empty();
  @override
  Future<List<MeasurementType>> getMeasurementTypes(int? profileId) async => [];
  @override
  Future<MeasurementType?> getMeasurementType(int id) async => types[id];
  @override
  Future<MeasurementType?> getMeasurementTypeByKey(String key) async => null;
  @override
  Future<int> createMeasurementType(MeasurementType type) async => 0;
  @override
  Future<void> updateMeasurementType(MeasurementType type) async {}
  @override
  Future<void> deactivateMeasurementType(int id) async {}
  @override
  Stream<List<MeasurementTypeField>> watchFieldsForType(int measurementTypeId) => const Stream.empty();
  @override
  Future<List<MeasurementTypeField>> getFieldsForType(int measurementTypeId) async => [];
  @override
  Stream<List<MeasurementRecord>> watchRecords(int profileId, {int? typeId, DateTime? from, DateTime? to, bool ascending = false}) => const Stream.empty();
  @override
  Future<List<MeasurementRecord>> getRecords(int profileId, {int? typeId, DateTime? from, DateTime? to, bool ascending = false}) async => [];
  @override
  Future<MeasurementRecord?> getRecord(int id) async => null;
  @override
  Future<int> createRecord(MeasurementRecord record, List<MeasurementRecordValue> values) async => 0;
  @override
  Future<void> updateRecord(MeasurementRecord record, List<MeasurementRecordValue> values) async {}
  @override
  Future<void> deleteRecord(int id) async {}
  @override
  Future<List<MeasurementRecordValue>> getValuesForRecord(int measurementRecordId) async => [];
  @override
  Future<Map<int, List<MeasurementRecordValue>>> getValuesForRecords(List<int> recordIds) async => {};
  @override
  Stream<List<MeasurementSchedule>> watchSchedules(int profileId) => const Stream.empty();
  @override
  Stream<List<MeasurementSchedule>> watchSchedulesForType(int measurementTypeId) => const Stream.empty();
  @override
  Future<MeasurementSchedule?> getSchedule(int id) async => schedules[id];
  @override
  Future<List<MeasurementSchedule>> getActiveSchedules(int profileId) async => schedules.values.where((s) => s.active).toList();
  @override
  Stream<List<MeasurementSchedule>> watchActiveSchedules(int profileId) => const Stream.empty();
  @override
  Future<int> createSchedule(MeasurementSchedule schedule) async => schedule.id ?? 1;
  @override
  Future<void> updateSchedule(MeasurementSchedule schedule) async {}
  @override
  Future<void> deleteSchedule(int id) async {}
  @override
  Future<int> logReminder(MeasurementReminderLog log) async { logs.add(log); return log.id ?? logs.length; }
  @override
  Future<void> updateReminderLog(MeasurementReminderLog log) async {}
  @override
  Future<MeasurementReminderLog?> getReminderLog(int scheduleId, DateTime scheduledTime) async => null;
  @override
  Future<List<MeasurementReminderLog>> getReminderLogsForSchedule(int scheduleId) async => [];
  @override
  Stream<List<MeasurementReminderLog>> watchReminderLogsForSchedule(int scheduleId) => const Stream.empty();
  @override
  Future<List<MeasurementReminderLog>> getTodayReminderLogs(int profileId) async => [];
}

class FakeMedicationRepository implements MedicationRepository {
  final List<MedicationLog> loggedDoses = [];
  final Map<int, Medication> medications = {};
  final Map<int, MedicationSchedule> schedules = {};
  final Map<int, List<MedicationSchedule>> schedulesByMedicationId = {};
  final Map<int, List<MedicationComponent>> componentsByMedicationId = {};
  final Map<int, List<MedicationAlternativeComponent>> componentsByAlternativeId = {};

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
  Future<List<Medication>> getActiveMedications(int profileId) async =>
      medications.values
          .where((m) => m.profileId == profileId && m.active)
          .toList();
  @override
  Future<List<MedicationSchedule>> getSchedulesForMedication(
    int medicationId,
  ) async =>
      schedulesByMedicationId[medicationId] ?? [];

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

  @override
  Stream<List<MedicationComponent>> watchComponents(int medicationId) async* {
    yield componentsByMedicationId[medicationId] ?? [];
  }

  @override
  Future<List<MedicationComponent>> getComponents(int medicationId) async =>
      componentsByMedicationId[medicationId] ?? [];

  @override
  Future<void> replaceMedicationComponents(
    int medicationId,
    List<MedicationComponent> components,
  ) async {
    componentsByMedicationId[medicationId] = components;
  }

  @override
  Stream<List<MedicationAlternativeComponent>>
      watchAlternativeComponents(int alternativeId) async* {
    yield componentsByAlternativeId[alternativeId] ?? [];
  }

  @override
  Future<List<MedicationAlternativeComponent>>
      getAlternativeComponents(int alternativeId) async =>
          componentsByAlternativeId[alternativeId] ?? [];

  @override
  Future<void> replaceAlternativeComponents(
    int alternativeId,
    List<MedicationAlternativeComponent> components,
  ) async {
    componentsByAlternativeId[alternativeId] = components;
  }
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
  Future<void> waitForInitialization() async {}

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
    test('DailySchedule with single time returns single ID', () {
      final ids = NotificationActionBridge.computeNotificationIds(
        scheduleId: 10,
        config: const DailySchedule(times: ['08:00']),
      );
      expect(ids, [10]);
    });

    test('DailySchedule with multiple times returns sequential IDs', () {
      final ids = NotificationActionBridge.computeNotificationIds(
        scheduleId: 10,
        config: const DailySchedule(times: ['08:00', '14:00', '20:00']),
      );
      expect(ids, [10, 11, 12]);
    });

    test('IntervalDaysSchedule returns sequential IDs', () {
      final ids = NotificationActionBridge.computeNotificationIds(
        scheduleId: 10,
        config: const IntervalDaysSchedule(intervalDays: 3, times: ['09:00']),
      );
      expect(ids, [10]);
    });

    test('IntervalDaysSchedule with multiple times returns sequential IDs', () {
      final ids = NotificationActionBridge.computeNotificationIds(
        scheduleId: 10,
        config: const IntervalDaysSchedule(
            intervalDays: 3, times: ['09:00', '21:00']),
      );
      expect(ids, [10, 11]);
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
        scheduleConfig: DailySchedule(times: ['08:00']),
        intakeQuantity: 1,
        dosageForm: DosageForm.tablet,
      );
      final body = NotificationActionBridge.buildNotificationBody(medication, schedule);
      expect(body, contains('200 mg'));
      expect(body, contains('1 tablet'));
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
        scheduleConfig: DailySchedule(times: ['08:00']),
        intakeQuantity: 1,
        dosageForm: DosageForm.unit,
        instructions: 'Take with food',
      );
      final body = NotificationActionBridge.buildNotificationBody(medication, schedule);
      expect(body, contains('Take with food'));
    });

    test('combines dose, intake quantity, and instructions', () {
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
        scheduleConfig: DailySchedule(times: ['08:00']),
        intakeQuantity: 2,
        dosageForm: DosageForm.capsule,
        instructions: 'After meals',
      );
      final body = NotificationActionBridge.buildNotificationBody(medication, schedule);
      expect(body, contains('200 mg'));
      expect(body, contains('2 capsules'));
      expect(body, contains('After meals'));
    });

    test('includes intake quantity with custom dosage form', () {
      final medication = Medication(
        profileId: 1,
        name: 'Insulin',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      const schedule = MedicationSchedule(
        medicationId: 1,
        scheduleType: 'daily',
        scheduleConfig: DailySchedule(times: ['08:00']),
        intakeQuantity: 1,
        dosageForm: DosageForm.other,
        customDosageForm: 'pump',
      );
      final body = NotificationActionBridge.buildNotificationBody(medication, schedule);
      expect(body, contains('1 pump'));
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
        measurementRepository: FakeMeasurementRepository(),
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
        scheduleConfig: const DailySchedule(times: ['08:00']),
        intakeQuantity: 1,
        dosageForm: DosageForm.tablet,
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
        contains('200 mg'),
      );
      expect(
        notificationService.scheduledNotifications.first['body'],
        contains('1 tablet'),
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
        measurementRepository: FakeMeasurementRepository(),
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
          scheduleConfig: const DailySchedule(times: ['08:00']),
          intakeQuantity: 1,
          dosageForm: DosageForm.tablet,
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
          scheduleConfig: const DailySchedule(times: ['08:00']),
          intakeQuantity: 1,
          dosageForm: DosageForm.tablet,
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
          scheduleConfig: const DailySchedule(times: ['08:00']),
          intakeQuantity: 1,
          dosageForm: DosageForm.tablet,
          active: false,
        ),
      ];

      await bridge.initialize(profileId: 1);
      expect(notificationService.actionCallback, isNotNull);
    });
  });
}
