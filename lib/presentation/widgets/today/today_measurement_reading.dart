import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/domain/entities/blood_pressure_component_status.dart';
import 'package:rehab_track/domain/entities/default_reference_ranges.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';
import 'package:rehab_track/domain/services/blood_pressure_status_evaluator.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/providers/reference_range_provider.dart';
import 'package:rehab_track/presentation/utils/measurement_formatter.dart';
import 'package:rehab_track/presentation/widgets/measurements/blood_pressure_summary_text.dart';
import 'package:rehab_track/presentation/widgets/measurements/status_aware_measurement_value.dart';

class TodayMeasurementReading extends ConsumerWidget {
  final TodayAgendaItem item;
  final TextStyle? style;

  const TodayMeasurementReading({
    super.key,
    required this.item,
    this.style,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final typeKey = item.measurementTypeKey ?? '';
    final profileId = ref.watch(currentActiveProfileIdProvider);

    final effectiveRangesAsync = profileId != null
        ? ref.watch(effectiveRangesForCurrentProfileProvider(typeKey))
        : const AsyncValue.data(null);
    final effectiveRanges = effectiveRangesAsync.valueOrNull;
    final ranges = effectiveRanges ?? DefaultReferenceRanges.rangesForType(typeKey);

    final values = item.readingValues;
    if (values.isEmpty) return const SizedBox.shrink();

    final fieldValues = <String, double>{};
    for (final v in values) {
      fieldValues[v.fieldKey] = v.numericValue;
    }

    final isBP = typeKey == 'blood_pressure';
    Widget readingWidget;

    if (isBP) {
      final componentStatus = _computeBPStatus(fieldValues, ranges);
      readingWidget = BloodPressureSummaryText(
        values: values,
        componentStatus: componentStatus,
        style: style ?? theme.textTheme.bodyMedium,
        pulseLabel: l10n.pulseLabel,
      );
    } else if (typeKey == 'spo2') {
      readingWidget = _buildSpO2Reading(values, ranges, l10n, theme);
    } else {
      readingWidget = _buildSingleValueReading(typeKey, values, ranges, l10n, theme);
    }

    final children = <Widget>[readingWidget];

    if (item.irregularHeartbeatDetected == true) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.heart_broken,
                size: 12,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  l10n.irregularHeartbeat,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  BloodPressureComponentStatus _computeBPStatus(
    Map<String, double> fieldValues,
    MeasurementRanges? ranges,
  ) {
    if (ranges == null) {
      return const BloodPressureComponentStatus(
        overallStatus: ReadingStatus.unknown,
        systolicStatus: ReadingStatus.unknown,
        diastolicStatus: ReadingStatus.unknown,
        pulseStatus: null,
      );
    }
    return BloodPressureStatusEvaluator.evaluate(
      fieldValues: fieldValues,
      ranges: ranges,
    );
  }

  ReadingStatus _computeFieldStatus(
    String fieldKey,
    double value,
    MeasurementRanges? ranges,
  ) {
    if (ranges == null) return ReadingStatus.unknown;
    final range = ranges.rangeForField(fieldKey);
    if (range == null || !range.hasRange) return ReadingStatus.unknown;
    if (range.isAbove(value)) return ReadingStatus.aboveRange;
    if (range.isBelow(value)) return ReadingStatus.belowRange;
    return ReadingStatus.inRange;
  }

  Widget _buildSpO2Reading(
    List<MeasurementRecordValue> values,
    MeasurementRanges? ranges,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final valueMap = <String, MeasurementRecordValue>{};
    for (final v in values) {
      valueMap[v.fieldKey] = v;
    }

    final spo2 = valueMap['spo2'];
    if (spo2 == null) return const SizedBox.shrink();

    final spo2Status = _computeFieldStatus('spo2', spo2.numericValue, ranges);
    final spo2Str = MeasurementFormatter.formatNumber(spo2.numericValue, 0);

    final parts = <MeasurementValuePart>[
      MeasurementValuePart(
        value: spo2Str,
        unit: '%',
        status: spo2Status,
      ),
    ];

    final pulse = valueMap['pulse'];
    if (pulse != null) {
      final pulseStatus = _computeFieldStatus('pulse', pulse.numericValue, ranges);
      final pulseStr = MeasurementFormatter.formatNumber(pulse.numericValue, 0);
      parts.add(MeasurementValuePart(
        label: '${l10n.pulseLabel} ',
        value: pulseStr,
        unit: ' ${pulse.unit}',
        status: pulseStatus,
      ));
    }

    final spo2Semantics = '${l10n.spo2} $spo2Str%, ${_statusText(spo2Status, l10n)}';
    final pulseSemantics = pulse != null
        ? '. ${l10n.pulse} ${pulse.numericValue.toInt()} ${pulse.unit}, ${_statusText(_computeFieldStatus('pulse', pulse.numericValue, ranges), l10n)}'
        : '';

    return StatusAwareMeasurementValue(
      parts: parts,
      style: style ?? theme.textTheme.bodyMedium,
      semanticsLabel: '$spo2Semantics$pulseSemantics',
    );
  }

  Widget _buildSingleValueReading(
    String typeKey,
    List<MeasurementRecordValue> values,
    MeasurementRanges? ranges,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final valueMap = <String, MeasurementRecordValue>{};
    for (final v in values) {
      valueMap[v.fieldKey] = v;
    }

    String fieldKey;
    int decimals;
    switch (typeKey) {
      case 'pulse':
        fieldKey = 'pulse';
        decimals = 0;
      case 'weight':
        fieldKey = 'weight';
        decimals = 1;
      case 'blood_glucose':
        fieldKey = 'glucose';
        decimals = 1;
      case 'temperature':
        fieldKey = 'temperature';
        decimals = 1;
      default:
        fieldKey = valueMap.isNotEmpty ? valueMap.keys.first : '';
        decimals = 0;
    }

    final fieldValue = valueMap[fieldKey];
    if (fieldValue == null) return const SizedBox.shrink();

    final status = _computeFieldStatus(fieldKey, fieldValue.numericValue, ranges);
    final formatted = MeasurementFormatter.formatNumber(
      fieldValue.numericValue,
      decimals,
    );

    return StatusAwareMeasurementValue(
      parts: [
        MeasurementValuePart(
          value: formatted,
          unit: ' ${fieldValue.unit}',
          status: status,
        ),
      ],
      style: style ?? theme.textTheme.bodyMedium,
      semanticsLabel: '${fieldValue.unit} $formatted, ${_statusText(status, l10n)}',
    );
  }

  String _statusText(ReadingStatus status, AppLocalizations l10n) {
    return switch (status) {
      ReadingStatus.inRange => l10n.withinConfiguredRange,
      ReadingStatus.belowRange => l10n.belowConfiguredRange,
      ReadingStatus.aboveRange => l10n.aboveConfiguredRange,
      ReadingStatus.unknown => l10n.noReferenceRangeConfigured,
    };
  }
}
