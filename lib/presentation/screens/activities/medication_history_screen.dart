import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/domain/entities/adherence_stats.dart';
import 'package:rehab_track/domain/entities/history_period.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/medication_provider.dart';
import 'package:rehab_track/presentation/widgets/empty_state.dart';
import 'package:rehab_track/presentation/widgets/medication/status_chip.dart';

class MedicationHistoryScreen extends ConsumerStatefulWidget {
  final int medicationId;

  const MedicationHistoryScreen({super.key, required this.medicationId});

  @override
  ConsumerState<MedicationHistoryScreen> createState() =>
      _MedicationHistoryScreenState();
}

class _MedicationHistoryScreenState
    extends ConsumerState<MedicationHistoryScreen> {
  HistoryPeriod _selectedPeriod = HistoryPeriod.last30Days;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final medicationAsync =
        ref.watch(medicationProvider(widget.medicationId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyScreenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showLogDoseDialog(context, ref, l10n),
            tooltip: l10n.logDoseNow,
          ),
        ],
      ),
      body: medicationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.error)),
        data: (medication) {
          if (medication == null) {
            return Center(child: Text(l10n.error));
          }
          return _buildContent(context, ref, l10n, medication);
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Medication medication,
  ) {
    final params = (
      medicationId: widget.medicationId,
      period: _selectedPeriod,
    );
    final logsAsync = ref.watch(medicationAllLogsProvider(params));
    final stats = ref.watch(medicationAdherenceStatsProvider(params));

    return Column(
      children: [
        // Period selector
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SegmentedButton<HistoryPeriod>(
            segments: [
              ButtonSegment(
                value: HistoryPeriod.last7Days,
                label: Text(l10n.last7Days),
              ),
              ButtonSegment(
                value: HistoryPeriod.last30Days,
                label: Text(l10n.last30Days),
              ),
              ButtonSegment(
                value: HistoryPeriod.allTime,
                label: Text(l10n.allTime),
              ),
            ],
            selected: {_selectedPeriod},
            onSelectionChanged: (selected) {
              setState(() => _selectedPeriod = selected.first);
            },
          ),
        ),
        // Adherence summary
        _AdherenceSummary(stats: stats, l10n: l10n),
        const Divider(height: 1),
        // Log list
        Expanded(
          child: logsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(child: Text(l10n.error)),
            data: (logs) {
              if (logs.isEmpty) {
                return EmptyState(
                  icon: Icons.history_outlined,
                  title: l10n.noLogsYet,
                  subtitle: l10n.noLogsDescription,
                  actionLabel: l10n.logDoseNow,
                  onAction: () =>
                      _showLogDoseDialog(context, ref, l10n),
                );
              }
              return _LogList(logs: logs, l10n: l10n);
            },
          ),
        ),
      ],
    );
  }

  void _showLogDoseDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog<String>(
      context: context,
      builder: (ctx) => _LogDoseDialog(l10n: l10n),
    ).then((status) async {
      if (status == null) return;
      final now = DateTime.now();
      final log = MedicationLog(
        medicationScheduleId: 0,
        scheduledTime: now,
        takenTime: status == 'taken' ? now : null,
        status: status,
        createdAt: now,
      );
      try {
        final repo = ref.read(medicationRepositoryProvider);
        // Get the first schedule for this medication
        final schedules = await repo
            .watchSchedules(widget.medicationId)
            .first;
        if (schedules.isEmpty) return;
        final scheduleLog = log.copyWith(
          medicationScheduleId: schedules.first.id!,
        );
        await repo.logDose(scheduleLog);
        ref.invalidate(medicationAllLogsProvider(
          (medicationId: widget.medicationId, period: _selectedPeriod),
        ));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.doseLogged)),
          );
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.logDoseError)),
          );
        }
      }
    });
  }
}

class _AdherenceSummary extends StatelessWidget {
  final AdherenceStats stats;
  final AppLocalizations l10n;

  const _AdherenceSummary({required this.stats, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _StatTile(
            label: l10n.totalDoses,
            value: '${stats.total}',
            color: colorScheme.primary,
          ),
          const SizedBox(width: 16),
          _StatTile(
            label: l10n.completedDoses,
            value: '${stats.taken + stats.missed + stats.skipped}',
            color: Colors.green,
          ),
          const SizedBox(width: 16),
          _StatTile(
            label: l10n.adherenceRate,
            value: '${stats.percentage.round()}%',
            color: colorScheme.tertiary,
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LogList extends StatelessWidget {
  final List<MedicationLog> logs;
  final AppLocalizations l10n;

  const _LogList({required this.logs, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: StatusChip(status: log.status),
            title: Text(
              _formatDateTime(log.scheduledTime),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            subtitle: log.takenTime != null
                ? Text(
                    l10n.takenAt(_formatTime(log.takenTime!)),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  )
                : null,
            trailing: log.notes != null && log.notes!.isNotEmpty
                ? Icon(
                    Icons.notes,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )
                : null,
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _LogDoseDialog extends StatefulWidget {
  final AppLocalizations l10n;

  const _LogDoseDialog({required this.l10n});

  @override
  State<_LogDoseDialog> createState() => _LogDoseDialogState();
}

class _LogDoseDialogState extends State<_LogDoseDialog> {
  String _selectedStatus = 'taken';
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.l10n.logDoseNow),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.l10n.selectStatus,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'taken',
                label: Text(widget.l10n.taken),
              ),
              ButtonSegment(
                value: 'missed',
                label: Text(widget.l10n.missed),
              ),
              ButtonSegment(
                value: 'skipped',
                label: Text(widget.l10n.skipped),
              ),
            ],
            selected: {_selectedStatus},
            onSelectionChanged: (selected) {
              setState(() => _selectedStatus = selected.first);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: widget.l10n.doseNotes,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selectedStatus),
          child: Text(widget.l10n.save),
        ),
      ],
    );
  }
}
