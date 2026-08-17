import 'package:flutter/material.dart';
import 'package:rehab_track/domain/entities/measurement_time_of_day_filter.dart';
import 'package:rehab_track/l10n/app_localizations.dart';

/// Compact time-of-day filter for the Measurement Trends screen, styled like
/// the Care Contacts filter buttons: circular icon buttons where the selected
/// option gets a tonal fill, an accent border and a distinct foreground so the
/// active filter is immediately obvious without relying on icons alone.
class MeasurementTimeOfDaySelector extends StatelessWidget {
  final MeasurementTimeOfDayFilter selected;
  final ValueChanged<MeasurementTimeOfDayFilter> onChanged;

  const MeasurementTimeOfDaySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    Widget filterButton(
      MeasurementTimeOfDayFilter value,
      IconData icon,
      IconData selectedIcon,
      String label,
      String selectedLabel,
    ) {
      final isSelected = selected == value;
      return Semantics(
        label: isSelected ? '$selectedLabel, ${l10n.selected}' : selectedLabel,
        button: true,
        selected: isSelected,
        child: Tooltip(
          message: selectedLabel,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => onChanged(value),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? colorScheme.secondaryContainer
                    : colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color:
                      isSelected ? colorScheme.secondary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          filterButton(
            MeasurementTimeOfDayFilter.all,
            Icons.grid_view,
            Icons.grid_view,
            l10n.allReadings,
            l10n.allReadings,
          ),
          filterButton(
            MeasurementTimeOfDayFilter.morning,
            Icons.light_mode_outlined,
            Icons.light_mode,
            l10n.morningReadings,
            l10n.morningReadings,
          ),
          filterButton(
            MeasurementTimeOfDayFilter.midday,
            Icons.wb_sunny_outlined,
            Icons.wb_sunny,
            l10n.middayReadings,
            l10n.middayReadings,
          ),
          filterButton(
            MeasurementTimeOfDayFilter.evening,
            Icons.wb_twilight_outlined,
            Icons.wb_twilight,
            l10n.eveningReadings,
            l10n.eveningReadings,
          ),
          filterButton(
            MeasurementTimeOfDayFilter.night,
            Icons.nightlight_round_outlined,
            Icons.nightlight_round,
            l10n.nightReadings,
            l10n.nightReadings,
          ),
        ],
      ),
    );
  }
}