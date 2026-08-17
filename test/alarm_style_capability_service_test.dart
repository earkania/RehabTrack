import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/data/services/notification/alarm_style_capability_service.dart';
import 'package:rehab_track/data/services/notification/notification_service.dart';

class _FakeNotificationService extends NotificationService {
  bool notificationPermission;
  bool exactAlarmAccess;
  bool channelEnabled;

  _FakeNotificationService({
    this.notificationPermission = true,
    this.exactAlarmAccess = true,
    this.channelEnabled = true,
  });

  @override
  Future<bool> hasNotificationPermission() async => notificationPermission;

  @override
  Future<bool> hasExactAlarmPermission() async => exactAlarmAccess;

  @override
  Future<List<AndroidNotificationChannel>> getNotificationChannels() async {
    return [
      AndroidNotificationChannel(
        NotificationService.alarmChannelId,
        'Alarm',
        description: 'Alarm channel',
        importance:
            channelEnabled ? Importance.max : Importance.none,
      ),
    ];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.earkania.rehabtrack/notifications');

  void mockNative({
    required int sdkInt,
    bool? fullScreenAllowed,
    bool fullScreenSettingsOpened = false,
  }) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'getAndroidSdkInt':
          return sdkInt;
        case 'canUseFullScreenIntent':
          return fullScreenAllowed;
        case 'openFullScreenIntentSettings':
          return fullScreenSettingsOpened;
        default:
          return null;
      }
    });
  }

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('AlarmStyleCapabilityService resolution', () {
    test('available when everything is granted on API 34+', () async {
      mockNative(sdkInt: 34, fullScreenAllowed: true);
      final service = AlarmStyleCapabilityService(
        notificationService: _FakeNotificationService(),
      );

      final capability = await service.check();

      expect(capability.status, AlarmStyleCapabilityStatus.available);
      expect(capability.isAvailable, isTrue);
      expect(capability.fallsBackToProminent, isFalse);
      expect(capability.fullScreenAllowed, isTrue);
      expect(capability.notificationPermission, isTrue);
      expect(capability.exactAlarmAccess, isTrue);
      expect(capability.alarmChannelEnabled, isTrue);
    });

    test('missing notification permission takes precedence', () async {
      mockNative(sdkInt: 34, fullScreenAllowed: true);
      final service = AlarmStyleCapabilityService(
        notificationService:
            _FakeNotificationService(notificationPermission: false),
      );

      final capability = await service.check();

      expect(
        capability.status,
        AlarmStyleCapabilityStatus.notificationPermissionMissing,
      );
      expect(capability.isAvailable, isFalse);
    });

    test('missing exact alarm access reports the specific cause', () async {
      mockNative(sdkInt: 34, fullScreenAllowed: true);
      final service = AlarmStyleCapabilityService(
        notificationService: _FakeNotificationService(exactAlarmAccess: false),
      );

      final capability = await service.check();

      expect(
        capability.status,
        AlarmStyleCapabilityStatus.exactAlarmAccessMissing,
      );
    });

    test('API below 34 falls back to prominent presentation', () async {
      mockNative(sdkInt: 33, fullScreenAllowed: null);
      final service = AlarmStyleCapabilityService(
        notificationService: _FakeNotificationService(),
      );

      final capability = await service.check();

      expect(
        capability.status,
        AlarmStyleCapabilityStatus.unsupportedAndroidVersion,
      );
      expect(capability.fallsBackToProminent, isTrue);
      expect(capability.fullScreenAllowed, isNull);
    });

    test('full-screen denied by the user falls back to prominent', () async {
      mockNative(sdkInt: 35, fullScreenAllowed: false);
      final service = AlarmStyleCapabilityService(
        notificationService: _FakeNotificationService(),
      );

      final capability = await service.check();

      expect(
        capability.status,
        AlarmStyleCapabilityStatus.fullScreenNotAllowed,
      );
      expect(capability.fallsBackToProminent, isTrue);
      expect(capability.fullScreenAllowed, isFalse);
    });

    test('native full-screen check failure reports not allowed', () async {
      mockNative(sdkInt: 34, fullScreenAllowed: null);
      final service = AlarmStyleCapabilityService(
        notificationService: _FakeNotificationService(),
      );

      final capability = await service.check();

      expect(
        capability.status,
        AlarmStyleCapabilityStatus.fullScreenNotAllowed,
      );
    });

    test('disabled alarm channel reports channel issue last', () async {
      mockNative(sdkInt: 34, fullScreenAllowed: true);
      final service = AlarmStyleCapabilityService(
        notificationService: _FakeNotificationService(channelEnabled: false),
      );

      final capability = await service.check();

      expect(
        capability.status,
        AlarmStyleCapabilityStatus.channelDisabledOrLimited,
      );
      expect(capability.alarmChannelEnabled, isFalse);
    });

    test('openFullScreenSettings forwards the native result', () async {
      mockNative(
        sdkInt: 34,
        fullScreenAllowed: true,
        fullScreenSettingsOpened: true,
      );
      final service = AlarmStyleCapabilityService(
        notificationService: _FakeNotificationService(),
      );

      final opened = await service.openFullScreenSettings();

      expect(opened, isTrue);
    });
  });
}
