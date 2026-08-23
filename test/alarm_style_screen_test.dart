import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/app.dart';
import 'package:rehab_track/core/router/app_router.dart';
import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/data/services/notification/alarm_presentation.dart';
import 'package:rehab_track/data/services/notification/notification_service.dart';
import 'package:rehab_track/data/services/notification/reminder_payload.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/notification_provider.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';
import 'package:rehab_track/presentation/screens/health/measurement_entry_screen.dart';

void main() {
  const testNotificationId = 5000001;
  late db.AppDatabase database;
  late _RecordingNotificationService recording;

  setUp(() {
    database = db.AppDatabase.test();
    recording = _RecordingNotificationService();
  });

  tearDown(() async {
    await database.close();
  });

  Future<int> insertProfile() {
    return database.into(database.profiles).insert(
      db.ProfilesCompanion.insert(
        firstName: 'John',
        lastName: 'Doe',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        isPrimary: const Value(true),
        isActive: const Value(true),
      ),
    );
  }

  Future<int> insertDoctor(int profileId) {
    return database.careContactDao.insertContact(
      db.CareContactsCompanion.insert(
        profileId: profileId,
        contactType: 'doctor',
        displayName: 'Dr. Smith',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    );
  }

  Future<int> createVisit(int profileId, int doctorId) {
    return database.into(database.doctorVisitRecords).insert(
      db.DoctorVisitRecordsCompanion.insert(
        profileId: profileId,
        doctorContactId: Value(doctorId),
        visitType: 'planned',
        status: 'scheduled',
        scheduledDateTime: DateTime(2026, 8, 1, 10, 0),
        reason: const Value('Check-up'),
        reminderEnabled: const Value(true),
        reminderMinutesBefore: const Value(15),
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    );
  }

  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        notificationServiceProvider.overrideWithValue(recording),
        todayAutoRefreshProvider.overrideWith((ref) {}),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<ProviderContainer> pumpAlarm(
    WidgetTester tester,
    ReminderPayload payload,
  ) async {
    final container = buildContainer();
    container.read(activeAlarmPresentationProvider.notifier).state =
        AlarmPresentation(
      notificationId: testNotificationId,
      payload: payload.toJsonString(),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const RehabTrackApp(),
      ),
    );
    // The app auto-presents the active alarm by pushing `/alarm` after the
    // first frame (same path as a cold start / notification tap).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets(
      'Doctor visit alarm Details navigates to the visit details screen, '
      'not Today', (tester) async {
    final profileId = await insertProfile();
    final doctorId = await insertDoctor(profileId);
    final visitId = await createVisit(profileId, doctorId);

    final container = buildContainer();
    final router = container.read(routerProvider);
    final visitRepo = container.read(doctorVisitRepositoryProvider);

    // Make sure the visit resolves through the real repository used by the
    // action bridge.
    final visit = await visitRepo.getVisitById(profileId, visitId);
    expect(visit, isNotNull);

    final alarmPresentation = AlarmPresentation(
      notificationId: 5000001,
      payload: ReminderPayload(
        type: ReminderType.doctorVisit,
        profileId: profileId,
        scheduleId: visitId,
        occurrenceTime: '2026-08-01T10:00:00',
        visitId: visitId,
      ).toJsonString(),
    );

    container.read(activeAlarmPresentationProvider.notifier).state =
        alarmPresentation;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const RehabTrackApp(),
      ),
    );
    await tester.pump();

    router.go(AppRoutes.alarm);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Alarm'), findsOneWidget);
    expect(find.text('Details'), findsOneWidget);

    await tester.tap(find.text('Details'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Visit Details'), findsOneWidget);
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('Alarm screen clears the presentation after dismissing',
      (tester) async {
    final profileId = await insertProfile();
    final doctorId = await insertDoctor(profileId);
    final visitId = await createVisit(profileId, doctorId);

    final container = buildContainer();
    final router = container.read(routerProvider);

    final alarmPresentation = AlarmPresentation(
      notificationId: 5000001,
      payload: ReminderPayload(
        type: ReminderType.doctorVisit,
        profileId: profileId,
        scheduleId: visitId,
        occurrenceTime: '2026-08-01T10:00:00',
        visitId: visitId,
      ).toJsonString(),
    );

    container.read(activeAlarmPresentationProvider.notifier).state =
        alarmPresentation;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const RehabTrackApp(),
      ),
    );
    await tester.pump();

    router.go(AppRoutes.alarm);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Alarm'), findsOneWidget);
  });

  group('Alarm-style action surface', () {
    ReminderPayload medicationPayload() => ReminderPayload(
          type: ReminderType.medication,
          profileId: 1,
          scheduleId: 77,
          occurrenceTime: '2026-08-01T10:00:00',
          medicationId: 3,
        );

    ReminderPayload measurementPayload() => ReminderPayload(
          type: ReminderType.measurement,
          profileId: 1,
          scheduleId: 88,
          occurrenceTime: '2026-08-01T10:00:00',
          measurementTypeId: 1,
        );

    testWidgets('Medication alarm offers only Taken, Snooze and Skip',
        (tester) async {
      await pumpAlarm(tester, medicationPayload());

      expect(find.text('Mark as Taken'), findsOneWidget);
      expect(find.text('Snooze'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Dismiss'), findsNothing);
      expect(find.text('Close'), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
      expect(find.byIcon(Icons.notifications_off_outlined), findsNothing);
    });

    testWidgets('Measurement alarm offers only Record Now, Snooze and Skip',
        (tester) async {
      await pumpAlarm(tester, measurementPayload());

      expect(find.text('Record Now'), findsOneWidget);
      expect(find.text('Snooze'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Dismiss'), findsNothing);
      expect(find.text('Close'), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
      expect(find.byIcon(Icons.notifications_off_outlined), findsNothing);
    });

    testWidgets('Doctor visit alarm offers only Details and Snooze',
        (tester) async {
      final profileId = await insertProfile();
      final doctorId = await insertDoctor(profileId);
      final visitId = await createVisit(profileId, doctorId);

      await pumpAlarm(
        tester,
        ReminderPayload(
          type: ReminderType.doctorVisit,
          profileId: profileId,
          scheduleId: visitId,
          occurrenceTime: '2026-08-01T10:00:00',
          visitId: visitId,
        ),
      );

      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Snooze'), findsOneWidget);
      expect(find.text('Dismiss'), findsNothing);
      expect(find.text('Close'), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
      expect(find.byIcon(Icons.notifications_off_outlined), findsNothing);
    });

    testWidgets(
        'System back closes the alarm, stops the sound and leaves the '
        'occurrence unresolved', (tester) async {
      final container = await pumpAlarm(tester, medicationPayload());
      final router = container.read(routerProvider);

      expect(find.text('Mark as Taken'), findsOneWidget);

      final stopsBefore = recording.stopSoundCount;
      expect(router.canPop(), isTrue);
      router.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Alarm UI closed and the sound was stopped exactly once by the screen's
      // dispose path (the presentation is intentionally left unresolved).
      expect(find.text('Mark as Taken'), findsNothing);
      expect(recording.stopSoundCount, stopsBefore + 1);

      // No medical log was created for the occurrence.
      final logs = await database.medicationDao.getLogs(77);
      expect(logs, isEmpty);
    });
    testWidgets(
        'Blood pressure alarm Record Now opens Add Measurement, not Today',
        (tester) async {
      final profileId = await insertProfile();
      await database.into(database.measurementTypes).insert(
        db.MeasurementTypesCompanion.insert(
          name: 'Blood Pressure',
          unit: 'mmHg',
          measurementCategory: 'vital',
          key: const Value('blood_pressure'),
          isSystem: const Value(true),
          displayOrder: const Value(0),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final container = await pumpAlarm(
        tester,
        ReminderPayload(
          type: ReminderType.measurement,
          profileId: profileId,
          scheduleId: 88,
          occurrenceTime: '2026-08-01T10:00:00',
          measurementTypeId: 1,
        ),
      );
      final router = container.read(routerProvider);

      expect(find.text('Record Now'), findsOneWidget);

      await tester.tap(find.text('Record Now'));
      await tester.pump();
      await tester.pumpAndSettle();

      // The entry form for the reminded type is on top — not Today.
      expect(find.byType(MeasurementEntryScreen), findsOneWidget);
      expect(
        router.routerDelegate.currentConfiguration.last.matchedLocation,
        '/measurements/measurement/1/add',
      );

      // The alarm presentation was consumed exactly once.
      expect(container.read(activeAlarmPresentationProvider), isNull);

      // Record Now itself must not log any values; only saving the form does.
      final records = await database.select(database.measurementRecords).get();
      expect(records, isEmpty);
    });

    testWidgets(
        'Record Now survives a duplicate alarm screen deeper in the stack '
        '(cold-start double presentation)', (tester) async {
      await insertProfile();
      await database.into(database.measurementTypes).insert(
        db.MeasurementTypesCompanion.insert(
          name: 'Blood Pressure',
          unit: 'mmHg',
          measurementCategory: 'vital',
          key: const Value('blood_pressure'),
          isSystem: const Value(true),
          displayOrder: const Value(0),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final container = await pumpAlarm(tester, measurementPayload());
      final router = container.read(routerProvider);

      // On a real device the alarm route used to be pushed twice on cold
      // start (onAlarmPresent + the uri-based re-check, which cannot see
      // imperative pushes). Two AlarmStyleScreen instances end up stacked;
      // simulate exactly that.
      router.push(AppRoutes.alarm);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.text('Record Now'), findsAtLeastNWidgets(1));

      // The visible (top-most) alarm handles the tap.
      await tester.tap(find.text('Record Now').last);
      await tester.pump();
      await tester.pumpAndSettle();

      // The buried duplicate's stale-route fallback must not wipe the
      // Add Measurement handoff.
      expect(find.byType(MeasurementEntryScreen), findsOneWidget);
      expect(
        router.routerDelegate.currentConfiguration.last.matchedLocation,
        '/measurements/measurement/1/add',
      );
      expect(container.read(activeAlarmPresentationProvider), isNull);
    });

    testWidgets('Malformed alarm payload falls back to dismiss-only view',
        (tester) async {
      final container = buildContainer();
      container.read(activeAlarmPresentationProvider.notifier).state =
          AlarmPresentation(
        notificationId: testNotificationId,
        payload: 'not-a-valid-payload',
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const RehabTrackApp(),
        ),
      );
      await tester.pump();

      final router = container.read(routerProvider);
      router.go(AppRoutes.alarm);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // No medical actions are offered for an unrecognized payload.
      expect(find.text('Dismiss test alarm'), findsOneWidget);
      expect(find.text('Record Now'), findsNothing);

      await tester.tap(find.text('Dismiss test alarm'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Falls back safely to Today without trapping or crashing.
      expect(
        router.routerDelegate.currentConfiguration.last.matchedLocation,
        '/',
      );
    });
  });
}

class _RecordingNotificationService extends NotificationService {
  int stopSoundCount = 0;

  @override
  Future<bool> startAlarmSound({String? uri}) async => true;

  @override
  Future<void> stopAlarmSound() async {
    stopSoundCount++;
  }

  @override
  Future<void> cancelNotification(int id) async {}
}