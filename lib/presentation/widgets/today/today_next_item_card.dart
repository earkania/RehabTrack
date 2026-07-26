import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';
import 'package:rehab_track/presentation/utils/dosage_form_localizer.dart';
import 'package:rehab_track/presentation/utils/measurement_icon.dart';
import 'package:rehab_track/presentation/utils/measurement_localizer.dart';
import 'package:intl/intl.dart';

class TodayNextItemCard extends ConsumerWidget {
  const TodayNextItemCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final nextItem = ref.watch(nextTodayItemProvider);
    final theme = Theme.of(context);

    if (nextItem == null) return const SizedBox.shrink();

    final timeStr = DateFormat.Hm().format(nextItem.effectiveTime);
    final isMedication = nextItem.type == TodayAgendaItemType.medication;

    final strength = nextItem.strength;
    final intakeText = _formatIntake(nextItem, l10n);
    final hasDosageInfo = (strength != null && strength.isNotEmpty) ||
        (intakeText.isNotEmpty);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isMedication ? Icons.medication : measurementIconForType(nextItem.measurementTypeKey),
              color: theme.colorScheme.onPrimaryContainer,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.nextItem,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_displayTitle(nextItem, l10n)}  •  $timeStr',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  if (hasDosageInfo) ...[
                    const SizedBox(height: 2),
                    Text(
                      [strength, intakeText]
                          .where((s) => s != null && s.isNotEmpty)
                          .join('  •  '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer
                            .withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (nextItem.subtitle != null &&
                      !hasDosageInfo) ...[
                    const SizedBox(height: 2),
                    Text(
                      nextItem.subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer
                            .withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ],
        ),
      ),
    );
  }

  static String _displayTitle(TodayAgendaItem item, AppLocalizations l10n) {
    if (item.type == TodayAgendaItemType.measurement &&
        item.measurementTypeKey != null) {
      return MeasurementLocalizer.typeName(l10n, item.measurementTypeKey);
    }
    return item.title;
  }

  String _formatIntake(TodayAgendaItem item, AppLocalizations l10n) {
    if (item.intakeQuantity == null || item.intakeQuantity! <= 0) return '';
    if (item.dosageForm == null) return '';
    return DosageFormLocalizer.localizeWithQuantity(
      item.intakeQuantity!,
      item.dosageForm!,
      l10n,
      customForm: item.customDosageForm,
    );
  }
}
