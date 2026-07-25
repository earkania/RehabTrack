import 'package:flutter/material.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/domain/entities/reading_status_summary.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/theme/app_spacing.dart';
import 'package:rehab_track/presentation/widgets/common/reading_status_indicator.dart';

class MeasurementStatusSummaryCard extends StatelessWidget {
  final ReadingStatusSummary summary;

  const MeasurementStatusSummaryCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.statusSummary,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            _StatusRow(
              status: ReadingStatus.belowRange,
              label: l10n.belowCount,
              count: summary.belowCount,
            ),
            _StatusRow(
              status: ReadingStatus.inRange,
              label: l10n.withinCount,
              count: summary.withinCount,
            ),
            _StatusRow(
              status: ReadingStatus.aboveRange,
              label: l10n.aboveCount,
              count: summary.aboveCount,
            ),
            _StatusRow(
              status: ReadingStatus.unknown,
              label: l10n.unknownCount,
              count: summary.unknownCount,
            ),
            if (summary.hasIrregularHeartbeat) ...[
              const Divider(height: AppSpacing.md),
              Row(
                children: [
                  Icon(
                    Icons.heart_broken,
                    size: 14,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.irregularHeartbeatCount,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    summary.irregularHeartbeatCount.toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final ReadingStatus status;
  final String label;
  final int count;

  const _StatusRow({
    required this.status,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          ReadingStatusIndicator(status: status, size: 10),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
