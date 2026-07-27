import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';
import 'package:rehab_track/presentation/screens/today/today_screen.dart';
import 'package:rehab_track/presentation/widgets/today/date_navigation_bar.dart';
import 'package:rehab_track/presentation/widgets/today/today_agenda_item.dart';

Widget _wrapScreen({
  TodayAgenda? agenda,
  DateTime? selectedDate,
}) {
  final overrides = <Override>[];
  if (agenda != null) {
    overrides.add(dailyAgendaProvider.overrideWith((_) async => agenda));
  }
  if (selectedDate != null) {
    overrides.add(
      selectedAgendaDateProvider.overrideWith((ref) => selectedDate),
    );
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
      home: const TodayScreen(),
    ),
  );
}

TodayAgenda _todayAgenda({
  List<TodayAgendaItem>? items,
  DateTime? date,
}) {
  final now = DateTime.now();
  final d = date ?? DateTime(now.year, now.month, now.day);
  final agendaItems = items ?? [
    TodayAgendaItem(
      id: 'med_1_0800',
      type: TodayAgendaItemType.medication,
      sourceScheduleId: 1,
      scheduledDateTime: DateTime(d.year, d.month, d.day, 8, 0),
      title: 'Aspirin',
      status: TodayAgendaItemStatus.due,
    ),
  ];
  return TodayAgenda(
    date: d,
    items: agendaItems,
    summary: TodaySummary(
      medicationTotal: agendaItems.where((i) => i.type == TodayAgendaItemType.medication).length,
      medicationCompleted: 0,
      medicationSkipped: 0,
      medicationOverdue: 0,
      measurementTotal: agendaItems.where((i) => i.type == TodayAgendaItemType.measurement).length,
      measurementCompleted: 0,
      measurementSkipped: 0,
      measurementOverdue: 0,
    ),
  );
}

TodayAgenda _pastAgenda() {
  final past = DateTime.now().subtract(const Duration(days: 3));
  final d = DateTime(past.year, past.month, past.day);
  return TodayAgenda(
    date: d,
    items: [
      TodayAgendaItem(
        id: 'med_1_0800',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(d.year, d.month, d.day, 8, 0),
        title: 'Aspirin',
        status: TodayAgendaItemStatus.missed,
      ),
      TodayAgendaItem(
        id: 'meas_1_0900',
        type: TodayAgendaItemType.measurement,
        sourceScheduleId: 2,
        scheduledDateTime: DateTime(d.year, d.month, d.day, 9, 0),
        title: 'Blood Pressure',
        status: TodayAgendaItemStatus.completed,
      ),
    ],
    summary: const TodaySummary(
      medicationTotal: 1,
      medicationCompleted: 0,
      medicationSkipped: 0,
      medicationOverdue: 0,
      medicationMissed: 1,
      measurementTotal: 1,
      measurementCompleted: 1,
      measurementSkipped: 0,
      measurementOverdue: 0,
    ),
  );
}

TodayAgenda _futureAgenda() {
  final future = DateTime.now().add(const Duration(days: 5));
  final d = DateTime(future.year, future.month, future.day);
  return TodayAgenda(
    date: d,
    items: [
      TodayAgendaItem(
        id: 'med_1_0800',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(d.year, d.month, d.day, 8, 0),
        title: 'Aspirin',
        status: TodayAgendaItemStatus.upcoming,
      ),
      TodayAgendaItem(
        id: 'meas_1_1400',
        type: TodayAgendaItemType.measurement,
        sourceScheduleId: 2,
        scheduledDateTime: DateTime(d.year, d.month, d.day, 14, 0),
        title: 'Blood Pressure',
        status: TodayAgendaItemStatus.upcoming,
      ),
    ],
    summary: const TodaySummary(
      medicationTotal: 1,
      medicationCompleted: 0,
      medicationSkipped: 0,
      medicationOverdue: 0,
      measurementTotal: 1,
      measurementCompleted: 0,
      measurementSkipped: 0,
      measurementOverdue: 0,
    ),
  );
}

void main() {
  group('DateNavigationBar', () {
    testWidgets('shows formatted date when today', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedAgendaDateProvider.overrideWith((ref) => today),
            dailyAgendaProvider.overrideWith((_) async => _todayAgenda(date: today)),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: DateNavigationBar()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.today), findsNothing);
    });

    testWidgets('shows formatted date when not today', (tester) async {
      final past = DateTime.now().subtract(const Duration(days: 3));
      final d = DateTime(past.year, past.month, past.day);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedAgendaDateProvider.overrideWith((ref) => d),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: DateNavigationBar()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('left chevron navigates to previous day', (tester) async {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedAgendaDateProvider.overrideWith((ref) => todayDate),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: DateNavigationBar()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(DateNavigationBar)),
      );
      final newDate = container.read(selectedAgendaDateProvider);
      final expected = todayDate.subtract(const Duration(days: 1));
      expect(newDate, equals(expected));
    });

    testWidgets('right chevron navigates to next day', (tester) async {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedAgendaDateProvider.overrideWith((ref) => todayDate),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: DateNavigationBar()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(DateNavigationBar)),
      );
      final newDate = container.read(selectedAgendaDateProvider);
      final expected = todayDate.add(const Duration(days: 1));
      expect(newDate, equals(expected));
    });

    testWidgets('return to today icon appears on non-today', (tester) async {
      final past = DateTime.now().subtract(const Duration(days: 3));
      final d = DateTime(past.year, past.month, past.day);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedAgendaDateProvider.overrideWith((ref) => d),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: DateNavigationBar()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.today), findsOneWidget);
    });

    testWidgets('tapping return to today icon navigates back to today', (tester) async {
      final past = DateTime.now().subtract(const Duration(days: 3));
      final d = DateTime(past.year, past.month, past.day);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedAgendaDateProvider.overrideWith((ref) => d),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: DateNavigationBar()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.today));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(DateNavigationBar)),
      );
      final newDate = container.read(selectedAgendaDateProvider);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      expect(newDate, equals(today));
    });
  });

  group('TodayAgenda.isPast/isFuture/isToday', () {
    test('isToday returns true for today', () {
      final now = DateTime.now();
      final agenda = TodayAgenda(
        date: DateTime(now.year, now.month, now.day),
        items: const [],
        summary: const TodaySummary.empty(),
      );
      expect(agenda.isToday, isTrue);
      expect(agenda.isPast, isFalse);
      expect(agenda.isFuture, isFalse);
    });

    test('isPast returns true for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final agenda = TodayAgenda(
        date: DateTime(yesterday.year, yesterday.month, yesterday.day),
        items: const [],
        summary: const TodaySummary.empty(),
      );
      expect(agenda.isPast, isTrue);
      expect(agenda.isToday, isFalse);
      expect(agenda.isFuture, isFalse);
    });

    test('isFuture returns true for tomorrow', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final agenda = TodayAgenda(
        date: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
        items: const [],
        summary: const TodaySummary.empty(),
      );
      expect(agenda.isFuture, isTrue);
      expect(agenda.isToday, isFalse);
      expect(agenda.isPast, isFalse);
    });
  });

  group('Past date behavior', () {
    testWidgets('AppBar title shows Daily Plan for past date', (tester) async {
      final agenda = _pastAgenda();

      await tester.pumpWidget(_wrapScreen(agenda: agenda, selectedDate: agenda.date));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final title = appBar.title as Text;
      expect(title.data, contains('Daily Plan'));
    });

    testWidgets('shows History summary title for past date', (tester) async {
      final agenda = _pastAgenda();

      await tester.pumpWidget(_wrapScreen(agenda: agenda, selectedDate: agenda.date));
      await tester.pumpAndSettle();

      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('past date shows missed items', (tester) async {
      final agenda = _pastAgenda();

      await tester.pumpWidget(_wrapScreen(agenda: agenda, selectedDate: agenda.date));
      await tester.pumpAndSettle();

      expect(find.byType(TodayAgendaItemWidget), findsNWidgets(2));
      expect(find.text('Aspirin'), findsOneWidget);
      expect(find.text('Blood Pressure'), findsOneWidget);
    });

    testWidgets('past date shows missed count chip', (tester) async {
      final agenda = _pastAgenda();

      await tester.pumpWidget(_wrapScreen(agenda: agenda, selectedDate: agenda.date));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.event_busy), findsWidgets);
    });

    testWidgets('past date has no next item card', (tester) async {
      final agenda = _pastAgenda();

      await tester.pumpWidget(_wrapScreen(agenda: agenda, selectedDate: agenda.date));
      await tester.pumpAndSettle();

      expect(find.text('Next'), findsNothing);
    });
  });

  group('Future date behavior', () {
    testWidgets('AppBar title shows Daily Plan for future date', (tester) async {
      final agenda = _futureAgenda();

      await tester.pumpWidget(_wrapScreen(agenda: agenda, selectedDate: agenda.date));
      await tester.pumpAndSettle();

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final title = appBar.title as Text;
      expect(title.data, contains('Daily Plan'));
    });

    testWidgets('shows Todays Plan summary title for future date', (tester) async {
      final agenda = _futureAgenda();

      await tester.pumpWidget(_wrapScreen(agenda: agenda, selectedDate: agenda.date));
      await tester.pumpAndSettle();

      expect(find.text("Today's Plan"), findsOneWidget);
    });

    testWidgets('future date shows no next item card', (tester) async {
      final agenda = _futureAgenda();

      await tester.pumpWidget(_wrapScreen(agenda: agenda, selectedDate: agenda.date));
      await tester.pumpAndSettle();

      expect(find.text('Next'), findsNothing);
    });

    testWidgets('future date has no progress bar', (tester) async {
      final agenda = _futureAgenda();

      await tester.pumpWidget(_wrapScreen(agenda: agenda, selectedDate: agenda.date));
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('future date shows total count only', (tester) async {
      final agenda = _futureAgenda();

      await tester.pumpWidget(_wrapScreen(agenda: agenda, selectedDate: agenda.date));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsWidgets);
    });
  });

  group('Today date behavior', () {
    testWidgets('AppBar title shows Today for today', (tester) async {
      final agenda = _todayAgenda();

      await tester.pumpWidget(_wrapScreen(agenda: agenda));
      await tester.pumpAndSettle();

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final title = appBar.title as Text;
      expect(title.data, 'Today');
    });

    testWidgets('shows Todays Progress for today', (tester) async {
      final agenda = _todayAgenda();

      await tester.pumpWidget(_wrapScreen(agenda: agenda));
      await tester.pumpAndSettle();

      expect(find.text("Today's Progress"), findsOneWidget);
    });

    testWidgets('today shows next item card', (tester) async {
      final agenda = _todayAgenda();

      await tester.pumpWidget(_wrapScreen(agenda: agenda));
      await tester.pumpAndSettle();

      expect(find.text('Next'), findsOneWidget);
    });
  });

  group('Missed status', () {
    test('missed status is actionable', () {
      final item = TodayAgendaItem(
        id: 'med_1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime.now().subtract(const Duration(hours: 3)),
        title: 'Aspirin',
        status: TodayAgendaItemStatus.missed,
      );
      expect(item.isActionable, isTrue);
      expect(item.isCompleted, isFalse);
    });

    test('missed count is computed in summary', () {
      const summary = TodaySummary(
        medicationTotal: 3,
        medicationCompleted: 1,
        medicationSkipped: 0,
        medicationOverdue: 0,
        medicationMissed: 2,
        measurementTotal: 2,
        measurementCompleted: 1,
        measurementSkipped: 0,
        measurementOverdue: 0,
        measurementMissed: 1,
      );
      expect(summary.missed, 3);
      expect(summary.handled, 2);
    });
  });

  group('Empty state', () {
    testWidgets('shows correct empty message for past date', (tester) async {
      final past = DateTime.now().subtract(const Duration(days: 3));
      final d = DateTime(past.year, past.month, past.day);
      final emptyPast = TodayAgenda(
        date: d,
        items: const [],
        summary: const TodaySummary.empty(),
      );

      await tester.pumpWidget(_wrapScreen(agenda: emptyPast, selectedDate: d));
      await tester.pumpAndSettle();

      expect(find.text('Nothing scheduled for this day'), findsOneWidget);
    });

    testWidgets('shows correct empty message for today', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final emptyToday = TodayAgenda(
        date: today,
        items: const [],
        summary: const TodaySummary.empty(),
      );

      await tester.pumpWidget(_wrapScreen(agenda: emptyToday));
      await tester.pumpAndSettle();

      expect(find.text('Nothing scheduled for today'), findsOneWidget);
    });
  });
}
