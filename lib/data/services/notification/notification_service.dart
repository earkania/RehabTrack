import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../../../domain/entities/alarm_sound_selection.dart';
import '../../../domain/entities/reminder_style.dart';
import 'notification_action_handler.dart';
import 'pending_action_store.dart';

NotificationActionCallback? _notificationActionCallback;
NotificationTapCallback? _notificationTapCallback;

@pragma('vm:entry-point')
void _onBackgroundNotificationResponse(NotificationResponse response) {
  _handleBackgroundNotificationResponse(response);
}

void _onNotificationResponse(NotificationResponse response) {
  _handleNotificationResponse(response);
}

void _handleBackgroundNotificationResponse(NotificationResponse response) {
  final actionType = _parseActionType(response.actionId);
  if (actionType == null) return;

  PendingActionStore.instance.addPendingAction(
    PendingActionEntry(
      actionType: actionType,
      notificationId: response.id ?? 0,
      actionId: response.actionId ?? '',
      payload: response.payload,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ),
  );
}

void _handleNotificationResponse(NotificationResponse response) {
  if (response.actionId == null || response.actionId!.isEmpty) {
    final tapCallback = _notificationTapCallback;
    if (tapCallback != null) {
      tapCallback(response.id, response.payload);
    }
    return;
  }

  final callback = _notificationActionCallback;
  if (callback == null) return;

  final actionType = _parseActionType(response.actionId);
  if (actionType == null) return;

  callback(
    NotificationActionResponse(
      notificationId: response.id ?? 0,
      actionId: response.actionId ?? '',
      actionType: actionType,
      payload: response.payload,
    ),
  );
}

NotificationActionType? _parseActionType(String? actionId) {
  return switch (actionId) {
    'medication_mark_taken' => NotificationActionType.medicationMarkTaken,
    'medication_snooze' => NotificationActionType.medicationSnooze,
    'medication_skip' => NotificationActionType.medicationSkip,
    'measurement_record_now' => NotificationActionType.measurementRecordNow,
    'measurement_snooze' => NotificationActionType.measurementSnooze,
    'measurement_skip' => NotificationActionType.measurementSkip,
    'doctor_visit_open' => NotificationActionType.doctorVisitOpen,
    'doctor_visit_snooze' => NotificationActionType.doctorVisitSnooze,
    _ => null,
  };
}

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  Completer<void>? _initCompleter;

  /// Default alarm ringtone URI from the OS, cached after channel setup so
  /// alarm-style notifications can reuse the same alarm sound without
  /// falling back to the ordinary notification tone.
  String? _alarmSoundUri;

  static const medicationChannelId = 'rehabtrack_medications';
  static const measurementChannelId = 'rehabtrack_measurements';
  static const doctorVisitChannelId = 'rehabtrack_doctor_visits';

  static const _medicationChannelName = 'Medication Reminders';
  static const _medicationChannelDesc =
      'Reminders to take your medications on time';
  static const _measurementChannelName = 'Measurement Reminders';
  static const _measurementChannelDesc =
      'Reminders to record your health measurements';
  static const _doctorVisitChannelName = 'Doctor Visit Reminders';
  static const _doctorVisitChannelDesc =
      'Reminders about your upcoming doctor visits';

  static const _medicationNotificationIdOffset = 100000;
  static const _measurementNotificationIdOffset = 1000000;
  static const _snoozeNotificationIdOffset = 2000000;
  static const _doctorVisitNotificationIdOffset = 5000000;

  static final _vibrationPattern = Int64List.fromList([0, 250, 200, 250]);

  /// Dedicated channel for the [ReminderStyle.prominent] presentation.
  ///
  /// Kept separate from the event-type channels so users can independently
  /// manage prominent alerts in Android Settings without affecting their
  /// standard per-event channel choices (and vice versa).
  static const prominentChannelId = 'rehabtrack_reminders_prominent';
  static const _prominentChannelName = 'Prominent Reminders';
  static const _prominentChannelDesc =
      'High-attention reminders with a stronger alert';
  static final _prominentVibrationPattern =
      Int64List.fromList([0, 300, 200, 300, 200, 300]);

  /// Dedicated channel for the [ReminderStyle.alarmStyle] presentation.
  ///
  /// Alarm-style reminders present through this channel with the strongest
  /// sound, an extended repeating vibration, and (when the OS permits) a
  /// full-screen intent so the alert can interrupt while the screen is locked.
  /// Separate from standard and prominent channels so users can manage it
  /// independently in Android Settings.
  static const alarmChannelId = 'rehabtrack_reminders_alarm_v2';

  /// Legacy alarm channel ID from before the v2 split. The OS on some devices
  /// (e.g. stock Android 17 Pixels) refuses to apply sound/audio-attributes
  /// changes to an existing channel even after a delete+recreate, so the alarm
  /// channel was re-created under a fresh ID. The old channel is removed once
  /// the app launches with the new ID so no stale duplicate remains.
  static const _legacyAlarmChannelId = 'rehabtrack_reminders_alarm';

  /// Channel ID used only by early diagnostic builds during channel-setup
  /// investigation. Cleaned up if present so the notification channel list
  /// stays free of leftover probes.
  static const _debugProbeChannelId = 'rehabtrack_reminders_alarm_probe';
  static const _alarmChannelName = 'Alarm-style Reminders';
  static const _alarmChannelDesc =
      'High-priority alarms with a strong alert and full-screen presentation';
  static final _alarmVibrationPattern =
      Int64List.fromList([0, 400, 300, 400, 300, 400, 300, 400]);

  /// Stable IDs for manual test notifications. Chosen well above all real ID
  /// offsets (medication 100k, measurement 1M, snooze 2M, doctor 5M) so they
  /// can never collide with a scheduled occurrence.
  static const testMedicationNotificationId = 9000000;
  static const testMeasurementNotificationId = 9000001;
  static const testAlarmNotificationId = 9000002;

  static const _insistentFlag = 4;

  /// Payload marker for the manual Alarm-style test. Not a real reminder; the
  /// alarm screen recognises it and shows a safe, Dismiss-only presentation.
  static const testAlarmPayload = 'rehabtrack_test_alarm';

  /// Resolves the channel that presents a reminder of the given event type
  /// under [style]. Standard style keeps the existing per-event channels
  /// (backward compatible with user channel overrides); prominent style routes
  /// all event types through the shared prominent channel; alarm style routes
  /// all event types through the dedicated alarm channel.
  static String channelForReminderStyle({
    required ReminderStyle style,
    required String eventChannelId,
  }) {
    return switch (style) {
      ReminderStyle.standard => eventChannelId,
      ReminderStyle.prominent => prominentChannelId,
      ReminderStyle.alarmStyle => alarmChannelId,
    };
  }

  bool get isInitialized => _initialized;

  Future<void> waitForInitialization() {
    if (_initialized) return Future.value();
    _initCompleter ??= Completer<void>();
    return _initCompleter!.future;
  }

  void setActionCallback(NotificationActionCallback callback) {
    _notificationActionCallback = callback;
  }

  void setNotificationTapCallback(NotificationTapCallback callback) {
    _notificationTapCallback = callback;
  }

  Future<bool> initialize() async {
    if (_initialized) return true;
    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      await _initCompleter!.future;
      return _initialized;
    }
    _initCompleter = Completer<void>();

    tz.initializeTimeZones();
    debugPrint('[NotificationService] tz.local.name: ${tz.local.name}');
    debugPrint('[NotificationService] DateTime.now(): ${DateTime.now()}');
    debugPrint('[NotificationService] DateTime.now().timeZoneName: ${DateTime.now().timeZoneName}');
    debugPrint('[NotificationService] DateTime.now().timeZoneOffset: ${DateTime.now().timeZoneOffset}');

    // Detect and set the device timezone.
    final tzName = await getDeviceTimeZone();
    debugPrint('[NotificationService] device timezone: $tzName');
    if (tzName != null) {
      try {
        tz.setLocalLocation(tz.getLocation(tzName));
        debugPrint('[NotificationService] tz.local set to: ${tz.local.name}');
      } catch (e) {
        debugPrint('[NotificationService] failed to set timezone "$tzName": $e');
      }
    }

    final tzNow = tz.TZDateTime.now(tz.local);
    debugPrint('[NotificationService] tz.local now: $tzNow');

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      debugPrint('[NotificationService] creating channels');
      await _createChannels(androidPlugin);
      debugPrint('[NotificationService] channels created');
    }

    final androidSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    final initSettings = InitializationSettings(android: androidSettings);

    debugPrint('[NotificationService] initializing plugin');
    final result = await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );
    debugPrint('[NotificationService] plugin initialize result: $result');

    _initialized = result ?? false;
    _initCompleter!.complete();
    debugPrint('[NotificationService] initialization complete, _initialized: $_initialized');
    return _initialized;
  }

  Future<void> _createChannels(
    AndroidFlutterLocalNotificationsPlugin androidPlugin,
  ) async {
    await androidPlugin.createNotificationChannel(
      AndroidNotificationChannel(
        medicationChannelId,
        _medicationChannelName,
        description: _medicationChannelDesc,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        vibrationPattern: _vibrationPattern,
      ),
    );
    await androidPlugin.createNotificationChannel(
      AndroidNotificationChannel(
        measurementChannelId,
        _measurementChannelName,
        description: _measurementChannelDesc,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        vibrationPattern: _vibrationPattern,
      ),
    );
    await androidPlugin.createNotificationChannel(
      AndroidNotificationChannel(
        doctorVisitChannelId,
        _doctorVisitChannelName,
        description: _doctorVisitChannelDesc,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        vibrationPattern: _vibrationPattern,
      ),
    );
    await androidPlugin.createNotificationChannel(
      AndroidNotificationChannel(
        prominentChannelId,
        _prominentChannelName,
        description: _prominentChannelDesc,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        vibrationPattern: _prominentVibrationPattern,
      ),
    );

    final alarmSoundUri = await getDefaultAlarmSoundUri();
    _alarmSoundUri = alarmSoundUri;

    final existingChannels = await androidPlugin.getNotificationChannels();
    final existingAlarm = existingChannels
        ?.where((c) => c.id == alarmChannelId)
        .toList()
        .firstOrNull;
    final needsRecreate =
        existingAlarm != null && !_alarmChannelMatches(existingAlarm, alarmSoundUri);
    if (needsRecreate) {
      await androidPlugin.deleteNotificationChannel(alarmChannelId);
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    if (existingChannels
        ?.any((c) => c.id == _legacyAlarmChannelId) ??
        false) {
      await androidPlugin.deleteNotificationChannel(_legacyAlarmChannelId);
    }
    if (existingChannels?.any((c) => c.id == _debugProbeChannelId) ??
        false) {
      await androidPlugin.deleteNotificationChannel(_debugProbeChannelId);
    }

    await androidPlugin.createNotificationChannel(
      AndroidNotificationChannel(
        alarmChannelId,
        _alarmChannelName,
        description: _alarmChannelDesc,
        importance: Importance.max,
        playSound: true,
        sound: alarmSoundUri != null
            ? UriAndroidNotificationSound(alarmSoundUri)
            : null,
        enableVibration: true,
        vibrationPattern: _alarmVibrationPattern,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );
  }

  bool _alarmChannelMatches(
    AndroidNotificationChannel channel,
    String? alarmSoundUri,
  ) {
    return channel.audioAttributesUsage == AudioAttributesUsage.alarm &&
        channel.sound?.sound == alarmSoundUri;
  }

  Future<bool> requestNotificationPermission() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return true;
    final result = await androidPlugin.requestNotificationsPermission();
    return result ?? false;
  }

  Future<bool> requestExactAlarmPermission() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return true;
    final result = await androidPlugin.requestExactAlarmsPermission();
    return result ?? false;
  }

  Future<bool> hasNotificationPermission() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return true;
    return await androidPlugin.areNotificationsEnabled() ?? false;
  }

  Future<bool> hasExactAlarmPermission() async {
    const channel = MethodChannel('com.earkania.rehabtrack/notifications');
    try {
      final result = await channel.invokeMethod<bool>('hasExactAlarmPermission');
      return result ?? true;
    } catch (_) {
      return false;
    }
  }

  Future<void> openAppNotificationSettings() async {
    const channel = MethodChannel('com.earkania.rehabtrack/notifications');
    try {
      await channel.invokeMethod<void>('openNotificationSettings');
    } catch (_) {}
  }

  Future<void> openAlarmSettings() async {
    const channel = MethodChannel('com.earkania.rehabtrack/notifications');
    try {
      await channel.invokeMethod<void>('openAlarmSettings');
    } catch (_) {}
  }

  /// Whether the OS allows full-screen intents for this app (Android 14+ only).
  /// Returns null on older Android or when the native check is unavailable.
  Future<bool?> canUseFullScreenIntent() async {
    const channel = MethodChannel('com.earkania.rehabtrack/notifications');
    try {
      return await channel.invokeMethod<bool>('canUseFullScreenIntent');
    } catch (_) {
      return null;
    }
  }

  /// Opens the system "Full screen content" settings for this app. Returns
  /// false when the setting does not exist on the device.
  Future<bool> openFullScreenSettings() async {
    const channel = MethodChannel('com.earkania.rehabtrack/notifications');
    try {
      return await channel.invokeMethod<bool>('openFullScreenIntentSettings') ??
          false;
    } catch (_) {
      return false;
    }
  }

  /// Android SDK level reported by the device (Build.VERSION.SDK_INT).
  Future<int> getAndroidSdkInt() async {
    const channel = MethodChannel('com.earkania.rehabtrack/notifications');
    try {
      return await channel.invokeMethod<int>('getAndroidSdkInt') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<List<AndroidNotificationChannel>> getNotificationChannels() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return [];
    return await androidPlugin.getNotificationChannels() ?? [];
  }

  Future<String?> getDeviceTimeZone() async {
    const channel = MethodChannel('com.earkania.rehabtrack/notifications');
    try {
      return await channel.invokeMethod<String>('getTimeZone');
    } catch (_) {
      return null;
    }
  }

  /// The OS-default alarm ringtone URI, or null when unavailable.
  Future<String?> getDefaultAlarmSoundUri() async {
    const channel = MethodChannel('com.earkania.rehabtrack/notifications');
    try {
      return await channel.invokeMethod<String>('getDefaultAlarmSoundUri');
    } catch (_) {
      return null;
    }
  }

  /// Resolves the human-readable title for a ringtone/alarm [uri], or null
  /// when the URI cannot be resolved on this device.
  Future<String?> getRingtoneTitle(String uri) async {
    const channel = MethodChannel('com.earkania.rehabtrack/notifications');
    try {
      return await channel.invokeMethod<String>(
        'getRingtoneTitle',
        {'uri': uri},
      );
    } catch (_) {
      return null;
    }
  }

  /// Opens the system alarm-sound picker. Returns the chosen selection, or
  /// null when the user dismisses the picker without choosing.
  Future<AlarmSoundSelection?> pickAlarmSound({String? currentUri}) async {
    const channel = MethodChannel('com.earkania.rehabtrack/notifications');
    try {
      final raw = await channel.invokeMethod<String>(
        'pickAlarmSound',
        {'currentUri': currentUri},
      );
      if (raw == null || raw.isEmpty) return null;
      return AlarmSoundSelection.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  /// Starts looping the given alarm sound through the native alarm player.
  /// A null [uri] plays the system default alarm sound. Returns true when the
  /// sound started successfully.
  Future<bool> startAlarmSound({String? uri}) async {
    const channel = MethodChannel('com.earkania.rehabtrack/notifications');
    try {
      return await channel.invokeMethod<bool>(
            'startAlarmSound',
            {'uri': uri},
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }

  /// Stops the native alarm sound player immediately.
  Future<void> stopAlarmSound() async {
    const channel = MethodChannel('com.earkania.rehabtrack/notifications');
    try {
      await channel.invokeMethod<void>('stopAlarmSound');
    } catch (_) {}
  }

  /// Plays the given alarm sound as a short preview that auto-stops after
  /// ~12 seconds. A null [uri] plays the system default alarm sound.
  Future<bool> startAlarmSoundPreview({String? uri}) async {
    const channel = MethodChannel('com.earkania.rehabtrack/notifications');
    try {
      return await channel.invokeMethod<bool>(
            'startAlarmSoundPreview',
            {'uri': uri},
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }

  /// Stops a playing alarm sound preview immediately.
  Future<void> stopAlarmSoundPreview() async {
    const channel = MethodChannel('com.earkania.rehabtrack/notifications');
    try {
      await channel.invokeMethod<void>('stopAlarmSoundPreview');
    } catch (_) {}
  }



  AndroidNotificationDetails _channelDetails({
    required String channelId,
    required String channelName,
    required String channelDesc,
    List<AndroidNotificationAction>? actions,
    bool playSound = true,
    bool enableVibration = true,
    NotificationVisibility visibility = NotificationVisibility.public,
    bool fullScreenIntent = false,
  }) {
    final isHighAttention =
        channelId == prominentChannelId || channelId == alarmChannelId;
    final isAlarm = channelId == alarmChannelId;
    final alarmSoundUri = _alarmSoundUri;
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: isHighAttention ? Importance.max : Importance.high,
      priority: isHighAttention ? Priority.max : Priority.high,
      category: AndroidNotificationCategory.alarm,
      actions: actions,
      playSound: playSound,
      sound: isAlarm && alarmSoundUri != null
          ? UriAndroidNotificationSound(alarmSoundUri)
          : null,
      enableVibration: enableVibration,
      vibrationPattern: enableVibration
          ? (channelId == alarmChannelId
              ? _alarmVibrationPattern
              : (isHighAttention ? _prominentVibrationPattern : _vibrationPattern))
          : null,
      visibility: visibility,
      fullScreenIntent: fullScreenIntent,
      audioAttributesUsage:
          isAlarm ? AudioAttributesUsage.alarm : AudioAttributesUsage.notification,
      additionalFlags: isAlarm
          ? Int32List.fromList([_insistentFlag])
          : null,
    );
  }

  NotificationDetails _detailsForChannel({
    required String channelId,
    required String channelName,
    required String channelDesc,
    List<AndroidNotificationAction>? actions,
    bool playSound = true,
    bool enableVibration = true,
    NotificationVisibility visibility = NotificationVisibility.public,
    bool fullScreenIntent = false,
  }) {
    return NotificationDetails(
      android: _channelDetails(
        channelId: channelId,
        channelName: channelName,
        channelDesc: channelDesc,
        actions: actions,
        playSound: playSound,
        enableVibration: enableVibration,
        visibility: visibility,
        fullScreenIntent: fullScreenIntent,
      ),
    );
  }

  static const _medicationActions = [
    AndroidNotificationAction(
      'medication_mark_taken',
      'Mark as Taken',
      showsUserInterface: true,
    ),
    AndroidNotificationAction(
      'medication_snooze',
      'Snooze',
      showsUserInterface: true,
    ),
    AndroidNotificationAction(
      'medication_skip',
      'Skip',
      showsUserInterface: true,
    ),
  ];

  static const _measurementActions = [
    AndroidNotificationAction(
      'measurement_record_now',
      'Record Now',
      showsUserInterface: true,
    ),
    AndroidNotificationAction(
      'measurement_snooze',
      'Snooze',
      showsUserInterface: true,
    ),
    AndroidNotificationAction(
      'measurement_skip',
      'Skip',
      showsUserInterface: true,
    ),
  ];

  static const _doctorVisitActions = [
    AndroidNotificationAction(
      'doctor_visit_open',
      'Open',
      showsUserInterface: true,
    ),
    AndroidNotificationAction(
      'doctor_visit_snooze',
      'Snooze',
      showsUserInterface: true,
    ),
  ];

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
  }) async {
    if (!_initialized) {
      debugPrint('[NotificationService] showNotification SKIPPED: not initialized');
      return;
    }

    final channelDesc = _channelDescForId(channelId);
    final channelName = _channelNameForId(channelId);
    final actions = includeActions
        ? _actionsFor(isMeasurement: isMeasurement, isDoctorVisit: isDoctorVisit)
        : null;

    final details = _detailsForChannel(
      channelId: channelId,
      channelName: channelName,
      channelDesc: channelDesc,
      actions: actions,
      playSound: playSound,
      enableVibration: enableVibration,
      visibility: visibility,
      fullScreenIntent: fullScreenIntent,
    );

    debugPrint('[NotificationService] showNotification calling plugin.show');
    try {
      await _plugin.show(id, title, body, details, payload: payload);
      debugPrint('[NotificationService] showNotification completed');
    } catch (e, stack) {
      debugPrint('[NotificationService] showNotification EXCEPTION: $e');
      debugPrint('[NotificationService] showNotification stack: $stack');
      rethrow;
    }
  }

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
    if (!_initialized) {
      debugPrint('[NotificationService] scheduleNotification SKIPPED: not initialized');
      return;
    }

    final channelDesc = _channelDescForId(channelId);
    final channelName = _channelNameForId(channelId);
    final actions = includeActions
        ? _actionsFor(isMeasurement: isMeasurement, isDoctorVisit: isDoctorVisit)
        : null;

    final details = _detailsForChannel(
      channelId: channelId,
      channelName: channelName,
      channelDesc: channelDesc,
      actions: actions,
      playSound: playSound,
      enableVibration: enableVibration,
      visibility: visibility,
      fullScreenIntent: fullScreenIntent,
    );

    debugPrint('[NotificationService] zonedSchedule: id=$id channelId=$channelId scheduledDate=$scheduledDate');
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      debugPrint('[NotificationService] scheduleNotification completed');
    } catch (e, stack) {
      debugPrint('[NotificationService] scheduleNotification EXCEPTION: $e');
      debugPrint('[NotificationService] scheduleNotification stack: $stack');
      rethrow;
    }
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelNotifications(List<int> ids) async {
    for (final id in ids) {
      await _plugin.cancel(id);
    }
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }

  Future<List<ActiveNotification>> getActiveNotifications() async {
    return await _plugin.getActiveNotifications();
  }

  Future<NotificationAppLaunchDetails?> getLaunchDetails() async {
    return await _plugin.getNotificationAppLaunchDetails();
  }

  static int medicationNotificationId({
    required int scheduleId,
    required int dayIndex,
    int slotIndex = 0,
  }) {
    return _medicationNotificationIdOffset +
        scheduleId * 1000 +
        dayIndex * 10 +
        slotIndex;
  }

  static int measurementNotificationId({
    required int scheduleId,
    required int dayIndex,
    int slotIndex = 0,
  }) {
    return _measurementNotificationIdOffset +
        scheduleId * 1000 +
        dayIndex * 10 +
        slotIndex;
  }

  static int snoozeNotificationId(int originalId) {
    return _snoozeNotificationIdOffset + originalId;
  }

  static int doctorVisitNotificationId(int visitId) {
    return _doctorVisitNotificationIdOffset + visitId;
  }

  List<AndroidNotificationAction>? _actionsFor({
    required bool isMeasurement,
    required bool isDoctorVisit,
  }) {
    if (isDoctorVisit) return _doctorVisitActions;
    if (isMeasurement) return _measurementActions;
    return _medicationActions;
  }

  String _channelNameForId(String channelId) => switch (channelId) {
        medicationChannelId => _medicationChannelName,
        measurementChannelId => _measurementChannelName,
        doctorVisitChannelId => _doctorVisitChannelName,
        prominentChannelId => _prominentChannelName,
        alarmChannelId => _alarmChannelName,
        _ => _medicationChannelName,
      };

  String _channelDescForId(String channelId) => switch (channelId) {
        medicationChannelId => _medicationChannelDesc,
        measurementChannelId => _measurementChannelDesc,
        doctorVisitChannelId => _doctorVisitChannelDesc,
        prominentChannelId => _prominentChannelDesc,
        alarmChannelId => _alarmChannelDesc,
        _ => _medicationChannelDesc,
      };
}

enum NotificationChannelType {
  medication,
  measurement,
  appointment,
  exercise,
  general,
}
