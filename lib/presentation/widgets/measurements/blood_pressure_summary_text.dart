import 'package:flutter/material.dart';
import 'package:rehab_track/domain/entities/blood_pressure_component_status.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/utils/reading_status_color.dart';

class BloodPressureSummaryText extends StatelessWidget {
  final List<MeasurementRecordValue> values;
  final BloodPressureComponentStatus componentStatus;
  final TextStyle? style;
  final String? pulseLabel;

  const BloodPressureSummaryText({
    super.key,
    required this.values,
    required this.componentStatus,
    this.style,
    this.pulseLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final effectivePulseLabel = pulseLabel ?? l10n.pulseLabel;

    final valueMap = <String, MeasurementRecordValue>{};
    for (final v in values) {
      valueMap[v.fieldKey] = v;
    }

    final sys = valueMap['systolic'];
    final dia = valueMap['diastolic'];
    final pulse = valueMap['pulse'];

    if (sys == null || dia == null) {
      return Semantics(
        label: l10n.unavailable,
        child: Text('--/--', style: style),
      );
    }

    final sysColor = ReadingStatusColor.forStatus(
      componentStatus.systolicStatus,
      colorScheme,
    );
    final diaColor = ReadingStatusColor.forStatus(
      componentStatus.diastolicStatus,
      colorScheme,
    );

    final sysStr = sys.numericValue.toInt().toString();
    final diaStr = dia.numericValue.toInt().toString();
    final unit = sys.unit;

    final spans = <InlineSpan>[
      TextSpan(
        text: sysStr,
        style: style?.copyWith(color: sysColor) ??
            TextStyle(color: sysColor),
        children: [
          TextSpan(
            text: '/',
            style: style,
          ),
          TextSpan(
            text: diaStr,
            style: style?.copyWith(color: diaColor) ??
                TextStyle(color: diaColor),
          ),
          TextSpan(
            text: ' $unit',
            style: style,
          ),
        ],
      ),
    ];

    if (pulse != null) {
      final pulseColor = componentStatus.pulseStatus != null
          ? ReadingStatusColor.forStatus(
              componentStatus.pulseStatus!,
              colorScheme,
            )
          : colorScheme.outline;
      final pulseStr = pulse.numericValue.toInt().toString();
      spans.addAll([
        const TextSpan(text: ', '),
        TextSpan(
          text: '$effectivePulseLabel ',
          style: style,
        ),
        TextSpan(
          text: pulseStr,
          style: style?.copyWith(color: pulseColor) ??
              TextStyle(color: pulseColor),
        ),
        TextSpan(
          text: ' ${pulse.unit}',
          style: style,
        ),
      ]);
    }

    final sysSemantics = l10n.componentStatusSystolic(
      _statusLabel(componentStatus.systolicStatus, l10n),
    );
    final diaSemantics = l10n.componentStatusDiastolic(
      _statusLabel(componentStatus.diastolicStatus, l10n),
    );
    final pulseSemantics = pulse != null
        ? ' ${l10n.componentStatusPulse(
            _statusLabel(componentStatus.pulseStatus ?? ReadingStatus.unknown, l10n),
          )}'
        : '';
    final semanticsLabel = '$sysSemantics, $diaSemantics$pulseSemantics';

    return Semantics(
      label: semanticsLabel,
      child: RichText(
        text: TextSpan(children: spans),
      ),
    );
  }

  String _statusLabel(
    ReadingStatus status,
    AppLocalizations l10n,
  ) {
    return switch (status) {
      ReadingStatus.inRange => l10n.withinConfiguredRange,
      ReadingStatus.belowRange => l10n.belowConfiguredRange,
      ReadingStatus.aboveRange => l10n.aboveConfiguredRange,
      ReadingStatus.unknown => l10n.noReferenceRangeConfigured,
    };
  }
}
