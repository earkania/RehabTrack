import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:rehab_track/data/services/notification/doctor_visit_reminder_service.dart';
import 'package:rehab_track/data/services/notification/notification_scheduler.dart';
import 'package:rehab_track/data/services/notification/notification_service.dart';
import 'package:rehab_track/domain/entities/care_contact.dart';
import 'package:rehab_track/domain/entities/doctor_visit_record.dart';
import 'package:rehab_track/domain/entities/profile.dart';
import 'package:rehab_track/domain/enums/enums.dart';
import 'package:rehab_track/domain/repositories/care_contact_repository.dart';
import 'package:rehab_track/domain/repositories/profile_repository.dart';

class _RecordingNotificationService extends NotificationService {
  final List<Map<String, dynamic>> scheduled = [];
  final List<int> cancelled = [];

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
    scheduled.add({
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate,
      'channelId': channelId,
      'payload': payload,
      'isDoctorVisit': isDoctorVisit,
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
    cancelled.add(id);
  }

  @override
  Future<void> cancelNotifications(List<int> ids) async {
    cancelled.addAll(ids);
  }

  @override
  Future<void> cancelAllNotifications() async {}
}

class _FakeCareContactRepository implements CareContactRepository {
  final Map<int, CareContact> contacts = {};

  @override
  Future<CareContact?> getContactById(int profileId, int contactId) async =>
      contacts[contactId];

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

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<Profile?> getActiveProfile(int profileId) async => Profile(
        firstName: 'Test',
        lastName: 'User',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

  @override
  Stream<Profile?> watchActiveProfile(int profileId) => Stream.value(null);

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

void main() {
  setUpAll(() {
    tzdata.initializeTimeZones();
  });

  late _RecordingNotificationService notificationService;
  late NotificationScheduler scheduler;
  late _FakeCareContactRepository careContacts;
  late DoctorVisitReminderService service;

  setUp(() {
    notificationService = _RecordingNotificationService();
    scheduler = NotificationScheduler(
      notificationService: notificationService,
    );
    careContacts = _FakeCareContactRepository();
    service = DoctorVisitReminderService(
      notificationService: notificationService,
      notificationScheduler: scheduler,
      careContactRepository: careContacts,
      profileRepository: _FakeProfileRepository(),
      showProfileName: () => true,
    );
  });

  DoctorVisitRecord makeVisit({
    int id = 1,
    DoctorVisitStatus status = DoctorVisitStatus.scheduled,
    bool reminderEnabled = true,
    int reminderMinutesBefore = 1440,
    DateTime? scheduledDateTime,
  }) {
    return DoctorVisitRecord(
      id: id,
      profileId: 1,
      visitType: DoctorVisitType.planned,
      status: status,
      scheduledDateTime:
          scheduledDateTime ?? DateTime.now().add(const Duration(days: 7)),
      reminderEnabled: reminderEnabled,
      reminderMinutesBefore: reminderMinutesBefore,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
  }

  group('scheduleReminder', () {
    test('schedules a notification on the doctor visit channel', () async {
      final scheduledAt =
          DateTime.now().add(const Duration(days: 7, hours: 1));
      final visit = makeVisit(scheduledDateTime: scheduledAt);
      careContacts.contacts[10] = CareContact(
        profileId: 1,
        contactType: CareContactType.doctor,
        displayName: 'Dr. Smith',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      final id = await service.scheduleReminder(
        visit.copyWith(doctorContactId: 10),
      );

      expect(id, NotificationService.doctorVisitNotificationId(1));
      expect(notificationService.scheduled, hasLength(1));
      final scheduled = notificationService.scheduled.single;
      expect(scheduled['channelId'], NotificationService.doctorVisitChannelId);
      expect(scheduled['isDoctorVisit'], isTrue);
      expect(scheduled['title'], 'Doctor visit reminder');
      expect(scheduled['body'], contains('Dr. Smith'));
    });

    test('returns null when reminder is disabled', () async {
      final id = await service.scheduleReminder(makeVisit(reminderEnabled: false));
      expect(id, isNull);
      expect(notificationService.scheduled, isEmpty);
    });

    test('returns null when the visit is not scheduled', () async {
      final id = await service.scheduleReminder(makeVisit(
        status: DoctorVisitStatus.completed,
      ));
      expect(id, isNull);
      expect(notificationService.scheduled, isEmpty);
    });

    test('skips a reminder that would already be in the past', () async {
      final id = await service.scheduleReminder(makeVisit(
        scheduledDateTime: DateTime.now().add(const Duration(hours: 1)),
        reminderMinutesBefore: 1440,
      ));
      expect(id, isNull);
      expect(notificationService.scheduled, isEmpty);
    });
  });

  group('cancelReminder', () {
    test('cancels the reminder and its snooze variant', () async {
      await service.cancelReminder(5);

      final mainId = NotificationService.doctorVisitNotificationId(5);
      expect(notificationService.cancelled, contains(mainId));
      expect(
        notificationService.cancelled,
        contains(NotificationService.snoozeNotificationId(mainId)),
      );
    });
  });
}
