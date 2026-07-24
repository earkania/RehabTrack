import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/entities/default_reference_ranges.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/domain/services/reading_status_calculator.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/measurement_provider.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/reference_range_provider.dart';
import 'package:rehab_track/presentation/theme/app_spacing.dart';
import 'package:rehab_track/presentation/utils/measurement_formatter.dart';
import 'package:rehab_track/presentation/utils/measurement_localizer.dart';
import 'package:rehab_track/presentation/widgets/common/reading_status_indicator.dart';
import 'package:rehab_track/presentation/widgets/empty_state.dart';

class MeasurementHistoryScreen extends ConsumerWidget {
  final int measurementTypeId;

  const MeasurementHistoryScreen({
    super.key,
    required this.measurementTypeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final typeAsync = ref.watch(
      measurementTypeProvider(measurementTypeId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.measurementHistory),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.measurementRanges),
            icon: const Icon(Icons.tune),
            tooltip: l10n.referenceRanges,
          ),
          IconButton(
            onPressed: () => _showLegend(context, l10n),
            icon: const Icon(Icons.info_outline),
            tooltip: l10n.readingStatusLegend,
          ),
          IconButton(
            onPressed: () => context.push(
              AppRoutes.measurementAdd(measurementTypeId),
            ),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: l10n.addReadingTooltip,
          ),
        ],
      ),
      body: typeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.error)),
        data: (type) {
          if (type == null) return Center(child: Text(l10n.error));

          final typeKey = type.key ?? '';
          final effectiveRangesAsync = ref.watch(
            effectiveRangesForCurrentProfileProvider(typeKey),
          );

          final fieldsAsync = ref.watch(
            measurementTypeFieldsProvider(measurementTypeId),
          );
          final recordsAsync = ref.watch(
            measurementRecordsProvider(
              (typeId: measurementTypeId, from: null, to: null),
            ),
          );

          return recordsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.error),
                  AppSpacing.smH,
                  FilledButton.tonal(
                    onPressed: () => ref.invalidate(
                      measurementRecordsProvider,
                    ),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
            data: (records) {
              return fieldsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Center(child: Text(l10n.error)),
                data: (fields) {
                  if (records.isEmpty) {
                    return EmptyState(
                      icon: Icons.history,
                      title: l10n.noReadingsYet,
                      subtitle: l10n.addFirstReading,
                    );
                  }
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                MeasurementLocalizer.typeName(l10n, type.key),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          itemCount: records.length,
                          separatorBuilder: (_, _) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final record = records[index];
                            final effectiveRanges =
                                effectiveRangesAsync.valueOrNull;
                            return _RecordTile(
                              record: record,
                              fields: fields,
                              type: type,
                              effectiveRanges: effectiveRanges,
                              onEdit: () => context.push(
                                AppRoutes.measurementEdit(record.id!),
                              ),
                              onDelete: () => _confirmDelete(
                                context,
                                ref,
                                l10n,
                                record,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showLegend(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.readingStatusLegend,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              _LegendItem(
                status: ReadingStatus.inRange,
                label: l10n.withinRange,
                description: l10n.legendWithinRangeDescription,
              ),
              _LegendItem(
                status: ReadingStatus.belowRange,
                label: l10n.belowRange,
                description: l10n.legendBelowRangeDescription,
              ),
              _LegendItem(
                status: ReadingStatus.aboveRange,
                label: l10n.aboveRange,
                description: l10n.legendAboveRangeDescription,
              ),
              _LegendItem(
                status: ReadingStatus.unknown,
                label: l10n.noReferenceRange,
                description: l10n.legendNoReferenceRangeDescription,
              ),
              const Divider(height: AppSpacing.lg),
              Row(
                children: [
                  Icon(
                    Icons.heart_broken,
                    size: 14,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.irregularHeartbeat,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          l10n.legendIrregularHeartbeat,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    MeasurementRecord record,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.confirmDeleteMeasurement),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final repo = ref.read(measurementRepositoryProvider);
              await repo.deleteRecord(record.id!);
              ref.invalidate(measurementRecordsProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.measurementDeleted)),
                );
              }
            },
            child: Text(
              l10n.delete,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final ReadingStatus status;
  final String label;
  final String description;

  const _LegendItem({
    required this.status,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          ReadingStatusIndicator(status: status, size: 12),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  final MeasurementRecord record;
  final List<MeasurementTypeField> fields;
  final MeasurementType type;
  final MeasurementRanges? effectiveRanges;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RecordTile({
    required this.record,
    required this.fields,
    required this.type,
    this.effectiveRanges,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return FutureBuilder<List<MeasurementRecordValue>>(
      future: _loadValues(context),
      builder: (context, snapshot) {
        final values = snapshot.data ?? [];
        final formatted = MeasurementFormatter.formatRecordSummary(
          type,
          fields,
          values,
          pulseLabel: l10n.pulseLabel,
        );

        final status = _calculateStatus(values);

        return ListTile(
          leading: ReadingStatusIndicator(status: status),
          title: Text(
            formatted,
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(record.timestamp),
                style: theme.textTheme.bodySmall,
              ),
              if (record.irregularHeartbeatDetected == true)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.heart_broken,
                        size: 14,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          l10n.irregularHeartbeat,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Text(l10n.edit),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  l10n.delete,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ReadingStatus _calculateStatus(List<MeasurementRecordValue> values) {
    final fieldValues = <String, double>{};
    for (final v in values) {
      fieldValues[v.fieldKey] = v.numericValue;
    }

    final typeKey = type.key ?? '';
    final ranges = effectiveRanges ?? DefaultReferenceRanges.rangesForType(typeKey);
    return ReadingStatusCalculator.calculate(
      typeKey: typeKey,
      fieldValues: fieldValues,
      ranges: ranges,
    );
  }

  Future<List<MeasurementRecordValue>> _loadValues(
    BuildContext context,
  ) async {
    final container = ProviderScope.containerOf(context);
    final repo = container.read(measurementRepositoryProvider);
    return repo.getValuesForRecord(record.id!);
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
