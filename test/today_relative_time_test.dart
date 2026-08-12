import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';
import 'package:rehab_track/domain/services/today_relative_time.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/utils/today_relative_time_format.dart';

void main() {
  group('computeTodayRelativeTime', () {
    final scheduled = DateTime(2025, 7, 25, 10, 0);
    const grace = Duration(minutes: 15);

    TodayRelativeTime compute({
      DateTime? at,
      TodayAgendaItemStatus status = TodayAgendaItemStatus.upcoming,
    }) =>
        computeTodayRelativeTime(
          scheduledAt: scheduled,
          now: at ?? scheduled,
          gracePeriod: grace,
          status: status,
        );

    group('future occurrences', () {
      test('rounds remaining time up to the next whole minute', () {
        final rel = compute(at: scheduled.subtract(const Duration(minutes: 4, seconds: 10)));
        expect(rel.state, TodayRelativeTimeState.upcoming);
        expect(rel.amount, const Duration(minutes: 5));
      });

      test('never shows 0 minutes while still future', () {
        final rel = compute(at: scheduled.subtract(const Duration(seconds: 30)));
        expect(rel.state, TodayRelativeTimeState.upcoming);
        expect(rel.amount, const Duration(minutes: 1));
      });

      test('exact whole minutes are preserved', () {
        final rel = compute(at: scheduled.subtract(const Duration(hours: 2, minutes: 15)));
        expect(rel.state, TodayRelativeTimeState.upcoming);
        expect(rel.amount, const Duration(minutes: 135));
      });
    });

    group('grace period', () {
      test('exactly at the scheduled time shows nothing', () {
        final rel = compute();
        expect(rel.state, TodayRelativeTimeState.none);
      });

      test('inside the grace period shows nothing', () {
        final rel = compute(at: scheduled.add(const Duration(minutes: 10)));
        expect(rel.state, TodayRelativeTimeState.none);
      });

      test('at the grace boundary shows overdue', () {
        final rel = compute(at: scheduled.add(const Duration(minutes: 15)));
        expect(rel.state, TodayRelativeTimeState.overdue);
      });
    });

    group('overdue occurrences', () {
      test('measures elapsed time from the scheduled time, not the grace end',
          () {
        final rel = compute(
          at: scheduled.add(const Duration(minutes: 16)),
          status: TodayAgendaItemStatus.overdue,
        );
        expect(rel.state, TodayRelativeTimeState.overdue);
        expect(rel.amount, const Duration(minutes: 16));
      });

      test('rounds elapsed time down to whole minutes', () {
        final rel = compute(at: scheduled.add(const Duration(minutes: 16, seconds: 40)));
        expect(rel.amount, const Duration(minutes: 16));
      });

      test('clamps to at least one minute', () {
        final rel = computeTodayRelativeTime(
          scheduledAt: scheduled,
          now: scheduled.add(const Duration(seconds: 30)),
          gracePeriod: Duration.zero,
          status: TodayAgendaItemStatus.overdue,
        );
        expect(rel.state, TodayRelativeTimeState.overdue);
        expect(rel.amount, const Duration(minutes: 1));
      });
    });

    group('today-only gate', () {
      test('shows nothing when scheduled on a previous day', () {
        final yesterday = scheduled.subtract(const Duration(days: 1));
        final rel = computeTodayRelativeTime(
          scheduledAt: yesterday,
          now: scheduled.add(const Duration(minutes: 16)),
          gracePeriod: grace,
          status: TodayAgendaItemStatus.overdue,
        );
        expect(rel.state, TodayRelativeTimeState.none);
      });

      test('shows nothing when scheduled on a future day', () {
        final tomorrow = scheduled.add(const Duration(days: 1));
        final rel = computeTodayRelativeTime(
          scheduledAt: tomorrow,
          now: scheduled,
          gracePeriod: grace,
          status: TodayAgendaItemStatus.upcoming,
        );
        expect(rel.state, TodayRelativeTimeState.none);
      });

      test('compares local calendar components, not elapsed time', () {
        final rel = compute(
          at: scheduled.subtract(const Duration(hours: 30)),
        );
        expect(rel.state, TodayRelativeTimeState.none);
      });
    });

    group('terminal states', () {
      for (final status in [
        TodayAgendaItemStatus.completed,
        TodayAgendaItemStatus.skipped,
        TodayAgendaItemStatus.missed,
        TodayAgendaItemStatus.snoozed,
      ]) {
        test('$status never gets a label', () {
          final rel = compute(
            at: scheduled.subtract(const Duration(hours: 3)),
            status: status,
          );
          expect(rel.state, TodayRelativeTimeState.none);
        });
      }
    });

    test('due and overdue statuses still participate', () {
      for (final status in [
        TodayAgendaItemStatus.upcoming,
        TodayAgendaItemStatus.due,
        TodayAgendaItemStatus.overdue,
      ]) {
        final rel = compute(
          at: scheduled.subtract(const Duration(hours: 1)),
          status: status,
        );
        expect(rel.state, TodayRelativeTimeState.upcoming);
      }
    });
  });

  group('formatTodayRelativeTime / semanticTodayRelativeTime', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final ka = lookupAppLocalizations(const Locale('ka'));

    test('none formats to null', () {
      expect(formatTodayRelativeTime(const TodayRelativeTime.none(), en), isNull);
      expect(semanticTodayRelativeTime(const TodayRelativeTime.none(), en), isNull);
    });

    test('English upcoming: hours and minutes', () {
      final rel = TodayRelativeTime.upcoming(const Duration(minutes: 135));
      expect(formatTodayRelativeTime(rel, en), 'In 2h 15m');
      expect(semanticTodayRelativeTime(rel, en), 'in 2 hours 15 minutes');
    });

    test('English upcoming: whole hours', () {
      final rel = TodayRelativeTime.upcoming(const Duration(minutes: 120));
      expect(formatTodayRelativeTime(rel, en), 'In 2h');
      expect(semanticTodayRelativeTime(rel, en), 'in 2 hours');
    });

    test('English upcoming: minutes only', () {
      final rel = TodayRelativeTime.upcoming(const Duration(minutes: 45));
      expect(formatTodayRelativeTime(rel, en), 'In 45m');
      expect(semanticTodayRelativeTime(rel, en), 'in 45 minutes');
    });

    test('English upcoming: single units', () {
      expect(
        formatTodayRelativeTime(TodayRelativeTime.upcoming(const Duration(minutes: 60)), en),
        'In 1h',
      );
      expect(
        formatTodayRelativeTime(TodayRelativeTime.upcoming(const Duration(minutes: 1)), en),
        'In 1m',
      );
    });

    test('English overdue: hours and minutes', () {
      final rel = TodayRelativeTime.overdue(const Duration(minutes: 80));
      expect(formatTodayRelativeTime(rel, en), '1h 20m overdue');
      expect(
        semanticTodayRelativeTime(rel, en),
        '1 hours 20 minutes overdue',
      );
    });

    test('English overdue: whole hours', () {
      final rel = TodayRelativeTime.overdue(const Duration(minutes: 180));
      expect(formatTodayRelativeTime(rel, en), '3h overdue');
      expect(semanticTodayRelativeTime(rel, en), '3 hours overdue');
    });

    test('English overdue: minutes only', () {
      final rel = TodayRelativeTime.overdue(const Duration(minutes: 16));
      expect(formatTodayRelativeTime(rel, en), '16m overdue');
      expect(semanticTodayRelativeTime(rel, en), '16 minutes overdue');
    });

    test('Georgian upcoming', () {
      expect(
        formatTodayRelativeTime(TodayRelativeTime.upcoming(const Duration(minutes: 135)), ka),
        '2სთ 15წთ-ში',
      );
      expect(
        formatTodayRelativeTime(TodayRelativeTime.upcoming(const Duration(minutes: 120)), ka),
        '2სთ-ში',
      );
      expect(
        formatTodayRelativeTime(TodayRelativeTime.upcoming(const Duration(minutes: 45)), ka),
        '45წთ-ში',
      );
    });

    test('Georgian overdue', () {
      expect(
        formatTodayRelativeTime(TodayRelativeTime.overdue(const Duration(minutes: 37)), ka),
        '37წთ გადაცილება',
      );
      expect(
        formatTodayRelativeTime(TodayRelativeTime.overdue(const Duration(minutes: 60)), ka),
        '1სთ გადაცილება',
      );
      expect(
        formatTodayRelativeTime(TodayRelativeTime.overdue(const Duration(minutes: 80)), ka),
        '1სთ 20წთ გადაცილება',
      );
      expect(
        formatTodayRelativeTime(TodayRelativeTime.overdue(const Duration(minutes: 180)), ka),
        '3სთ გადაცილება',
      );
      expect(
        formatTodayRelativeTime(TodayRelativeTime.overdue(const Duration(minutes: 16)), ka),
        '16წთ გადაცილება',
      );
    });

    test('Georgian semantic upcoming', () {
      expect(
        semanticTodayRelativeTime(TodayRelativeTime.upcoming(const Duration(minutes: 135)), ka),
        '2 საათსა და 15 წუთში',
      );
      expect(
        semanticTodayRelativeTime(TodayRelativeTime.upcoming(const Duration(minutes: 120)), ka),
        '2 საათში',
      );
      expect(
        semanticTodayRelativeTime(TodayRelativeTime.upcoming(const Duration(minutes: 45)), ka),
        '45 წუთში',
      );
    });

    test('Georgian semantic overdue', () {
      expect(
        semanticTodayRelativeTime(TodayRelativeTime.overdue(const Duration(minutes: 80)), ka),
        '1 საათი და 20 წუთია ვადაგადაცილებული',
      );
      expect(
        semanticTodayRelativeTime(TodayRelativeTime.overdue(const Duration(minutes: 180)), ka),
        '3 საათია ვადაგადაცილებული',
      );
      expect(
        semanticTodayRelativeTime(TodayRelativeTime.overdue(const Duration(minutes: 16)), ka),
        '16 წუთია ვადაგადაცილებული',
      );
    });

    test('does not depend on intl locale for plain formatting', () {
      final prior = Intl.getCurrentLocale();
      Intl.defaultLocale = 'ka';
      try {
        final rel = TodayRelativeTime.upcoming(const Duration(minutes: 135));
        expect(formatTodayRelativeTime(rel, en), 'In 2h 15m');
      } finally {
        Intl.defaultLocale = prior;
      }
    });
  });
}
