import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';
import 'package:rehab_track/presentation/screens/today/today_screen.dart';
import 'package:rehab_track/presentation/widgets/today/date_navigation_bar.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class _FakeTodayClock implements TodayClock {
  _FakeTodayClock(this._now);

  DateTime _now;

  @override
  DateTime now() => _now;

  void advanceTo(DateTime time) => _now = time;
}

class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<String?> getValue(String key) async => null;

  @override
  Future<void> setValue(String key, String value) async {}

  @override
  Future<void> remove(String key) async {}

  @override
  Stream<Map<String, String>> watchAll() => const Stream.empty();

  @override
  Future<Map<String, String>> getAll() async => {};
}

TodayAgenda _agendaFor(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return TodayAgenda(
    date: day,
    items: [
      TodayAgendaItem(
        id: 'med_${day.day}',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(day.year, day.month, day.day, 8, 0),
        title: 'Med ${day.day}',
        status: TodayAgendaItemStatus.upcoming,
      ),
    ],
    summary: const TodaySummary(
      medicationTotal: 1,
      medicationCompleted: 0,
      medicationSkipped: 0,
      medicationOverdue: 0,
      measurementTotal: 0,
      measurementCompleted: 0,
      measurementSkipped: 0,
      measurementOverdue: 0,
    ),
  );
}

Widget _wrap({
  required TodayClock clock,
  required DateTime selectedDate,
}) {
  return ProviderScope(
    overrides: [
      todayClockProvider.overrideWithValue(clock),
      selectedAgendaDateProvider.overrideWith((ref) => selectedDate),
      dailyAgendaProvider.overrideWith((ref) async {
        final date = ref.watch(selectedAgendaDateProvider);
        return _agendaFor(date);
      }),
      nextItemGracePeriodProvider.overrideWith(
        (ref) => NextItemGracePeriodNotifier(_FakeSettingsRepository()),
      ),
      currentMinuteProvider.overrideWith((ref) => DateTime(2000, 1, 1)),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
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

ProviderContainer _containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(TodayScreen)));

void main() {
  tzdata.initializeTimeZones();

  group('midnight boundary while viewing Today', () {
    testWidgets(
        'advances the selected date, agenda, next item, and daily progress',
        (tester) async {
      final now = DateTime.now();
      final day1 = DateTime(now.year, now.month, now.day);
      final day2 = day1.add(const Duration(days: 1));
      final clock = _FakeTodayClock(
        DateTime(day1.year, day1.month, day1.day, 23, 59),
      );

      await tester.pumpWidget(_wrap(clock: clock, selectedDate: day1));
      await tester.pumpAndSettle();

      final container = _containerOf(tester);
      expect(container.read(selectedAgendaDateProvider), day1);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Med ${day1.day}'), findsWidgets);

      clock.advanceTo(DateTime(day2.year, day2.month, day2.day, 0, 0));
      await tester.pump(const Duration(minutes: 1));
      await tester.pumpAndSettle();

      expect(container.read(selectedAgendaDateProvider), day2);
      final agenda = container.read(dailyAgendaProvider).value;
      expect(agenda?.date, day2);
      expect(agenda?.items.single.title, 'Med ${day2.day}');
      expect(container.read(nextDailyItemProvider)?.id, 'med_${day2.day}');
      expect(container.read(dailySummaryProvider).medicationTotal, 1);
      expect(find.text('Med ${day2.day}'), findsWidgets);
      expect(find.text('Today'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('does not change a deliberately selected past date',
        (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final past = today.subtract(const Duration(days: 2));
      final clock = _FakeTodayClock(
        DateTime(today.year, today.month, today.day, 23, 59),
      );

      await tester.pumpWidget(_wrap(clock: clock, selectedDate: past));
      await tester.pumpAndSettle();

      final container = _containerOf(tester);
      expect(container.read(selectedAgendaDateProvider), past);

      clock.advanceTo(
        DateTime(today.year, today.month, today.day + 1, 0, 0),
      );
      await tester.pump(const Duration(minutes: 1));
      await tester.pumpAndSettle();

      expect(container.read(selectedAgendaDateProvider), past);
      expect(container.read(dailyAgendaProvider).value?.date, past);
    });

    testWidgets('does not change a deliberately selected future date',
        (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final future = today.add(const Duration(days: 3));
      final clock = _FakeTodayClock(
        DateTime(today.year, today.month, today.day, 23, 59),
      );

      await tester.pumpWidget(_wrap(clock: clock, selectedDate: future));
      await tester.pumpAndSettle();

      final container = _containerOf(tester);
      expect(container.read(selectedAgendaDateProvider), future);

      clock.advanceTo(
        DateTime(today.year, today.month, today.day + 1, 0, 0),
      );
      await tester.pump(const Duration(minutes: 1));
      await tester.pumpAndSettle();

      expect(container.read(selectedAgendaDateProvider), future);
      expect(container.read(dailyAgendaProvider).value?.date, future);
    });
  });

  group('app resume across midnight', () {
    testWidgets('updates Today to the new day when viewing Today',
        (tester) async {
      final now = DateTime.now();
      final day1 = DateTime(now.year, now.month, now.day);
      final day2 = day1.add(const Duration(days: 1));
      final clock = _FakeTodayClock(
        DateTime(day1.year, day1.month, day1.day, 23, 59),
      );

      await tester.pumpWidget(_wrap(clock: clock, selectedDate: day1));
      await tester.pumpAndSettle();

      final container = _containerOf(tester);
      expect(container.read(selectedAgendaDateProvider), day1);
      expect(find.text('Med ${day1.day}'), findsWidgets);

      clock.advanceTo(
        DateTime(day2.year, day2.month, day2.day, 0, 30),
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(container.read(selectedAgendaDateProvider), day2);
      expect(container.read(dailyAgendaProvider).value?.date, day2);
      expect(container.read(nextDailyItemProvider)?.id, 'med_${day2.day}');
      expect(find.text('Med ${day2.day}'), findsWidgets);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('preserves a selected past date', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final past = today.subtract(const Duration(days: 1));
      final clock = _FakeTodayClock(
        DateTime(today.year, today.month, today.day, 23, 59),
      );

      await tester.pumpWidget(_wrap(clock: clock, selectedDate: past));
      await tester.pumpAndSettle();

      final container = _containerOf(tester);
      expect(container.read(selectedAgendaDateProvider), past);

      clock.advanceTo(
        DateTime(today.year, today.month, today.day + 1, 0, 30),
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(container.read(selectedAgendaDateProvider), past);
      expect(container.read(dailyAgendaProvider).value?.date, past);
    });

    testWidgets('updates the date navigator label after returning to Today',
        (tester) async {
      final now = DateTime.now();
      final day1 = DateTime(now.year, now.month, now.day);
      final day2 = day1.add(const Duration(days: 1));
      final clock = _FakeTodayClock(
        DateTime(day1.year, day1.month, day1.day, 23, 59),
      );

      await tester.pumpWidget(_wrap(clock: clock, selectedDate: day1));
      await tester.pumpAndSettle();

      String navLabel(WidgetTester tester) {
        final texts = tester
            .widgetList<Text>(find.descendant(
              of: find.byType(DateNavigationBar),
              matching: find.byType(Text),
            ))
            .toList();
        return texts
            .map((t) => t.data ?? '')
            .reduce((a, b) => a.length >= b.length ? a : b);
      }

      final before = navLabel(tester);

      clock.advanceTo(
        DateTime(day2.year, day2.month, day2.day, 0, 30),
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pumpAndSettle();

      final after = navLabel(tester);
      expect(after, isNot(before));

      await tester.pumpWidget(const SizedBox());
    });
  });

  group('nextLocalMidnight', () {
    test('returns the next local midnight', () {
      expect(
        nextLocalMidnight(DateTime(2026, 8, 1, 23, 59)),
        DateTime(2026, 8, 2),
      );
      expect(
        nextLocalMidnight(DateTime(2026, 8, 2, 0, 5)),
        DateTime(2026, 8, 3),
      );
    });

    test('rolls over month and year boundaries', () {
      expect(
        nextLocalMidnight(DateTime(2026, 8, 31, 23, 59)),
        DateTime(2026, 9, 1),
      );
      expect(
        nextLocalMidnight(DateTime(2026, 12, 31, 23, 59)),
        DateTime(2027, 1, 1),
      );
    });

    test('boundary is one minute after 23:59 local', () {
      final now = DateTime(2026, 8, 1, 23, 59);
      expect(
        nextLocalMidnight(now).difference(now),
        const Duration(minutes: 1),
      );
    });

    test('is calculated in Asia/Tbilisi local time, not UTC', () {
      final tbilisi = tz.getLocation('Asia/Tbilisi');
      // Device local time 23:59 on Aug 1 (Tbilisi is UTC+04).
      final localNow = tz.TZDateTime(tbilisi, 2026, 8, 1, 23, 59);

      final boundary = nextLocalMidnight(localNow);

      // Next Tbilisi-local midnight is 2026-08-02 00:00.
      expect(boundary.year, 2026);
      expect(boundary.month, 8);
      expect(boundary.day, 2);
      expect(boundary.hour, 0);
      expect(boundary.minute, 0);
      expect(boundary.isUtc, isFalse);

      // 23:59 in +04 is 19:59 UTC, so a UTC-derived midnight would be
      // 00:00 UTC == 04:00 local. The boundary is 00:00 local, proving the
      // helper derives it from the device-local date parts, never from UTC
      // and never via a manual +04:00 offset.
      expect(boundary.hour, 0);
    });
  });
}
