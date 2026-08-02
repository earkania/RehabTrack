import 'package:flutter/material.dart';
import 'package:rehab_track/domain/entities/measurement_statistics.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/domain/services/reading_status_calculator.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/theme/app_spacing.dart';
import 'package:rehab_track/presentation/utils/measurement_formatter.dart';
import 'package:rehab_track/presentation/utils/reading_status_color.dart';

class SeriesColumn {
  final String label;
  final String compactLabel;
  final String unit;
  final String? fieldKey;
  final MeasurementStatistics? statistics;

  const SeriesColumn({
    required this.label,
    required this.compactLabel,
    required this.unit,
    this.fieldKey,
    this.statistics,
  });
}

class MeasurementStatisticsComparisonTable extends StatelessWidget {
  final List<SeriesColumn> columns;
  final MeasurementRanges? ranges;

  const MeasurementStatisticsComparisonTable({
    super.key,
    required this.columns,
    this.ranges,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final rows = [
      (
        label: l10n.latest,
        extract: (MeasurementStatistics s) => s.latest,
        derived: false,
      ),
      (
        label: l10n.average,
        extract: (MeasurementStatistics s) => s.average,
        derived: true,
      ),
      (
        label: l10n.minimum,
        extract: (MeasurementStatistics s) => s.minimum,
        derived: true,
      ),
      (
        label: l10n.maximum,
        extract: (MeasurementStatistics s) => s.maximum,
        derived: true,
      ),
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
                        row.derived,
                        row.label,
                        col.label,
                        l10n,
                        fieldKey: col.fieldKey,
                        unit: col.unit,
                        ranges: ranges,
                      ),
                      child: Text(
                        _formatCell(col, row.extract, row.derived),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: _cellColor(
                            col,
                            row.extract,
                            row.derived,
                            colorScheme,
                          ),
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

  StatisticsValue? _statisticsValue(
    SeriesColumn col,
    double? Function(MeasurementStatistics) extract,
    bool derived,
  ) {
    final stats = col.statistics;
    if (stats == null) return null;
    final value = extract(stats);
    if (value == null) return null;
    return MeasurementFormatter.statisticsValue(
      value,
      derived: derived,
      fieldKey: col.fieldKey,
    );
  }

  String _formatCell(
    SeriesColumn col,
    double? Function(MeasurementStatistics) extract,
    bool derived,
  ) {
    final display = _statisticsValue(col, extract, derived);
    if (display == null) return '\u2014';
    return display.text;
  }

  String _formatCellAccessibility(
    MeasurementStatistics? stats,
    double? Function(MeasurementStatistics) extract,
    bool derived,
    String rowLabel,
    String colLabel,
    AppLocalizations l10n, {
    String? fieldKey,
    String? unit,
    MeasurementRanges? ranges,
  }) {
    if (stats == null) return '$rowLabel $colLabel: ${l10n.unavailable}';
    final value = extract(stats);
    if (value == null) return '$rowLabel $colLabel: ${l10n.unavailable}';
    final display = MeasurementFormatter.statisticsValue(
      value,
      derived: derived,
      fieldKey: fieldKey,
    );
    final status = ReadingStatusCalculator.calculateFieldValue(
      fieldKey: fieldKey ?? '',
      value: display.numericValue,
      ranges: ranges,
    );
    final unitPart = (unit == null || unit.isEmpty) ? '' : '$unit, ';
    return '$rowLabel $colLabel: ${display.text} $unitPart${_statusLabel(status, l10n)}';
  }

  Color? _cellColor(
    SeriesColumn col,
    double? Function(MeasurementStatistics) extract,
    bool derived,
    ColorScheme colorScheme,
  ) {
    if (col.fieldKey == null) return null;
    final display = _statisticsValue(col, extract, derived);
    if (display == null) return null;

    final status = ReadingStatusCalculator.calculateFieldValue(
      fieldKey: col.fieldKey!,
      value: display.numericValue,
      ranges: ranges,
    );
    return ReadingStatusColor.forStatus(status, colorScheme);
  }

  String _statusLabel(ReadingStatus status, AppLocalizations l10n) {
    return switch (status) {
      ReadingStatus.inRange => l10n.withinRange,
      ReadingStatus.belowRange => l10n.belowRange,
      ReadingStatus.aboveRange => l10n.aboveRange,
      ReadingStatus.unknown => l10n.noReferenceRange,
    };
  }

  static MeasurementStatisticsComparisonTable fromBloodPressure({
    required Map<String, MeasurementStatistics> fieldStatistics,
    required AppLocalizations l10n,
    MeasurementRanges? ranges,
  }) {
    final columns = <SeriesColumn>[
      SeriesColumn(
        label: l10n.systolicLabel,
        compactLabel: l10n.systolicShort,
        unit: 'mmHg',
        fieldKey: 'systolic',
        statistics: fieldStatistics['systolic'],
      ),
      SeriesColumn(
        label: l10n.diastolicLabel,
        compactLabel: l10n.diastolicShort,
        unit: 'mmHg',
        fieldKey: 'diastolic',
        statistics: fieldStatistics['diastolic'],
      ),
      SeriesColumn(
        label: l10n.pulseLabelStat,
        compactLabel: l10n.pulseShort,
        unit: 'bpm',
        fieldKey: 'pulse',
        statistics: fieldStatistics['pulse'],
      ),
    ];

    return MeasurementStatisticsComparisonTable(
      columns: columns,
      ranges: ranges,
    );
  }
}
