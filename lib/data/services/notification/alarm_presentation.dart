import 'notification_service.dart';
import 'reminder_payload.dart';

/// The active Alarm-style presentation shown when the app is opened by an
/// alarm notification (full-screen intent) or an alarm notification is tapped.
///
/// This is transient UI state, not a medical record: it only carries enough
/// information to render the alarm and to acknowledge it through the canonical
/// notification action bridge. Dismissing it never creates or mutates medical
/// data.
class AlarmPresentation {
  const AlarmPresentation({
    required this.notificationId,
    required this.payload,
  });

  final int notificationId;
  final String payload;

  bool get isTestAlarm => payload == NotificationService.testAlarmPayload;

  ReminderPayload? get reminder => ReminderPayload.parse(payload);
}