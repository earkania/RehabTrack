enum NotificationActionType {
  medicationMarkTaken,
  medicationSnooze,
  medicationSkip,
  measurementRecordNow,
  measurementSnooze,
  measurementSkip,
  doctorVisitOpen,
  doctorVisitSnooze,
  tap,
  dismiss,
}

class NotificationActionResponse {
  const NotificationActionResponse({
    required this.notificationId,
    required this.actionId,
    required this.actionType,
    this.payload,
  });

  final int notificationId;
  final String actionId;
  final NotificationActionType actionType;
  final String? payload;
}

typedef NotificationActionCallback = void Function(
  NotificationActionResponse response,
);

/// Invoked when a notification body is tapped (no action button pressed). The
/// payload allows routing doctor-visit notifications to the matching visit.
/// [notificationId] is the id of the tapped notification (used to dismiss an
/// active Alarm-style presentation).
typedef NotificationTapCallback = void Function(
  int? notificationId,
  String? payload,
);
