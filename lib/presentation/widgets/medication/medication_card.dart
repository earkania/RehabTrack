import 'package:flutter/material.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/presentation/utils/dose_formatter.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback? onTap;

  const MedicationCard({
    super.key,
    required this.medication,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final doseText = DoseFormatter.format(medication);

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
