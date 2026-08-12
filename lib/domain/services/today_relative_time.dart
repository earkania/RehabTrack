import 'package:rehab_track/domain/entities/today_agenda.dart';

/// Whether an occurrence should show a relative time label and, if so,
/// which kind of label.
enum TodayRelativeTimeState {
  /// No label: the occurrence is not on the current local date, is in a
  /// terminal state, or is still inside the grace period.
  none,

  /// Scheduled in the future: show a countdown like "In 2h 15m".
  upcoming,

  /// Past the grace period and still unresolved: show "16m overdue".
  overdue,
}

/// The result of [computeTodayRelativeTime].
class TodayRelativeTime {
  final TodayRelativeTimeState state;

  /// For [TodayRelativeTimeState.upcoming]: the remaining time rounded up to
  /// whole minutes. For [TodayRelativeTimeState.overdue]: the elapsed time
  /// rounded down to whole minutes. For [TodayRelativeTimeState.none] this is
  /// [Duration.zero].
  final Duration amount;

  const TodayRelativeTime._(this.state, this.amount);

  const TodayRelativeTime.none()
      : this._(TodayRelativeTimeState.none, Duration.zero);

  const TodayRelativeTime.upcoming(Duration amount)
      : this._(TodayRelativeTimeState.upcoming, amount);

  const TodayRelativeTime.overdue(Duration amount)
      : this._(TodayRelativeTimeState.overdue, amount);
}

/// Computes the relative-time label for an occurrence.
///
/// Rules:
/// - Only occurrences whose scheduled **local** calendar date matches the
///   current local calendar date get a label (never a manual offset, never a
///   UTC comparison).
/// - Terminal states ([TodayAgendaItemStatus.completed], `.skipped`,
///   `.missed`, `.snoozed`) never get a label.
/// - While `now` is between [scheduledAt] and `scheduledAt + gracePeriod` no
///   label is shown.
/// - Future occurrences round the remaining time **up** to the next whole
///   minute (4m10s -> 5m; never "In 0m" while still future).
/// - Overdue occurrences measure elapsed time from [scheduledAt] (never from
///   the grace boundary) and round **down** to completed whole minutes,
///   clamped to at least 1 minute.
TodayRelativeTime computeTodayRelativeTime({
  required DateTime scheduledAt,
  required DateTime now,
  required Duration gracePeriod,
  required TodayAgendaItemStatus status,
}) {
  switch (status) {
    case TodayAgendaItemStatus.completed:
    case TodayAgendaItemStatus.skipped:
    case TodayAgendaItemStatus.missed:
    case TodayAgendaItemStatus.snoozed:
      return const TodayRelativeTime.none();
    case TodayAgendaItemStatus.upcoming:
    case TodayAgendaItemStatus.due:
    case TodayAgendaItemStatus.overdue:
      break;
  }

  if (scheduledAt.year != now.year ||
      scheduledAt.month != now.month ||
      scheduledAt.day != now.day) {
    return const TodayRelativeTime.none();
  }

  final diff = scheduledAt.difference(now);

  if (!diff.isNegative) {
    final seconds = diff.inSeconds;
    final minutes = (seconds + 59) ~/ 60;
    if (minutes < 1) return const TodayRelativeTime.none();
    return TodayRelativeTime.upcoming(Duration(minutes: minutes));
  }

  final graceEnd = scheduledAt.add(gracePeriod);
  if (now.isBefore(graceEnd)) return const TodayRelativeTime.none();

  final elapsed = now.difference(scheduledAt);
  final minutes = elapsed.inMinutes < 1 ? 1 : elapsed.inMinutes;
  return TodayRelativeTime.overdue(Duration(minutes: minutes));
}
