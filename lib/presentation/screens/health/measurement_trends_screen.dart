import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/entities/measurement_period.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/measurement_provider.dart';
import 'package:rehab_track/presentation/theme/app_spacing.dart';
import 'package:rehab_track/presentation/utils/measurement_localizer.dart';
import 'package:rehab_track/presentation/widgets/charts/chart_legend.dart';
import 'package:rehab_track/presentation/widgets/charts/measurement_line_chart.dart';
import 'package:rehab_track/presentation/widgets/empty_state.dart';
import 'package:rehab_track/presentation/widgets/measurements/measurement_period_selector.dart';
import 'package:rehab_track/presentation/widgets/measurements/measurement_statistics_card.dart';
import 'package:rehab_track/presentation/widgets/measurements/measurement_status_summary_card.dart';

class MeasurementTrendsScreen extends ConsumerStatefulWidget {
  final int measurementTypeId;

  const MeasurementTrendsScreen({
    super.key,
    required this.measurementTypeId,
  });

  @override
  ConsumerState<MeasurementTrendsScreen> createState() =>
      _MeasurementTrendsScreenState();
}

class _MeasurementTrendsScreenState
    extends ConsumerState<MeasurementTrendsScreen> {
  MeasurementPeriod _selectedPeriod = MeasurementPeriod.last30Days;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typeAsync = ref.watch(trendTypeProvider(widget.measurementTypeId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.measurementTrends),
        actions: [
          IconButton(
            onPressed: () => context.push(
              AppRoutes.measurementHistory(widget.measurementTypeId),
            ),
            icon: const Icon(Icons.history),
            tooltip: l10n.measurementHistory,
          ),
        ],
      ),
      body: typeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildError(l10n),
        data: (type) {
          if (type == null) return Center(child: Text(l10n.error));

          final typeName = MeasurementLocalizer.typeName(l10n, type.key);
          final trendParams = (
            measurementTypeId: widget.measurementTypeId,
            period: _selectedPeriod,
          );
          final trendAsync = ref.watch(trendDataProvider(trendParams));

          return trendAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _buildError(l10n),
            data: (trendData) {
              if (trendData.dataPoints.isEmpty) {
                return EmptyState(
                  icon: Icons.show_chart,
                  title: l10n.noTrendData,
                  subtitle: l10n.addFirstReading,
                  actionLabel: l10n.addReading,
                  onAction: () => context.push(
                    AppRoutes.measurementAdd(widget.measurementTypeId),
                  ),
                );
              }

              return _buildContent(
                l10n,
                typeName,
                type.key ?? '',
                trendData,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildContent(
    AppLocalizations l10n,
    String typeName,
    String typeKey,
    TrendData trendData,
  ) {
    final hasOneReading = trendData.dataPoints.length == 1;
    final showChart = !hasOneReading;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                MeasurementPeriodSelector(
                  selected: _selectedPeriod,
                  onChanged: (period) {
                    setState(() => _selectedPeriod = period);
                  },
                ),
              ],
            ),
          ),
        ),
        if (showChart)
          SliverToBoxAdapter(
            child: MeasurementLineChart(
              series: trendData.chartSeries,
              typeKey: typeKey,
            ),
          ),
        if (hasOneReading)
          SliverToBoxAdapter(
            child: _OneReadingCard(
              trendData: trendData,
              typeKey: typeKey,
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: MeasurementStatisticsCard(
              fieldStatistics: trendData.fieldStatistics,
              series: trendData.chartSeries,
              typeKey: typeKey,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: MeasurementStatusSummaryCard(
              summary: trendData.statusSummary,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            child: MeasurementChartLegend(
              series: trendData.chartSeries,
              showIrregularHeartbeat: typeKey == 'blood_pressure',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.failedToLoadTrends),
          const SizedBox(height: AppSpacing.sm),
          FilledButton.tonal(
            onPressed: () => ref.invalidate(trendDataProvider),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}

class _OneReadingCard extends StatelessWidget {
  final TrendData trendData;
  final String typeKey;

  const _OneReadingCard({
    required this.trendData,
    required this.typeKey,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final point = trendData.dataPoints.first;

    final formattedValues = <String>[];
    for (final v in point.values) {
      formattedValues.add('${_formatValue(v.numericValue)} ${v.unit}');
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.latestReading,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              formattedValues.join(', '),
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.moreReadingsNeeded,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatValue(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }
}
