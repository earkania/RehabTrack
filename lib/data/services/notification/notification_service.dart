import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'notification_action_handler.dart';

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  NotificationActionCallback? _actionCallback;
  bool _initialized = false;

  static const _medicationChannelId = 'rehabtrack_medications';
  static const _medicationChannelName = 'Medication Reminders';
  static const _medicationChannelDesc =
      'Reminders to take your medications on time';

  static const _measurementChannelId = 'rehabtrack_measurements';
  static const _measurementChannelName = 'Measurement Reminders';
  static const _measurementChannelDesc =
      'Reminders to record your health measurements';

  static const _appointmentChannelId = 'rehabtrack_appointments';
  static const _appointmentChannelName = 'Appointment Reminders';
  static const _appointmentChannelDesc =
      'Reminders for upcoming doctor appointments';

  static const _exerciseChannelId = 'rehabtrack_exercise';
  static const _exerciseChannelName = 'Exercise Reminders';
  static const _exerciseChannelDesc = 'Reminders for daily exercise activities';

  static const _generalChannelId = 'rehabtrack_general';
  static const _generalChannelName = 'General Notifications';
  static const _generalChannelDesc = 'General app notifications';

  bool get isInitialized => _initialized;

  void setActionCallback(NotificationActionCallback callback) {
    _actionCallback = callback;
  }

  Future<bool> initialize() async {
    if (_initialized) return true;

    tz.initializeTimeZones();

    final androidSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    final initSettings = InitializationSettings(android: androidSettings);

    final result = await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    _initialized = result ?? false;
    return _initialized;
  }

  void _onNotificationResponse(NotificationResponse response) {
    if (_actionCallback == null) return;

    final actionType = _parseActionType(response.actionId);
    if (actionType == null) return;

    _actionCallback!(
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
      'action_taken' => NotificationActionType.taken,
      'action_skipped' => NotificationActionType.skipped,
      'action_snoozed' => NotificationActionType.snoozed,
      _ => null,
    };
  }

  AndroidNotificationDetails _channelDetails({
    required String channelId,
    required String channelName,
    required String channelDesc,
    List<AndroidNotificationAction>? actions,
    Importance importance = Importance.high,
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: importance,
      priority: Priority.high,
      actions: actions,
      enableVibration: true,
    );
  }

  NotificationDetails _detailsForChannel({
    required String channelId,
    required String channelName,
    required String channelDesc,
    List<AndroidNotificationAction>? actions,
    Importance importance = Importance.high,
  }) {
    return NotificationDetails(
      android: _channelDetails(
        channelId: channelId,
        channelName: channelName,
        channelDesc: channelDesc,
        actions: actions,
        importance: importance,
      ),
    );
  }

  static const _defaultActions = [
    AndroidNotificationAction(
      'action_taken',
      'Taken',
      showsUserInterface: false,
    ),
    AndroidNotificationAction(
      'action_snoozed',
      'Snooze',
      showsUserInterface: false,
    ),
    AndroidNotificationAction(
      'action_skipped',
      'Skip',
      showsUserInterface: false,
    ),
  ];

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationChannelType channelType = NotificationChannelType.general,
    bool includeActions = false,
  }) async {
    if (!_initialized) return;

    final details = _detailsForChannel(
      channelId: _channelIdForType(channelType),
      channelName: _channelNameForType(channelType),
      channelDesc: _channelDescForType(channelType),
      actions: includeActions ? _defaultActions : null,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
    NotificationChannelType channelType = NotificationChannelType.general,
    bool includeActions = false,
  }) async {
    if (!_initialized) return;

    final details = _detailsForChannel(
      channelId: _channelIdForType(channelType),
      channelName: _channelNameForType(channelType),
      channelDesc: _channelDescForType(channelType),
      actions: includeActions ? _defaultActions : null,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> scheduleRecurringNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required DateTimeComponents matchComponents,
    String? payload,
    NotificationChannelType channelType = NotificationChannelType.general,
    bool includeActions = false,
  }) async {
    if (!_initialized) return;

    final details = _detailsForChannel(
      channelId: _channelIdForType(channelType),
      channelName: _channelNameForType(channelType),
      channelDesc: _channelDescForType(channelType),
      actions: includeActions ? _defaultActions : null,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
      matchDateTimeComponents: matchComponents,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
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

  String _channelIdForType(NotificationChannelType type) => switch (type) {
        NotificationChannelType.medication => _medicationChannelId,
        NotificationChannelType.measurement => _measurementChannelId,
        NotificationChannelType.appointment => _appointmentChannelId,
        NotificationChannelType.exercise => _exerciseChannelId,
        NotificationChannelType.general => _generalChannelId,
      };

  String _channelNameForType(NotificationChannelType type) => switch (type) {
        NotificationChannelType.medication => _medicationChannelName,
        NotificationChannelType.measurement => _measurementChannelName,
        NotificationChannelType.appointment => _appointmentChannelName,
        NotificationChannelType.exercise => _exerciseChannelName,
        NotificationChannelType.general => _generalChannelName,
      };

  String _channelDescForType(NotificationChannelType type) => switch (type) {
        NotificationChannelType.medication => _medicationChannelDesc,
        NotificationChannelType.measurement => _measurementChannelDesc,
        NotificationChannelType.appointment => _appointmentChannelDesc,
        NotificationChannelType.exercise => _exerciseChannelDesc,
        NotificationChannelType.general => _generalChannelDesc,
      };
}

enum NotificationChannelType {
  medication,
  measurement,
  appointment,
  exercise,
  general,
}
