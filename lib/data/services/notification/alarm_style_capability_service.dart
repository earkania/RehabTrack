import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_service.dart';

/// Whether Alarm-style reminders are fully available on the current device.
///
/// Alarm-style reminders present through a dedicated alarm channel using a
/// full-screen intent so they can interrupt while the screen is locked. That
/// presentation requires a combination of OS-version, permission and
/// exemption support; when any piece is missing the app falls back to the
/// [ReminderStyle.prominent] presentation on the prominent channel instead of
/// silently pretending a full alarm is active.
enum AlarmStyleCapabilityStatus {
  /// Everything required is available: alarm channel is enabled, notification
  /// permission granted, exact-alarm access granted, and full-screen intents
  /// are allowed.
  available,

  /// The device reports full-screen alarms are NOT allowed (the user or OEM
  /// denied the `USE_FULL_SCREEN_INTENT` exemption). The app still schedules
  /// reminders but presents them in the prominent fallback style.
  fullScreenNotAllowed,

  /// Android version older than 34 cannot use full-screen intents at all.
  unsupportedAndroidVersion,

  /// Notification permission is missing; no reminders can be shown.
  notificationPermissionMissing,

  /// Exact-alarm access is missing; reminder timing may be less precise.
  exactAlarmAccessMissing,

  /// The dedicated alarm channel has been disabled or limited by the user in
  /// Android Settings, so the alarm presentation may not be guaranteed.
  channelDisabledOrLimited,
}

/// Result of probing alarm-style capability on the device.
///
/// [status] describes the overall capability for the alarm presentation.
/// [fullScreenAllowed] is the raw `canUseFullScreenIntent()` value when the OS
/// supports it (null on older Android). [alarmChannelEnabled] reports whether
/// the dedicated alarm channel is currently usable in Android Settings.
@immutable
class AlarmStyleCapability {
  const AlarmStyleCapability({
    required this.status,
    required this.fullScreenAllowed,
    required this.notificationPermission,
    required this.exactAlarmAccess,
    required this.alarmChannelEnabled,
  });

  final AlarmStyleCapabilityStatus status;
  final bool? fullScreenAllowed;
  final bool notificationPermission;
  final bool exactAlarmAccess;
  final bool alarmChannelEnabled;

  bool get isAvailable => status == AlarmStyleCapabilityStatus.available;

  bool get fallsBackToProminent =>
      status == AlarmStyleCapabilityStatus.fullScreenNotAllowed ||
      status == AlarmStyleCapabilityStatus.unsupportedAndroidVersion;
}

/// Probes and reports whether Alarm-style reminders can be presented.
///
/// This is a thin facade over the [NotificationService] and the native
/// platform channel. Widgets and providers consume [AlarmStyleCapability]
/// through a Riverpod provider; they never reach into platform APIs directly.
class AlarmStyleCapabilityService {
  AlarmStyleCapabilityService({required NotificationService notificationService})
      // ignore: prefer_initializing_formals
      : _notificationService = notificationService;

  static const _channel = MethodChannel('com.earkania.rehabtrack/notifications');

  static const _fullScreenIntentMinSdk = 34;

  final NotificationService _notificationService;

  /// The reported Android SDK level from the native side (Build.VERSION.SDK_INT).
  /// 0 until first fetch.
  int _osSdkInt = 0;

  @visibleForTesting
  int get osSdkInt => _osSdkInt;

  /// Re-inspects the current device state. Call after returning from the
  /// system "Full screen content" settings to refresh the reported status.
  Future<AlarmStyleCapability> check() async {
    final notificationPermission =
        await _notificationService.hasNotificationPermission();
    final exactAlarmAccess = await _notificationService.hasExactAlarmPermission();
    final alarmChannelEnabled = await _isAlarmChannelEnabled();
    final osSdkInt = await _androidSdkInt();
    final osSupported = osSdkInt >= _fullScreenIntentMinSdk;

    bool? fullScreenAllowed;
    if (osSupported) {
      fullScreenAllowed = await _canUseFullScreenIntent();
    }

    final status = AlarmStyleCapabilityService._resolveStatus(
      osSupported: osSupported,
      notificationPermission: notificationPermission,
      exactAlarmAccess: exactAlarmAccess,
      alarmChannelEnabled: alarmChannelEnabled,
      fullScreenAllowed: fullScreenAllowed,
    );

    return AlarmStyleCapability(
      status: status,
      fullScreenAllowed: fullScreenAllowed,
      notificationPermission: notificationPermission,
      exactAlarmAccess: exactAlarmAccess,
      alarmChannelEnabled: alarmChannelEnabled,
    );
  }

  Future<int> _androidSdkInt() async {
    if (_osSdkInt > 0) return _osSdkInt;
    try {
      final value =
          await _channel.invokeMethod<int>('getAndroidSdkInt');
      _osSdkInt = value ?? 0;
    } catch (_) {
      _osSdkInt = 0;
    }
    return _osSdkInt;
  }

  Future<bool?> _canUseFullScreenIntent() async {
    try {
      return await _channel.invokeMethod<bool>('canUseFullScreenIntent');
    } catch (_) {
      return null;
    }
  }

  Future<bool> _isAlarmChannelEnabled() async {
    try {
      final channels = await _notificationService.getNotificationChannels();
      final alarm =
          channels.where((c) => c.id == NotificationService.alarmChannelId);
      if (alarm.isEmpty) return true; // Not yet created this session.
      final importance = alarm.first.importance;
      return importance == Importance.max || importance == Importance.high;
    } catch (_) {
      return true;
    }
  }

  /// Canonical fallback hierarchy for Alarm-style reminders:
  ///
  /// 1. Alarm requested and full-screen allowed -> alarm channel with the
  ///    full-screen presentation.
  /// 2. Alarm requested and full-screen NOT allowed (API < 34, or exemption
  ///    denied) -> the prominent fallback presentation on the prominent
  ///    channel. Never a crash, never a silent "pretend alarm".
  static AlarmStyleCapabilityStatus _resolveStatus({
    required bool osSupported,
    required bool notificationPermission,
    required bool exactAlarmAccess,
    required bool alarmChannelEnabled,
    required bool? fullScreenAllowed,
  }) {
    if (!notificationPermission) {
      return AlarmStyleCapabilityStatus.notificationPermissionMissing;
    }
    if (!exactAlarmAccess) {
      return AlarmStyleCapabilityStatus.exactAlarmAccessMissing;
    }
    if (!osSupported) {
      return AlarmStyleCapabilityStatus.unsupportedAndroidVersion;
    }
    if (fullScreenAllowed != true) {
      return AlarmStyleCapabilityStatus.fullScreenNotAllowed;
    }
    if (!alarmChannelEnabled) {
      return AlarmStyleCapabilityStatus.channelDisabledOrLimited;
    }
    return AlarmStyleCapabilityStatus.available;
  }

  /// Opens the system "Full screen content" settings for this app.
  /// No-op on Android versions that do not expose the setting.
  Future<bool> openFullScreenSettings() async {
    try {
      return await _channel.invokeMethod<bool>('openFullScreenIntentSettings') ??
          false;
    } catch (_) {
      return false;
    }
  }
}
