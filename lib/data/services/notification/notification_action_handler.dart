enum NotificationActionType { taken, skipped, snoozed }

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
