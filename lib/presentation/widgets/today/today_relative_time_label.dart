import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';
import 'package:rehab_track/domain/services/app_date_formatter.dart';
import 'package:rehab_track/domain/services/today_relative_time.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';
import 'package:rehab_track/presentation/utils/measurement_localizer.dart';
import 'package:rehab_track/presentation/utils/today_relative_time_format.dart';

/// A small relative-time label for a Today item.
///
/// - Future occurrences show a countdown ("In 2h 15m").
/// - Occurrences inside the grace period show nothing.
/// - Unresolved occurrences past the grace period show "16m overdue".
/// - Occurrences that are terminal (completed/skipped/missed/snoozed) or not
///   scheduled on the current local date show nothing.
///
/// All labels share [currentMinuteProvider], so a single aligned minute timer
/// keeps every visible label fresh.
class TodayRelativeTimeLabel extends ConsumerWidget {
  final TodayAgendaItem item;
  final TextStyle? style;
  final Color? upcomingColor;
  final Color? overdueColor;

  const TodayRelativeTimeLabel({
    super.key,
    required this.item,
    this.style,
    this.upcomingColor,
    this.overdueColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final now = ref.watch(currentMinuteProvider);
    final gracePeriod =
        Duration(minutes: ref.watch(nextItemGracePeriodProvider));
    final effectiveStatus = classifyAgendaItem(item, now, gracePeriod);

    final relativeTime = computeTodayRelativeTime(
      scheduledAt: item.scheduledDateTime,
      now: now,
      gracePeriod: gracePeriod,
      status: effectiveStatus,
    );

    final visible = formatTodayRelativeTime(relativeTime, l10n);
    if (visible == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isOverdue =
        relativeTime.state == TodayRelativeTimeState.overdue;
    final color = isOverdue
        ? (overdueColor ?? theme.colorScheme.error)
        : (upcomingColor ?? theme.colorScheme.onSurfaceVariant);
    final effectiveStyle = (style ?? theme.textTheme.bodySmall)
        ?.copyWith(color: color, fontWeight: FontWeight.w500);

    final spoken = semanticTodayRelativeTime(relativeTime, l10n);
    final timeStr =
        AppDateFormatter.of(context).formatTime(item.scheduledDateTime);
    final semanticLabel =
        '${_displayTitle(item, l10n)}, ${l10n.scheduledAt(timeStr)}, $spoken';

    return Semantics(
      label: semanticLabel,
      child: Text(
        visible,
        style: effectiveStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  static String _displayTitle(TodayAgendaItem item, AppLocalizations l10n) {
    if (item.type == TodayAgendaItemType.measurement &&
        item.measurementTypeKey != null) {
      return MeasurementLocalizer.typeName(l10n, item.measurementTypeKey);
    }
    return item.title;
  }
}
