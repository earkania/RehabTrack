import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/schedule_config.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/measurement_provider.dart';
import 'package:rehab_track/presentation/providers/notification_provider.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';
import 'package:rehab_track/presentation/theme/app_spacing.dart';
import 'package:rehab_track/presentation/utils/measurement_localizer.dart';
import 'package:rehab_track/presentation/widgets/empty_state.dart';

class MeasurementScheduleListScreen extends ConsumerWidget {
  final int measurementTypeId;

  const MeasurementScheduleListScreen({
    super.key,
    required this.measurementTypeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final typeAsync = ref.watch(measurementTypeProvider(measurementTypeId));
    final schedulesAsync = ref.watch(
      measurementSchedulesForTypeProvider(measurementTypeId),
    );

    final typeName = typeAsync.when(
      data: (type) =>
          type != null ? MeasurementLocalizer.typeName(l10n, type.key) : '',
      loading: () => '',
      error: (_, _) => '',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.measurementSchedules),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (typeName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Text(
                typeName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          Expanded(
            child: schedulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.error),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(
                  measurementSchedulesForTypeProvider(measurementTypeId),
                ),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (schedules) {
          if (schedules.isEmpty) {
            return _EmptySchedules(
              onAdd: () => context.push(
                AppRoutes.measurementScheduleAdd(measurementTypeId),
              ),
            );
          }
          return _ScheduleList(
            schedules: schedules,
            measurementTypeId: measurementTypeId,
          );
        },
      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => context.push(
          AppRoutes.measurementScheduleAdd(measurementTypeId),
        ),
        tooltip: l10n.addMeasurementSchedule,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptySchedules extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptySchedules({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EmptyState(
            icon: Icons.alarm,
            title: l10n.noMeasurementSchedules,
            subtitle: l10n.noMeasurementSchedulesDescription,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.tonalIcon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.addMeasurementSchedule),
          ),
        ],
      ),
    );
  }
}

class _ScheduleList extends ConsumerWidget {
  final List<MeasurementSchedule> schedules;
  final int measurementTypeId;

  const _ScheduleList({
    required this.schedules,
    required this.measurementTypeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      itemCount: schedules.length,
      separatorBuilder: (_, _) => AppSpacing.smH,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return _ScheduleCard(
          schedule: schedule,
          measurementTypeId: measurementTypeId,
          onEdit: () => context.push(
            AppRoutes.measurementScheduleEdit(
              measurementTypeId,
              schedule.id!,
            ),
          ),
          onDelete: () => _confirmDelete(context, ref, schedule),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MeasurementSchedule schedule,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteSchedule),
        content: Text(l10n.deleteScheduleConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.delete,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final repo = ref.read(measurementRepositoryProvider);
      final scheduler = ref.read(notificationSchedulerProvider);
      try {
        final config = schedule.isDaily
            ? DailySchedule(times: [schedule.time])
            : IntervalDaysSchedule(
                intervalDays: schedule.intervalDays ?? 1,
                times: [schedule.time],
              );
        await scheduler.cancelNotificationsInRange(
          scheduleId: schedule.id!,
          config: config,
          isMeasurement: true,
        );
        await repo.deleteSchedule(schedule.id!);
        ref.invalidate(todayAgendaProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.scheduleDeleted)),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.failedToDeleteSchedule)),
          );
        }
      }
    }
  }
}

class _ScheduleCard extends StatelessWidget {
  final MeasurementSchedule schedule;
  final int measurementTypeId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ScheduleCard({
    required this.schedule,
    required this.measurementTypeId,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final String scheduleLabel;
    if (schedule.isDaily) {
      scheduleLabel = l10n.daily;
    } else {
      scheduleLabel = '${l10n.everyNDaysLabel} (${schedule.intervalDays})';
    }

    final startDateStr = schedule.startDate != null
        ? '${schedule.startDate!.day}.${schedule.startDate!.month}.${schedule.startDate!.year}'
        : null;
    final endDateStr = schedule.endDate != null
        ? '${schedule.endDate!.day}.${schedule.endDate!.month}.${schedule.endDate!.year}'
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(
              schedule.active ? Icons.alarm : Icons.alarm_off,
              size: 20,
              color: schedule.active
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          scheduleLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        schedule.time,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (startDateStr != null || endDateStr != null)
                    Text(
                      _buildDateLine(startDateStr, endDateStr),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Icon(
              schedule.active
                  ? Icons.check_circle_outline
                  : Icons.cancel_outlined,
              size: 18,
              color: schedule.active
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                      Text(l10n.edit),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete,
                        size: 18,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        l10n.delete,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _buildDateLine(String? startDate, String? endDate) {
    if (startDate != null && endDate != null) {
      return '$startDate – $endDate';
    }
    if (startDate != null) {
      return 'Starts $startDate';
    }
    if (endDate != null) {
      return 'Until $endDate';
    }
    return '';
  }
}
