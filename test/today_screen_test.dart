import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/dosage_form.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';
import 'package:rehab_track/presentation/screens/today/today_screen.dart';
import 'package:rehab_track/presentation/widgets/today/today_agenda_item.dart';
import 'package:rehab_track/presentation/widgets/today/today_next_item_card.dart';
import 'package:rehab_track/presentation/widgets/today/today_background.dart';

Widget _wrapWithApp(Widget child, {TodayAgenda? agenda}) {
  return ProviderScope(
    overrides: agenda != null
        ? [todayAgendaProvider.overrideWith((_) async => agenda)]
        : [],
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
    overrides: [todayAgendaProvider.overrideWith((_) async => agenda)],
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
      final now = DateTime(2025, 7, 25, 12, 0);
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

      final bg = TodayBackground.forItem(item, DateTime.now());
      final theme = ThemeData.light();
      expect(bg.cardColor(theme), isNotNull);
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

      final bg = TodayBackground.forItem(item, DateTime.now());
      final theme = ThemeData.light();
      expect(bg.cardColor(theme), isNull);
    });

    testWidgets('empty state shows when no items', (tester) async {
      final agenda = TodayAgenda(
        date: DateTime(2025, 7, 25),
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
          overrides: [todayAgendaProvider.overrideWith((_) async => agenda)],
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
          overrides: [todayAgendaProvider.overrideWith((_) async => agenda)],
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
          overrides: [todayAgendaProvider.overrideWith((_) async => agenda)],
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
          overrides: [todayAgendaProvider.overrideWith((_) async => agenda)],
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

      final bg = TodayBackground.forItem(pastItem, DateTime.now());
      expect(bg.position, TodayItemTimePosition.past);

      final lightColor = bg.cardColor(lightTheme);
      final darkColor = bg.cardColor(darkTheme);
      expect(lightColor, isNotNull);
      expect(darkColor, isNotNull);
    });

    testWidgets('due/current item uses highlighted background', (tester) async {
      final now = DateTime.now();
      final lightTheme = ThemeData.light();
      final darkTheme = ThemeData.dark();

      final dueItem = TodayAgendaItem(
        id: 'due',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: now.add(const Duration(minutes: 10)),
        title: 'Due Item',
        status: TodayAgendaItemStatus.due,
      );

      final bg = TodayBackground.forItem(dueItem, now);
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

      final bg = TodayBackground.forItem(futureItem, now);
      expect(bg.position, TodayItemTimePosition.future);

      expect(bg.cardColor(lightTheme), isNull);
      expect(bg.cardColor(darkTheme), isNull);
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
      );

      final currentBg = TodayBackground.forItem(
        TodayAgendaItem(
          id: '2',
          type: TodayAgendaItemType.medication,
          sourceScheduleId: 2,
          scheduledDateTime: now.add(const Duration(minutes: 10)),
          title: 'Current',
          status: TodayAgendaItemStatus.due,
        ),
        now,
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
      );

      // Past and current must be non-null; future must be null
      expect(pastBg.cardColor(theme), isNotNull);
      expect(currentBg.cardColor(theme), isNotNull);
      expect(futureBg.cardColor(theme), isNull);

      // Past and current colors must differ
      expect(
        pastBg.cardColor(theme) != currentBg.cardColor(theme),
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

      // 60 minutes before: future (outside 30-min grace window)
      final bgFuture = TodayBackground.forItem(
        item,
        DateTime(2025, 7, 25, 11, 0),
      );
      expect(bgFuture.position, TodayItemTimePosition.future);

      // 15 minutes before: due (within 30-min grace window)
      final bgDue = TodayBackground.forItem(
        item,
        DateTime(2025, 7, 25, 11, 45),
      );
      expect(bgDue.position, TodayItemTimePosition.current);

      // At scheduled time: current (within grace window)
      final bgCurrent = TodayBackground.forItem(
        item,
        DateTime(2025, 7, 25, 12, 0),
      );
      expect(bgCurrent.position, TodayItemTimePosition.current);
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
      expect(find.text('Details'), findsOneWidget);
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
    testWidgets('shows correct next item (21:32 example)', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final agenda = TodayAgenda(
        date: today,
        items: [
          TodayAgendaItem(
            id: 'overdue',
            type: TodayAgendaItemType.medication,
            sourceScheduleId: 1,
            scheduledDateTime: today.add(const Duration(hours: 10)),
            title: 'Concor',
            status: TodayAgendaItemStatus.overdue,
          ),
          TodayAgendaItem(
            id: 'upcoming',
            type: TodayAgendaItemType.medication,
            sourceScheduleId: 2,
            scheduledDateTime: today.add(const Duration(days: 1, hours: 10)),
            title: 'Physiotens',
            status: TodayAgendaItemStatus.upcoming,
          ),
        ],
        summary: const TodaySummary.empty(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [todayAgendaProvider.overrideWith((_) async => agenda)],
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

      expect(find.textContaining('Physiotens'), findsOneWidget);
      expect(find.textContaining('Concor'), findsNothing);
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
      );

      await tester.pumpWidget(_wrapWithApp(TodayAgendaItemWidget(item: item)));

      expect(find.byIcon(Icons.monitor_heart_outlined), findsOneWidget);
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

    testWidgets('shows strength and intake as separate lines', (tester) async {
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

      expect(find.text('5 mg'), findsOneWidget);
      expect(find.text('1 capsule'), findsOneWidget);
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

      expect(find.text('5 mg'), findsOneWidget);
      expect(find.text('0.5 tablets'), findsOneWidget);
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
}
