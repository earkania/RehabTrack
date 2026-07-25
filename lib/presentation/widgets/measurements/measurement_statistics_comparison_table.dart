import 'package:flutter/material.dart';
import 'package:rehab_track/domain/entities/measurement_statistics.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/theme/app_spacing.dart';

class _SeriesColumn {
  final String label;
  final String compactLabel;
  final String unit;
  final MeasurementStatistics? statistics;

  const _SeriesColumn({
    required this.label,
    required this.compactLabel,
    required this.unit,
    this.statistics,
  });
}

class MeasurementStatisticsComparisonTable extends StatelessWidget {
  final List<_SeriesColumn> columns;

  const MeasurementStatisticsComparisonTable({
    super.key,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final rows = [
      (label: l10n.latest, extract: (MeasurementStatistics s) => s.latest),
      (label: l10n.average, extract: (MeasurementStatistics s) => s.average),
      (label: l10n.minimum, extract: (MeasurementStatistics s) => s.minimum),
      (label: l10n.maximum, extract: (MeasurementStatistics s) => s.maximum),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        columnWidths: {
          0: const IntrinsicColumnWidth(),
          for (var i = 1; i <= columns.length; i++)
            i: const FixedColumnWidth(80),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            children: [
              const SizedBox(height: 32),
              for (final col in columns)
                Semantics(
                  label: col.label,
                  child: Tooltip(
                    message: col.label,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                      child: Column(
                        children: [
                          Text(
                            col.compactLabel,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            col.unit,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          for (final row in rows)
            TableRow(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                    horizontal: AppSpacing.xs,
                  ),
                  child: Text(
                    row.label,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                for (final col in columns)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                      horizontal: AppSpacing.xs,
                    ),
                    child: Semantics(
                      label: _formatCellAccessibility(
                        col.statistics,
                        row.extract,
                        row.label,
                        col.label,
                        l10n,
                      ),
                      child: Text(
                        _formatCell(col.statistics, row.extract, l10n),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatCell(
    MeasurementStatistics? stats,
    double? Function(MeasurementStatistics) extract,
    AppLocalizations l10n,
  ) {
    if (stats == null) return '\u2014';
    final value = extract(stats);
    if (value == null) return '\u2014';
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  String _formatCellAccessibility(
    MeasurementStatistics? stats,
    double? Function(MeasurementStatistics) extract,
    String rowLabel,
    String colLabel,
    AppLocalizations l10n,
  ) {
    if (stats == null) return '$rowLabel $colLabel: ${l10n.unavailable}';
    final value = extract(stats);
    if (value == null) return '$rowLabel $colLabel: ${l10n.unavailable}';
    final formatted =
        value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);
    return '$rowLabel $colLabel: $formatted';
  }

  static MeasurementStatisticsComparisonTable fromBloodPressure({
    required Map<String, MeasurementStatistics> fieldStatistics,
    required AppLocalizations l10n,
  }) {
    final columns = <_SeriesColumn>[
      _SeriesColumn(
        label: l10n.systolicLabel,
        compactLabel: l10n.systolicShort,
        unit: 'mmHg',
        statistics: fieldStatistics['systolic'],
      ),
      _SeriesColumn(
        label: l10n.diastolicLabel,
        compactLabel: l10n.diastolicShort,
        unit: 'mmHg',
        statistics: fieldStatistics['diastolic'],
      ),
      _SeriesColumn(
        label: l10n.pulseLabelStat,
        compactLabel: l10n.pulseShort,
        unit: 'bpm',
        statistics: fieldStatistics['pulse'],
      ),
    ];

    return MeasurementStatisticsComparisonTable(columns: columns);
  }
}
