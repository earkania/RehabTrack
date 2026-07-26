import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';
import 'package:rehab_track/presentation/utils/dosage_form_localizer.dart';
import 'package:rehab_track/presentation/utils/measurement_icon.dart';
import 'package:rehab_track/presentation/utils/measurement_localizer.dart';
import 'package:rehab_track/presentation/widgets/today/today_background.dart';
import 'package:rehab_track/presentation/widgets/today/today_measurement_reading.dart';
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
            _TypeIcon(type: item.type, measurementTypeKey: item.measurementTypeKey),
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
                  if (_shouldShowReading(item))
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: TodayMeasurementReading(item: item),
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
                      item.subtitle != item.instructions &&
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

  static bool _shouldShowReading(TodayAgendaItem item) {
    return item.type == TodayAgendaItemType.measurement &&
        item.status == TodayAgendaItemStatus.completed &&
        item.readingValues.isNotEmpty;
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
  final String? measurementTypeKey;

  const _TypeIcon({required this.type, this.measurementTypeKey});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Icon(
      type == TodayAgendaItemType.medication
          ? Icons.medication
          : measurementIconForType(measurementTypeKey),
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

class _AgendaItemMenu extends ConsumerStatefulWidget {
  final TodayAgendaItem item;

  const _AgendaItemMenu({required this.item});

  @override
  ConsumerState<_AgendaItemMenu> createState() => _AgendaItemMenuState();
}

class _AgendaItemMenuState extends ConsumerState<_AgendaItemMenu> {
  bool _isProcessing = false;

  TodayAgendaItem get item => widget.item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<String>(
      onSelected: _isProcessing ? null : (value) => _handleAction(context, value, l10n),
      tooltip: l10n.moreActions,
      itemBuilder: (context) => _buildMenuItems(l10n),
    );
  }

  List<PopupMenuItem<String>> _buildMenuItems(AppLocalizations l10n) {
    final items = <PopupMenuItem<String>>[];

    if (item.type == TodayAgendaItemType.medication) {
      _buildMedicationMenu(items, l10n);
    } else {
      _buildMeasurementMenu(items, l10n);
    }

    return items;
  }

  void _buildMedicationMenu(List<PopupMenuItem<String>> items, AppLocalizations l10n) {
    if (item.isActionable) {
      items.add(PopupMenuItem(
        value: 'mark_taken',
        child: Row(
          mainAxisSize: MainAxisSize.min,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.skip_next, size: 20),
            const SizedBox(width: 8),
            Text(l10n.skip),
          ],
        ),
      ));
    } else if (item.status == TodayAgendaItemStatus.completed) {
      items.add(PopupMenuItem(
        value: 'change_to_skipped',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.remove_circle_outline, size: 20),
            const SizedBox(width: 8),
            Flexible(child: Text(l10n.changeToSkipped, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ));
      items.add(PopupMenuItem(
        value: 'reset_to_pending',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.replay, size: 20),
            const SizedBox(width: 8),
            Flexible(child: Text(l10n.resetToPending, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ));
    } else if (item.status == TodayAgendaItemStatus.skipped) {
      items.add(PopupMenuItem(
        value: 'change_to_taken',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 20),
            const SizedBox(width: 8),
            Flexible(child: Text(l10n.changeToTaken, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ));
      items.add(PopupMenuItem(
        value: 'reset_to_pending',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.replay, size: 20),
            const SizedBox(width: 8),
            Flexible(child: Text(l10n.resetToPending, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ));
    }

    items.add(PopupMenuItem(
      value: 'details',
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history, size: 20),
          const SizedBox(width: 8),
          Text(l10n.viewHistory),
        ],
      ),
    ));
  }

  void _buildMeasurementMenu(List<PopupMenuItem<String>> items, AppLocalizations l10n) {
    if (item.isActionable) {
      items.add(PopupMenuItem(
        value: 'record_now',
        child: Row(
          mainAxisSize: MainAxisSize.min,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.skip_next, size: 20),
            const SizedBox(width: 8),
            Text(l10n.skip),
          ],
        ),
      ));
    } else if (item.status == TodayAgendaItemStatus.completed ||
        item.status == TodayAgendaItemStatus.skipped) {
      if (item.measurementRecordId != null) {
        items.add(PopupMenuItem(
          value: 'edit_reading',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.edit, size: 20),
              const SizedBox(width: 8),
              Text(l10n.editReading),
            ],
          ),
        ));
      }
      items.add(PopupMenuItem(
        value: 'reset_to_pending',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.replay, size: 20),
            const SizedBox(width: 8),
            Flexible(child: Text(l10n.resetToPending, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ));
    }

    items.add(PopupMenuItem(
      value: 'schedules',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule, size: 20),
          const SizedBox(width: 8),
          Text(l10n.schedules),
        ],
      ),
    ));

    items.add(PopupMenuItem(
      value: 'history',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history, size: 20),
          const SizedBox(width: 8),
          Text(l10n.viewHistory),
        ],
      ),
    ));

    items.add(PopupMenuItem(
      value: 'trends',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.show_chart, size: 20),
          const SizedBox(width: 8),
          Text(l10n.viewTrends),
        ],
      ),
    ));
  }

  void _handleAction(
    BuildContext context,
    String value,
    AppLocalizations l10n,
  ) {
    switch (value) {
      case 'mark_taken':
        _markTaken(context, l10n);
      case 'record_now':
        _recordNow(context);
      case 'edit_reading':
        _editReading(context);
      case 'skip':
        _skip(context, l10n);
      case 'details':
        _openDetails(context);
      case 'history':
        _openHistory(context);
      case 'trends':
        _openTrends(context);
      case 'schedules':
        _openSchedules(context);
      case 'reset_to_pending':
        _resetToPending(context, l10n);
      case 'change_to_skipped':
        _changeStatus(context, l10n, 'skipped');
      case 'change_to_taken':
        _changeStatus(context, l10n, 'taken');
    }
  }

  Future<void> _markTaken(BuildContext context, AppLocalizations l10n) async {
    if (item.medicationId == null || item.sourceScheduleId <= 0) return;
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
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
      if (!mounted) return;
      ref.invalidate(todayAgendaProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.actionFailed)),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _recordNow(BuildContext context) {
    final typeId = item.measurementTypeId;
    if (typeId == null) return;
    final extra = RecordNowExtra(
      scheduledOccurrenceTime: item.scheduledDateTime,
      reminderScheduleId: item.sourceScheduleId,
    );
    context.push(AppRoutes.measurementAdd(typeId), extra: extra);
  }

  void _editReading(BuildContext context) {
    final recordId = item.measurementRecordId;
    if (recordId == null) return;
    context.push(AppRoutes.measurementEdit(recordId));
  }

  Future<void> _skip(BuildContext context, AppLocalizations l10n) async {
    if (_isProcessing) return;
    if (item.sourceScheduleId <= 0) return;
    setState(() => _isProcessing = true);

    try {
      if (item.type == TodayAgendaItemType.medication &&
          item.medicationId != null) {
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
      } else if (item.type == TodayAgendaItemType.measurement) {
        final repo = ref.read(measurementRepositoryProvider);
        final log = MeasurementReminderLog(
          measurementScheduleId: item.sourceScheduleId,
          scheduledTime: item.scheduledDateTime,
          actionTime: DateTime.now(),
          status: MeasurementReminderAction.skipped,
          createdAt: DateTime.now(),
        );
        await repo.logReminder(log);
      }
      if (!mounted) return;
      ref.invalidate(todayAgendaProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.actionFailed)),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _resetToPending(BuildContext context, AppLocalizations l10n) async {
    if (_isProcessing) return;
    if (item.sourceScheduleId <= 0) return;
    setState(() => _isProcessing = true);

    try {
      if (item.type == TodayAgendaItemType.medication) {
        final repo = ref.read(medicationRepositoryProvider);
        await repo.deleteLogForOccurrence(
          item.sourceScheduleId,
          item.scheduledDateTime,
        );
      } else {
        final repo = ref.read(measurementRepositoryProvider);
        await repo.deleteReminderLogForOccurrence(
          item.sourceScheduleId,
          item.scheduledDateTime,
        );
      }
      if (!mounted) return;
      ref.invalidate(todayAgendaProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.actionFailed)),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _changeStatus(
    BuildContext context,
    AppLocalizations l10n,
    String newStatus,
  ) async {
    if (_isProcessing) return;
    if (item.sourceScheduleId <= 0) return;
    setState(() => _isProcessing = true);

    try {
      final repo = ref.read(medicationRepositoryProvider);
      final existing = await repo.getLogForOccurrence(
        item.sourceScheduleId,
        item.scheduledDateTime,
      );

      if (existing != null && existing.id != null) {
        await repo.updateLog(existing.copyWith(status: newStatus));
      } else {
        final log = MedicationLog(
          medicationScheduleId: item.sourceScheduleId,
          scheduledTime: item.scheduledDateTime,
          takenTime: newStatus == 'taken' ? DateTime.now() : null,
          status: newStatus,
          createdAt: DateTime.now(),
          snapshotIntakeQuantity: item.intakeQuantity,
          snapshotDosageForm: item.dosageForm,
          snapshotCustomDosageForm: item.customDosageForm,
        );
        await repo.logDose(log);
      }
      if (!mounted) return;
      ref.invalidate(todayAgendaProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.actionFailed)),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
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

  void _openSchedules(BuildContext context) {
    if (item.measurementTypeId != null) {
      context.push(AppRoutes.measurementScheduleList(item.measurementTypeId!));
    }
  }
}
