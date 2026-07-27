import 'package:flutter/material.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';
import 'package:rehab_track/l10n/app_localizations.dart';

class TodaySummaryCard extends StatelessWidget {
  final TodayAgenda agenda;

  const TodaySummaryCard({super.key, required this.agenda});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final summary = agenda.summary;
    final theme = Theme.of(context);

    if (summary.total == 0) return const SizedBox.shrink();

    final String title;
    if (agenda.isPast) {
      title = l10n.dailySummary;
    } else {
      title = l10n.todaysProgress;
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (!agenda.isFuture) ...[
              LinearProgressIndicator(
                value: summary.handledPercentage,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  summary.completionPercentage >= 1.0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!agenda.isFuture) ...[
                  _CountChip(
                    label: '${summary.completed}',
                    icon: Icons.check_circle_outline,
                    color: theme.colorScheme.primary,
                  ),
                  if (summary.skipped > 0)
                    _CountChip(
                      label: '${summary.skipped}',
                      icon: Icons.remove_circle_outline,
                      color: theme.colorScheme.outline,
                    ),
                  if (summary.overdue > 0)
                    _CountChip(
                      label: '${summary.overdue}',
                      icon: Icons.warning_amber_rounded,
                      color: theme.colorScheme.error,
                    ),
                  if (summary.missed > 0)
                    _CountChip(
                      label: '${summary.missed}',
                      icon: Icons.event_busy,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                ] else ...[
                  _CountChip(
                    label: '${summary.total}',
                    icon: Icons.schedule,
                    color: theme.colorScheme.primary,
                  ),
                ],
                Text(
                  agenda.isFuture
                      ? '${summary.total}'
                      : '${summary.completed}/${summary.total}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _CountChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
