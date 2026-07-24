import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/measurement_provider.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/theme/app_spacing.dart';
import 'package:rehab_track/presentation/utils/measurement_formatter.dart';
import 'package:rehab_track/presentation/utils/measurement_localizer.dart';
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
            onPressed: () => context.push(
              '/health/measurement/$measurementTypeId/add',
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
                            return _RecordTile(
                              record: record,
                              fields: fields,
                              type: type,
                              onEdit: () => context.push(
                                '/health/measurement/record/${record.id}/edit',
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

class _RecordTile extends StatelessWidget {
  final MeasurementRecord record;
  final List<MeasurementTypeField> fields;
  final MeasurementType type;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RecordTile({
    required this.record,
    required this.fields,
    required this.type,
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

        return ListTile(
          title: Text(
            formatted,
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Text(
            _formatDate(record.timestamp),
            style: theme.textTheme.bodySmall,
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
