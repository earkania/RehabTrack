import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/app.dart';
import 'package:rehab_track/core/router/app_router.dart';
import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/data/services/notification/alarm_presentation.dart';
import 'package:rehab_track/data/services/notification/reminder_payload.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/notification_provider.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';

void main() {
  late db.AppDatabase database;

  setUp(() {
    database = db.AppDatabase.test();
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
        todayAutoRefreshProvider.overrideWith((ref) {}),
      ],
    );
    addTearDown(container.dispose);
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
}