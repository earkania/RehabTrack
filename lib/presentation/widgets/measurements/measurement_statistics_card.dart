import 'package:flutter/material.dart';
import 'package:rehab_track/domain/entities/measurement_chart.dart';
import 'package:rehab_track/domain/entities/measurement_statistics.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/domain/services/reading_status_calculator.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/theme/app_spacing.dart';
import 'package:rehab_track/presentation/utils/measurement_formatter.dart';
import 'package:rehab_track/presentation/utils/reading_status_color.dart';
import 'package:rehab_track/presentation/widgets/measurements/measurement_statistics_comparison_table.dart';

class MeasurementStatisticsCard extends StatelessWidget {
  final Map<String, MeasurementStatistics> fieldStatistics;
  final List<MeasurementChartSeries> series;
  final String typeKey;
  final MeasurementRanges? ranges;

  const MeasurementStatisticsCard({
    super.key,
    required this.fieldStatistics,
    required this.series,
    required this.typeKey,
    this.ranges,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (fieldStatistics.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.statistics,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (typeKey == 'blood_pressure')
              _buildBloodPressureStats(l10n, theme)
            else
              _buildSingleStats(l10n, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleStats(AppLocalizations l10n, ThemeData theme) {
    final entry = fieldStatistics.entries.first;
    final stats = entry.value;
    final fieldKey = entry.key;
    final componentLabel = series.isNotEmpty ? series.first.label : fieldKey;
    final unit = series.isNotEmpty ? series.first.unit : '';

    Widget rowFor({
      required String label,
      required double? value,
      required bool derived,
    }) {
      final display = value == null
          ? null
          : MeasurementFormatter.statisticsValue(
              value,
              derived: derived,
              typeKey: typeKey,
              fieldKey: fieldKey,
            );
      final formatted = display?.text ?? '--';
      final status = display == null
          ? null
          : ReadingStatusCalculator.calculateFieldValue(
              fieldKey: fieldKey,
              value: display.numericValue,
              ranges: ranges,
            );
      final semanticsLabel = display == null || status == null
          ? null
          : '$componentLabel $label: $formatted '
                '${unit.isEmpty ? '' : '$unit, '}${_statusText(status, l10n)}';
      return _StatRow(
        label: label,
        value: formatted,
        status: status,
        semanticsLabel: semanticsLabel,
      );
    }

    return Column(
      children: [
        rowFor(label: l10n.latest, value: stats.latest, derived: false),
        rowFor(label: l10n.average, value: stats.average, derived: true),
        rowFor(label: l10n.minimum, value: stats.minimum, derived: true),
        rowFor(label: l10n.maximum, value: stats.maximum, derived: true),
        _StatRow(
          label: l10n.readingCount,
          value: stats.count.toString(),
        ),
      ],
    );
  }

  Widget _buildBloodPressureStats(AppLocalizations l10n, ThemeData theme) {
    return MeasurementStatisticsComparisonTable.fromBloodPressure(
      fieldStatistics: fieldStatistics,
      l10n: l10n,
      ranges: ranges,
    );
  }

  String _statusText(ReadingStatus status, AppLocalizations l10n) {
    return switch (status) {
      ReadingStatus.inRange => l10n.withinRange,
      ReadingStatus.belowRange => l10n.belowRange,
      ReadingStatus.aboveRange => l10n.aboveRange,
      ReadingStatus.unknown => l10n.noReferenceRange,
    };
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final ReadingStatus? status;
  final String? semanticsLabel;

  const _StatRow({
    required this.label,
    required this.value,
    this.status,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = this.status;
    final valueColor = status == null
        ? null
        : ReadingStatusColor.forStatus(status, theme.colorScheme);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Semantics(
            label: semanticsLabel,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
