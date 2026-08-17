import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/data/repositories/measurement_repository_impl.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/measurement_period.dart';
import 'package:rehab_track/domain/entities/measurement_time_of_day_filter.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/measurement_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/screens/health/measurement_trends_screen.dart';
import 'package:rehab_track/presentation/widgets/measurements/measurement_time_of_day_selector.dart';

void main() {
  late db.AppDatabase database;
  late MeasurementRepositoryImpl repo;
  late int profileId;
  late int typeId;

  DateTime at({required int daysAgo, required int hour, int minute = 0}) {
    final base = DateTime.now();
    final d = base.subtract(Duration(days: daysAgo));
    return DateTime(d.year, d.month, d.day, hour, minute);
  }

  Future<void> seedWeightType() async {
    profileId = await database.into(database.profiles).insert(
          db.ProfilesCompanion.insert(
            firstName: 'Test',
            lastName: 'User',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isPrimary: const Value(true),
            isActive: const Value(true),
          ),
        );
    typeId = await database.into(database.measurementTypes).insert(
          db.MeasurementTypesCompanion.insert(
            name: 'Weight',
            unit: 'kg',
            measurementCategory: 'vital',
            key: const Value('weight'),
            isSystem: const Value(true),
            displayOrder: const Value(0),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
    await database.into(database.measurementTypeFields).insert(
      db.MeasurementTypeFieldsCompanion.insert(
        measurementTypeId: typeId,
        fieldKey: 'weight',
        label: 'Weight',
        defaultUnit: const Value('kg'),
        required: const Value(true),
        decimalPlaces: const Value(1),
        displayOrder: const Value(0),
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> seedReading({
    required int daysAgo,
    required int hour,
    int minute = 0,
    required double value,
  }) async {
    await repo.createRecord(
      MeasurementRecord(
        profileId: profileId,
        measurementTypeId: typeId,
        timestamp: at(daysAgo: daysAgo, hour: hour, minute: minute),
        valuePrimary: value,
        unit: 'kg',
        createdAt: DateTime.now(),
      ),
      [
        MeasurementRecordValue(
          measurementRecordId: 0,
          fieldKey: 'weight',
          numericValue: value,
          unit: 'kg',
          displayOrder: 0,
        ),
      ],
    );
  }

  /// Seeds a mix of readings:
  ///  * last 7 days: morning (08:00), midday (13:00), evening (19:00)
  ///  * last 30 days (beyond 7): night (23:00, 05:30)
  ///  * older than 30 days: morning (08:00), night (23:30)
  Future<void> seedStdReadings() async {
    await seedReading(daysAgo: 1, hour: 8, value: 70);
    await seedReading(daysAgo: 5, hour: 7, value: 69);
    await seedReading(daysAgo: 2, hour: 13, value: 72);
    await seedReading(daysAgo: 3, hour: 19, value: 74);
    await seedReading(daysAgo: 10, hour: 23, value: 76);
    await seedReading(daysAgo: 12, hour: 5, minute: 30, value: 71);
    await seedReading(daysAgo: 40, hour: 8, value: 68);
    await seedReading(daysAgo: 40, hour: 23, minute: 30, value: 75);
  }

  Widget buildApp(
    ProviderContainer container, {
    Locale locale = const Locale('en'),
    ThemeData? theme,
    double textScale = 1.0,
  }) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              MeasurementTrendsScreen(measurementTypeId: typeId),
        ),
        GoRoute(
          path: '/measurements/measurement/:typeId/add',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Add Reading'))),
        ),
        GoRoute(
          path: '/measurements/measurement/:typeId/history',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Measurement History'))),
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

  Future<ProviderContainer> newContainer() async {
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        currentActiveProfileIdProvider.overrideWithValue(profileId),
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

  Finder tod(String label) => find.byTooltip(label);

  RegExp selected(String label) =>
      RegExp('^${RegExp.escape(label)}, selected\$');

  group('MeasurementTrendsScreen time-of-day filter', () {
    setUp(() async {
      database = db.AppDatabase.test();
      await database.customStatement('PRAGMA foreign_keys = ON');
      repo = MeasurementRepositoryImpl(database);
      await seedWeightType();
      await seedStdReadings();
      addTearDown(database.close);
    });

    testWidgets(
        'renders date-range filter, five time-of-day options, defaults to All',
        (tester) async {
      usePixel7Portrait(tester);
      final container = await newContainer();
      await tester.pumpWidget(buildApp(container));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(MeasurementTimeOfDaySelector)),
      )!;

      // Existing date-range filter is still present.
      final segmented = tester.widget<SegmentedButton<MeasurementPeriod>>(
        find.byType(SegmentedButton<MeasurementPeriod>),
      );
      expect(segmented.selected, {MeasurementPeriod.last30Days});

      // Five time-of-day options exist.
      expect(tod(l10n.allReadings), findsOneWidget);
      expect(tod(l10n.morningReadings), findsOneWidget);
      expect(tod(l10n.middayReadings), findsOneWidget);
      expect(tod(l10n.eveningReadings), findsOneWidget);
      expect(tod(l10n.nightReadings), findsOneWidget);

      // Default selection is All.
      final handle = tester.ensureSemantics();
      expect(
        find.bySemanticsLabel(selected(l10n.allReadings)),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(selected(l10n.nightReadings)),
        findsNothing,
      );
      handle.dispose();

      expect(tester.takeException(), isNull);
    });

    testWidgets('changing time-of-day filters the dataset and keeps date range',
        (tester) async {
      usePixel7Portrait(tester);
      final container = await newContainer();
      await tester.pumpWidget(buildApp(container));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(MeasurementTimeOfDaySelector)),
      )!;

      await tester.tap(tod(l10n.morningReadings));
      await tester.pumpAndSettle();

      // Time-of-day provider updated; date range untouched.
      expect(
        container.read(measurementTrendTimeOfDayFilterProvider.notifier).state,
        MeasurementTimeOfDayFilter.morning,
      );
      final segmented = tester.widget<SegmentedButton<MeasurementPeriod>>(
        find.byType(SegmentedButton<MeasurementPeriod>),
      );
      expect(segmented.selected, {MeasurementPeriod.last30Days});

      // The final dataset satisfies BOTH filters: 2 morning readings from the
      // last 30 days, and statistics describe that same dataset.
      final data = await container.read(
        trendDataProvider(
          (
            measurementTypeId: typeId,
            period: MeasurementPeriod.last30Days,
            timeOfDay: MeasurementTimeOfDayFilter.morning,
          ),
        ).future,
      );
      expect(data.dataPoints.length, 2);
      expect(data.fieldStatistics['weight']!.count, 2);

      final handle = tester.ensureSemantics();
      expect(
        find.bySemanticsLabel(selected(l10n.morningReadings)),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(selected(l10n.allReadings)),
        findsNothing,
      );
      handle.dispose();
      expect(tester.takeException(), isNull);
    });

    testWidgets('date range and time-of-day are independent', (tester) async {
      usePixel7Portrait(tester);
      final container = await newContainer();
      await tester.pumpWidget(buildApp(container));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(MeasurementTimeOfDaySelector)),
      )!;

      // Last 30 Days + Morning.
      await tester.tap(tod(l10n.morningReadings));
      await tester.pumpAndSettle();

      // Change date range: time-of-day must survive.
      await tester.tap(find.text(l10n.lastSevenDays));
      await tester.pumpAndSettle();
      expect(
        container.read(measurementTrendTimeOfDayFilterProvider.notifier).state,
        MeasurementTimeOfDayFilter.morning,
      );
      expect(
        tester
            .widget<SegmentedButton<MeasurementPeriod>>(
              find.byType(SegmentedButton<MeasurementPeriod>),
            )
            .selected,
        {MeasurementPeriod.last7Days},
      );

      // Change time-of-day: date range must survive.
      await tester.tap(tod(l10n.nightReadings));
      await tester.pumpAndSettle();
      expect(
        container.read(measurementTrendTimeOfDayFilterProvider.notifier).state,
        MeasurementTimeOfDayFilter.night,
      );
      expect(
        tester
            .widget<SegmentedButton<MeasurementPeriod>>(
              find.byType(SegmentedButton<MeasurementPeriod>),
            )
            .selected,
        {MeasurementPeriod.last7Days},
      );

      // Last 7 Days + Night has no night readings in the last 7 days.
      expect(find.text(l10n.noNightReadings), findsOneWidget);

      // Filters remain usable without leaving Trends.
      await tester.tap(tod(l10n.allReadings));
      await tester.pumpAndSettle();
      expect(find.text(l10n.noNightReadings), findsNothing);
      expect(
        container.read(measurementTrendTimeOfDayFilterProvider.notifier).state,
        MeasurementTimeOfDayFilter.all,
      );

      // Last 7 Days + All shows the three readings from the last 7 days.
      final data = await container.read(
        trendDataProvider(
          (
            measurementTypeId: typeId,
            period: MeasurementPeriod.last7Days,
            timeOfDay: MeasurementTimeOfDayFilter.all,
          ),
        ).future,
      );
      expect(data.dataPoints.length, 4);
      expect(data.fieldStatistics['weight']!.count, 4);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Night over 30 days shows a chart, night statistics match',
        (tester) async {
      usePixel7Portrait(tester);
      final container = await newContainer();
      await tester.pumpWidget(buildApp(container));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(MeasurementTimeOfDaySelector)),
      )!;

      await tester.tap(tod(l10n.nightReadings));
      await tester.pumpAndSettle();

      // Two night readings within the last 30 days.
      final data = await container.read(
        trendDataProvider(
          (
            measurementTypeId: typeId,
            period: MeasurementPeriod.last30Days,
            timeOfDay: MeasurementTimeOfDayFilter.night,
          ),
        ).future,
      );
      expect(data.dataPoints.length, 2);
      expect(data.fieldStatistics['weight']!.count, 2);
      expect(data.fieldStatistics['weight']!.minimum, 71);
      // No empty state, chart rendered.
      expect(find.text(l10n.noNightReadings), findsNothing);
      expect(find.byType(MeasurementTimeOfDaySelector), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty combined filter keeps both filters and announces state',
        (tester) async {
      // Force a fresh date range with only non-night readings by using
      // All => empty night set within 7 days.
      usePixel7Portrait(tester);
      final container = await newContainer();
      await tester.pumpWidget(buildApp(container));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(MeasurementTimeOfDaySelector)),
      )!;

      await tester.tap(tod(l10n.nightReadings));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.lastSevenDays));
      await tester.pumpAndSettle();

      expect(find.text(l10n.noNightReadings), findsOneWidget);
      // Both filter controls remain visible and do not reset.
      expect(
        find.byType(SegmentedButton<MeasurementPeriod>),
        findsOneWidget,
      );
      expect(find.byType(MeasurementTimeOfDaySelector), findsOneWidget);
      expect(
        container.read(measurementTrendTimeOfDayFilterProvider.notifier).state,
        MeasurementTimeOfDayFilter.night,
      );
      expect(
        tester
            .widget<SegmentedButton<MeasurementPeriod>>(
              find.byType(SegmentedButton<MeasurementPeriod>),
            )
            .selected,
        {MeasurementPeriod.last7Days},
      );
      final handle = tester.ensureSemantics();
      expect(
        find.bySemanticsLabel(selected(l10n.nightReadings)),
        findsOneWidget,
      );
      handle.dispose();
      expect(tester.takeException(), isNull);
    });

    testWidgets('dark theme + large text fit Pixel 7 portrait', (tester) async {
      usePixel7Portrait(tester);
      final container = await newContainer();
      await tester.pumpWidget(
        buildApp(
          container,
          theme: ThemeData.dark(),
          textScale: 1.5,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Georgian locale renders without overflow', (tester) async {
      usePixel7Portrait(tester);
      final container = await newContainer();
      await tester.pumpWidget(
        buildApp(container, locale: const Locale('ka')),
      );
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(MeasurementTimeOfDaySelector)),
      )!;

      // Georgian tooltips are present.
      expect(tod(l10n.nightReadings), findsOneWidget);
      expect(tod(l10n.morningReadings), findsOneWidget);

      // Georgian empty state for a combined empty result.
      await tester.tap(tod(l10n.nightReadings));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.lastSevenDays));
      await tester.pumpAndSettle();
      expect(find.text(l10n.noNightReadings), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}