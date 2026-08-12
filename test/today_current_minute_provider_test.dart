import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';
import 'package:rehab_track/presentation/widgets/today/today_relative_time_label.dart';

class _MutableClock implements TodayClock {
  DateTime _now;

  _MutableClock(this._now);

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

Widget _wrap({required _MutableClock clock, DateTime? scheduledAt}) {
  return ProviderScope(
    overrides: [
      todayClockProvider.overrideWithValue(clock),
      nextItemGracePeriodProvider.overrideWith(
        (ref) => NextItemGracePeriodNotifier(_FakeSettingsRepository()),
      ),
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
      home: Scaffold(
        body: TodayRelativeTimeLabel(
          item: TodayAgendaItem(
            id: 'id1',
            type: TodayAgendaItemType.medication,
            sourceScheduleId: 1,
            scheduledDateTime: scheduledAt ?? DateTime(2025, 7, 25, 10, 30),
            title: 'Concor',
            status: TodayAgendaItemStatus.upcoming,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('currentMinuteProvider', () {
    testWidgets('starts truncated to the current clock minute', (tester) async {
      final clock = _MutableClock(DateTime(2025, 7, 25, 10, 23, 42));
      await tester.pumpWidget(_wrap(clock: clock));
      await tester.pump();

      final now = ProviderScope.containerOf(
        tester.element(find.byType(TodayRelativeTimeLabel)),
      ).read(currentMinuteProvider);
      expect(now, DateTime(2025, 7, 25, 10, 23));
    });

    testWidgets('ticks to the next minute at the aligned boundary',
        (tester) async {
      final clock = _MutableClock(DateTime(2025, 7, 25, 10, 23, 42));
      await tester.pumpWidget(_wrap(clock: clock));
      await tester.pump();
      expect(find.text('In 7m'), findsOneWidget);

      clock.advanceTo(DateTime(2025, 7, 25, 10, 24));
      await tester.pump(const Duration(seconds: 18));

      expect(find.text('In 6m'), findsOneWidget);
    });

    testWidgets('keeps ticking across many minutes', (tester) async {
      final clock = _MutableClock(DateTime(2025, 7, 25, 10, 23, 42));
      await tester.pumpWidget(_wrap(clock: clock));
      await tester.pump();
      expect(find.text('In 7m'), findsOneWidget);

      for (var i = 1; i <= 3; i++) {
        clock.advanceTo(DateTime(2025, 7, 25, 10, 23 + i));
        await tester.pump(const Duration(minutes: 1));
      }
      expect(find.text('In 4m'), findsOneWidget);
    });

    testWidgets('ticking is aligned to clock minutes, not construction time',
        (tester) async {
      // Construction at 10:23:05 -> the current minute is 10:23:00 and the
      // first tick is still 55s later, at 10:24:00.
      final clock = _MutableClock(DateTime(2025, 7, 25, 10, 23, 5));
      await tester.pumpWidget(_wrap(clock: clock));
      await tester.pump();
      expect(
        ProviderScope.containerOf(
          tester.element(find.byType(TodayRelativeTimeLabel)),
        ).read(currentMinuteProvider),
        DateTime(2025, 7, 25, 10, 23),
      );

      // Advancing only 30s (before the aligned boundary) must not tick.
      clock.advanceTo(DateTime(2025, 7, 25, 10, 23, 35));
      await tester.pump(const Duration(seconds: 30));
      expect(
        ProviderScope.containerOf(
          tester.element(find.byType(TodayRelativeTimeLabel)),
        ).read(currentMinuteProvider),
        DateTime(2025, 7, 25, 10, 23),
      );

      clock.advanceTo(DateTime(2025, 7, 25, 10, 24));
      await tester.pump(const Duration(seconds: 25));
      expect(
        ProviderScope.containerOf(
          tester.element(find.byType(TodayRelativeTimeLabel)),
        ).read(currentMinuteProvider),
        DateTime(2025, 7, 25, 10, 24),
      );
    });

    testWidgets('cancels the timer when the last listener disappears',
        (tester) async {
      final clock = _MutableClock(DateTime(2025, 7, 25, 10, 23, 42));
      await tester.pumpWidget(_wrap(clock: clock));
      await tester.pump();

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(hours: 1));

      expect(tester.takeException(), isNull);
    });
  });

  group('currentMinuteProvider across a grace-period boundary', () {
    testWidgets('label turns from none to overdue once grace elapses',
        (tester) async {
      final clock = _MutableClock(DateTime(2025, 7, 25, 10, 0));

      await tester.pumpWidget(
        _wrap(clock: clock, scheduledAt: DateTime(2025, 7, 25, 10, 0)),
      );
      await tester.pump();
      expect(find.text('16m overdue'), findsNothing);

      // 10:00 + 15m grace -> still inside grace.
      clock.advanceTo(DateTime(2025, 7, 25, 10, 15));
      await tester.pump(const Duration(minutes: 15));
      expect(find.text('16m overdue'), findsNothing);

      // Past grace -> overdue.
      clock.advanceTo(DateTime(2025, 7, 25, 10, 16));
      await tester.pump(const Duration(minutes: 1));
      expect(find.text('16m overdue'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });
  });
}