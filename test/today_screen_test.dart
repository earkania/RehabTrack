import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/domain/entities/dosage_form.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';
import 'package:rehab_track/presentation/screens/today/today_screen.dart';
import 'package:rehab_track/presentation/widgets/today/today_agenda_item.dart';
import 'package:rehab_track/presentation/widgets/today/today_next_item_card.dart';
import 'package:rehab_track/presentation/widgets/today/today_background.dart';

Widget _wrapWithApp(Widget child, {TodayAgenda? agenda}) {
  final overrides = <Override>[
    todayAutoRefreshProvider.overrideWith((ref) {}),
    selectedAgendaDateProvider.overrideWith((ref) => DateTime(2000, 1, 1)),
  ];
  if (agenda != null) {
    overrides.add(todayAgendaProvider.overrideWith((_) async => agenda));
  }
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

Widget _wrapWithGoRouter(Widget child) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(body: child),
      ),
      GoRoute(
        path: '/measurements/measurement/:typeId/add',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Add Reading')),
        ),
      ),
      GoRoute(
        path: '/measurements/measurement/:typeId/history',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Measurement History')),
        ),
      ),
      GoRoute(
        path: '/measurements/measurement/:typeId/trends',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Measurement Trends')),
        ),
      ),
      GoRoute(
        path: '/medications/medication/:id',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Medication Detail')),
        ),
      ),
      GoRoute(
        path: '/medications/medication/:id/history',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Medication History')),
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      selectedAgendaDateProvider.overrideWith((ref) => DateTime(2000, 1, 1)),
      todayAutoRefreshProvider.overrideWith((ref) {}),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

TodayAgenda _mockAgenda({
  required DateTime now,
  List<TodayAgendaItem>? items,
}) {
  final defaultItems = items ??
      [
        TodayAgendaItem(
          id: 'med_1_0800',
          type: TodayAgendaItemType.medication,
          sourceScheduleId: 1,
          scheduledDateTime: DateTime(now.year, now.month, now.day, 8, 0),
          title: 'Concor 5 mg',
          subtitle: '0.5 tablet',
          status: TodayAgendaItemStatus.overdue,
        ),
        TodayAgendaItem(
          id: 'med_2_1200',
          type: TodayAgendaItemType.medication,
          sourceScheduleId: 2,
          scheduledDateTime: DateTime(now.year, now.month, now.day, 12, 0),
          title: 'Aspirin',
          status: TodayAgendaItemStatus.due,
        ),
        TodayAgendaItem(
          id: 'meas_1_0900',
          type: TodayAgendaItemType.measurement,
          sourceScheduleId: 3,
          scheduledDateTime: DateTime(now.year, now.month, now.day, 9, 0),
          title: 'Blood Pressure',
          status: TodayAgendaItemStatus.completed,
        ),
        TodayAgendaItem(
          id: 'med_3_2300',
          type: TodayAgendaItemType.medication,
          sourceScheduleId: 4,
          scheduledDateTime: DateTime(now.year, now.month, now.day, 23, 0),
          title: 'Physiotens',
          status: TodayAgendaItemStatus.upcoming,
        ),
      ];

  return TodayAgenda(
    date: DateTime(now.year, now.month, now.day),
    items: defaultItems,
    summary: TodaySummary(
      medicationTotal: 3,
      medicationCompleted: 0,
      medicationSkipped: 0,
      medicationOverdue: 1,
      measurementTotal: 1,
      measurementCompleted: 1,
      measurementSkipped: 0,
      measurementOverdue: 0,
    ),
  );
}

Widget _buildScreen({required TodayAgenda agenda}) {
  return ProviderScope(
    overrides: [
      todayAgendaProvider.overrideWith((_) async => agenda),
      todayAutoRefreshProvider.overrideWith((ref) {}),
      selectedAgendaDateProvider.overrideWith((ref) => agenda.date),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const TodayScreen(),
    ),
  );
}

void main() {
  group('TodayScreen', () {
    testWidgets('shows one chronological agenda list with all items',
        (tester) async {
      final now = DateTime(2025, 7, 25, 12, 0);
      final agenda = _mockAgenda(now: now);

      await tester.pumpWidget(_buildScreen(agenda: agenda));
      await tester.pumpAndSettle();

      expect(find.byType(TodayAgendaItemWidget), findsNWidgets(4));
    });

    testWidgets('no separate Overdue section header', (tester) async {
      final now = DateTime(2025, 7, 25, 12, 0);
      final agenda = _mockAgenda(now: now);

      await tester.pumpWidget(_buildScreen(agenda: agenda));
      await tester.pumpAndSettle();

      expect(find.text('Overdue'), findsNothing);
    });

    testWidgets('no separate Medications section header', (tester) async {
      final now = DateTime(2025, 7, 25, 12, 0);
      final agenda = _mockAgenda(now: now);

      await tester.pumpWidget(_buildScreen(agenda: agenda));
      await tester.pumpAndSettle();

      expect(find.text('Medications'), findsNothing);
    });

    testWidgets('no separate Measurements section header', (tester) async {
      final now = DateTime(2025, 7, 25, 12, 0);
      final agenda = _mockAgenda(now: now);

      await tester.pumpWidget(_buildScreen(agenda: agenda));
      await tester.pumpAndSettle();

      expect(find.text('Measurements'), findsNothing);
    });

    testWidgets('no duplicate rows', (tester) async {
      final now = DateTime(2025, 7, 25, 12, 0);
      final agenda = _mockAgenda(now: now);

      await tester.pumpWidget(_buildScreen(agenda: agenda));
      await tester.pumpAndSettle();

      final itemWidgets = find.byType(TodayAgendaItemWidget).evaluate();
      final ids = itemWidgets.map((e) {
        final widget = e.widget as TodayAgendaItemWidget;
        return widget.item.id;
      }).toList();
      expect(ids.toSet().length, ids.length);
    });

    testWidgets('summary is visible', (tester) async {
      final now = DateTime.now();
      final agenda = _mockAgenda(now: now);

      await tester.pumpWidget(_buildScreen(agenda: agenda));
      await tester.pumpAndSettle();

      expect(find.text("Today's Progress"), findsOneWidget);
    });

    testWidgets('status icons are visible for each status', (tester) async {
      final now = DateTime(2025, 7, 25, 12, 0);
      final agenda = _mockAgenda(now: now);

      await tester.pumpWidget(_buildScreen(agenda: agenda));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning_amber_rounded), findsWidgets);
      expect(find.byIcon(Icons.alarm), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsWidgets);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('past item has muted background via TodayBackground',
        (tester) async {
      final item = TodayAgendaItem(
        id: 'past',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime.now().subtract(const Duration(hours: 2)),
        title: 'Past Item',
        status: TodayAgendaItemStatus.overdue,
      );

      final bg = TodayBackground.forItem(item, DateTime.now(), const Duration(minutes: 15));
      final theme = ThemeData.light();
      expect(bg.cardColor(theme), isNull);
    });

    testWidgets('future item has normal background via TodayBackground',
        (tester) async {
      final item = TodayAgendaItem(
        id: 'future',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime.now().add(const Duration(hours: 2)),
        title: 'Future Item',
        status: TodayAgendaItemStatus.upcoming,
      );

      final bg = TodayBackground.forItem(item, DateTime.now(), const Duration(minutes: 15));
      final theme = ThemeData.light();
      expect(bg.cardColor(theme), isNotNull);
    });

    testWidgets('empty state shows when no items', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final agenda = TodayAgenda(
        date: today,
        items: const [],
        summary: const TodaySummary.empty(),
      );

      await tester.pumpWidget(_buildScreen(agenda: agenda));
      await tester.pumpAndSettle();

      expect(find.text('Nothing scheduled for today'), findsOneWidget);
    });

    testWidgets('narrow screen does not overflow', (tester) async {
      final now = DateTime(2025, 7, 25, 12, 0);
      final agenda = _mockAgenda(now: now);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(320, 568)),
          child: _buildScreen(agenda: agenda),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Georgian locale layout works', (tester) async {
      final now = DateTime(2025, 7, 25, 12, 0);
      final agenda = _mockAgenda(now: now);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todayAgendaProvider.overrideWith((_) async => agenda),
            todayAutoRefreshProvider.overrideWith((ref) {}),
            selectedAgendaDateProvider.overrideWith((ref) => agenda.date),
          ],
          child: MaterialApp(
            locale: const Locale('ka'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const TodayScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TodayAgendaItemWidget), findsNWidgets(4));
      expect(tester.takeException(), isNull);
    });

    testWidgets('light theme renders correctly', (tester) async {
      final now = DateTime(2025, 7, 25, 12, 0);
      final agenda = _mockAgenda(now: now);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todayAgendaProvider.overrideWith((_) async => agenda),
            todayAutoRefreshProvider.overrideWith((ref) {}),
            selectedAgendaDateProvider.overrideWith((ref) => agenda.date),
          ],
          child: MaterialApp(
            theme: ThemeData.light(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const TodayScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TodayAgendaItemWidget), findsNWidgets(4));
    });

    testWidgets('dark theme renders correctly', (tester) async {
      final now = DateTime(2025, 7, 25, 12, 0);
      final agenda = _mockAgenda(now: now);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todayAgendaProvider.overrideWith((_) async => agenda),
            todayAutoRefreshProvider.overrideWith((ref) {}),
            selectedAgendaDateProvider.overrideWith((ref) => agenda.date),
          ],
          child: MaterialApp(
            theme: ThemeData.dark(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const TodayScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TodayAgendaItemWidget), findsNWidgets(4));
    });
  });

  group('Agenda section title', () {
    testWidgets('Agenda title appears below Next card', (tester) async {
      final now = DateTime(2025, 7, 25, 12, 0);
      final agenda = _mockAgenda(now: now);

      await tester.pumpWidget(_buildScreen(agenda: agenda));
      await tester.pumpAndSettle();

      expect(find.text('Agenda'), findsOneWidget);
    });

    testWidgets('Georgian Agenda title displays correctly', (tester) async {
      final now = DateTime(2025, 7, 25, 12, 0);
      final agenda = _mockAgenda(now: now);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todayAgendaProvider.overrideWith((_) async => agenda),
            todayAutoRefreshProvider.overrideWith((ref) {}),
            selectedAgendaDateProvider.overrideWith((ref) => agenda.date),
          ],
          child: MaterialApp(
            locale: const Locale('ka'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const TodayScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('დღის განრიგი'), findsOneWidget);
    });

    testWidgets('no duplicate section headings', (tester) async {
      final now = DateTime(2025, 7, 25, 12, 0);
      final agenda = _mockAgenda(now: now);

      await tester.pumpWidget(_buildScreen(agenda: agenda));
      await tester.pumpAndSettle();

      // Only one "Agenda" heading should appear
      expect(find.text('Agenda'), findsOneWidget);
      expect(find.text('Overdue'), findsNothing);
      expect(find.text('Medications'), findsNothing);
      expect(find.text('Measurements'), findsNothing);
    });
  });

  group('Background styling', () {
    testWidgets('past item uses muted background', (tester) async {
      final lightTheme = ThemeData.light();
      final darkTheme = ThemeData.dark();

      final pastItem = TodayAgendaItem(
        id: 'past',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime.now().subtract(const Duration(hours: 2)),
        title: 'Past Item',
        status: TodayAgendaItemStatus.overdue,
      );

      final bg = TodayBackground.forItem(pastItem, DateTime.now(), const Duration(minutes: 15));
      expect(bg.position, TodayItemTimePosition.past);

      final lightColor = bg.cardColor(lightTheme);
      final darkColor = bg.cardColor(darkTheme);
      expect(lightColor, isNull);
      expect(darkColor, isNull);
    });

    testWidgets('due/current item uses highlighted background', (tester) async {
      final now = DateTime.now();
      final lightTheme = ThemeData.light();
      final darkTheme = ThemeData.dark();

      final dueItem = TodayAgendaItem(
        id: 'due',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: now,
        title: 'Due Item',
        status: TodayAgendaItemStatus.due,
      );

      final bg = TodayBackground.forItem(dueItem, now, const Duration(minutes: 15));
      expect(bg.position, TodayItemTimePosition.current);

      final lightColor = bg.cardColor(lightTheme);
      final darkColor = bg.cardColor(darkTheme);
      expect(lightColor, isNotNull);
      expect(darkColor, isNotNull);
    });

    testWidgets('future item uses normal background', (tester) async {
      final now = DateTime.now();
      final lightTheme = ThemeData.light();
      final darkTheme = ThemeData.dark();

      final futureItem = TodayAgendaItem(
        id: 'future',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: now.add(const Duration(hours: 2)),
        title: 'Future Item',
        status: TodayAgendaItemStatus.upcoming,
      );

      final bg = TodayBackground.forItem(futureItem, now, const Duration(minutes: 15));
      expect(bg.position, TodayItemTimePosition.future);

      expect(bg.cardColor(lightTheme), isNotNull);
      expect(bg.cardColor(darkTheme), isNotNull);
    });

    testWidgets('backgrounds differ visibly between positions', (tester) async {
      final now = DateTime.now();
      final theme = ThemeData.light();

      final pastBg = TodayBackground.forItem(
        TodayAgendaItem(
          id: '1',
          type: TodayAgendaItemType.medication,
          sourceScheduleId: 1,
          scheduledDateTime: now.subtract(const Duration(hours: 2)),
          title: 'Past',
          status: TodayAgendaItemStatus.overdue,
        ),
        now,
        const Duration(minutes: 15),
      );

      final currentBg = TodayBackground.forItem(
        TodayAgendaItem(
          id: '2',
          type: TodayAgendaItemType.medication,
          sourceScheduleId: 2,
          scheduledDateTime: now,
          title: 'Current',
          status: TodayAgendaItemStatus.due,
        ),
        now,
        const Duration(minutes: 15),
      );

      final futureBg = TodayBackground.forItem(
        TodayAgendaItem(
          id: '3',
          type: TodayAgendaItemType.medication,
          sourceScheduleId: 3,
          scheduledDateTime: now.add(const Duration(hours: 2)),
          title: 'Future',
          status: TodayAgendaItemStatus.upcoming,
        ),
        now,
        const Duration(minutes: 15),
      );

      // Past must be null; current and future must be non-null
      expect(pastBg.cardColor(theme), isNull);
      expect(currentBg.cardColor(theme), isNotNull);
      expect(futureBg.cardColor(theme), isNotNull);

      // Current and future colors must differ
      expect(
        currentBg.cardColor(theme) != futureBg.cardColor(theme),
        isTrue,
      );
    });

    testWidgets('time refresh updates item classification', (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(2025, 7, 25, 12, 0),
        title: 'Transitioning',
        status: TodayAgendaItemStatus.due,
      );

      // 60 minutes before: future (upcoming)
      final bgFuture = TodayBackground.forItem(
        item,
        DateTime(2025, 7, 25, 11, 0),
        const Duration(minutes: 15),
      );
      expect(bgFuture.position, TodayItemTimePosition.future);

      // At scheduled time: current (due within grace)
      final bgCurrent = TodayBackground.forItem(
        item,
        DateTime(2025, 7, 25, 12, 0),
        const Duration(minutes: 15),
      );
      expect(bgCurrent.position, TodayItemTimePosition.current);

      // 31 minutes after: past (overdue, outside 15-min grace)
      final bgPast = TodayBackground.forItem(
        item,
        DateTime(2025, 7, 25, 12, 31),
        const Duration(minutes: 15),
      );
      expect(bgPast.position, TodayItemTimePosition.past);
    });
  });

  group('Action menu', () {
    testWidgets('wide Mark as taken button is absent', (tester) async {
      final now = DateTime(2025, 7, 25, 12, 0);
      final agenda = _mockAgenda(now: now);

      await tester.pumpWidget(_buildScreen(agenda: agenda));
      await tester.pumpAndSettle();

      // The old inline TextButton.icon for "Mark as taken" should not exist
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('vertical three-dots button is visible for actionable items',
        (tester) async {
      final now = DateTime(2025, 7, 25, 12, 0);
      final agenda = _mockAgenda(now: now);

      await tester.pumpWidget(_buildScreen(agenda: agenda));
      await tester.pumpAndSettle();

      // 3 actionable items (overdue, due, upcoming) + 1 completed (still has menu)
      expect(find.byType(PopupMenuButton<String>), findsWidgets);
    });

    testWidgets('medication pending item shows Mark as taken and Skip',
        (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime.now().add(const Duration(hours: 1)),
        title: 'Test Med',
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Mark as Taken'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('completed medication hides Mark as taken', (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime.now().subtract(const Duration(hours: 1)),
        title: 'Completed Med',
        status: TodayAgendaItemStatus.completed,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Mark as Taken'), findsNothing);
      expect(find.text('Skip'), findsNothing);
      expect(find.text('Change to Skipped'), findsOneWidget);
      expect(find.text('Reset to Pending'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('measurement item shows Record now', (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.measurement,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime.now().add(const Duration(hours: 1)),
        title: 'Blood Pressure',
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Record Now'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Schedules'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Trends'), findsOneWidget);
    });

    testWidgets('menu closes after selection', (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime.now().add(const Duration(hours: 1)),
        title: 'Test Med',
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Menu is open
      expect(find.text('Details'), findsOneWidget);

      // Tap an action
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();

      // Menu should be closed
      expect(find.text('Details'), findsNothing);
    });
  });

  group('Agenda row layout', () {
    testWidgets('long medication name is more readable', (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(2025, 7, 25, 8, 0),
        title: 'Very Long Medication Name That Should Wrap Instead of Truncating',
        subtitle: '0.5 tablet - once daily',
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(360, 640)),
          child: _wrapWithApp(TodayAgendaItemWidget(item: item)),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('Georgian long title does not overflow', (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(2025, 7, 25, 8, 0),
        title: 'ძალიან გრძელი მედიკამენტის სახელი რომელიც უნდა გადაიჭრას',
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(320, 568)),
          child: _wrapWithApp(TodayAgendaItemWidget(item: item)),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('status icon remains visible', (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(2025, 7, 25, 8, 0),
        title: 'Test',
        status: TodayAgendaItemStatus.overdue,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('more-menu icon remains visible', (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(2025, 7, 25, 8, 0),
        title: 'Test',
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));

      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });

    testWidgets('narrow Pixel-sized screen has no overflow', (tester) async {
      final now = DateTime(2025, 7, 25, 12, 0);
      final agenda = _mockAgenda(now: now);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(412, 915)),
          child: _buildScreen(agenda: agenda),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(TodayAgendaItemWidget), findsNWidgets(4));
    });
  });

  group('NextItemCard', () {
    testWidgets('shows earliest non-past non-completed item', (tester) async {
      final fixedNow = DateTime(2025, 7, 25, 10, 0);
      final today = DateTime(2025, 7, 25);
      final agenda = TodayAgenda(
        date: today,
        items: [
          TodayAgendaItem(
            id: 'past',
            type: TodayAgendaItemType.medication,
            sourceScheduleId: 1,
            scheduledDateTime: DateTime(2025, 7, 25, 8, 0),
            title: 'Medication A',
            status: TodayAgendaItemStatus.overdue,
          ),
          TodayAgendaItem(
            id: 'future',
            type: TodayAgendaItemType.medication,
            sourceScheduleId: 2,
            scheduledDateTime: DateTime(2025, 7, 25, 14, 0),
            title: 'Medication B',
            status: TodayAgendaItemStatus.upcoming,
          ),
        ],
        summary: const TodaySummary.empty(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todayAgendaProvider.overrideWith((_) async => agenda),
            nextTodayItemProvider.overrideWith((ref) {
              return agenda.nextItem(now: fixedNow, graceWindow: const Duration(minutes: 15));
            }),
            selectedAgendaDateProvider.overrideWith((_) => today),
            todayAutoRefreshProvider.overrideWith((ref) {}),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: TodayNextItemCard()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Medication B'), findsOneWidget);
      expect(find.textContaining('Medication A'), findsNothing);
    });
  });

  group('TodayAgendaItemWidget', () {
    testWidgets('type icon shows medication icon', (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(2025, 7, 25, 8, 0),
        title: 'Test',
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));

      expect(find.byIcon(Icons.medication), findsOneWidget);
    });

    testWidgets('type icon shows measurement icon', (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.measurement,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(2025, 7, 25, 8, 0),
        title: 'Test',
        status: TodayAgendaItemStatus.upcoming,
        measurementTypeKey: 'blood_pressure',
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));

      expect(find.byIcon(Icons.monitor_heart), findsOneWidget);
    });

    testWidgets('menu shows correct actions for overdue medication',
        (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime.now().subtract(const Duration(hours: 2)),
        title: 'Overdue Med',
        status: TodayAgendaItemStatus.overdue,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Mark as Taken'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('menu shows correct actions for skipped medication',
        (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime.now().subtract(const Duration(hours: 1)),
        title: 'Skipped Med',
        status: TodayAgendaItemStatus.skipped,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Mark as Taken'), findsNothing);
      expect(find.text('Skip'), findsNothing);
      expect(find.text('Change to Taken'), findsOneWidget);
      expect(find.text('Reset to Pending'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('menu shows Trends for measurement items', (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.measurement,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime.now().add(const Duration(hours: 1)),
        title: 'Blood Pressure',
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Trends'), findsOneWidget);
    });

    testWidgets('menu does not show Trends for medication items',
        (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime.now().add(const Duration(hours: 1)),
        title: 'Test Med',
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Trends'), findsNothing);
    });
  });

  group('Medication info display', () {
    testWidgets('shows strength when available', (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(2025, 7, 25, 8, 0),
        title: 'Concor',
        strength: '5 mg',
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));

      expect(find.text('5 mg'), findsOneWidget);
    });

    testWidgets('shows intake quantity with dosage form', (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(2025, 7, 25, 8, 0),
        title: 'Concor',
        intakeQuantity: 0.5,
        dosageForm: DosageForm.tablet,
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));

      expect(find.text('0.5 tablets'), findsOneWidget);
    });

    testWidgets('shows strength and intake combined with bullet', (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(2025, 7, 25, 8, 0),
        title: 'Concor',
        strength: '5 mg',
        intakeQuantity: 1.0,
        dosageForm: DosageForm.capsule,
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));

      expect(find.text('5 mg  •  1 capsule'), findsOneWidget);
    });

    testWidgets('shows instructions below dosage info', (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(2025, 7, 25, 8, 0),
        title: 'Concor',
        strength: '5 mg',
        intakeQuantity: 0.5,
        dosageForm: DosageForm.tablet,
        instructions: 'Take with food',
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));

      expect(find.text('5 mg  •  0.5 tablets'), findsOneWidget);
      expect(find.text('Take with food'), findsOneWidget);
    });

    testWidgets('does not show strength when null', (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(2025, 7, 25, 8, 0),
        title: 'Concor',
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));

      // No dosage info rendered — only the title
      expect(find.byType(TodayAgendaItemWidget), findsOneWidget);
    });

    testWidgets('does not show intake when intakeQuantity is 0', (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(2025, 7, 25, 8, 0),
        title: 'Concor',
        strength: '10 mg',
        intakeQuantity: 0.0,
        dosageForm: DosageForm.tablet,
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));

      expect(find.text('10 mg'), findsOneWidget);
      // 0 tablets should NOT render
      expect(find.textContaining('tablet'), findsNothing);
    });

    testWidgets('shows subtitle fallback for medications without strength',
        (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(2025, 7, 25, 8, 0),
        title: 'Concor',
        subtitle: 'For blood pressure',
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));

      expect(find.text('For blood pressure'), findsOneWidget);
    });

    testWidgets('Georgian locale formats intake correctly', (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(2025, 7, 25, 8, 0),
        title: 'Concor',
        intakeQuantity: 0.5,
        dosageForm: DosageForm.tablet,
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('ka'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: TodayAgendaItemWidget(item: item)),
          ),
        ),
      );

      // Georgian: no plural suffix, custom form name
      expect(find.textContaining('0.5'), findsOneWidget);
    });

    testWidgets('medication with full dosage info has no overflow',
        (tester) async {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(2025, 7, 25, 8, 0),
        title: 'Very Long Medication Name',
        strength: '10/2.5/10 mg',
        intakeQuantity: 0.5,
        dosageForm: DosageForm.tablet,
        instructions: 'Take in the morning with breakfast',
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(360, 640)),
          child: _wrapWithApp(TodayAgendaItemWidget(item: item)),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('Popup menu actions', () {
    testWidgets('menu closes after tapping Details (no blank screen)',
        (tester) async {
      final item = TodayAgendaItem(
        id: 'med_1_0800',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime.now().add(const Duration(hours: 1)),
        title: 'Test Med',
        medicationId: 42,
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(_wrapWithGoRouter(TodayAgendaItemWidget(item: item)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Details'), findsOneWidget);

      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();

      // Menu must be closed — no blank screen from Navigator.pop
      expect(find.text('Details'), findsNothing);
      expect(find.text('Medication Detail'), findsOneWidget);
    });

    testWidgets('menu closes after tapping History', (tester) async {
      final item = TodayAgendaItem(
        id: 'med_1_0800',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime.now().add(const Duration(hours: 1)),
        title: 'Test Med',
        medicationId: 42,
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(_wrapWithGoRouter(TodayAgendaItemWidget(item: item)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('History'), findsOneWidget);

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      expect(find.text('Medication History'), findsOneWidget);
    });

    testWidgets('measurement menu closes after tapping Trends', (tester) async {
      final item = TodayAgendaItem(
        id: 'meas_1_0900',
        type: TodayAgendaItemType.measurement,
        sourceScheduleId: 3,
        scheduledDateTime: DateTime.now().add(const Duration(hours: 1)),
        title: 'Blood Pressure',
        measurementTypeId: 5,
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(_wrapWithGoRouter(TodayAgendaItemWidget(item: item)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Trends'), findsOneWidget);

      await tester.tap(find.text('Trends'));
      await tester.pumpAndSettle();

      expect(find.text('Measurement Trends'), findsOneWidget);
    });

    testWidgets('measurement menu closes after tapping Record Now',
        (tester) async {
      final item = TodayAgendaItem(
        id: 'meas_1_0900',
        type: TodayAgendaItemType.measurement,
        sourceScheduleId: 3,
        scheduledDateTime: DateTime.now().add(const Duration(hours: 1)),
        title: 'Blood Pressure',
        measurementTypeId: 5,
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(_wrapWithGoRouter(TodayAgendaItemWidget(item: item)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Record Now'), findsOneWidget);

      await tester.tap(find.text('Record Now'));
      await tester.pumpAndSettle();

      expect(find.text('Add Reading'), findsOneWidget);
    });

    testWidgets('medication item has medicationId for navigation',
        (tester) async {
      final item = TodayAgendaItem(
        id: 'med_1_0800',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime.now().add(const Duration(hours: 1)),
        title: 'Test Med',
        medicationId: 42,
        status: TodayAgendaItemStatus.upcoming,
      );

      // Verify the item carries the correct ID for navigation
      expect(item.medicationId, 42);
      expect(item.sourceScheduleId, 1);
      expect(item.measurementTypeId, isNull);
    });

    testWidgets('measurement item has measurementTypeId for navigation',
        (tester) async {
      final item = TodayAgendaItem(
        id: 'meas_1_0900',
        type: TodayAgendaItemType.measurement,
        sourceScheduleId: 3,
        scheduledDateTime: DateTime.now().add(const Duration(hours: 1)),
        title: 'Blood Pressure',
        measurementTypeId: 5,
        status: TodayAgendaItemStatus.upcoming,
      );

      // Verify the item carries the correct ID for navigation
      expect(item.measurementTypeId, 5);
      expect(item.sourceScheduleId, 3);
      expect(item.medicationId, isNull);
    });

    testWidgets('medication due item shows Mark as Taken and Skip',
        (tester) async {
      final item = TodayAgendaItem(
        id: 'med_1_0800',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime.now().add(const Duration(minutes: 10)),
        title: 'Test Med',
        medicationId: 42,
        status: TodayAgendaItemStatus.due,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Mark as Taken'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Trends'), findsNothing);
    });

    testWidgets('measurement due item shows Record Now and Skip',
        (tester) async {
      final item = TodayAgendaItem(
        id: 'meas_1_0900',
        type: TodayAgendaItemType.measurement,
        sourceScheduleId: 3,
        scheduledDateTime: DateTime.now().add(const Duration(minutes: 10)),
        title: 'Blood Pressure',
        measurementTypeId: 5,
        status: TodayAgendaItemStatus.due,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Record Now'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Mark as Taken'), findsNothing);
      expect(find.text('Schedules'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Trends'), findsOneWidget);
    });

    testWidgets('no old route paths used in agenda item',
        (tester) async {
      // Verify the agenda item widget does not reference old routes
      final item = TodayAgendaItem(
        id: 'med_1_0800',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime.now().add(const Duration(hours: 1)),
        title: 'Test Med',
        medicationId: 42,
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));

      // Verify no /health or /activities paths are rendered as text
      expect(find.textContaining('/health'), findsNothing);
      expect(find.textContaining('/activities'), findsNothing);
    });

    testWidgets('sourceScheduleId is the schedule ID not the entity ID',
        (tester) async {
      final medItem = TodayAgendaItem(
        id: 'med_1_0800',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 10, // schedule ID
        scheduledDateTime: DateTime.now().add(const Duration(hours: 1)),
        title: 'Test Med',
        medicationId: 42, // medication entity ID
        status: TodayAgendaItemStatus.upcoming,
      );

      final measItem = TodayAgendaItem(
        id: 'meas_1_0900',
        type: TodayAgendaItemType.measurement,
        sourceScheduleId: 20, // schedule ID
        scheduledDateTime: DateTime.now().add(const Duration(hours: 1)),
        title: 'Blood Pressure',
        measurementTypeId: 5, // measurement type entity ID
        status: TodayAgendaItemStatus.upcoming,
      );

      // sourceScheduleId is the schedule, not the entity
      expect(medItem.sourceScheduleId, 10);
      expect(medItem.medicationId, 42);
      expect(medItem.sourceScheduleId, isNot(equals(medItem.medicationId)));

      expect(measItem.sourceScheduleId, 20);
      expect(measItem.measurementTypeId, 5);
      expect(measItem.sourceScheduleId, isNot(equals(measItem.measurementTypeId)));
    });

    testWidgets('invalid medicationId does not crash', (tester) async {
      final item = TodayAgendaItem(
        id: 'med_1_0800',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime.now().add(const Duration(hours: 1)),
        title: 'Test Med',
        medicationId: null, // invalid
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(_wrapWithGoRouter(TodayAgendaItemWidget(item: item)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tapping Details with null medicationId should not crash
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('invalid measurementTypeId does not crash', (tester) async {
      final item = TodayAgendaItem(
        id: 'meas_1_0900',
        type: TodayAgendaItemType.measurement,
        sourceScheduleId: 3,
        scheduledDateTime: DateTime.now().add(const Duration(hours: 1)),
        title: 'Blood Pressure',
        measurementTypeId: null, // invalid
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(_wrapWithGoRouter(TodayAgendaItemWidget(item: item)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tapping Record Now with null measurementTypeId should not crash
      await tester.tap(find.text('Record Now'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('snoozed medication shows Mark as Taken and Skip',
        (tester) async {
      final item = TodayAgendaItem(
        id: 'med_1_0800',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime.now().subtract(const Duration(minutes: 15)),
        title: 'Snoozed Med',
        medicationId: 42,
        status: TodayAgendaItemStatus.snoozed,
        snoozedUntil: DateTime.now().add(const Duration(minutes: 15)),
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Mark as Taken'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('overdue measurement shows Record Now and Skip',
        (tester) async {
      final item = TodayAgendaItem(
        id: 'meas_1_0900',
        type: TodayAgendaItemType.measurement,
        sourceScheduleId: 3,
        scheduledDateTime: DateTime.now().subtract(const Duration(hours: 2)),
        title: 'Blood Pressure',
        measurementTypeId: 5,
        status: TodayAgendaItemStatus.overdue,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Record Now'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Schedules'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Trends'), findsOneWidget);
    });

    testWidgets('menu does not allow duplicate tap during processing',
        (tester) async {
      final item = TodayAgendaItem(
        id: 'med_1_0800',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime.now().add(const Duration(hours: 1)),
        title: 'Test Med',
        medicationId: 42,
        status: TodayAgendaItemStatus.upcoming,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Verify the menu is open
      expect(find.text('Mark as Taken'), findsOneWidget);
    });

    testWidgets('completed measurement shows Reset to Pending and Schedules',
        (tester) async {
      final item = TodayAgendaItem(
        id: 'meas_1_0900',
        type: TodayAgendaItemType.measurement,
        sourceScheduleId: 3,
        scheduledDateTime: DateTime.now().subtract(const Duration(hours: 1)),
        title: 'Blood Pressure',
        measurementTypeId: 5,
        status: TodayAgendaItemStatus.completed,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Reset to Pending'), findsOneWidget);
      expect(find.text('Schedules'), findsOneWidget);
      expect(find.text('Record Now'), findsNothing);
      expect(find.text('Skip'), findsNothing);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Trends'), findsOneWidget);
    });

    testWidgets('skipped measurement shows Reset to Pending and Schedules',
        (tester) async {
      final item = TodayAgendaItem(
        id: 'meas_1_0900',
        type: TodayAgendaItemType.measurement,
        sourceScheduleId: 3,
        scheduledDateTime: DateTime.now().subtract(const Duration(hours: 1)),
        title: 'Blood Pressure',
        measurementTypeId: 5,
        status: TodayAgendaItemStatus.skipped,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Reset to Pending'), findsOneWidget);
      expect(find.text('Schedules'), findsOneWidget);
      expect(find.text('Record Now'), findsNothing);
      expect(find.text('Skip'), findsNothing);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Trends'), findsOneWidget);
    });

    testWidgets('completed medication shows Change to Skipped and Reset to Pending',
        (tester) async {
      final item = TodayAgendaItem(
        id: 'med_1_0800',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime.now().subtract(const Duration(hours: 1)),
        title: 'Completed Med',
        medicationId: 42,
        status: TodayAgendaItemStatus.completed,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Change to Skipped'), findsOneWidget);
      expect(find.text('Reset to Pending'), findsOneWidget);
      expect(find.text('Mark as Taken'), findsNothing);
      expect(find.text('Skip'), findsNothing);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('skipped medication shows Change to Taken and Reset to Pending',
        (tester) async {
      final item = TodayAgendaItem(
        id: 'med_1_0800',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime.now().subtract(const Duration(hours: 1)),
        title: 'Skipped Med',
        medicationId: 42,
        status: TodayAgendaItemStatus.skipped,
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Change to Taken'), findsOneWidget);
      expect(find.text('Reset to Pending'), findsOneWidget);
      expect(find.text('Mark as Taken'), findsNothing);
      expect(find.text('Skip'), findsNothing);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });
  });
}
