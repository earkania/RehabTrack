import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/data/services/notification/reminder_content_formatter.dart';
import 'package:rehab_track/data/services/notification/reminder_payload.dart';
import 'package:rehab_track/domain/entities/care_contact.dart';
import 'package:rehab_track/domain/enums/enums.dart';

void main() {
  final now = DateTime(2026, 8, 1, 10, 0);

  CareContact makeContact({
    String displayName = 'Dr. Smith',
    CareContactType type = CareContactType.doctor,
  }) {
    return CareContact(
      profileId: 1,
      contactType: type,
      displayName: displayName,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('ReminderContentFormatter.doctorVisitTitle', () {
    test('returns the fixed doctor visit reminder title', () {
      expect(ReminderContentFormatter.doctorVisitTitle(),
          'Doctor visit reminder');
    });
  });

  group('ReminderContentFormatter.doctorVisitBody', () {
    test('includes doctor name, scheduled time, and reason', () {
      final body = ReminderContentFormatter.doctorVisitBody(
        doctor: makeContact(displayName: 'Dr. Smith'),
        organization: null,
        scheduledDateTime: DateTime(2026, 8, 2, 14, 30),
        reason: 'Follow-up',
      );
      expect(body, contains('Dr. Smith'));
      expect(body, contains('Scheduled for 14:30'));
      expect(body, contains('Follow-up'));
    });

    test('includes both doctor and organization names', () {
      final body = ReminderContentFormatter.doctorVisitBody(
        doctor: makeContact(displayName: 'Dr. Smith'),
        organization: makeContact(
          displayName: 'City Clinic',
          type: CareContactType.clinic,
        ),
        scheduledDateTime: now,
      );
      expect(body, contains('Dr. Smith'));
      expect(body, contains('City Clinic'));
    });

    test('falls back to "Doctor visit" when no contacts are named', () {
      final body = ReminderContentFormatter.doctorVisitBody(
        doctor: null,
        organization: null,
        scheduledDateTime: now,
      );
      expect(body, contains('Doctor visit'));
    });

    test('never includes profile name by default', () {
      final body = ReminderContentFormatter.doctorVisitBody(
        doctor: makeContact(),
        organization: null,
        scheduledDateTime: now,
        showProfileName: true,
        profile: null,
      );
      expect(body, isNot(contains('Patient')));
    });
  });

  group('ReminderPayload doctor visit fields', () {
    test('round-trips visitId through JSON', () {
      final payload = ReminderPayload(
        type: ReminderType.doctorVisit,
        profileId: 1,
        scheduleId: 42,
        occurrenceTime: now.toIso8601String(),
        visitId: 42,
        notificationId: 5000042,
      );

      final parsed = ReminderPayload.parse(payload.toJsonString());
      expect(parsed, isNotNull);
      expect(parsed!.type, ReminderType.doctorVisit);
      expect(parsed.visitId, 42);
      expect(parsed.scheduleId, 42);
    });

    test('round-trips a visit without visitId', () {
      final payload = ReminderPayload(
        type: ReminderType.doctorVisit,
        profileId: 1,
        scheduleId: 7,
        occurrenceTime: now.toIso8601String(),
      );

      final parsed = ReminderPayload.parse(payload.toJsonString());
      expect(parsed!.visitId, isNull);
      expect(parsed.scheduleId, 7);
    });
  });
}
