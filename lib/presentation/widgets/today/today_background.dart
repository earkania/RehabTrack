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

  factory TodayBackground.forItem(TodayAgendaItem item, DateTime now) {
    if (item.isOverdue) return TodayBackground._(TodayItemTimePosition.past);
    if (item.isDue(now, const Duration(minutes: 30))) {
      return TodayBackground._(TodayItemTimePosition.current);
    }
    if (item.isPast(now)) return TodayBackground._(TodayItemTimePosition.past);
    return TodayBackground._(TodayItemTimePosition.future);
  }

  Color? cardColor(ThemeData theme) {
    return switch (position) {
      TodayItemTimePosition.past => ElevationOverlay.applySurfaceTint(
          theme.colorScheme.surfaceContainerHighest,
          theme.colorScheme.surfaceTint,
          2,
        ),
      TodayItemTimePosition.current => ElevationOverlay.applySurfaceTint(
          theme.colorScheme.primaryContainer,
          theme.colorScheme.primary,
          3,
        ),
      TodayItemTimePosition.future => null,
    };
  }

  Color? timeColor(ThemeData theme) {
    return switch (position) {
      TodayItemTimePosition.past => theme.colorScheme.onSurface
          .withValues(alpha: 0.5),
      TodayItemTimePosition.current => theme.colorScheme.primary,
      TodayItemTimePosition.future => null,
    };
  }
}
