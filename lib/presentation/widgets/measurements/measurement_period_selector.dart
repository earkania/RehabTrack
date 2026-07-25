import 'package:flutter/material.dart';
import 'package:rehab_track/domain/entities/measurement_period.dart';
import 'package:rehab_track/l10n/app_localizations.dart';

class MeasurementPeriodSelector extends StatelessWidget {
  final MeasurementPeriod selected;
  final ValueChanged<MeasurementPeriod> onChanged;

  const MeasurementPeriodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SegmentedButton<MeasurementPeriod>(
      segments: [
        ButtonSegment(
          value: MeasurementPeriod.last7Days,
          label: Text(l10n.lastSevenDays),
        ),
        ButtonSegment(
          value: MeasurementPeriod.last30Days,
          label: Text(l10n.lastThirtyDays),
        ),
        ButtonSegment(
          value: MeasurementPeriod.last90Days,
          label: Text(l10n.lastNinetyDays),
        ),
        ButtonSegment(
          value: MeasurementPeriod.allTime,
          label: Text(l10n.allTime),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) {
        if (selection.isNotEmpty) onChanged(selection.first);
      },
    );
  }
}
