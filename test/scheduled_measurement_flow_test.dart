import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/data/repositories/measurement_repository_impl.dart';
import 'package:rehab_track/data/repositories/medication_repository_impl.dart';
import 'package:rehab_track/data/services/notification/notification_scheduler.dart';
import 'package:rehab_track/data/services/notification/notification_service.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/scheduled_measurement.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';
import 'package:rehab_track/domain/repositories/measurement_repository.dart';
import 'package:rehab_track/domain/services/today_agenda_service.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/notification_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';

class _FixedTodayClock implements TodayClock {
  final DateTime fixed;
  _FixedTodayClock(this.fixed);
  @override
  DateTime now() => fixed;
}

class _ThrowingNotificationScheduler extends NotificationScheduler {
  _ThrowingNotificationScheduler()
      : super(
          notificationService: NotificationService(),
          playSound: true,
          enableVibration: true,
        );

  @override
  Future<void> cancelOccurrenceNotification({
    required int scheduleId,
    required DateTime occurrenceDate,
    required DateTime scheduleStartDate,
    bool isMeasurement = false,
    int slotIndex = 0,
  }) async {
    throw StateError('cancel failed');
  }
}

void main() {
  setUpAll(tzdata.initializeTimeZones);

  group('MeasurementOccurrenceTime.normalize', () {
    test('truncates seconds and milliseconds to minute precision', () {
      final value = DateTime(2026, 8, 12, 10, 30, 45, 500);
      final normalized = MeasurementOccurrenceTime.normalize(value);
      expect(normalized, DateTime(2026, 8, 12, 10, 30));
      expect(normalized.second, 0);
      expect(normalized.millisecond, 0);
      expect(normalized.isUtc, isFalse);
    });

    test('is idempotent', () {
      final first =
          MeasurementOccurrenceTime.normalize(DateTime(2026, 8, 12, 10, 30));
      expect(MeasurementOccurrenceTime.normalize(first), first);
    });

    test('collapses a Tbilisi-offset payload to the device-local slot', () {
      final tzOcc = tz.TZDateTime(
        tz.getLocation('Asia/Tbilisi'),
        2026,
        8,
        12,
        10,
        30,
      );
      // Exactly what lands in a notification payload.
      final iso = tzOcc.toIso8601String();
      final parsed = DateTime.tryParse(iso);
      expect(parsed, isNotNull);
      expect(parsed!.isUtc, isTrue);

      final normalized = MeasurementOccurrenceTime.normalize(parsed);
      final expected = parsed.toLocal();
      expect(normalized.year, expected.year);
      expect(normalized.month, expected.month);
      expect(normalized.day, expected.day);
      expect(normalized.hour, expected.hour);
      expect(normalized.minute, expected.minute);

      // A plain local DateTime for the same wall clock normalizes the same.
      final plainLocal =
          MeasurementOccurrenceTime.normalize(DateTime(2026, 8, 12, 10, 30));
      expect(normalized.isAtSameMomentAs(plainLocal), isTrue);
    });

    test('exact local, ms-bearing local, and UTC instants share a key', () {
      final local = DateTime(2026, 8, 12, 10, 30);
      final withMillis = DateTime(2026, 8, 12, 10, 30, 0, 700);
      final utc = local.toUtc();
      expect(
        MeasurementOccurrenceTime.normalize(local),
        MeasurementOccurrenceTime.normalize(withMillis),
      );
      expect(
        MeasurementOccurrenceTime.normalize(local),
        MeasurementOccurrenceTime.normalize(utc),
      );
    });
  });

  group('recordScheduledMeasurement', () {
    late db.AppDatabase database;
    late MeasurementRepository repo;
    late int profileId;
    late int bpTypeId;
    late int scheduleId;
    late DateTime occurrenceUtc;
    late DateTime slotLocal;
    late String slotTime;

    Future<int> seedProfile() async {
      return database.into(database.profiles).insert(
        db.ProfilesCompanion.insert(
          firstName: 'Test',
          lastName: 'User',
          createdAt: DateTime(2026, 8, 12),
          updatedAt: DateTime(2026, 8, 12),
          isPrimary: const Value(true),
          isActive: const Value(true),
        ),
      );
    }

    Future<int> seedBpType() async {
      final typeId = await database.into(database.measurementTypes).insert(
        db.MeasurementTypesCompanion.insert(
          name: 'Blood Pressure',
          unit: 'mmHg',
          measurementCategory: 'vital',
          key: const Value('blood_pressure'),
          isSystem: const Value(true),
          displayOrder: const Value(0),
          createdAt: DateTime(2026, 8, 12),
          updatedAt: DateTime(2026, 8, 12),
        ),
      );
      for (final f in [
        ('systolic', 'Systolic', 0),
        ('diastolic', 'Diastolic', 1),
        ('pulse', 'Pulse', 2),
      ]) {
        await database.into(database.measurementTypeFields).insert(
          db.MeasurementTypeFieldsCompanion.insert(
            measurementTypeId: typeId,
            fieldKey: f.$1,
            label: f.$2,
            defaultUnit: const Value('mmHg'),
            required: Value(f.$1 != 'pulse'),
            decimalPlaces: const Value(0),
            displayOrder: Value(f.$3),
            createdAt: DateTime(2026, 8, 12),
          ),
        );
      }
      return typeId;
    }

    Future<int> seedSchedule({required String time}) async {
      return database.measurementDao.insertSchedule(
        db.MeasurementSchedulesCompanion.insert(
          profileId: profileId,
          measurementTypeId: bpTypeId,
          scheduleType: 'daily',
          time: time,
          active: const Value(true),
          startDate: Value(DateTime(2026, 8, 12)),
          createdAt: DateTime(2026, 8, 12),
          updatedAt: DateTime(2026, 8, 12),
        ),
      );
    }

    MeasurementRecord buildRecord(DateTime timestamp) {
      return MeasurementRecord(
        profileId: profileId,
        measurementTypeId: bpTypeId,
        timestamp: timestamp,
        valuePrimary: 120,
        unit: 'mmHg',
        irregularHeartbeatDetected: false,
        createdAt: DateTime.now(),
      );
    }

    List<MeasurementRecordValue> buildValues() => [
          MeasurementRecordValue(
            measurementRecordId: 0,
            fieldKey: 'systolic',
            numericValue: 120,
            unit: 'mmHg',
          ),
          MeasurementRecordValue(
            measurementRecordId: 0,
            fieldKey: 'diastolic',
            numericValue: 80,
            unit: 'mmHg',
          ),
        ];

    Future<TodayAgenda> agendaForDay() async {
      final service = TodayAgendaService(
        MedicationRepositoryImpl(database),
        repo,
      );
      return service.generateAgenda(
        profileId,
        selectedDate: DateTime(2026, 8, 12),
        now: slotLocal.add(const Duration(minutes: 5)),
      );
    }

    setUp(() async {
      database = db.AppDatabase.test();
      await database.customStatement('PRAGMA foreign_keys = ON');
      repo = MeasurementRepositoryImpl(database);
      profileId = await seedProfile();
      bpTypeId = await seedBpType();

      // A notification payload serialized from TZDateTime(Asia/Tbilisi,
      // 10:30) parses to this UTC instant regardless of the test machine.
      occurrenceUtc = DateTime.parse('2026-08-12T10:30:00.000+0400');
      slotLocal = MeasurementOccurrenceTime.normalize(occurrenceUtc);
      slotTime = '${slotLocal.hour.toString().padLeft(2, '0')}:'
          '${slotLocal.minute.toString().padLeft(2, '0')}';
      scheduleId = await seedSchedule(time: slotTime);
    });

    tearDown(() async {
      await database.close();
    });

    test('notification flow commits reading, completes occurrence, and Today shows it', () async {
      final result = await repo.recordScheduledMeasurement(
        profileId: profileId,
        record: buildRecord(slotLocal),
        values: buildValues(),
        scheduleId: scheduleId,
        occurrenceDateTime: occurrenceUtc,
      );

      // Reading persisted.
      final records =
          await database.measurementDao.getRecords(profileId, typeId: bpTypeId);
      expect(records, hasLength(1));
      expect(records.single.id, result.recordId);

      // Exactly one completed log, wall-clock matched to the slot, linked.
      final logs =
          await database.measurementDao.getReminderLogsForSchedule(scheduleId);
      expect(logs, hasLength(1));
      expect(logs.single.status, MeasurementReminderAction.completed.name);
      expect(logs.single.measurementRecordId, result.recordId);
      expect(logs.single.scheduledTime.year, slotLocal.year);
      expect(logs.single.scheduledTime.month, slotLocal.month);
      expect(logs.single.scheduledTime.day, slotLocal.day);
      expect(logs.single.scheduledTime.hour, slotLocal.hour);
      expect(logs.single.scheduledTime.minute, slotLocal.minute);

      // Today agenda shows the occurrence as completed.
      final agenda = await agendaForDay();
      final item = agenda.items
          .where((i) => i.type == TodayAgendaItemType.measurement)
          .single;
      expect(item.status, TodayAgendaItemStatus.completed);
      expect(item.measurementRecordId, result.recordId);
    });

    test('Today popup flow (local slot) also completes the occurrence', () async {
      final result = await repo.recordScheduledMeasurement(
        profileId: profileId,
        record: buildRecord(slotLocal),
        values: buildValues(),
        scheduleId: scheduleId,
        occurrenceDateTime: slotLocal,
      );

      final logs =
          await database.measurementDao.getReminderLogsForSchedule(scheduleId);
      expect(logs, hasLength(1));
      expect(logs.single.status, MeasurementReminderAction.completed.name);

      final agenda = await agendaForDay();
      expect(
        agenda.items
            .where((i) => i.type == TodayAgendaItemType.measurement)
            .single
            .status,
        TodayAgendaItemStatus.completed,
      );
      expect(result.notificationCancelled, isTrue);
    });

    test('manual entry (no schedule) creates a reading without any log', () async {
      final result = await repo.recordScheduledMeasurement(
        profileId: profileId,
        record: buildRecord(slotLocal),
        values: buildValues(),
      );

      expect(result.reminderLogId, isNull);
      final records =
          await database.measurementDao.getRecords(profileId, typeId: bpTypeId);
      expect(records, hasLength(1));
      final logs =
          await database.measurementDao.getReminderLogsForSchedule(scheduleId);
      expect(logs, isEmpty);
    });

    test('second save for the same occurrence updates the existing log (idempotent)', () async {
      final first = await repo.recordScheduledMeasurement(
        profileId: profileId,
        record: buildRecord(slotLocal),
        values: buildValues(),
        scheduleId: scheduleId,
        occurrenceDateTime: occurrenceUtc,
      );
      expect(first.alreadyCompleted, isFalse);

      final second = await repo.recordScheduledMeasurement(
        profileId: profileId,
        record: buildRecord(slotLocal),
        values: buildValues(),
        scheduleId: scheduleId,
        occurrenceDateTime: occurrenceUtc,
      );

      expect(second.alreadyCompleted, isTrue);
      expect(second.recordId, isNot(first.recordId));

      // Still one log row; only the linked reading changes.
      final logs =
          await database.measurementDao.getReminderLogsForSchedule(scheduleId);
      expect(logs, hasLength(1));
      expect(logs.single.measurementRecordId, second.recordId);
    });

    test('late notification (same slot, seconds later) still matches', () async {
      final lateOccurrence = occurrenceUtc.add(const Duration(seconds: 47));
      final result = await repo.recordScheduledMeasurement(
        profileId: profileId,
        record: buildRecord(slotLocal),
        values: buildValues(),
        scheduleId: scheduleId,
        occurrenceDateTime: lateOccurrence,
      );

      final records =
          await database.measurementDao.getRecords(profileId, typeId: bpTypeId);
      expect(records, hasLength(1));
      expect(records.single.id, result.recordId);

      final logs =
          await database.measurementDao.getReminderLogsForSchedule(scheduleId);
      expect(logs, hasLength(1));
      expect(logs.single.status, MeasurementReminderAction.completed.name);

      final agenda = await agendaForDay();
      expect(
        agenda.items
            .where((i) => i.type == TodayAgendaItemType.measurement)
            .single
            .status,
        TodayAgendaItemStatus.completed,
      );
    });

    test('failure after the reading insert rolls the whole operation back', () async {
      // scheduleId points to a non-existent schedule, so the reminder-log
      // insert violates the foreign key and must roll back the reading too.
      await expectLater(
        repo.recordScheduledMeasurement(
          profileId: profileId,
          record: buildRecord(slotLocal),
          values: buildValues(),
          scheduleId: 99999,
          occurrenceDateTime: occurrenceUtc,
        ),
        throwsA(anything),
      );

      final records =
          await database.measurementDao.getRecords(profileId, typeId: bpTypeId);
      expect(records, isEmpty);
    });

    test('cancellation failure does not roll back data and is reported', () async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(database),
          notificationSchedulerProvider
              .overrideWithValue(_ThrowingNotificationScheduler()),
          currentActiveProfileIdProvider.overrideWithValue(profileId),
        ],
      );
      addTearDown(container.dispose);

      final repoFromContainer = container.read(measurementRepositoryProvider);
      final result = await repoFromContainer.recordScheduledMeasurement(
        profileId: profileId,
        record: buildRecord(slotLocal),
        values: buildValues(),
        scheduleId: scheduleId,
        occurrenceDateTime: occurrenceUtc,
      );

      expect(result.notificationCancelled, isFalse);

      final records =
          await database.measurementDao.getRecords(profileId, typeId: bpTypeId);
      expect(records, hasLength(1));
      final logs =
          await database.measurementDao.getReminderLogsForSchedule(scheduleId);
      expect(logs, hasLength(1));
      expect(logs.single.status, MeasurementReminderAction.completed.name);
    });

    test('provider refresh surfaces the completed item immediately', () async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(database),
          currentActiveProfileIdProvider.overrideWithValue(profileId),
          todayClockProvider.overrideWithValue(
            _FixedTodayClock(slotLocal.add(const Duration(minutes: 5))),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Before saving, the scheduled item is pending.
      final before = await container.read(todayAgendaProvider.future);
      final beforeItem = before.items
          .where((i) => i.type == TodayAgendaItemType.measurement)
          .single;
      expect(beforeItem.status, isNot(TodayAgendaItemStatus.completed));

      final repoFromContainer = container.read(measurementRepositoryProvider);
      await repoFromContainer.recordScheduledMeasurement(
        profileId: profileId,
        record: buildRecord(slotLocal),
        values: buildValues(),
        scheduleId: scheduleId,
        occurrenceDateTime: occurrenceUtc,
      );

      container.invalidate(todayAgendaProvider);

      final after = await container.read(todayAgendaProvider.future);
      final afterItem = after.items
          .where((i) => i.type == TodayAgendaItemType.measurement)
          .single;
      expect(afterItem.status, TodayAgendaItemStatus.completed);
    });
  });
}
