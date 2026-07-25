import 'package:flutter/material.dart';
import 'package:rehab_track/domain/entities/measurement_chart.dart';
import 'package:rehab_track/domain/entities/measurement_statistics.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/theme/app_spacing.dart';

class MeasurementStatisticsCard extends StatelessWidget {
  final Map<String, MeasurementStatistics> fieldStatistics;
  final List<MeasurementChartSeries> series;
  final String typeKey;

  const MeasurementStatisticsCard({
    super.key,
    required this.fieldStatistics,
    required this.series,
    required this.typeKey,
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

    return Column(
      children: [
        _StatRow(
          label: l10n.latest,
          value: _formatDouble(stats.latest),
        ),
        _StatRow(
          label: l10n.average,
          value: _formatDouble(stats.average),
        ),
        _StatRow(
          label: l10n.minimum,
          value: _formatDouble(stats.minimum),
        ),
        _StatRow(
          label: l10n.maximum,
          value: _formatDouble(stats.maximum),
        ),
        _StatRow(
          label: l10n.readingCount,
          value: stats.count.toString(),
        ),
      ],
    );
  }

  Widget _buildBloodPressureStats(AppLocalizations l10n, ThemeData theme) {
    final sysStats = fieldStatistics['systolic'];
    final diaStats = fieldStatistics['diastolic'];
    final pulseStats = fieldStatistics['pulse'];

    return Column(
      children: [
        if (sysStats != null) ...[
          _SectionHeader(label: l10n.systolicLabel),
          _StatRow(
            label: l10n.latest,
            value: _formatDouble(sysStats.latest),
          ),
          _StatRow(
            label: l10n.average,
            value: _formatDouble(sysStats.average),
          ),
          _StatRow(
            label: l10n.minimum,
            value: _formatDouble(sysStats.minimum),
          ),
          _StatRow(
            label: l10n.maximum,
            value: _formatDouble(sysStats.maximum),
          ),
        ],
        if (diaStats != null) ...[
          _SectionHeader(label: l10n.diastolicLabel),
          _StatRow(
            label: l10n.latest,
            value: _formatDouble(diaStats.latest),
          ),
          _StatRow(
            label: l10n.average,
            value: _formatDouble(diaStats.average),
          ),
          _StatRow(
            label: l10n.minimum,
            value: _formatDouble(diaStats.minimum),
          ),
          _StatRow(
            label: l10n.maximum,
            value: _formatDouble(diaStats.maximum),
          ),
        ],
        if (pulseStats != null) ...[
          _SectionHeader(label: l10n.pulseLabelStat),
          _StatRow(
            label: l10n.latest,
            value: _formatDouble(pulseStats.latest),
          ),
          _StatRow(
            label: l10n.average,
            value: _formatDouble(pulseStats.average),
          ),
        ],
      ],
    );
  }

  String _formatDouble(double? value) {
    if (value == null) return '--';
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
