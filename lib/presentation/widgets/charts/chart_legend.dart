import 'package:flutter/material.dart';
import 'package:rehab_track/domain/entities/measurement_chart.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/theme/app_spacing.dart';
import 'package:rehab_track/presentation/widgets/common/reading_status_indicator.dart';

class MeasurementChartLegend extends StatelessWidget {
  final List<MeasurementChartSeries> series;
  final bool showIrregularHeartbeat;

  const MeasurementChartLegend({
    super.key,
    required this.series,
    this.showIrregularHeartbeat = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final seriesColors = _seriesColors(colorScheme);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.readingStatusLegend,
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _LegendItem(
              status: ReadingStatus.inRange,
              label: l10n.withinRange,
            ),
            _LegendItem(
              status: ReadingStatus.belowRange,
              label: l10n.belowRange,
            ),
            _LegendItem(
              status: ReadingStatus.aboveRange,
              label: l10n.aboveRange,
            ),
            _LegendItem(
              status: ReadingStatus.unknown,
              label: l10n.noReferenceRange,
            ),
            if (showIrregularHeartbeat) ...[
              const Divider(height: AppSpacing.md),
              Row(
                children: [
                  Icon(
                    Icons.heart_broken,
                    size: 14,
                    color: colorScheme.error,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.irregularHeartbeat,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            if (series.length > 1) ...[
              const Divider(height: AppSpacing.md),
              Text(
                l10n.chart,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              for (var i = 0; i < series.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 3,
                        decoration: BoxDecoration(
                          color: seriesColors[i % seriesColors.length],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        series[i].label,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  List<Color> _seriesColors(ColorScheme colorScheme) {
    return [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
    ];
  }
}

class _LegendItem extends StatelessWidget {
  final ReadingStatus status;
  final String label;

  const _LegendItem({required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          ReadingStatusIndicator(status: status, size: 10),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
