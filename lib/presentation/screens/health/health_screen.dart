import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/measurement_provider.dart';
import 'package:rehab_track/presentation/theme/app_spacing.dart';
import 'package:rehab_track/presentation/utils/measurement_localizer.dart';
import 'package:rehab_track/presentation/widgets/empty_state.dart';

class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final typesAsync = ref.watch(activeMeasurementTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.measurements),
      ),
      body: typesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.error),
              AppSpacing.smH,
              FilledButton.tonal(
                onPressed: () => ref.invalidate(activeMeasurementTypesProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (types) {
          if (types.isEmpty) {
            return EmptyState(
              icon: Icons.favorite,
              title: l10n.noMeasurementsYet,
              subtitle: l10n.addFirstReading,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            itemCount: types.length,
            separatorBuilder: (_, _) => AppSpacing.smH,
            itemBuilder: (context, index) {
              final type = types[index];
              return _MeasurementTypeCard(
                type: type,
                onAdd: () => context.push(
                  '/health/measurement/${type.id}/add',
                ),
                onHistory: () => context.push(
                  '/health/measurement/${type.id}/history',
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MeasurementTypeCard extends StatelessWidget {
  final dynamic type;
  final VoidCallback onAdd;
  final VoidCallback onHistory;

  const _MeasurementTypeCard({
    required this.type,
    required this.onAdd,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final unitSummary = type.defaultUnit ?? type.unit;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(
              _iconForType(type.key),
              size: 32,
              color: theme.colorScheme.primary,
            ),
            AppSpacing.mdW,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    MeasurementLocalizer.typeName(l10n, type.key),
                    style: theme.textTheme.titleMedium,
                  ),
                  if (unitSummary.isNotEmpty)
                    Text(
                      unitSummary,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: onHistory,
              icon: const Icon(Icons.history),
              tooltip: l10n.viewHistory,
            ),
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle_outline),
              tooltip: l10n.addReading,
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String? key) {
    return switch (key) {
      'blood_pressure' => Icons.monitor_heart,
      'pulse' => Icons.favorite,
      'weight' => Symbols.weight,
      'blood_glucose' => Icons.bloodtype,
      'spo2' => Icons.air,
      'temperature' => Icons.thermostat,
      _ => Icons.straighten,
    };
  }
}
