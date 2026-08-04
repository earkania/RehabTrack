import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:rehab_track/data/services/notification/notification_scheduler.dart';
import 'package:rehab_track/data/services/notification/notification_service.dart';
import 'package:rehab_track/data/services/notification/reminder_content_formatter.dart';
import 'package:rehab_track/data/services/notification/reminder_payload.dart';
import 'package:rehab_track/domain/entities/doctor_visit_record.dart';
import 'package:rehab_track/domain/enums/enums.dart';
import 'package:rehab_track/domain/repositories/care_contact_repository.dart';
import 'package:rehab_track/domain/repositories/profile_repository.dart';

/// Schedules and cancels the single reminder notification for a doctor visit.
///
/// Reminder semantics:
///  - Only open (`scheduled`) visits with `reminderEnabled` are scheduled.
///  - The reminder fires at `scheduledDateTime - reminderMinutesBefore`.
///  - A reminder that would already be in the past is never scheduled.
///  - The notification carries the visit ID in its payload so both the tap and
///    the Open/Snooze actions can route to the correct visit.
class DoctorVisitReminderService {
  DoctorVisitReminderService({
    required this._notificationService,
    required this._notificationScheduler,
    required this._careContactRepository,
    required this._profileRepository,
    required this._showProfileName,
  });

  final NotificationService _notificationService;
  final NotificationScheduler _notificationScheduler;
  final CareContactRepository _careContactRepository;
  final ProfileRepository _profileRepository;
  final bool Function() _showProfileName;

  /// Schedules (or refreshes) the reminder for [visit]. Returns the scheduled
  /// notification id, or null when nothing should be scheduled.
  Future<int?> scheduleReminder(DoctorVisitRecord visit) async {
    if (visit.id == null) return null;
    if (!visit.reminderEnabled) return null;
    if (visit.status != DoctorVisitStatus.scheduled) return null;

    final reminderAt = visit.scheduledDateTime
        .subtract(Duration(minutes: visit.reminderMinutesBefore));
    final now = DateTime.now();
    if (!reminderAt.isAfter(now)) {
      debugPrint('[DoctorVisitReminder] skipping past reminder '
          'visit=${visit.id} at=$reminderAt');
      return null;
    }

    final tzLocation = tz.local;
    final scheduledDate = tz.TZDateTime(
      tzLocation,
      reminderAt.year,
      reminderAt.month,
      reminderAt.day,
      reminderAt.hour,
      reminderAt.minute,
    );

    final doctor = visit.doctorContactId != null
        ? await _careContactRepository.getContactById(
            visit.profileId,
            visit.doctorContactId!,
          )
        : null;
    final organization = visit.organizationContactId != null
        ? await _careContactRepository.getContactById(
            visit.profileId,
            visit.organizationContactId!,
          )
        : null;
    final profile = await _profileRepository.getActiveProfile(visit.profileId);

    final payload = ReminderPayload(
      type: ReminderType.doctorVisit,
      profileId: visit.profileId,
      scheduleId: visit.id!,
      occurrenceTime: visit.scheduledDateTime.toIso8601String(),
      visitId: visit.id,
      notificationId: NotificationService.doctorVisitNotificationId(visit.id!),
    );

    final id = NotificationService.doctorVisitNotificationId(visit.id!);
    await _notificationScheduler.scheduleSingleOccurrence(
      notificationId: id,
      title: ReminderContentFormatter.doctorVisitTitle(),
      body: ReminderContentFormatter.doctorVisitBody(
        doctor: doctor,
        organization: organization,
        scheduledDateTime: visit.scheduledDateTime,
        reason: visit.reason,
        showProfileName: _showProfileName(),
        profile: profile,
      ),
      scheduledDate: scheduledDate,
      channelId: NotificationService.doctorVisitChannelId,
      payload: payload.toJsonString(),
      includeActions: true,
      isDoctorVisit: true,
    );
    return id;
  }

  /// Cancels the reminder (and any snoozed variant) for [visitId].
  Future<void> cancelReminder(int visitId) async {
    final id = NotificationService.doctorVisitNotificationId(visitId);
    try {
      await _notificationService.cancelNotification(id);
      await _notificationService.cancelNotification(
        NotificationService.snoozeNotificationId(id),
      );
    } catch (e) {
      debugPrint('[DoctorVisitReminder] cancel failed visit=$visitId error=$e');
    }
  }
}
