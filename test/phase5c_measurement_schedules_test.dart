import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/data/services/notification/measurement_notification_helper.dart';

void main() {
  group('MeasurementSchedule entity', () {
    test('copyWith preserves all fields', () {
      final now = DateTime(2025);
      final schedule = MeasurementSchedule(
        id: 1,
        profileId: 10,
        measurementTypeId: 5,
        scheduleType: 'daily',
        time: '08:00',
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        active: true,
        instructions: 'Take after breakfast',
        createdAt: now,
        updatedAt: now,
      );

      final copy = schedule.copyWith(instructions: 'New instructions');
      expect(copy.id, 1);
      expect(copy.profileId, 10);
      expect(copy.measurementTypeId, 5);
      expect(copy.scheduleType, 'daily');
      expect(copy.time, '08:00');
      expect(copy.instructions, 'New instructions');
      expect(copy.startDate, now);
      expect(copy.active, true);
    });

    test('copyWith clearInstructions sets instructions to null', () {
      final now = DateTime(2025);
      final schedule = MeasurementSchedule(
        id: 1,
        profileId: 10,
        measurementTypeId: 5,
        scheduleType: 'daily',
        time: '08:00',
        instructions: 'Old instructions',
        createdAt: now,
        updatedAt: now,
      );

      final copy = schedule.copyWith(clearInstructions: true);
      expect(copy.instructions, isNull);
    });

    test('copyWith clearEndDate sets endDate to null', () {
      final now = DateTime(2025);
      final schedule = MeasurementSchedule(
        id: 1,
        profileId: 10,
        measurementTypeId: 5,
        scheduleType: 'daily',
        time: '08:00',
        endDate: now.add(const Duration(days: 30)),
        createdAt: now,
        updatedAt: now,
      );

      final copy = schedule.copyWith(clearEndDate: true);
      expect(copy.endDate, isNull);
    });

    test('default active is true', () {
      final now = DateTime(2025);
      final schedule = MeasurementSchedule(
        profileId: 10,
        measurementTypeId: 5,
        scheduleType: 'daily',
        time: '08:00',
        createdAt: now,
        updatedAt: now,
      );
      expect(schedule.active, true);
    });

    test('isDaily returns true for daily schedule', () {
      final schedule = MeasurementSchedule(
        profileId: 10,
        measurementTypeId: 5,
        scheduleType: 'daily',
        time: '08:00',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      expect(schedule.isDaily, true);
      expect(schedule.isIntervalDays, false);
    });

    test('isIntervalDays returns true for interval schedule', () {
      final schedule = MeasurementSchedule(
        profileId: 10,
        measurementTypeId: 5,
        scheduleType: 'interval_days',
        time: '08:00',
        intervalDays: 3,
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      expect(schedule.isIntervalDays, true);
      expect(schedule.isDaily, false);
    });

    test('normalizeTime normalizes HH:mm format', () {
      expect(MeasurementSchedule.normalizeTime('8:0'), '08:00');
      expect(MeasurementSchedule.normalizeTime('08:00'), '08:00');
      expect(MeasurementSchedule.normalizeTime(' 08:00 '), '08:00');
      expect(MeasurementSchedule.normalizeTime('23:59'), '23:59');
    });

    test('isValidTime validates time format', () {
      expect(MeasurementSchedule.isValidTime('08:00'), true);
      expect(MeasurementSchedule.isValidTime('23:59'), true);
      expect(MeasurementSchedule.isValidTime('00:00'), true);
      expect(MeasurementSchedule.isValidTime('24:00'), false);
      expect(MeasurementSchedule.isValidTime('abc'), false);
      expect(MeasurementSchedule.isValidTime(''), false);
    });

    test('one time per schedule - intervalDays is null for daily', () {
      final schedule = MeasurementSchedule(
        profileId: 10,
        measurementTypeId: 5,
        scheduleType: 'daily',
        time: '08:00',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      expect(schedule.intervalDays, isNull);
    });

    test('clearIntervalDays sets intervalDays to null', () {
      final schedule = MeasurementSchedule(
        profileId: 10,
        measurementTypeId: 5,
        scheduleType: 'daily',
        time: '08:00',
        intervalDays: 3,
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      final copy = schedule.copyWith(clearIntervalDays: true);
      expect(copy.intervalDays, isNull);
    });
  });

  group('MeasurementReminderAction', () {
    test('fromString returns correct action for valid strings', () {
      expect(
        MeasurementReminderAction.fromString('completed'),
        MeasurementReminderAction.completed,
      );
      expect(
        MeasurementReminderAction.fromString('skipped'),
        MeasurementReminderAction.skipped,
      );
      expect(
        MeasurementReminderAction.fromString('snoozed'),
        MeasurementReminderAction.snoozed,
      );
      expect(
        MeasurementReminderAction.fromString('expired'),
        MeasurementReminderAction.expired,
      );
    });

    test('fromString defaults to expired for unknown values', () {
      expect(
        MeasurementReminderAction.fromString('unknown'),
        MeasurementReminderAction.expired,
      );
      expect(
        MeasurementReminderAction.fromString(''),
        MeasurementReminderAction.expired,
      );
    });
  });

  group('MeasurementReminderLog entity', () {
    test('copyWith preserves all fields', () {
      final now = DateTime(2025);
      final log = MeasurementReminderLog(
        id: 1,
        measurementScheduleId: 10,
        scheduledTime: now,
        actionTime: now.add(const Duration(minutes: 5)),
        status: MeasurementReminderAction.completed,
        createdAt: now,
      );

      final copy = log.copyWith(status: MeasurementReminderAction.skipped);
      expect(copy.id, 1);
      expect(copy.measurementScheduleId, 10);
      expect(copy.status, MeasurementReminderAction.skipped);
      expect(copy.scheduledTime, now);
      expect(copy.actionTime, now.add(const Duration(minutes: 5)));
    });
  });

  group('MeasurementNotificationHelper', () {
    test('computeNotificationId applies 100000 offset', () {
      final id = MeasurementNotificationHelper.computeNotificationId(5);
      expect(id, 100005);
    });

    test('computeNotificationId with schedule id 1', () {
      final id = MeasurementNotificationHelper.computeNotificationId(1);
      expect(id, 100001);
    });

    test('baseNotificationId applies offset', () {
      expect(
        MeasurementNotificationHelper.baseNotificationId(42),
        100042,
      );
    });

    test('buildPayload produces valid JSON with measurement type', () {
      final payload = MeasurementNotificationHelper.buildPayload(
        scheduleId: 5,
        measurementTypeId: 3,
        profileId: 1,
        scheduledTime: '2025-01-01T08:00:00',
      );

      final json = jsonDecode(payload) as Map<String, dynamic>;
      expect(json['type'], 'measurement');
      expect(json['scheduleId'], 5);
      expect(json['measurementTypeId'], 3);
      expect(json['profileId'], 1);
      expect(json['scheduledTime'], '2025-01-01T08:00:00');
    });

    test('parsePayload parses valid measurement payload', () {
      final payload = MeasurementNotificationHelper.buildPayload(
        scheduleId: 5,
        measurementTypeId: 3,
        profileId: 1,
        scheduledTime: '2025-01-01T08:00:00',
      );

      final parsed = MeasurementNotificationHelper.parsePayload(payload);
      expect(parsed, isNotNull);
      expect(parsed!.scheduleId, 5);
      expect(parsed.measurementTypeId, 3);
      expect(parsed.profileId, 1);
      expect(parsed.scheduledTime, '2025-01-01T08:00:00');
    });

    test('parsePayload returns null for null input', () {
      expect(MeasurementNotificationHelper.parsePayload(null), isNull);
    });

    test('parsePayload returns null for empty string', () {
      expect(MeasurementNotificationHelper.parsePayload(''), isNull);
    });

    test('parsePayload returns null for invalid JSON', () {
      expect(
        MeasurementNotificationHelper.parsePayload('not-json'),
        isNull,
      );
    });

    test('parsePayload returns null for non-measurement type', () {
      final payload = jsonEncode({
        'type': 'medication',
        'scheduleId': 5,
        'measurementTypeId': 3,
      });
      expect(
        MeasurementNotificationHelper.parsePayload(payload),
        isNull,
      );
    });

    test('parsePayload returns null when scheduleId is missing', () {
      final payload = jsonEncode({
        'type': 'measurement',
        'measurementTypeId': 3,
      });
      expect(
        MeasurementNotificationHelper.parsePayload(payload),
        isNull,
      );
    });

    test('parsePayload returns null when measurementTypeId is missing', () {
      final payload = jsonEncode({
        'type': 'measurement',
        'scheduleId': 5,
      });
      expect(
        MeasurementNotificationHelper.parsePayload(payload),
        isNull,
      );
    });

    test('parsePayload defaults profileId to 1 when not provided', () {
      final payload = jsonEncode({
        'type': 'measurement',
        'scheduleId': 5,
        'measurementTypeId': 3,
      });
      final parsed = MeasurementNotificationHelper.parsePayload(payload);
      expect(parsed!.profileId, 1);
    });
  });

  group('MeasurementNotificationPayload', () {
    test('isValid returns true for valid IDs', () {
      const payload = MeasurementNotificationPayload(
        scheduleId: 1,
        measurementTypeId: 1,
        profileId: 1,
      );
      expect(payload.isValid, true);
    });

    test('isValid returns false for zero scheduleId', () {
      const payload = MeasurementNotificationPayload(
        scheduleId: 0,
        measurementTypeId: 1,
        profileId: 1,
      );
      expect(payload.isValid, false);
    });

    test('isValid returns false for zero measurementTypeId', () {
      const payload = MeasurementNotificationPayload(
        scheduleId: 1,
        measurementTypeId: 0,
        profileId: 1,
      );
      expect(payload.isValid, false);
    });
  });

  group('MeasurementSchedule one-time-per-record model', () {
    test('daily schedule has single time', () {
      final schedule = MeasurementSchedule(
        profileId: 10,
        measurementTypeId: 5,
        scheduleType: 'daily',
        time: '08:00',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      expect(schedule.time, '08:00');
      expect(schedule.isDaily, true);
      expect(schedule.intervalDays, isNull);
    });

    test('interval schedule has single time and interval', () {
      final schedule = MeasurementSchedule(
        profileId: 10,
        measurementTypeId: 5,
        scheduleType: 'interval_days',
        time: '14:00',
        intervalDays: 3,
        startDate: DateTime(2025),
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      expect(schedule.time, '14:00');
      expect(schedule.intervalDays, 3);
      expect(schedule.isIntervalDays, true);
    });

    test('two schedules at different times are independent', () {
      final schedule1 = MeasurementSchedule(
        id: 1,
        profileId: 10,
        measurementTypeId: 5,
        scheduleType: 'daily',
        time: '08:00',
        active: true,
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      final schedule2 = MeasurementSchedule(
        id: 2,
        profileId: 10,
        measurementTypeId: 5,
        scheduleType: 'daily',
        time: '20:00',
        active: true,
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      expect(schedule1.time, isNot(equals(schedule2.time)));
      expect(schedule1.id, isNot(equals(schedule2.id)));
    });

    test('disabling one schedule does not affect another', () {
      final schedule1 = MeasurementSchedule(
        id: 1,
        profileId: 10,
        measurementTypeId: 5,
        scheduleType: 'daily',
        time: '08:00',
        active: false,
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      final schedule2 = MeasurementSchedule(
        id: 2,
        profileId: 10,
        measurementTypeId: 5,
        scheduleType: 'daily',
        time: '20:00',
        active: true,
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      expect(schedule1.active, false);
      expect(schedule2.active, true);
    });

    test('each schedule gets its own notification ID', () {
      final id1 = MeasurementNotificationHelper.computeNotificationId(1);
      final id2 = MeasurementNotificationHelper.computeNotificationId(2);
      expect(id1, isNot(equals(id2)));
      expect(id1, 100001);
      expect(id2, 100002);
    });
  });
}
