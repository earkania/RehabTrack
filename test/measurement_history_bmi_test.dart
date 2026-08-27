import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/data/repositories/measurement_repository_impl.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/screens/health/measurement_history_screen.dart';

void main() {
  late db.AppDatabase database;
  late MeasurementRepositoryImpl repo;
  late int weightTypeId;

  DateTime at({required int daysAgo, required int hour, int minute = 0}) {
    final base = DateTime.now();
    final d = base.subtract(Duration(days: daysAgo));
    return DateTime(d.year, d.month, d.day, hour, minute);
  }

  Future<int> seedProfile({double? heightCm}) async {
    return database.into(database.profiles).insert(
          db.ProfilesCompanion.insert(
            firstName: 'Test',
            lastName: 'User',
            heightCm: Value(heightCm),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isPrimary: const Value(true),
            isActive: const Value(true),
          ),
        );
  }

  Future<int> seedType(String key, String name) async {
    final typeId = await database.into(database.measurementTypes).insert(
          db.MeasurementTypesCompanion.insert(
            name: name,
            unit: 'kg',
            measurementCategory: 'vital',
            key: Value(key),
            isSystem: const Value(true),
            displayOrder: const Value(0),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
    await database.into(database.measurementTypeFields).insert(
          db.MeasurementTypeFieldsCompanion.insert(
            measurementTypeId: typeId,
            fieldKey: key,
            label: name,
            defaultUnit: const Value('kg'),
            required: const Value(true),
            decimalPlaces: const Value(1),
            displayOrder: const Value(0),
            createdAt: DateTime.now(),
          ),
        );
    return typeId;
  }

  Future<void> seedReading({
    required int profileId,
    required int typeId,
    required String fieldKey,
    required double value,
    required int daysAgo,
  }) async {
    await repo.createRecord(
      MeasurementRecord(
        profileId: profileId,
        measurementTypeId: typeId,
        timestamp: at(daysAgo: daysAgo, hour: 9),
        valuePrimary: value,
        unit: 'kg',
        createdAt: DateTime.now(),
      ),
      [
        MeasurementRecordValue(
          measurementRecordId: 0,
          fieldKey: fieldKey,
          numericValue: value,
          unit: 'kg',
          displayOrder: 0,
        ),
      ],
    );
  }

  Widget buildApp(
    ProviderContainer container, {
    Locale locale = const Locale('en'),
    ThemeData? theme,
    double textScale = 1.0,
    required int measurementTypeId,
  }) {
    final router = GoRouter(
      initialLocation: '/history',
      routes: [
        GoRoute(
          path: '/history',
          builder: (context, state) => MeasurementHistoryScreen(
            measurementTypeId: measurementTypeId,
          ),
        ),
      ],
    );
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        theme: theme,
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
      ),
    );
  }

  Future<ProviderContainer> newContainer(int activeProfileId) async {
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        currentActiveProfileIdProvider.overrideWithValue(activeProfileId),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  void usePixel7Portrait(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  setUp(() async {
    database = db.AppDatabase.test();
    await database.customStatement('PRAGMA foreign_keys = ON');
    repo = MeasurementRepositoryImpl(database);
    addTearDown(database.close);
  });

  group('BMI in Weight Measurement History', () {
    testWidgets(
        'each weight row shows BMI computed from its own recorded weight '
        '(profile height 170 cm)', (tester) async {
      final profileId = await seedProfile(heightCm: 170);
      weightTypeId = await seedType('weight', 'Weight');
      await seedReading(
        profileId: profileId,
        typeId: weightTypeId,
        fieldKey: 'weight',
        value: 90,
        daysAgo: 1,
      );
      await seedReading(
        profileId: profileId,
        typeId: weightTypeId,
        fieldKey: 'weight',
        value: 80,
        daysAgo: 2,
      );

      usePixel7Portrait(tester);
      final container = await newContainer(profileId);
      await tester
          .pumpWidget(buildApp(container, measurementTypeId: weightTypeId));
      await tester.pumpAndSettle();

      // 90 / 1.70² = 31.1 ; 80 / 1.70² = 27.7
      expect(find.text('BMI 31.1'), findsOneWidget);
      expect(find.text('BMI 27.7'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('missing profile height omits BMI but still shows weight',
        (tester) async {
      final profileId = await seedProfile(); // height null
      weightTypeId = await seedType('weight', 'Weight');
      await seedReading(
        profileId: profileId,
        typeId: weightTypeId,
        fieldKey: 'weight',
        value: 90,
        daysAgo: 1,
      );

      usePixel7Portrait(tester);
      final container = await newContainer(profileId);
      await tester
          .pumpWidget(buildApp(container, measurementTypeId: weightTypeId));
      await tester.pumpAndSettle();

      // The weight record is still present, but no BMI is derived.
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.textContaining('BMI'), findsNothing);
      expect(find.text('BMI 0.0'), findsNothing);
      expect(find.text('NaN'), findsNothing);
      expect(find.text('Infinity'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('zero-height profile omits BMI (no 0.0/NaN/Infinity)',
        (tester) async {
      final profileId = await seedProfile(heightCm: 0);
      weightTypeId = await seedType('weight', 'Weight');
      await seedReading(
        profileId: profileId,
        typeId: weightTypeId,
        fieldKey: 'weight',
        value: 90,
        daysAgo: 1,
      );

      usePixel7Portrait(tester);
      final container = await newContainer(profileId);
      await tester
          .pumpWidget(buildApp(container, measurementTypeId: weightTypeId));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.textContaining('BMI'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses only the active profile height for BMI (no leakage)',
        (tester) async {
      // Same recorded weight (90 kg) under two profiles with different heights.
      final profileA = await seedProfile(heightCm: 170);
      final profileB = await seedProfile(heightCm: 180);
      weightTypeId = await seedType('weight', 'Weight');
      await seedReading(
        profileId: profileA,
        typeId: weightTypeId,
        fieldKey: 'weight',
        value: 90,
        daysAgo: 1,
      );
      await seedReading(
        profileId: profileB,
        typeId: weightTypeId,
        fieldKey: 'weight',
        value: 90,
        daysAgo: 1,
      );

      usePixel7Portrait(tester);

      // Active profile A (170 cm): 90 / 1.70² = 31.1
      final containerA = await newContainer(profileA);
      await tester
          .pumpWidget(buildApp(containerA, measurementTypeId: weightTypeId));
      await tester.pumpAndSettle();
      expect(find.text('BMI 31.1'), findsOneWidget);
      expect(find.text('BMI 27.8'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('active profile with different height computes BMI with its own '
        'height', (tester) async {
      final profileA = await seedProfile(heightCm: 170);
      final profileB = await seedProfile(heightCm: 180);
      weightTypeId = await seedType('weight', 'Weight');
      await seedReading(
        profileId: profileA,
        typeId: weightTypeId,
        fieldKey: 'weight',
        value: 90,
        daysAgo: 1,
      );
      await seedReading(
        profileId: profileB,
        typeId: weightTypeId,
        fieldKey: 'weight',
        value: 90,
        daysAgo: 1,
      );

      usePixel7Portrait(tester);

      // Active profile B (180 cm): 90 / 1.80² = 27.8
      final containerB = await newContainer(profileB);
      await tester
          .pumpWidget(buildApp(containerB, measurementTypeId: weightTypeId));
      await tester.pumpAndSettle();
      expect(find.text('BMI 27.8'), findsOneWidget);
      expect(find.text('BMI 31.1'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('non-weight history type shows no BMI', (tester) async {
      final profileId = await seedProfile(heightCm: 170);
      final pulseTypeId = await seedType('pulse', 'Pulse');
      await seedReading(
        profileId: profileId,
        typeId: pulseTypeId,
        fieldKey: 'pulse',
        value: 72,
        daysAgo: 1,
      );

      usePixel7Portrait(tester);
      final container = await newContainer(profileId);
      await tester
          .pumpWidget(buildApp(container, measurementTypeId: pulseTypeId));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.textContaining('BMI'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dark theme + large text + Georgian show BMI without overflow',
        (tester) async {
      final profileId = await seedProfile(heightCm: 170);
      weightTypeId = await seedType('weight', 'Weight');
      await seedReading(
        profileId: profileId,
        typeId: weightTypeId,
        fieldKey: 'weight',
        value: 90,
        daysAgo: 1,
      );
      await seedReading(
        profileId: profileId,
        typeId: weightTypeId,
        fieldKey: 'weight',
        value: 80,
        daysAgo: 2,
      );

      usePixel7Portrait(tester);
      final container = await newContainer(profileId);
      await tester.pumpWidget(
        buildApp(
          container,
          measurementTypeId: weightTypeId,
          locale: const Locale('ka'),
          theme: ThemeData.dark(),
          textScale: 1.5,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('BMI'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  });
}
