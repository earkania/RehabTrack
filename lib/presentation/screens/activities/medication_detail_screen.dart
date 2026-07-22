import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/medication_provider.dart';

class MedicationDetailScreen extends ConsumerWidget {
  final int medicationId;

  const MedicationDetailScreen({super.key, required this.medicationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final medicationAsync = ref.watch(medicationProvider(medicationId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medications),
        actions: [
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
