import 'package:flutter/material.dart';
import 'package:rehab_track/l10n/app_localizations.dart';

enum ScheduleType { daily, fixedTimes, intervalDays }

class ScheduleTypeSelector extends StatelessWidget {
  final ScheduleType selectedType;
  final ValueChanged<ScheduleType> onChanged;

  const ScheduleTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.scheduleType,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _TypeOption(
          icon: Icons.today,
          label: l10n.dailySchedule,
          description: l10n.dailyAt('{time}').replaceAll('{time}', '08:00'),
          isSelected: selectedType == ScheduleType.daily,
          onTap: () => onChanged(ScheduleType.daily),
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 4),
        _TypeOption(
          icon: Icons.access_time,
          label: l10n.fixedTimesSchedule,
          description:
              l10n.fixedTimes('{times}').replaceAll('{times}', '08:00, 20:00'),
          isSelected: selectedType == ScheduleType.fixedTimes,
          onTap: () => onChanged(ScheduleType.fixedTimes),
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 4),
        _TypeOption(
          icon: Icons.date_range,
          label: l10n.intervalSchedule,
          description: l10n
              .everyNDays(3, '09:00'),
          isSelected: selectedType == ScheduleType.intervalDays,
          onTap: () => onChanged(ScheduleType.intervalDays),
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}

class _TypeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _TypeOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : null,
                          ),
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
