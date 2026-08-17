import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/data/services/notification/alarm_presentation.dart';
import 'package:rehab_track/data/services/notification/notification_action_handler.dart';
import 'package:rehab_track/data/services/notification/notification_service.dart';
import 'package:rehab_track/domain/entities/reminder_style.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/notification_provider.dart';
import 'package:rehab_track/presentation/providers/reminder_settings_provider.dart';

/// Records the native alarm-player calls instead of touching platform
/// channels, and exposes the notification-tap callback so tests can simulate
/// an Alarm-style presentation opening (tap, full-screen, or cold start).
class _RecordingNotificationService extends NotificationService {
  final List<String> startedUris = [];
  final List<int> cancelledIds = [];
  int stopSoundCount = 0;
  int stopPreviewCount = 0;

  void Function(int?, String?)? _tapCallback;

  @override
  void setNotificationTapCallback(NotificationTapCallback callback) {
    _tapCallback = callback;
  }

  void simulateTap({required int notificationId, required String payload}) {
    _tapCallback?.call(notificationId, payload);
  }

  @override
  Future<bool> startAlarmSound({String? uri}) async {
    startedUris.add(uri ?? '<default>');
    return true;
  }

  @override
  Future<void> stopAlarmSound() async {
    stopSoundCount++;
  }

  @override
  Future<bool> startAlarmSoundPreview({String? uri}) async => true;

  @override
  Future<void> stopAlarmSoundPreview() async {
    stopPreviewCount++;
  }

  @override
  Future<void> cancelNotification(int id) async {
    cancelledIds.add(id);
  }
}

class _SettingsRepo implements SettingsRepository {
  final Map<String, String> store = {};

  @override
  Future<String?> getValue(String key) async => store[key];

  @override
  Future<void> setValue(String key, String value) async {
    store[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    store.remove(key);
  }

  @override
  Stream<Map<String, String>> watchAll() async* {
    yield Map.of(store);
  }

  @override
  Future<Map<String, String>> getAll() async => Map.of(store);
}

void main() {
  late db.AppDatabase database;

  setUp(() {
    database = db.AppDatabase.test();
  });

  tearDown(() async {
    await database.close();
  });

  Future<(ProviderContainer, _RecordingNotificationService)> build({
    bool customSound = false,
    bool alarmStyle = true,
  }) async {
    final settings = _SettingsRepo();
    settings.store['reminder_style'] =
        alarmStyle ? ReminderStyle.alarmStyle.storageValue : 'standard';
    if (customSound) {
      settings.store['alarm_sound_uri'] = 'content://media/alarm/1';
      settings.store['alarm_sound_title'] = 'Morning Bell';
    }
    final service = _RecordingNotificationService();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        settingsRepositoryProvider.overrideWithValue(settings),
        notificationServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);
    await container.read(reminderStyleProvider.notifier).ready;
    await container.read(alarmSoundProvider.notifier).ready;
    // Register the audio lifecycle listener like main() does.
    container.read(alarmSoundLifecycleProvider);
    final bridge = container.read(notificationActionBridgeProvider);
    await bridge.initialize();
    return (container, service);
  }

  group('Alarm-style presentation starts the selected sound', () {
    test('custom sound: starts the native player and cancels the fired alarm',
        () async {
      final (_, service) = await build(customSound: true);

      service.simulateTap(
        notificationId: 42,
        payload: 'some alarm payload',
      );
      await Future<void>.delayed(Duration.zero);

      expect(service.startedUris, ['content://media/alarm/1']);
      expect(service.cancelledIds, contains(42));
    });

    test('no custom sound: channel plays unchanged, player untouched', () async {
      final (_, service) = await build(customSound: false);

      service.simulateTap(
        notificationId: 43,
        payload: 'some alarm payload',
      );
      await Future<void>.delayed(Duration.zero);

      expect(service.startedUris, isEmpty);
      expect(service.cancelledIds, isEmpty);
    });

    test('not alarm style: tap is not treated as an alarm presentation',
        () async {
      final (_, service) = await build(customSound: true, alarmStyle: false);

      service.simulateTap(
        notificationId: 44,
        payload: 'some alarm payload',
      );
      await Future<void>.delayed(Duration.zero);

      expect(service.startedUris, isEmpty);
      expect(service.cancelledIds, isEmpty);
    });
  });

  group('Acknowledging the presentation stops the sound', () {
    test('clearing the active presentation stops the native player', () async {
      final (container, service) = await build(customSound: true);

      container.read(activeAlarmPresentationProvider.notifier).state =
          const AlarmPresentation(
        notificationId: 42,
        payload: 'some alarm payload',
      );
      expect(service.stopSoundCount, 0);

      container.read(activeAlarmPresentationProvider.notifier).state = null;
      await Future<void>.delayed(Duration.zero);

      expect(service.stopSoundCount, 1);
    });
  });
}