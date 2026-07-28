import 'package:flutter/material.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';

enum TodayItemTimePosition {
  past,
  current,
  future,
}

class TodayBackground {
  final TodayItemTimePosition position;

  const TodayBackground._(this.position);

  factory TodayBackground.forItem(
    TodayAgendaItem item,
    DateTime now,
    Duration gracePeriod,
  ) {
    final status = classifyAgendaItem(item, now, gracePeriod);
    return switch (status) {
      TodayAgendaItemStatus.upcoming =>
        TodayBackground._(TodayItemTimePosition.future),
      TodayAgendaItemStatus.due =>
        TodayBackground._(TodayItemTimePosition.current),
      _ => TodayBackground._(TodayItemTimePosition.past),
    };
  }

  Color? cardColor(ThemeData theme) {
    return switch (position) {
      TodayItemTimePosition.past => null,
      TodayItemTimePosition.current => theme.colorScheme.primaryContainer,
      TodayItemTimePosition.future => ElevationOverlay.applySurfaceTint(
          theme.colorScheme.surfaceContainerHighest,
          theme.colorScheme.surfaceTint,
          2,
        ),
    };
  }

  Color? timeColor(ThemeData theme) {
    return switch (position) {
      TodayItemTimePosition.past => null,
      TodayItemTimePosition.current => theme.colorScheme.primary,
      TodayItemTimePosition.future => theme.colorScheme.onSurface
          .withValues(alpha: 0.5),
    };
  }
}
