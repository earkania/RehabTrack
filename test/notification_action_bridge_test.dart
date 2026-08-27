import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:rehab_track/data/services/notification/alarm_presentation.dart';
import 'package:rehab_track/data/services/notification/notification_action_bridge.dart';
import 'package:rehab_track/data/services/notification/notification_action_handler.dart';
import 'package:rehab_track/data/services/notification/notification_scheduler.dart';
import 'package:rehab_track/data/services/notification/notification_service.dart';
import 'package:rehab_track/data/services/notification/reminder_content_formatter.dart';
import 'package:rehab_track/data/services/notification/reminder_payload.dart';
import 'package:rehab_track/data/services/notification/schedule_recovery_service.dart';
import 'package:rehab_track/domain/entities/dosage_form.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/domain/entities/medication_alternative.dart';
import 'package:rehab_track/domain/entities/medication_alternative_component.dart';
import 'package:rehab_track/domain/entities/medication_component.dart';
import 'package:rehab_track/domain/entities/profile.dart';
import 'package:rehab_track/domain/entities/schedule_config.dart';
import 'package:rehab_track/domain/entities/scheduled_measurement.dart';
import 'package:rehab_track/domain/entities/care_contact.dart';
import 'package:rehab_track/domain/entities/doctor_visit_record.dart';
import 'package:rehab_track/domain/enums/enums.dart';
import 'package:rehab_track/domain/repositories/care_contact_repository.dart';
import 'package:rehab_track/domain/repositories/doctor_visit_repository.dart';
import 'package:rehab_track/domain/repositories/measurement_repository.dart';
import 'package:rehab_track/domain/repositories/medication_repository.dart';
import 'package:rehab_track/domain/repositories/profile_repository.dart';

class FakeProfileRepository implements ProfileRepository {
  @override
  Stream<Profile?> watchActiveProfile(int profileId) =>
      Stream.value(Profile(firstName: 'Test', lastName: 'User', createdAt: DateTime(2025), updatedAt: DateTime(2025)));

  @override
  Future<Profile?> getActiveProfile(int profileId) async =>
      Profile(firstName: 'Test', lastName: 'User', createdAt: DateTime(2025), updatedAt: DateTime(2025));

  @override
  Future<int> createProfile(Profile profile) async => 1;

  @override
  Future<void> updateProfile(Profile profile) async {}

  @override
  Future<void> deleteProfile(int id) async {}

  @override
  Stream<List<Profile>> watchAllProfiles() => Stream.value([]);

  @override
  Future<List<Profile>> getAllProfiles() async => [];

  @override
  Future<void> setPrimaryProfile(int profileId) async {}

  @override
  Future<int> getProfileCount() async => 1;
}

class FakeDoctorVisitRepository implements DoctorVisitRepository {
  final Map<int, DoctorVisitRecord> visits = {};

  @override
  Future<int> createVisit(DoctorVisitRecord visit) async {
    final id = visit.id ?? visits.length + 1;
    visits[id] = visit.copyWith(id: id);
    return id;
  }

  @override
  Future<void> updateVisit(DoctorVisitRecord visit) async {
    if (visit.id != null) visits[visit.id!] = visit;
  }

  @override
  Future<DoctorVisitRecord?> getVisitById(int profileId, int visitId) async =>
      visits[visitId];

  @override
  Stream<DoctorVisitRecord?> watchVisitById(int profileId, int visitId) =>
      Stream.value(visits[visitId]);

  @override
  Stream<List<DoctorVisitRecord>> watchUpcomingVisits(int profileId) =>
      Stream.value(
        visits.values
            .where((v) => v.status == DoctorVisitStatus.scheduled)
            .toList(),
      );

  @override
  Stream<List<DoctorVisitRecord>> watchVisitHistory(int profileId) =>
      Stream.value([]);

  @override
  Future<List<DoctorVisitRecord>> getUpcomingVisits(int profileId) async =>
      visits.values
          .where((v) => v.status == DoctorVisitStatus.scheduled)
          .toList();

  @override
  Future<List<DoctorVisitRecord>> getVisitsBetween(
    int profileId,
    DateTime startInclusive,
    DateTime endExclusive,
  ) async =>
      visits.values
          .where((v) =>
              !v.scheduledDateTime.isBefore(startInclusive) &&
              v.scheduledDateTime.isBefore(endExclusive))
          .toList()
        ..sort((a, b) => b.scheduledDateTime.compareTo(a.scheduledDateTime));

  @override
  Future<void> setVisitStatus(
    int profileId,
    int visitId,
    DoctorVisitStatus status,
  ) async {}

  @override
  Future<void> archiveVisit(int profileId, int visitId) async {}

  @override
  Future<void> deleteVisit(int profileId, int visitId) async {
    visits.remove(visitId);
  }

  @override
  Future<bool> isContactReferencedByVisits(int contactId) async => false;

  @override
  Future<int> countOpenVisitsReferencingContact(
    int profileId,
    int contactId,
  ) async =>
      0;
}

class FakeCareContactRepository implements CareContactRepository {
  @override
  Stream<List<CareContact>> watchActiveContacts(int profileId) =>
      Stream.value([]);

  @override
  Stream<List<CareContact>> watchArchivedContacts(int profileId) =>
      Stream.value([]);

  @override
  Stream<List<CareContact>> watchAllContacts(int profileId) =>
      Stream.value([]);

  @override
  Stream<CareContact?> watchContactById(int profileId, int contactId) =>
      Stream.value(null);

  @override
  Future<CareContact?> getContactById(int profileId, int contactId) async =>
      null;

  @override
  Future<int> createContact(CareContact contact) async => 1;

  @override
  Future<void> updateContact(CareContact contact) async {}

  @override
  Future<void> archiveContact(int profileId, int contactId) async {}

  @override
  Future<void> restoreContact(int profileId, int contactId) async {}

  @override
  Future<void> deleteContact(int profileId, int contactId) async {}

  @override
  Future<void> setFavorite(int profileId, int contactId, bool favorite) async {
  }
}

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
  Future<RecordScheduledMeasurementResult> recordScheduledMeasurement({
    required int profileId,
    required MeasurementRecord record,
    required List<MeasurementRecordValue> values,
    int? scheduleId,
    DateTime? occurrenceDateTime,
  }) async {
    return const RecordScheduledMeasurementResult(
      recordId: 0,
      notificationCancelled: true,
      alreadyCompleted: false,
    );
  }
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

  @override
  Future<void> cancelReminderNotification(int scheduleId, DateTime scheduledTime) async {}

  @override
  Future<void> deleteReminderLogForOccurrence(
    int scheduleId,
    DateTime scheduledTime,
  ) async {}
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

  @override
  Future<MedicationLog?> getLogForOccurrence(
    int scheduleId,
    DateTime scheduledTime,
  ) async => null;

  @override
  Future<void> cancelReminderNotification(int scheduleId, DateTime scheduledTime) async {}

  @override
  Future<void> deleteLogForOccurrence(
    int scheduleId,
    DateTime scheduledTime,
  ) async {}
}

class FakeNotificationService extends NotificationService {
  NotificationActionCallback? actionCallback;
  NotificationTapCallback? tapCallback;
  final List<Map<String, dynamic>> scheduledNotifications = [];
  final List<int> cancelledIds = [];

  FakeNotificationService() : super();

  @override
  bool get isInitialized => true;

  @override
  void setActionCallback(NotificationActionCallback callback) {
    actionCallback = callback;
  }

  @override
  void setNotificationTapCallback(NotificationTapCallback callback) {
    tapCallback = callback;
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
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate,
      'channelId': channelId,
      'payload': payload,
      'includeActions': includeActions,
      'isMeasurement': isMeasurement,
      'isDoctorVisit': isDoctorVisit,
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

class FakeNotificationScheduler extends NotificationScheduler {
  FakeNotificationScheduler({NotificationService? notificationService})
      : super(notificationService: notificationService ?? FakeNotificationService());
}

class _TapCaptureService extends FakeNotificationService {
  @override
  void setNotificationTapCallback(NotificationTapCallback callback) {
    tapCallback = callback;
  }
}

class _LaunchDetailsService extends FakeNotificationService {
  _LaunchDetailsService({required this.payload, required this.id, this.actionId});

  final String payload;
  final int id;
  final String? actionId;

  @override
  Future<NotificationAppLaunchDetails?> getLaunchDetails() async {
    return NotificationAppLaunchDetails(
      true,
      notificationResponse: NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        id: id,
        payload: payload,
        actionId: actionId,
      ),
    );
  }
}

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('ReminderPayload parsing', () {
    test('parse returns valid payload from correct JSON', () {
      final json = jsonEncode({
        'v': 1,
        't': 'medication',
        'p': 1,
        's': 7,
        'o': DateTime.now().toIso8601String(),
        'm': 42,
      });
      final payload = ReminderPayload.parse(json);
      expect(payload, isNotNull);
      expect(payload!.medicationId, 42);
      expect(payload.scheduleId, 7);
    });

    test('parse returns null for null input', () {
      expect(ReminderPayload.parse(null), isNull);
    });

    test('parse returns null for empty string', () {
      expect(ReminderPayload.parse(''), isNull);
    });

    test('parse returns null for invalid JSON', () {
      expect(ReminderPayload.parse('not json'), isNull);
    });

    test('parse returns null when required fields are missing', () {
      final json = jsonEncode({'m': 42, 's': 7});
      expect(ReminderPayload.parse(json), isNull);
    });
  });

  group('ReminderContentFormatter', () {
    test('medicationTitle includes strength when present', () {
      final medication = Medication(
        profileId: 1,
        name: 'Ibuprofen',
        doseAmount: '200',
        doseUnit: 'mg',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      final title = ReminderContentFormatter.medicationTitle(
        medication: medication,
        profile: null,
      );
      expect(title, 'Ibuprofen 200 mg');
    });

    test('medicationTitle shows name only when strength absent', () {
      final medication = Medication(
        profileId: 1,
        name: 'Vitamin D',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      final title = ReminderContentFormatter.medicationTitle(
        medication: medication,
        profile: null,
      );
      expect(title, 'Vitamin D');
    });

    test('medicationBody includes intake quantity', () {
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
      final body = ReminderContentFormatter.medicationBody(
        medication: medication,
        profile: null,
        schedule: schedule,
        scheduledTime: DateTime.now(),
      );
      expect(body, contains('1 tablet'));
    });

    test('medicationBody includes instructions', () {
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
      final body = ReminderContentFormatter.medicationBody(
        medication: medication,
        profile: null,
        schedule: schedule,
        scheduledTime: DateTime.now(),
      );
      expect(body, contains('Take with food'));
    });

    test('medicationBody combines intake quantity and instructions', () {
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
      final body = ReminderContentFormatter.medicationBody(
        medication: medication,
        profile: null,
        schedule: schedule,
        scheduledTime: DateTime.now(),
      );
      expect(body, contains('2 capsules'));
      expect(body, contains('After meals'));
    });

    test('medicationBody includes intake quantity with custom dosage form', () {
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
      final body = ReminderContentFormatter.medicationBody(
        medication: medication,
        profile: null,
        schedule: schedule,
        scheduledTime: DateTime.now(),
      );
      expect(body, contains('1 pump'));
    });

    test('medicationBody includes profile name when enabled', () {
      final profile = Profile(
        firstName: 'Emzari',
        lastName: 'Arkania',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      final medication = Medication(
        profileId: 1,
        name: 'Clopidogrel',
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
      final body = ReminderContentFormatter.medicationBody(
        medication: medication,
        profile: profile,
        schedule: schedule,
        scheduledTime: DateTime.now(),
        showProfileName: true,
      );
      expect(body, contains('Emzari Arkania'));
    });

    test('medicationBody omits profile name when disabled', () {
      final profile = Profile(
        firstName: 'Emzari',
        lastName: 'Arkania',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      final medication = Medication(
        profileId: 1,
        name: 'Clopidogrel',
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
      final body = ReminderContentFormatter.medicationBody(
        medication: medication,
        profile: profile,
        schedule: schedule,
        scheduledTime: DateTime.now(),
        showProfileName: false,
      );
      expect(body, isNot(contains('Emzari Arkania')));
    });
  });

  group('Action handling', () {
    late FakeMedicationRepository repo;
    late FakeNotificationService notificationService;
    late FakeMeasurementRepository measurementRepo;
    late NotificationActionBridge bridge;

    setUp(() {
      repo = FakeMedicationRepository();
      measurementRepo = FakeMeasurementRepository();
      notificationService = FakeNotificationService();
      final scheduler = FakeNotificationScheduler(
        notificationService: notificationService,
      );
      final recoveryService = ScheduleRecoveryService(
        notificationService: notificationService,
        notificationScheduler: scheduler,
      );
      bridge = NotificationActionBridge(
        notificationService: notificationService,
        notificationScheduler: scheduler,
        scheduleRecoveryService: recoveryService,
        medicationRepository: repo,
        measurementRepository: measurementRepo,
        doctorVisitRepository: FakeDoctorVisitRepository(),
        careContactRepository: FakeCareContactRepository(),
        profileRepository: FakeProfileRepository(),
        getSnoozeDuration: () => const Duration(minutes: 10),
        showProfileName: () => true,
        showDetailsOnLockScreen: () => true,
      );
    });

    test('initialize registers action callback', () async {
      await bridge.initialize();
      expect(notificationService.actionCallback, isNotNull);
    });

    test('taken action logs dose with status taken', () async {
      await bridge.initialize();

      final payload = ReminderPayload(
        type: ReminderType.medication,
        profileId: 1,
        scheduleId: 10,
        occurrenceTime: DateTime.now().toIso8601String(),
        medicationId: 1,
      );

      final response = NotificationActionResponse(
        notificationId: 10,
        actionId: 'medication_mark_taken',
        actionType: NotificationActionType.medicationMarkTaken,
        payload: payload.toJsonString(),
      );

      notificationService.actionCallback!(response);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(repo.loggedDoses, hasLength(1));
      expect(repo.loggedDoses.first.status, 'taken');
      expect(repo.loggedDoses.first.medicationScheduleId, 10);
      expect(repo.loggedDoses.first.takenTime, isNotNull);
    });

    test('skipped action logs dose with status skipped', () async {
      await bridge.initialize();

      final payload = ReminderPayload(
        type: ReminderType.medication,
        profileId: 1,
        scheduleId: 10,
        occurrenceTime: DateTime.now().toIso8601String(),
        medicationId: 1,
      );

      final response = NotificationActionResponse(
        notificationId: 10,
        actionId: 'medication_skip',
        actionType: NotificationActionType.medicationSkip,
        payload: payload.toJsonString(),
      );

      notificationService.actionCallback!(response);

      await Future<void>.delayed(Duration.zero);
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

      await bridge.initialize();

      final payload = ReminderPayload(
        type: ReminderType.medication,
        profileId: 1,
        scheduleId: 10,
        occurrenceTime: DateTime.now().toIso8601String(),
        medicationId: 1,
      );

      final response = NotificationActionResponse(
        notificationId: 10,
        actionId: 'medication_snooze',
        actionType: NotificationActionType.medicationSnooze,
        payload: payload.toJsonString(),
      );

      notificationService.actionCallback!(response);

      // Multiple delays to allow chained async operations to complete
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(notificationService.scheduledNotifications, hasLength(1));
      expect(
        notificationService.scheduledNotifications.first['id'],
        NotificationService.snoozeNotificationId(10),
      );
    });

    test('action with null payload is ignored', () async {
      await bridge.initialize();

      final response = NotificationActionResponse(
        notificationId: 10,
        actionId: 'medication_mark_taken',
        actionType: NotificationActionType.medicationMarkTaken,
        payload: null,
      );

      notificationService.actionCallback!(response);

      await Future<void>.delayed(Duration.zero);

      expect(repo.loggedDoses, isEmpty);
    });
  });

  group('Doctor visit actions', () {
    late FakeDoctorVisitRepository visitRepo;
    late FakeCareContactRepository careContactRepo;
    late FakeNotificationService notificationService;
    late NotificationActionBridge bridge;
    late NotificationActionType? lastProcessed;
    late ReminderPayload? lastProcessedPayload;

    setUp(() {
      visitRepo = FakeDoctorVisitRepository();
      careContactRepo = FakeCareContactRepository();
      notificationService = FakeNotificationService();
      final scheduler = FakeNotificationScheduler(
        notificationService: notificationService,
      );
      final recoveryService = ScheduleRecoveryService(
        notificationService: notificationService,
        notificationScheduler: scheduler,
      );
      lastProcessed = null;
      lastProcessedPayload = null;
      bridge = NotificationActionBridge(
        notificationService: notificationService,
        notificationScheduler: scheduler,
        scheduleRecoveryService: recoveryService,
        medicationRepository: FakeMedicationRepository(),
        measurementRepository: FakeMeasurementRepository(),
        doctorVisitRepository: visitRepo,
        careContactRepository: careContactRepo,
        profileRepository: FakeProfileRepository(),
        getSnoozeDuration: () => const Duration(minutes: 10),
        showProfileName: () => true,
        showDetailsOnLockScreen: () => true,
        onActionProcessed: (type, payload) {
          lastProcessed = type;
          lastProcessedPayload = payload;
        },
      );
    });

    DoctorVisitRecord makeVisit({int id = 1}) {
      return DoctorVisitRecord(
        id: id,
        profileId: 1,
        visitType: DoctorVisitType.planned,
        status: DoctorVisitStatus.scheduled,
        scheduledDateTime: DateTime.now().add(const Duration(days: 2)),
        reason: 'Follow-up',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
    }

    ReminderPayload visitPayload({int visitId = 1}) => ReminderPayload(
          type: ReminderType.doctorVisit,
          profileId: 1,
          scheduleId: visitId,
          occurrenceTime: DateTime.now().toIso8601String(),
          visitId: visitId,
          notificationId: NotificationService.doctorVisitNotificationId(visitId),
        );

    test('open action validates the visit exists', () async {
      visitRepo.visits[1] = makeVisit();
      await bridge.initialize();

      final response = NotificationActionResponse(
        notificationId: NotificationService.doctorVisitNotificationId(1),
        actionId: 'doctor_visit_open',
        actionType: NotificationActionType.doctorVisitOpen,
        payload: visitPayload().toJsonString(),
      );

      notificationService.actionCallback!(response);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(lastProcessed, NotificationActionType.doctorVisitOpen);
      expect(lastProcessedPayload!.visitId, 1);
    });

    test('open action for a missing visit reports entityNotFound', () async {
      await bridge.initialize();

      final response = NotificationActionResponse(
        notificationId: NotificationService.doctorVisitNotificationId(99),
        actionId: 'doctor_visit_open',
        actionType: NotificationActionType.doctorVisitOpen,
        payload: visitPayload(visitId: 99).toJsonString(),
      );

      notificationService.actionCallback!(response);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(lastProcessed, NotificationActionType.doctorVisitOpen);
      expect(lastProcessedPayload!.visitId, 99);
    });

    test('snooze action reschedules the reminder later', () async {
      visitRepo.visits[1] = makeVisit();
      await bridge.initialize();

      final notificationId = NotificationService.doctorVisitNotificationId(1);
      final response = NotificationActionResponse(
        notificationId: notificationId,
        actionId: 'doctor_visit_snooze',
        actionType: NotificationActionType.doctorVisitSnooze,
        payload: visitPayload().toJsonString(),
      );

      notificationService.actionCallback!(response);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(lastProcessed, NotificationActionType.doctorVisitSnooze);
      expect(notificationService.scheduledNotifications, hasLength(1));
      expect(
        notificationService.scheduledNotifications.first['id'],
        NotificationService.snoozeNotificationId(notificationId),
      );
      expect(
        notificationService.scheduledNotifications.first['isDoctorVisit'],
        isTrue,
      );
    });
  });

  group('Measurement recovery payloads', () {
    late NotificationActionBridge bridge;
    late FakeNotificationService notificationService;
    late FakeMeasurementRepository measurementRepo;
    late FakeMedicationRepository medicationRepo;

    setUp(() {
      notificationService = FakeNotificationService();
      measurementRepo = FakeMeasurementRepository();
      medicationRepo = FakeMedicationRepository();
      final scheduler = FakeNotificationScheduler(
        notificationService: notificationService,
      );
      final recoveryService = ScheduleRecoveryService(
        notificationService: notificationService,
        notificationScheduler: scheduler,
      );
      bridge = NotificationActionBridge(
        notificationService: notificationService,
        notificationScheduler: scheduler,
        scheduleRecoveryService: recoveryService,
        medicationRepository: medicationRepo,
        measurementRepository: measurementRepo,
        doctorVisitRepository: FakeDoctorVisitRepository(),
        careContactRepository: FakeCareContactRepository(),
        profileRepository: FakeProfileRepository(),
        getSnoozeDuration: () => const Duration(minutes: 10),
        showProfileName: () => true,
        showDetailsOnLockScreen: () => true,
      );
      measurementRepo.schedules[7] = MeasurementSchedule(
        id: 7,
        profileId: 1,
        measurementTypeId: 5,
        scheduleType: 'daily',
        time: '08:30',
        startDate: DateTime(2020, 1, 1),
        active: true,
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2020, 1, 1),
      );
    });

    test(
      'each recovered measurement notification carries its own occurrence time',
      () async {
        await bridge.initialize();

        final count = await bridge.recoverMeasurementSchedules(1);

        // One schedule entry was restored, which produced one notification per
        // future occurrence.
        expect(count, 1);
        expect(notificationService.scheduledNotifications, isNotEmpty);

        // Every payload must reference the exact occurrence it was scheduled
        // for, not a single "now" shared by all occurrences. This is what lets
        // Record Now bind the reading to the correct agenda slot.
        final occurrenceInstants = <DateTime>{};
        for (final scheduled in notificationService.scheduledNotifications) {
          final rawPayload = scheduled['payload'] as String;
          final payload = ReminderPayload.parse(rawPayload);
          expect(payload, isNotNull);
          expect(payload!.scheduleId, 7);
          expect(payload.measurementTypeId, 5);
          final occ = payload.occurrenceDateTime;
          expect(occ, isNotNull);
          final occIn = scheduled['scheduledDate'] as DateTime;
          expect(
            occ!.isAtSameMomentAs(occIn),
            isTrue,
            reason: 'payload occurrenceTime must match the scheduled occurrence',
          );
          occurrenceInstants.add(payload.occurrenceDateTime!);
        }

        // The static-payload bug made every notification share the same
        // occurrenceTime. A fixed per-occurrence payload yields many distinct
        // instants across the 30-day horizon.
        expect(occurrenceInstants.length, greaterThan(1));
      },
    );
  });

  group('Alarm presentation', () {
    test('test alarm payload is recognised and has no reminder', () {
      final presentation = AlarmPresentation(
        notificationId: NotificationService.testAlarmNotificationId,
        payload: NotificationService.testAlarmPayload,
      );
      expect(presentation.isTestAlarm, isTrue);
      expect(presentation.reminder, isNull);
    });

    test('medication payload yields a parseable reminder', () {
      final payload = ReminderPayload(
        type: ReminderType.medication,
        profileId: 1,
        scheduleId: 7,
        occurrenceTime: DateTime.now().toIso8601String(),
        medicationId: 3,
      );
      final presentation = AlarmPresentation(
        notificationId: 1234,
        payload: payload.toJsonString(),
      );
      expect(presentation.isTestAlarm, isFalse);
      expect(presentation.reminder!.scheduleId, 7);
      expect(presentation.reminder!.medicationId, 3);
    });

    test('executeUiAction dismiss cancels notification and snooze', () async {
      final notificationService = FakeNotificationService();
      final scheduler = FakeNotificationScheduler(
        notificationService: notificationService,
      );
      final recoveryService = ScheduleRecoveryService(
        notificationService: notificationService,
        notificationScheduler: scheduler,
      );
      String? lastDismissedPayload;
      final bridge = NotificationActionBridge(
        notificationService: notificationService,
        notificationScheduler: scheduler,
        scheduleRecoveryService: recoveryService,
        medicationRepository: FakeMedicationRepository(),
        measurementRepository: FakeMeasurementRepository(),
        doctorVisitRepository: FakeDoctorVisitRepository(),
        careContactRepository: FakeCareContactRepository(),
        profileRepository: FakeProfileRepository(),
        getSnoozeDuration: () => const Duration(minutes: 10),
        showProfileName: () => true,
        showDetailsOnLockScreen: () => true,
        onActionProcessed: (type, payload) {
          if (type == NotificationActionType.dismiss) {
            lastDismissedPayload = payload.toJsonString();
          }
        },
      );
      await bridge.initialize();

      final payload = ReminderPayload(
        type: ReminderType.medication,
        profileId: 1,
        scheduleId: 7,
        occurrenceTime: DateTime.now().toIso8601String(),
        medicationId: 3,
      );
      final result = await bridge.executeUiAction(
        actionType: NotificationActionType.dismiss,
        payload: payload,
        notificationId: 9000,
      );

      expect(result, ActionResult.success);
      expect(notificationService.cancelledIds, containsAll([
        9000,
        NotificationService.snoozeNotificationId(9000),
      ]));
      // The payload embedded the active notification id.
      expect(
        ReminderPayload.parse(lastDismissedPayload)!.notificationId,
        9000,
      );
    });

    test('notification tap with alarm style active presents the alarm', () async {
      final notificationService = _TapCaptureService();
      final scheduler = FakeNotificationScheduler(
        notificationService: notificationService,
      );
      final recoveryService = ScheduleRecoveryService(
        notificationService: notificationService,
        notificationScheduler: scheduler,
      );
      int? presentedId;
      String? presentedPayload;
      final bridge = NotificationActionBridge(
        notificationService: notificationService,
        notificationScheduler: scheduler,
        scheduleRecoveryService: recoveryService,
        medicationRepository: FakeMedicationRepository(),
        measurementRepository: FakeMeasurementRepository(),
        doctorVisitRepository: FakeDoctorVisitRepository(),
        careContactRepository: FakeCareContactRepository(),
        profileRepository: FakeProfileRepository(),
        getSnoozeDuration: () => const Duration(minutes: 10),
        showProfileName: () => true,
        showDetailsOnLockScreen: () => true,
        isAlarmStyleActive: () => true,
        onAlarmPresent: (id, payload) {
          presentedId = id;
          presentedPayload = payload;
        },
      );
      await bridge.initialize();
      expect(notificationService.tapCallback, isNotNull);
      final tapCallback = notificationService.tapCallback!;

      final payload = ReminderPayload(
        type: ReminderType.medication,
        profileId: 1,
        scheduleId: 7,
        occurrenceTime: DateTime.now().toIso8601String(),
        medicationId: 3,
      );

      tapCallback(9000, payload.toJsonString());

      expect(presentedId, 9000);
      expect(presentedPayload, payload.toJsonString());
    });

    test('cold start with alarm payload presents the alarm', () async {
      final launchService = _LaunchDetailsService(
        payload: ReminderPayload(
          type: ReminderType.medication,
          profileId: 1,
          scheduleId: 7,
          occurrenceTime: DateTime.now().toIso8601String(),
          medicationId: 3,
        ).toJsonString(),
        id: 9001,
      );
      final scheduler = FakeNotificationScheduler(
        notificationService: launchService,
      );
      final recoveryService = ScheduleRecoveryService(
        notificationService: launchService,
        notificationScheduler: scheduler,
      );
      int? presentedId;
      String? presentedPayload;
      final bridge = NotificationActionBridge(
        notificationService: launchService,
        notificationScheduler: scheduler,
        scheduleRecoveryService: recoveryService,
        medicationRepository: FakeMedicationRepository(),
        measurementRepository: FakeMeasurementRepository(),
        doctorVisitRepository: FakeDoctorVisitRepository(),
        careContactRepository: FakeCareContactRepository(),
        profileRepository: FakeProfileRepository(),
        getSnoozeDuration: () => const Duration(minutes: 10),
        showProfileName: () => true,
        showDetailsOnLockScreen: () => true,
        isAlarmStyleActive: () => true,
        onAlarmPresent: (id, payload) {
          presentedId = id;
          presentedPayload = payload;
        },
      );

      await bridge.processAppLaunchAlarmPresentation();

      expect(presentedId, 9001);
      expect(presentedPayload, isNotNull);
    });

    test('cold start with an action button does not present the alarm', () async {
      final launchService = _LaunchDetailsService(
        payload: ReminderPayload(
          type: ReminderType.medication,
          profileId: 1,
          scheduleId: 7,
          occurrenceTime: DateTime.now().toIso8601String(),
          medicationId: 3,
        ).toJsonString(),
        id: 9002,
        actionId: 'medication_mark_taken',
      );
      final scheduler = FakeNotificationScheduler(
        notificationService: launchService,
      );
      final recoveryService = ScheduleRecoveryService(
        notificationService: launchService,
        notificationScheduler: scheduler,
      );
      var presented = false;
      final bridge = NotificationActionBridge(
        notificationService: launchService,
        notificationScheduler: scheduler,
        scheduleRecoveryService: recoveryService,
        medicationRepository: FakeMedicationRepository(),
        measurementRepository: FakeMeasurementRepository(),
        doctorVisitRepository: FakeDoctorVisitRepository(),
        careContactRepository: FakeCareContactRepository(),
        profileRepository: FakeProfileRepository(),
        getSnoozeDuration: () => const Duration(minutes: 10),
        showProfileName: () => true,
        showDetailsOnLockScreen: () => true,
        isAlarmStyleActive: () => true,
        onAlarmPresent: (id, payload) {
          presented = true;
        },
      );

      await bridge.processAppLaunchAlarmPresentation();

      expect(presented, isFalse);
    });

    test('cold start ignores taps when alarm style is inactive', () async {
      final launchService = _LaunchDetailsService(
        payload: 'anything',
        id: 9003,
      );
      final scheduler = FakeNotificationScheduler(
        notificationService: launchService,
      );
      final recoveryService = ScheduleRecoveryService(
        notificationService: launchService,
        notificationScheduler: scheduler,
      );
      var presented = false;
      final bridge = NotificationActionBridge(
        notificationService: launchService,
        notificationScheduler: scheduler,
        scheduleRecoveryService: recoveryService,
        medicationRepository: FakeMedicationRepository(),
        measurementRepository: FakeMeasurementRepository(),
        doctorVisitRepository: FakeDoctorVisitRepository(),
        careContactRepository: FakeCareContactRepository(),
        profileRepository: FakeProfileRepository(),
        getSnoozeDuration: () => const Duration(minutes: 10),
        showProfileName: () => true,
        showDetailsOnLockScreen: () => true,
        isAlarmStyleActive: () => false,
        onAlarmPresent: (id, payload) {
          presented = true;
        },
      );

      await bridge.processAppLaunchAlarmPresentation();

      expect(presented, isFalse);
    });
  });
}
