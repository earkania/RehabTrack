import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:rehab_track/core/constants/app_constants.dart';
import 'package:rehab_track/data/services/notification/notification_action_bridge.dart';
import 'package:rehab_track/data/services/notification/notification_scheduler.dart';
import 'package:rehab_track/data/services/notification/notification_service.dart';
import 'package:rehab_track/data/services/notification/schedule_recovery_service.dart';
import 'package:rehab_track/domain/entities/reminder_style.dart';
import 'package:rehab_track/domain/restore/reminder_rebuild_report.dart';
import 'package:rehab_track/domain/repositories/care_contact_repository.dart';
import 'package:rehab_track/domain/repositories/doctor_visit_repository.dart';
import 'package:rehab_track/domain/repositories/measurement_repository.dart';
import 'package:rehab_track/domain/repositories/medication_repository.dart';
import 'package:rehab_track/domain/repositories/profile_repository.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/notification_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/providers/reminder_settings_provider.dart';

class _RecordingService extends NotificationService {
  int cancelAllCount = 0;

  @override
  bool get isInitialized => true;

  @override
  Future<bool> initialize() async => true;

  @override
  Future<void> waitForInitialization() async {}

  @override
  Future<void> cancelAllNotifications() async {
    cancelAllCount++;
  }

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
  }) async {}

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

class _RecordingBridge extends NotificationActionBridge {
  _RecordingBridge({required NotificationService service})
      : super(
          notificationService: service,
          notificationScheduler: NotificationScheduler(
            notificationService: service,
          ),
          scheduleRecoveryService: ScheduleRecoveryService(
            notificationService: service,
            notificationScheduler: NotificationScheduler(
              notificationService: service,
            ),
          ),
          medicationRepository: _EmptyMedicationRepository(),
          measurementRepository: _EmptyMeasurementRepository(),
          profileRepository: _EmptyProfileRepository(),
          doctorVisitRepository: _EmptyDoctorVisitRepository(),
          careContactRepository: _EmptyCareContactRepository(),
          getSnoozeDuration: () => const Duration(minutes: 10),
          showProfileName: () => true,
          showDetailsOnLockScreen: () => true,
        );

  int recoverAllCount = 0;

  @override
  Future<ReminderRebuildReport> recoverAll(int profileId) async {
    recoverAllCount++;
    return ReminderRebuildReport(
      succeeded: true,
      medicationReminders: 0,
      measurementReminders: 0,
      doctorVisitReminders: 0,
    );
  }
}

class _SettingsRepo implements SettingsRepository {
  final Map<String, String> _store = {};

  @override
  Future<String?> getValue(String key) async => _store[key];

  @override
  Future<void> setValue(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
  }

  @override
  Stream<Map<String, String>> watchAll() async* {
    yield Map.of(_store);
  }

  @override
  Future<Map<String, String>> getAll() async => Map.of(_store);
}

class _EmptyMedicationRepository implements MedicationRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _EmptyMeasurementRepository implements MeasurementRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _EmptyProfileRepository implements ProfileRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _EmptyDoctorVisitRepository implements DoctorVisitRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _EmptyCareContactRepository implements CareContactRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  setUpAll(() {
    tzdata.initializeTimeZones();
  });

  ProviderContainer buildContainer({
    required _SettingsRepo settings,
    required _RecordingService service,
    required _RecordingBridge bridge,
  }) {
    return ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settings),
        currentActiveProfileIdProvider.overrideWith((ref) => 1),
        notificationServiceProvider.overrideWithValue(service),
        notificationActionBridgeProvider.overrideWithValue(bridge),
      ],
    );
  }

  group('Reminder style change rescheduling', () {
    test('changing style cancels all notifications and recovers all', () async {
      final settings = _SettingsRepo();
      final service = _RecordingService();
      final bridge = _RecordingBridge(service: service);
      final container = buildContainer(
        settings: settings,
        service: service,
        bridge: bridge,
      );

      // Activate the watcher so its listeners are registered.
      container.read(reminderToggleWatcherProvider);
      await container.read(reminderStyleProvider.notifier).ready;
      expect(container.read(reminderStyleProvider), ReminderStyle.standard);

      await container.read(reminderStyleProvider.notifier)
          .setStyle(ReminderStyle.prominent);

      // Let the async listener fire.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(service.cancelAllCount, 1);
      expect(bridge.recoverAllCount, 1);
      expect(container.read(reminderStyleProvider), ReminderStyle.prominent);
      expect(
        await settings.getValue(AppConstants.reminderStyleKey),
        'prominent',
      );

      container.dispose();
    });

    test('re-selecting the same style does not reschedule', () async {
      final settings = _SettingsRepo();
      final service = _RecordingService();
      final bridge = _RecordingBridge(service: service);
      final container = buildContainer(
        settings: settings,
        service: service,
        bridge: bridge,
      );

      container.read(reminderToggleWatcherProvider);
      await container.read(reminderStyleProvider.notifier).ready;

      await container.read(reminderStyleProvider.notifier)
          .setStyle(ReminderStyle.standard);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(service.cancelAllCount, 0);
      expect(bridge.recoverAllCount, 0);

      container.dispose();
    });
  });
}