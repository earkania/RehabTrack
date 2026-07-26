import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';
import 'package:rehab_track/presentation/utils/dosage_form_localizer.dart';
import 'package:rehab_track/presentation/utils/measurement_localizer.dart';
import 'package:rehab_track/presentation/widgets/today/today_background.dart';
import 'package:intl/intl.dart';

class TodayAgendaItemWidget extends ConsumerWidget {
  final TodayAgendaItem item;

  const TodayAgendaItemWidget({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final timeStr = DateFormat.Hm().format(item.effectiveTime);
    final now = DateTime.now();
    final background = TodayBackground.forItem(item, now);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: background.cardColor(theme),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _TypeIcon(type: item.type),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        timeStr,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _displayTitle(item, l10n),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (_hasDosageInfo(item))
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        _formatDosageLine(item, l10n),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (item.instructions != null &&
                      item.instructions != _displayTitle(item, l10n))
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        item.instructions!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.7),
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (item.subtitle != null &&
                      item.subtitle != _displayTitle(item, l10n) &&
                      !_hasDosageInfo(item))
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        item.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            _StatusIcon(status: item.status),
            _AgendaItemMenu(item: item),
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

  static bool _hasDosageInfo(TodayAgendaItem item) {
    final hasStrength = item.strength != null && item.strength!.isNotEmpty;
    final hasIntake = item.intakeQuantity != null &&
        item.intakeQuantity! > 0 &&
        item.dosageForm != null;
    return hasStrength || hasIntake;
  }

  static String _formatDosageLine(TodayAgendaItem item, AppLocalizations l10n) {
    final strength = item.strength;
    final hasIntake = item.intakeQuantity != null &&
        item.intakeQuantity! > 0 &&
        item.dosageForm != null;
    final intake = hasIntake
        ? DosageFormLocalizer.localizeWithQuantity(
            item.intakeQuantity!,
            item.dosageForm!,
            l10n,
            customForm: item.customDosageForm,
          )
        : '';
    return [strength, intake]
        .where((s) => s != null && s.isNotEmpty)
        .join('  •  ');
  }
}

class _TypeIcon extends StatelessWidget {
  final TodayAgendaItemType type;

  const _TypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Icon(
      type == TodayAgendaItemType.medication
          ? Icons.medication
          : Icons.monitor_heart_outlined,
      size: 20,
      color: theme.colorScheme.onSurfaceVariant,
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final TodayAgendaItemStatus status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (icon, color) = switch (status) {
      TodayAgendaItemStatus.upcoming => (
        Icons.schedule,
        theme.colorScheme.onSurfaceVariant,
      ),
      TodayAgendaItemStatus.due => (
        Icons.alarm,
        theme.colorScheme.primary,
      ),
      TodayAgendaItemStatus.overdue => (
        Icons.warning_amber_rounded,
        theme.colorScheme.error,
      ),
      TodayAgendaItemStatus.completed => (
        Icons.check_circle,
        theme.colorScheme.primary,
      ),
      TodayAgendaItemStatus.skipped => (
        Icons.remove_circle_outline,
        theme.colorScheme.outline,
      ),
      TodayAgendaItemStatus.snoozed => (
        Icons.snooze,
        theme.colorScheme.tertiary,
      ),
    };

    return Icon(icon, color: color, size: 22);
  }
}

class _AgendaItemMenu extends ConsumerWidget {
  final TodayAgendaItem item;

  const _AgendaItemMenu({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<String>(
      onSelected: (value) => _handleAction(context, ref, value, l10n),
      tooltip: l10n.moreActions,
      itemBuilder: (context) => _buildMenuItems(l10n),
    );
  }

  List<PopupMenuItem<String>> _buildMenuItems(AppLocalizations l10n) {
    final items = <PopupMenuItem<String>>[];

    if (item.type == TodayAgendaItemType.medication) {
      if (item.isActionable) {
        items.add(PopupMenuItem(
          value: 'mark_taken',
          child: Row(
            children: [
              const Icon(Icons.check, size: 20),
              const SizedBox(width: 8),
              Text(l10n.markTaken),
            ],
          ),
        ));
        items.add(PopupMenuItem(
          value: 'skip',
          child: Row(
            children: [
              const Icon(Icons.skip_next, size: 20),
              const SizedBox(width: 8),
              Text(l10n.skip),
            ],
          ),
        ));
      }
    } else {
      if (item.isActionable) {
        items.add(PopupMenuItem(
          value: 'record_now',
          child: Row(
            children: [
              const Icon(Icons.add, size: 20),
              const SizedBox(width: 8),
              Text(l10n.recordNow),
            ],
          ),
        ));
        items.add(PopupMenuItem(
          value: 'skip',
          child: Row(
            children: [
              const Icon(Icons.skip_next, size: 20),
              const SizedBox(width: 8),
              Text(l10n.skip),
            ],
          ),
        ));
      }
    }

    items.add(PopupMenuItem(
      value: 'details',
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20),
          const SizedBox(width: 8),
          Text(l10n.openDetails),
        ],
      ),
    ));

    items.add(PopupMenuItem(
      value: 'history',
      child: Row(
        children: [
          const Icon(Icons.history, size: 20),
          const SizedBox(width: 8),
          Text(l10n.viewHistory),
        ],
      ),
    ));

    if (item.type == TodayAgendaItemType.measurement) {
      items.add(PopupMenuItem(
        value: 'trends',
        child: Row(
          children: [
            const Icon(Icons.show_chart, size: 20),
            const SizedBox(width: 8),
            Text(l10n.viewTrends),
          ],
        ),
      ));
    }

    return items;
  }

  void _handleAction(
    BuildContext context,
    WidgetRef ref,
    String value,
    AppLocalizations l10n,
  ) {
    Navigator.of(context).pop();

    switch (value) {
      case 'mark_taken':
        _markTaken(ref);
      case 'record_now':
        _recordNow(context);
      case 'skip':
        _skip(ref);
      case 'details':
        _openDetails(context);
      case 'history':
        _openHistory(context);
      case 'trends':
        _openTrends(context);
    }
  }

  void _markTaken(WidgetRef ref) async {
    if (item.medicationId == null || item.sourceScheduleId <= 0) return;
    final repo = ref.read(medicationRepositoryProvider);
    final log = MedicationLog(
      medicationScheduleId: item.sourceScheduleId,
      scheduledTime: item.scheduledDateTime,
      takenTime: DateTime.now(),
      status: 'taken',
      createdAt: DateTime.now(),
      snapshotIntakeQuantity: item.intakeQuantity,
      snapshotDosageForm: item.dosageForm,
      snapshotCustomDosageForm: item.customDosageForm,
    );
    await repo.logDose(log);
    ref.invalidate(todayAgendaProvider);
  }

  void _recordNow(BuildContext context) {
    if (item.measurementTypeId == null) return;
    context.push(AppRoutes.measurementAdd(item.measurementTypeId!));
  }

  void _skip(WidgetRef ref) async {
    if (item.medicationId == null || item.sourceScheduleId <= 0) return;
    final repo = ref.read(medicationRepositoryProvider);
    final log = MedicationLog(
      medicationScheduleId: item.sourceScheduleId,
      scheduledTime: item.scheduledDateTime,
      takenTime: DateTime.now(),
      status: 'skipped',
      createdAt: DateTime.now(),
      snapshotIntakeQuantity: item.intakeQuantity,
      snapshotDosageForm: item.dosageForm,
      snapshotCustomDosageForm: item.customDosageForm,
    );
    await repo.logDose(log);
    ref.invalidate(todayAgendaProvider);
  }

  void _openDetails(BuildContext context) {
    if (item.type == TodayAgendaItemType.medication && item.medicationId != null) {
      context.push(AppRoutes.medicationDetail(item.medicationId!));
    } else if (item.type == TodayAgendaItemType.measurement && item.measurementTypeId != null) {
      context.push(AppRoutes.measurementHistory(item.measurementTypeId!));
    }
  }

  void _openHistory(BuildContext context) {
    if (item.type == TodayAgendaItemType.medication && item.medicationId != null) {
      context.push(AppRoutes.medicationHistory(item.medicationId!));
    } else if (item.type == TodayAgendaItemType.measurement && item.measurementTypeId != null) {
      context.push(AppRoutes.measurementHistory(item.measurementTypeId!));
    }
  }

  void _openTrends(BuildContext context) {
    if (item.measurementTypeId != null) {
      context.push(AppRoutes.measurementTrends(item.measurementTypeId!));
    }
  }
}
