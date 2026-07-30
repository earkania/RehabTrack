import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'notification_action_handler.dart';
import 'pending_action_store.dart';

NotificationActionCallback? _notificationActionCallback;
VoidCallback? _notificationTapCallback;

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
      debugPrint('[NotificationService] notification tap, invoking navigation callback');
      tapCallback();
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
    _ => null,
  };
}

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  Completer<void>? _initCompleter;

  static const medicationChannelId = 'rehabtrack_medications';
  static const measurementChannelId = 'rehabtrack_measurements';

  static const _medicationChannelName = 'Medication Reminders';
  static const _medicationChannelDesc =
      'Reminders to take your medications on time';
  static const _measurementChannelName = 'Measurement Reminders';
  static const _measurementChannelDesc =
      'Reminders to record your health measurements';

  static const _medicationNotificationIdOffset = 100000;
  static const _measurementNotificationIdOffset = 1000000;
  static const _snoozeNotificationIdOffset = 2000000;

  static final _vibrationPattern = Int64List.fromList([0, 250, 200, 250]);

  bool get isInitialized => _initialized;

  Future<void> waitForInitialization() {
    if (_initialized) return Future.value();
    _initCompleter ??= Completer<void>();
    return _initCompleter!.future;
  }

  void setActionCallback(NotificationActionCallback callback) {
    _notificationActionCallback = callback;
  }

  void setNotificationTapCallback(VoidCallback callback) {
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

  Future<String?> getDeviceTimeZone() async {
    const channel = MethodChannel('com.earkania.rehabtrack/notifications');
    try {
      return await channel.invokeMethod<String>('getTimeZone');
    } catch (_) {
      return null;
    }
  }



  AndroidNotificationDetails _channelDetails({
    required String channelId,
    required String channelName,
    required String channelDesc,
    List<AndroidNotificationAction>? actions,
    bool playSound = true,
    bool enableVibration = true,
    NotificationVisibility visibility = NotificationVisibility.public,
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      actions: actions,
      playSound: playSound,
      enableVibration: enableVibration,
      vibrationPattern: enableVibration ? _vibrationPattern : null,
      visibility: visibility,
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
      ),
    );
  }

  static const _medicationActions = [
    AndroidNotificationAction(
      'medication_mark_taken',
      'Mark as Taken',
      showsUserInterface: false,
    ),
    AndroidNotificationAction(
      'medication_snooze',
      'Snooze',
      showsUserInterface: false,
    ),
    AndroidNotificationAction(
      'medication_skip',
      'Skip',
      showsUserInterface: false,
    ),
  ];

  static const _measurementActions = [
    AndroidNotificationAction(
      'measurement_record_now',
      'Record Now',
      showsUserInterface: false,
    ),
    AndroidNotificationAction(
      'measurement_snooze',
      'Snooze',
      showsUserInterface: false,
    ),
    AndroidNotificationAction(
      'measurement_skip',
      'Skip',
      showsUserInterface: false,
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
    bool playSound = true,
    bool enableVibration = true,
    NotificationVisibility visibility = NotificationVisibility.public,
  }) async {
    if (!_initialized) {
      debugPrint('[NotificationService] showNotification SKIPPED: not initialized');
      return;
    }

    final channelDesc = _channelDescForId(channelId);
    final channelName = _channelNameForId(channelId);
    final actions = includeActions
        ? (isMeasurement ? _measurementActions : _medicationActions)
        : null;

    final details = _detailsForChannel(
      channelId: channelId,
      channelName: channelName,
      channelDesc: channelDesc,
      actions: actions,
      playSound: playSound,
      enableVibration: enableVibration,
      visibility: visibility,
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
    bool playSound = true,
    bool enableVibration = true,
    NotificationVisibility visibility = NotificationVisibility.public,
  }) async {
    if (!_initialized) {
      debugPrint('[NotificationService] scheduleNotification SKIPPED: not initialized');
      return;
    }

    final channelDesc = _channelDescForId(channelId);
    final channelName = _channelNameForId(channelId);
    final actions = includeActions
        ? (isMeasurement ? _measurementActions : _medicationActions)
        : null;

    final details = _detailsForChannel(
      channelId: channelId,
      channelName: channelName,
      channelDesc: channelDesc,
      actions: actions,
      playSound: playSound,
      enableVibration: enableVibration,
      visibility: visibility,
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

  String _channelNameForId(String channelId) => switch (channelId) {
        medicationChannelId => _medicationChannelName,
        measurementChannelId => _measurementChannelName,
        _ => _medicationChannelName,
      };

  String _channelDescForId(String channelId) => switch (channelId) {
        medicationChannelId => _medicationChannelDesc,
        measurementChannelId => _measurementChannelDesc,
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
