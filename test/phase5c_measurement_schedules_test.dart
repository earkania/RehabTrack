import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/schedule_config.dart';
import 'package:rehab_track/data/services/notification/measurement_notification_helper.dart';

void main() {
  group('MeasurementSchedule entity', () {
    test('copyWith preserves all fields', () {
      final now = DateTime(2025);
      final schedule = MeasurementSchedule(
        id: 1,
        profileId: 10,
        measurementTypeId: 5,
        scheduleConfig: const DailySchedule(times: ['08:00']),
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
        scheduleConfig: const DailySchedule(times: ['08:00']),
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
        scheduleConfig: const DailySchedule(times: ['08:00']),
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
        scheduleConfig: const DailySchedule(times: ['08:00']),
        createdAt: now,
        updatedAt: now,
      );
      expect(schedule.active, true);
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

  group('ScheduleConfig', () {
    test('DailySchedule toJson and fromJson roundtrip', () {
      const config = DailySchedule(times: ['08:00', '20:00']);
      final json = config.toJson();
      final restored = ScheduleConfig.fromJson(json);

      expect(restored, isA<DailySchedule>());
      expect((restored as DailySchedule).times, ['08:00', '20:00']);
    });

    test('IntervalDaysSchedule toJson and fromJson roundtrip', () {
      const config = IntervalDaysSchedule(
        intervalDays: 3,
        times: ['09:00'],
      );
      final json = config.toJson();
      final restored = ScheduleConfig.fromJson(json);

      expect(restored, isA<IntervalDaysSchedule>());
      final interval = restored as IntervalDaysSchedule;
      expect(interval.intervalDays, 3);
      expect(interval.times, ['09:00']);
    });

    test('fromJsonString roundtrip works', () {
      const config = DailySchedule(times: ['06:30', '18:00']);
      final jsonStr = config.toJsonString();
      final restored = ScheduleConfig.fromJsonString(jsonStr);

      expect(restored, isA<DailySchedule>());
      expect((restored as DailySchedule).times, ['06:30', '18:00']);
    });

    test('fromJson throws on unknown type', () {
      expect(
        () => ScheduleConfig.fromJson({'type': 'unknown'}),
        throwsArgumentError,
      );
    });

    test('normalizeTimes removes duplicates and sorts', () {
      final result = ScheduleConfig.normalizeTimes(
        ['20:00', '08:00', '08:00', 'invalid', '20:00'],
      );
      expect(result, ['08:00', '20:00']);
    });

    test('normalizeTimes filters invalid formats', () {
      final result = ScheduleConfig.normalizeTimes([
        '08:00',
        '8:00',
        'abc',
      ]);
      expect(result, ['08:00']);
    });

    test('validateTimes throws on empty list', () {
      expect(
        () => ScheduleConfig.validateTimes([]),
        throwsArgumentError,
      );
    });

    test('validateTimes throws on duplicates', () {
      expect(
        () => ScheduleConfig.validateTimes(['08:00', '08:00']),
        throwsArgumentError,
      );
    });

    test('validateTimes accepts valid unique times', () {
      expect(
        () => ScheduleConfig.validateTimes(['08:00', '20:00']),
        returnsNormally,
      );
    });
  });

  group('MeasurementNotificationHelper', () {
    test('computeNotificationIds applies 100000 offset', () {
      final ids = MeasurementNotificationHelper.computeNotificationIds(
        scheduleId: 5,
        config: const DailySchedule(times: ['08:00', '20:00']),
      );
      expect(ids, [100005, 100006]);
    });

    test('computeNotificationIds with single time', () {
      final ids = MeasurementNotificationHelper.computeNotificationIds(
        scheduleId: 1,
        config: const DailySchedule(times: ['08:00']),
      );
      expect(ids, [100001]);
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

  group('ScheduleConfig equality', () {
    test('DailySchedule equality based on times', () {
      const a = DailySchedule(times: ['08:00', '20:00']);
      const b = DailySchedule(times: ['08:00', '20:00']);
      const c = DailySchedule(times: ['08:00']);

      expect(a, equals(b));
      expect(a == c, false);
    });

    test('IntervalDaysSchedule equality based on interval and times', () {
      const a = IntervalDaysSchedule(intervalDays: 3, times: ['08:00']);
      const b = IntervalDaysSchedule(intervalDays: 3, times: ['08:00']);
      const c = IntervalDaysSchedule(intervalDays: 5, times: ['08:00']);

      expect(a, equals(b));
      expect(a == c, false);
    });

    test('DailySchedule and IntervalDaysSchedule are not equal', () {
      const a = DailySchedule(times: ['08:00']);
      const b = IntervalDaysSchedule(intervalDays: 1, times: ['08:00']);
      expect(a == b, false);
    });
  });
}
