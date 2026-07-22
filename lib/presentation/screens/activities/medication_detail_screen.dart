import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/domain/entities/history_period.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/domain/entities/medication_alternative.dart';
import 'package:rehab_track/domain/entities/schedule_config.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/medication_provider.dart';
import 'package:rehab_track/presentation/widgets/empty_state.dart';
import 'package:rehab_track/presentation/widgets/medication/medication_alternative_card.dart';

class MedicationDetailScreen extends ConsumerWidget {
  final int medicationId;

  const MedicationDetailScreen({super.key, required this.medicationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final medicationAsync = ref.watch(medicationProvider(medicationId));
    final schedulesAsync =
        ref.watch(medicationSchedulesProvider(medicationId));
    final alternativesAsync =
        ref.watch(medicationAlternativesProvider(medicationId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medications),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context.push('/activities/medication/$medicationId/history');
            },
            tooltip: l10n.history,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/activities/medication/$medicationId/edit');
            },
          ),
        ],
      ),
      body: medicationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(l10n.error),
        ),
        data: (medication) {
          if (medication == null) {
            return Center(child: Text(l10n.error));
          }

          final textTheme = Theme.of(context).textTheme;
          final colorScheme = Theme.of(context).colorScheme;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                medication.name,
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              if (medication.description != null &&
                  medication.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    medication.description!,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              const Divider(),
              _DetailRow(
                label: l10n.doseAmount,
                value: _formatDose(medication),
              ),
              _DetailRow(
                label: l10n.active,
                value: medication.active ? l10n.yes : l10n.no,
                valueColor: medication.active ? Colors.green : null,
              ),
              if (medication.startDate != null)
                _DetailRow(
                  label: l10n.startDate,
                  value: _formatDate(medication.startDate!),
                ),
              if (medication.endDate != null)
                _DetailRow(
                  label: l10n.endDate,
                  value: _formatDate(medication.endDate!),
                ),
              if (medication.notes != null && medication.notes!.isNotEmpty)
                _DetailRow(
                  label: l10n.notes,
                  value: medication.notes!,
                ),
              const Divider(height: 32),

              // Schedules Section
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.schedulesSection,
                      style: textTheme.titleMedium,
                    ),
                  ),
                  if (medication.active)
                    FilledButton.tonalIcon(
                      onPressed: () {
                        context.push(
                            '/activities/medication/$medicationId/schedule/add');
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l10n.addSchedule),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _buildSchedulesSection(
                context,
                ref,
                schedulesAsync,
                l10n,
                colorScheme,
                textTheme,
              ),

              const Divider(height: 32),

              // Alternatives Section
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.alternativesSection,
                      style: textTheme.titleMedium,
                    ),
                  ),
                  if (medication.active)
                    FilledButton.tonalIcon(
                      onPressed: () {
                        context.push(
                            '/activities/medication/$medicationId/alternative/add');
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l10n.addAlternative),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _buildAlternativesSection(
                context,
                ref,
                alternativesAsync,
                l10n,
                colorScheme,
                textTheme,
              ),

              const Divider(height: 32),

              // History & Adherence Section
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.historySection,
                      style: textTheme.titleMedium,
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: () {
                      context.push(
                          '/activities/medication/$medicationId/history');
                    },
                    child: Text(l10n.viewHistory),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildHistoryPreview(
                context,
                ref,
                l10n,
                colorScheme,
                textTheme,
              ),

              const Divider(height: 32),

              if (medication.active)
                ListTile(
                  leading: Icon(
                    Icons.pause_circle_outline,
                    color: colorScheme.error,
                  ),
                  title: Text(
                    l10n.deactivate,
                    style: TextStyle(color: colorScheme.error),
                  ),
                  onTap: () => _confirmDeactivate(context, ref, l10n),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSchedulesSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<MedicationSchedule>> schedulesAsync,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return schedulesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Column(
            children: [
              Text(l10n.error),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.invalidate(medicationSchedulesProvider(medicationId)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
      data: (schedules) {
        if (schedules.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 48,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noSchedulesYet,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.addScheduleSubtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: schedules.map((schedule) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  _scheduleIcon(schedule.scheduleType),
                  color: schedule.active
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  _formatScheduleSummary(schedule, l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (schedule.instructions != null &&
                        schedule.instructions!.isNotEmpty)
                      Text(
                        schedule.instructions!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Row(
                      children: [
                        Icon(
                          schedule.active
                              ? Icons.check_circle_outline
                              : Icons.cancel_outlined,
                          size: 14,
                          color: schedule.active ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          schedule.active ? l10n.active : l10n.disabled,
                          style: textTheme.bodySmall?.copyWith(
                            color: schedule.active ? Colors.green : Colors.grey,
                          ),
                        ),
                        if (schedule.startDate != null) ...[
                          const SizedBox(width: 12),
                          Text(
                            _formatDate(schedule.startDate!),
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                isThreeLine: schedule.instructions != null &&
                    schedule.instructions!.isNotEmpty,
                onTap: () {
                  context.push(
                    '/activities/medication/$medicationId/schedule/${schedule.id}/edit',
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAlternativesSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<MedicationAlternative>> alternativesAsync,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return alternativesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Column(
            children: [
              Text(l10n.error),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref
                    .invalidate(medicationAlternativesProvider(medicationId)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
      data: (alternatives) {
        if (alternatives.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: EmptyState(
              icon: Icons.medication_outlined,
              title: l10n.noAlternatives,
              subtitle: l10n.noAlternativesDescription,
            ),
          );
        }

        return Column(
          children: alternatives.map((alternative) {
            return MedicationAlternativeCard(
              alternative: alternative,
              onTap: () {
                context.push(
                  '/activities/medication/$medicationId/alternative/${alternative.id}/edit',
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildHistoryPreview(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final stats = ref.watch(medicationAdherenceStatsProvider(
      (medicationId: medicationId, period: HistoryPeriod.last30Days),
    ));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.pie_chart_outline,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.adherenceRate,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${stats.percentage.round()}% '
                    '(${stats.taken}/${stats.taken + stats.missed + stats.skipped})',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  IconData _scheduleIcon(String type) => switch (type) {
        'daily' => Icons.today,
        'fixed_times' => Icons.access_time,
        'interval_days' => Icons.date_range,
        _ => Icons.schedule,
      };

  String _formatScheduleSummary(
      MedicationSchedule schedule, AppLocalizations l10n) {
    final config = schedule.scheduleConfig;
    switch (config) {
      case DailySchedule(:final time):
        return l10n.dailyAt(time);
      case FixedTimesSchedule(:final times):
        return l10n.fixedTimes(times.join(', '));
      case IntervalDaysSchedule(:final interval, :final time):
        return l10n.everyNDays(interval, time);
    }
  }

  String _formatDose(Medication medication) {
    final parts = <String>[];
    if (medication.doseAmount != null && medication.doseAmount!.isNotEmpty) {
      parts.add(medication.doseAmount!);
    }
    if (medication.doseUnit != null && medication.doseUnit!.isNotEmpty) {
      parts.add(medication.doseUnit!);
    }
    return parts.isEmpty ? '-' : parts.join(' ');
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  void _confirmDeactivate(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deactivate),
        content: Text(l10n.confirmDeactivate),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _deactivateMedication(context, ref, l10n);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _deactivateMedication(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final medicationAsync =
        ref.read(medicationProvider(medicationId));
    final current = medicationAsync.value;
    if (current == null) return;

    try {
      final repo = ref.read(medicationRepositoryProvider);
      final updated = current.copyWith(
        active: false,
        endDate: current.endDate ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repo.updateMedication(updated);

      if (context.mounted) {
        ref.invalidate(medicationProvider(medicationId));
        ref.invalidate(medicationListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.medicationUpdated)),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.error)),
        );
      }
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: valueColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
