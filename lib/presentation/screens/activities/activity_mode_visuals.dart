import 'package:flutter/material.dart';

import 'package:rehab_track/domain/entities/activity.dart';
import 'package:rehab_track/l10n/app_localizations.dart';

/// Localized label for a session mode.
String sessionModeLabel(AppLocalizations l10n, String mode) {
  switch (SessionMode.fromValue(mode)) {
    case SessionMode.timedSession:
      return l10n.countdownMode;
    case SessionMode.timedInterval:
      return l10n.intervalMode;
    case SessionMode.paused:
      return l10n.pausedStatus;
    case SessionMode.untimed:
      return l10n.manualMode;
  }
}

/// Localized label for a session status. Completed sessions recorded in
/// [SessionMode.paused] render the paused label.
String sessionStatusLabel(AppLocalizations l10n, String status, String mode) {
  switch (SessionStatus.fromValue(status)) {
    case SessionStatus.completed:
      return SessionMode.fromValue(mode) == SessionMode.paused
          ? l10n.pausedStatus
          : l10n.completedStatus;
    case SessionStatus.cancelled:
      return l10n.cancelledStatus;
    case SessionStatus.running:
      return l10n.sessionRunning;
    case SessionStatus.paused:
      return l10n.sessionPaused;
  }
}

/// Icon for a session mode.
IconData sessionModeIcon(String mode) {
  switch (SessionMode.fromValue(mode)) {
    case SessionMode.timedSession:
      return Icons.timer_outlined;
    case SessionMode.timedInterval:
      return Icons.repeat_outlined;
    case SessionMode.paused:
      return Icons.pause_circle_outline;
    case SessionMode.untimed:
      return Icons.timer_off_outlined;
  }
}

/// Theme-based tint color for a session mode.
Color sessionModeColor(ColorScheme colorScheme, String mode) {
  switch (SessionMode.fromValue(mode)) {
    case SessionMode.timedSession:
      return colorScheme.primary;
    case SessionMode.timedInterval:
      return colorScheme.tertiary;
    case SessionMode.paused:
      return colorScheme.error;
    case SessionMode.untimed:
      return colorScheme.secondary;
  }
}

/// Compact badge showing the session mode with a tinted icon and label.
class SessionModeBadge extends StatelessWidget {
  const SessionModeBadge({super.key, required this.mode, this.compact = false});

  final String mode;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final color = sessionModeColor(colorScheme, mode);
    final label = sessionModeLabel(l10n, mode);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(sessionModeIcon(mode), size: compact ? 12 : 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
