import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/data/repositories/measurement_repository_impl.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/measurement_period.dart';
import 'package:rehab_track/domain/entities/measurement_time_of_day_filter.dart';
import 'package:rehab_track/domain/services/measurement_time_of_day_classifier.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/measurement_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/screens/health/measurement_history_screen.dart';
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

  /// Seeds a mix covering every time-of-day group, with several in the same
  /// group so chronological ordering can be asserted:
  ///  * Morning (06:00..12:00): 3 readings
  ///  * Midday (12:00..17:00):  2 readings
  ///  * Evening (17:00..22:00): 1 reading
  ///  * Night (22:00..06:00):   2 readings
  Future<void> seedStdReadings() async {
    await seedReading(daysAgo: 1, hour: 8, value: 70); // morning
    await seedReading(daysAgo: 3, hour: 7, value: 71); // morning
    await seedReading(daysAgo: 5, hour: 11, minute: 59, value: 72); // morning
    await seedReading(daysAgo: 2, hour: 12, value: 73); // midday
    await seedReading(daysAgo: 4, hour: 16, minute: 59, value: 74); // midday
    await seedReading(daysAgo: 6, hour: 18, value: 75); // evening
    await seedReading(daysAgo: 7, hour: 23, value: 76); // night
    await seedReading(daysAgo: 0, hour: 23, value: 77); // night
  }

  Widget buildApp(
    ProviderContainer container, {
    Locale locale = const Locale('en'),
    ThemeData? theme,
    double textScale = 1.0,
  }) {
    final router = GoRouter(
      initialLocation: '/history',
      routes: [
        GoRoute(
          path: '/history',
          builder: (context, state) =>
              MeasurementHistoryScreen(measurementTypeId: typeId),
        ),
        GoRoute(
          path: '/measurements/measurement/:typeId/trends',
          builder: (context, state) {
            final gTypeId =
                int.parse(state.pathParameters['typeId']!);
            final extra = state.extra as MeasurementTrendsExtra?;
            return MeasurementTrendsScreen(
              measurementTypeId: gTypeId,
              initialTimeOfDayFilter:
                  extra?.initialTimeOfDayFilter ??
                      MeasurementTimeOfDayFilter.all,
            );
          },
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

  Future<int> countMatching(MeasurementTimeOfDayFilter f) async {
    final all = await repo.getRecords(profileId,
        typeId: typeId, ascending: true);
    return all
        .where((r) => MeasurementTimeOfDayClassifier.matches(r.timestamp, f))
        .length;
  }

  setUp(() async {
    database = db.AppDatabase.test();
    await database.customStatement('PRAGMA foreign_keys = ON');
    repo = MeasurementRepositoryImpl(database);
    await seedWeightType();
    await seedStdReadings();
    addTearDown(database.close);
  });

  group('MeasurementHistoryScreen time-of-day filter', () {
    testWidgets('shows five time-of-day options and defaults to All',
        (tester) async {
      usePixel7Portrait(tester);
      final container = await newContainer();
      await tester.pumpWidget(buildApp(container));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(MeasurementTimeOfDaySelector)),
      )!;

      expect(tod(l10n.allReadings), findsOneWidget);
      expect(tod(l10n.morningReadings), findsOneWidget);
      expect(tod(l10n.middayReadings), findsOneWidget);
      expect(tod(l10n.eveningReadings), findsOneWidget);
      expect(tod(l10n.nightReadings), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('All shows all records; Morning filters to morning only',
        (tester) async {
      usePixel7Portrait(tester);
      final container = await newContainer();
      await tester.pumpWidget(buildApp(container));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(MeasurementTimeOfDaySelector)),
      )!;

      // All time-of-day: every seeded record is present.
      final allCount = await countMatching(MeasurementTimeOfDayFilter.all);
      expect(allCount, 8);
      expect(
        tester.widgetList(find.byType(ListTile)).length,
        allCount,
      );

      // Morning: only the three morning records remain.
      await tester.tap(tod(l10n.morningReadings));
      await tester.pumpAndSettle();
      final morningCount =
          await countMatching(MeasurementTimeOfDayFilter.morning);
      expect(morningCount, 3);
      expect(
        tester.widgetList(find.byType(ListTile)).length,
        morningCount,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('each time-of-day group shows only its own records',
        (tester) async {
      usePixel7Portrait(tester);
      final container = await newContainer();
      await tester.pumpWidget(buildApp(container));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(MeasurementTimeOfDaySelector)),
      )!;

      for (final (label, filter) in [
        (l10n.middayReadings, MeasurementTimeOfDayFilter.midday),
        (l10n.eveningReadings, MeasurementTimeOfDayFilter.evening),
        (l10n.nightReadings, MeasurementTimeOfDayFilter.night),
      ]) {
        await tester.tap(tod(label));
        await tester.pumpAndSettle();
        final expected = await countMatching(filter);
        expect(
          tester.widgetList(find.byType(ListTile)).length,
          expected,
          reason: 'Unexpected count for ${filter.name}',
        );
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('filtering keeps chronological ordering (newest first)',
        (tester) async {
      usePixel7Portrait(tester);
      final container = await newContainer();
      await tester.pumpWidget(buildApp(container));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(MeasurementTimeOfDaySelector)),
      )!;

      // The repo returns records newest-first. The classifier filter must
      // preserve that relative order for the morning subset.
      final records = await repo.getRecords(profileId,
          typeId: typeId, ascending: false);
      final morningValues = records
          .where((r) =>
              MeasurementTimeOfDayClassifier.matches(
                r.timestamp,
                MeasurementTimeOfDayFilter.morning,
              ))
          .map((r) => r.valuePrimary)
          .toList();

      await tester.tap(tod(l10n.morningReadings));
      await tester.pumpAndSettle();

      // Three morning readings, preserved in newest-first order.
      expect(morningValues, [70.0, 71.0, 72.0]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('filtered empty state shows when none match the time of day',
        (tester) async {
      // Isolated fresh database containing only a single morning reading, so
      // selecting Night yields a filtered-empty state distinct from the
      // generic "no readings yet" state.
      await database.close();
      database = db.AppDatabase.test();
      await database.customStatement('PRAGMA foreign_keys = ON');
      repo = MeasurementRepositoryImpl(database);
      await seedWeightType();
      await seedReading(daysAgo: 1, hour: 8, value: 90);
      addTearDown(database.close);

      usePixel7Portrait(tester);
      final container = await newContainer();
      await tester.pumpWidget(buildApp(container));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(MeasurementTimeOfDaySelector)),
      )!;

      await tester.tap(tod(l10n.nightReadings));
      await tester.pumpAndSettle();
      expect(find.text(l10n.noReadingsForTimeOfDay), findsOneWidget);
      expect(find.text(l10n.noReadingsYet), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('three-dot menu is a trailing action and still opens the menu',
        (tester) async {
      usePixel7Portrait(tester);
      final container = await newContainer();
      await tester.pumpWidget(buildApp(container));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(MeasurementTimeOfDaySelector)),
      )!;

      // Each row exposes a trailing popup menu button.
      final menu = find.byType(PopupMenuButton<String>);
      final menuFinder = find.descendant(
        of: find.byType(ListTile),
        matching: find.byType(PopupMenuButton<String>),
      );
      expect(menuFinder, findsNWidgets(8));

      // Tapping the button opens the Edit / Delete menu.
      await tester.tap(menu.first);
      await tester.pumpAndSettle();
      expect(find.text(l10n.edit), findsOneWidget);
      expect(find.text(l10n.delete), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dark theme + large text fit Pixel 7 portrait without overflow',
        (tester) async {
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
      expect(tod(l10n.morningReadings), findsOneWidget);
      expect(tod(l10n.nightReadings), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('MeasurementHistory to Trends filter handoff', () {
    testWidgets('History All opens Trends with All selected', (tester) async {
      usePixel7Portrait(tester);
      final container = await newContainer();
      await tester.pumpWidget(buildApp(container));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.show_chart));
      await tester.pumpAndSettle();

      expect(
        container.read(measurementTrendTimeOfDayFilterProvider.notifier).state,
        MeasurementTimeOfDayFilter.all,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('History Morning opens Trends with Morning selected',
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

      await tester.tap(find.byIcon(Icons.show_chart));
      await tester.pumpAndSettle();

      expect(
        container.read(measurementTrendTimeOfDayFilterProvider.notifier).state,
        MeasurementTimeOfDayFilter.morning,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Trends opened with a History filter remains interactive (can change)',
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
      await tester.tap(find.byIcon(Icons.show_chart));
      await tester.pumpAndSettle();

      // Trends has its own selector and can switch to Evening normally.
      final trendsL10n = AppLocalizations.of(
        tester.element(find.byType(MeasurementTimeOfDaySelector)),
      )!;
      await tester.tap(tod(trendsL10n.eveningReadings));
      await tester.pumpAndSettle();

      expect(
        container.read(measurementTrendTimeOfDayFilterProvider.notifier).state,
        MeasurementTimeOfDayFilter.evening,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Trends combines incoming time-of-day with its date range',
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
      await tester.tap(find.byIcon(Icons.show_chart));
      await tester.pumpAndSettle();

      // Trends initial = Night (from History).
      expect(
        container.read(measurementTrendTimeOfDayFilterProvider.notifier).state,
        MeasurementTimeOfDayFilter.night,
      );

      // Date-range filter still present and combined with the time-of-day.
      final segmented = tester.widget<SegmentedButton<MeasurementPeriod>>(
        find.byType(SegmentedButton<MeasurementPeriod>),
      );
      expect(segmented.selected, {MeasurementPeriod.last30Days});

      final nightData = await container.read(
        trendDataProvider(
          (
            measurementTypeId: typeId,
            period: MeasurementPeriod.last30Days,
            timeOfDay: MeasurementTimeOfDayFilter.night,
          ),
        ).future,
      );
      expect(nightData.dataPoints, isNotEmpty);
      expect(
        nightData.dataPoints.every(
          (p) =>
              MeasurementTimeOfDayClassifier.matches(
                p.record.timestamp,
                MeasurementTimeOfDayFilter.night,
              ),
        ),
        isTrue,
      );

      // Changing time-of-day inside Trends recombines with the same date range.
      final trendsL10n = AppLocalizations.of(
        tester.element(find.byType(MeasurementTimeOfDaySelector)),
      )!;
      await tester.tap(tod(trendsL10n.morningReadings));
      await tester.pumpAndSettle();

      final morningData = await container.read(
        trendDataProvider(
          (
            measurementTypeId: typeId,
            period: MeasurementPeriod.last30Days,
            timeOfDay: MeasurementTimeOfDayFilter.morning,
          ),
        ).future,
      );
      expect(morningData.dataPoints, isNotEmpty);
      expect(
        morningData.dataPoints.every(
          (p) =>
              MeasurementTimeOfDayClassifier.matches(
                p.record.timestamp,
                MeasurementTimeOfDayFilter.morning,
              ),
        ),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
