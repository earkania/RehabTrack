import 'package:rehab_track/domain/services/today_relative_time.dart';
import 'package:rehab_track/l10n/app_localizations.dart';

/// Returns the short visible text for [rel] (e.g. "In 2h 15m", "16m overdue")
/// or `null` when no label should be shown.
String? formatTodayRelativeTime(TodayRelativeTime rel, AppLocalizations l10n) {
  switch (rel.state) {
    case TodayRelativeTimeState.none:
      return null;
    case TodayRelativeTimeState.upcoming:
      final minutes = rel.amount.inMinutes;
      if (minutes >= 60) {
        final hours = minutes ~/ 60;
        final rem = minutes % 60;
        if (rem == 0) return l10n.inHours(hours);
        return l10n.inHoursMinutes(hours, rem);
      }
      return l10n.inMinutes(minutes);
    case TodayRelativeTimeState.overdue:
      final minutes = rel.amount.inMinutes;
      if (minutes >= 60) {
        final hours = minutes ~/ 60;
        final rem = minutes % 60;
        if (rem == 0) return l10n.hoursOverdue(hours);
        return l10n.hoursMinutesOverdue(hours, rem);
      }
      return l10n.minutesOverdue(minutes);
  }
}

/// Returns a spoken phrase for screen readers (e.g. "in 2 hours 15 minutes",
/// "1 hour 20 minutes overdue") or `null` when no label should be shown.
String? semanticTodayRelativeTime(
  TodayRelativeTime rel,
  AppLocalizations l10n,
) {
  switch (rel.state) {
    case TodayRelativeTimeState.none:
      return null;
    case TodayRelativeTimeState.upcoming:
      final minutes = rel.amount.inMinutes;
      if (minutes >= 60) {
        final hours = minutes ~/ 60;
        final rem = minutes % 60;
        if (rem == 0) return l10n.semanticInHours(hours);
        return l10n.semanticInHoursMinutes(hours, rem);
      }
      return l10n.semanticInMinutes(minutes);
    case TodayRelativeTimeState.overdue:
      final minutes = rel.amount.inMinutes;
      if (minutes >= 60) {
        final hours = minutes ~/ 60;
        final rem = minutes % 60;
        if (rem == 0) return l10n.semanticHoursOverdue(hours);
        return l10n.semanticHoursMinutesOverdue(hours, rem);
      }
      return l10n.semanticMinutesOverdue(minutes);
  }
}
