import 'package:flutter/material.dart';
import 'package:rehab_track/l10n/app_localizations.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final (Color bgColor, Color fgColor, String label) = switch (status) {
      'taken' => (
          Colors.green.withValues(alpha: 0.15),
          Colors.green,
          l10n.taken,
        ),
      'missed' => (
          colorScheme.error.withValues(alpha: 0.15),
          colorScheme.error,
          l10n.missed,
        ),
      'skipped' => (
          Colors.orange.withValues(alpha: 0.15),
          Colors.orange,
          l10n.skipped,
        ),
      _ => (
          colorScheme.surfaceContainerHighest,
          colorScheme.onSurface,
          l10n.pending,
        ),
    };

    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: fgColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: bgColor,
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
