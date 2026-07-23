import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/presentation/providers/medication_provider.dart';
import 'package:rehab_track/presentation/utils/component_formatter.dart';

class MedicationCard extends ConsumerWidget {
  final Medication medication;
  final VoidCallback? onTap;

  const MedicationCard({
    super.key,
    required this.medication,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final componentsAsync = ref.watch(
      medicationComponentsProvider(medication.id!),
    );
    final doseText = componentsAsync.when(
      data: (components) {
        if (components.isEmpty) return '';
        return ComponentFormatter.formatComponents(components);
      },
      loading: () => '',
      error: (_, _) => '',
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          Icons.medication,
          color: medication.active
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
        ),
        title: Text(
          medication.name,
          style: textTheme.titleMedium?.copyWith(
            color: medication.active ? null : colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: doseText.isNotEmpty
            ? Text(
                doseText,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: Icon(
          medication.active ? Icons.circle : Icons.circle_outlined,
          size: 10,
          color: medication.active ? Colors.green : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

}
