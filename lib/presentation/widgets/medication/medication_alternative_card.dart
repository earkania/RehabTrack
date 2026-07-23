import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/domain/entities/medication_alternative.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/medication_provider.dart';
import 'package:rehab_track/presentation/utils/component_formatter.dart';

class MedicationAlternativeCard extends ConsumerWidget {
  final MedicationAlternative alternative;
  final VoidCallback? onTap;

  const MedicationAlternativeCard({
    super.key,
    required this.alternative,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final componentsAsync = ref.watch(
      medicationAlternativeComponentsProvider(alternative.id!),
    );
    final doseText = componentsAsync.when(
      data: (components) {
        if (components.isEmpty) return '';
        return ComponentFormatter.formatAlternativeComponents(components);
      },
      loading: () => '',
      error: (_, _) => '',
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          Icons.medication_outlined,
          color: alternative.doctorApproved
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
        ),
        title: Text(
          alternative.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (doseText.isNotEmpty)
              Text(
                doseText,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            if (alternative.doctorApproved)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.doctorApproved,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            if (alternative.notes != null && alternative.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  alternative.notes!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
