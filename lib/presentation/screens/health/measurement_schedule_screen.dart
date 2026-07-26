import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/repositories/measurement_repository.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/measurement_provider.dart';
import 'package:rehab_track/presentation/providers/notification_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';
import 'package:rehab_track/presentation/theme/app_spacing.dart';
import 'package:rehab_track/data/services/notification/measurement_notification_helper.dart';
import 'package:rehab_track/data/services/notification/notification_scheduler.dart';
import 'package:rehab_track/data/services/notification/notification_service.dart';

enum ScheduleType { daily, intervalDays }

class MeasurementScheduleScreen extends ConsumerStatefulWidget {
  final int measurementTypeId;
  final int? scheduleId;

  const MeasurementScheduleScreen({
    super.key,
    required this.measurementTypeId,
    this.scheduleId,
  });

  bool get isEditing => scheduleId != null;

  @override
  ConsumerState<MeasurementScheduleScreen> createState() =>
      _MeasurementScheduleScreenState();
}

class _MeasurementScheduleScreenState
    extends ConsumerState<MeasurementScheduleScreen> {
  ScheduleType _scheduleType = ScheduleType.daily;
  String _time = '08:00';
  int _intervalDays = 2;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _active = true;
  final _instructionsController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadExistingSchedule();
    }
  }

  Future<void> _loadExistingSchedule() async {
    final repo = ref.read(measurementRepositoryProvider);
    final schedule = await repo.getSchedule(widget.scheduleId!);
    if (schedule == null || !mounted) return;

    setState(() {
      _scheduleType = schedule.isDaily
          ? ScheduleType.daily
          : ScheduleType.intervalDays;
      _time = schedule.time;
      _intervalDays = schedule.intervalDays ?? 2;
      _startDate = schedule.startDate;
      _endDate = schedule.endDate;
      _active = schedule.active;
      _instructionsController.text = schedule.instructions ?? '';
    });
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;

    final l10n = AppLocalizations.of(context)!;

    final normalizedTime = MeasurementSchedule.normalizeTime(_time);
    if (!MeasurementSchedule.isValidTime(_time)) {
      _showError(l10n.atLeastOneTimeRequired);
      return;
    }

    if (_scheduleType == ScheduleType.intervalDays && _intervalDays < 1) {
      _showError(l10n.invalidInterval);
      return;
    }

    if (_scheduleType == ScheduleType.intervalDays && _startDate == null) {
      _showError(l10n.everyNDaysRequiresStartDate);
      return;
    }

    if (_startDate != null &&
        _endDate != null &&
        _startDate!.isAfter(_endDate!)) {
      _showError(l10n.endDateBeforeStartDate);
      return;
    }

    setState(() => _saving = true);

    try {
      final profileId = ref.read(activeProfileIdProvider) ?? 1;
      final now = DateTime.now();
      final scheduleTypeName = _scheduleType == ScheduleType.daily
          ? 'daily'
          : 'interval_days';

      final repo = ref.read(measurementRepositoryProvider);
      final scheduler = ref.read(notificationSchedulerProvider);

      if (widget.isEditing) {
        final existing = await repo.getSchedule(widget.scheduleId!);
        if (existing == null) {
          if (!mounted) return;
          _showError(l10n.failedToSaveSchedule);
          return;
        }

        await scheduler.cancelNotification(
          MeasurementNotificationHelper.baseNotificationId(existing.id!),
        );

        final updated = existing.copyWith(
          scheduleType: scheduleTypeName,
          time: normalizedTime,
          intervalDays:
              _scheduleType == ScheduleType.intervalDays ? _intervalDays : null,
          clearIntervalDays: _scheduleType == ScheduleType.daily,
          startDate: _startDate,
          endDate: _endDate,
          active: _active,
          instructions: _instructionsController.text.isEmpty
              ? null
              : _instructionsController.text,
          updatedAt: now,
        );

        await repo.updateSchedule(updated);

        if (_active) {
          await _scheduleNotifications(
            repo,
            scheduler,
            updated,
            profileId,
          );
        }
      } else {
        final schedule = MeasurementSchedule(
          profileId: profileId,
          measurementTypeId: widget.measurementTypeId,
          scheduleType: scheduleTypeName,
          time: normalizedTime,
          intervalDays:
              _scheduleType == ScheduleType.intervalDays ? _intervalDays : null,
          startDate: _startDate,
          endDate: _endDate,
          active: _active,
          instructions: _instructionsController.text.isEmpty
              ? null
              : _instructionsController.text,
          createdAt: now,
          updatedAt: now,
        );

        final id = await repo.createSchedule(schedule);
        final created = schedule.copyWith(id: id);

        if (_active) {
          await _scheduleNotifications(
            repo,
            scheduler,
            created,
            profileId,
          );
        }
      }

      if (mounted) {
        ref.invalidate(
          measurementSchedulesForTypeProvider(widget.measurementTypeId),
        );
        ref.invalidate(todayAgendaProvider);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        _showError(AppLocalizations.of(context)!.failedToSaveSchedule);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _scheduleNotifications(
    MeasurementRepository repo,
    NotificationScheduler scheduler,
    MeasurementSchedule schedule,
    int profileId,
  ) async {
    final type = await repo.getMeasurementType(
      schedule.measurementTypeId,
    );
    final typeName = type?.name ?? 'Measurement';

    final notifPayload = MeasurementNotificationHelper.buildPayload(
      scheduleId: schedule.id!,
      measurementTypeId: schedule.measurementTypeId,
      profileId: profileId,
    );

    final bodyParts = <String>[];
    bodyParts.add('Please record your ${typeName.toLowerCase()}');
    if (schedule.instructions != null &&
        schedule.instructions!.isNotEmpty) {
      bodyParts.add(schedule.instructions!);
    }
    final body = bodyParts.join(' — ');

    final notificationId =
        MeasurementNotificationHelper.computeNotificationId(
      schedule.id!,
    );

    if (schedule.isIntervalDays && schedule.intervalDays != null) {
      await scheduler.scheduleSingleIntervalNotification(
        notificationId: notificationId,
        title: 'Time to record $typeName',
        body: body,
        time: schedule.time,
        intervalDays: schedule.intervalDays!,
        channelType: NotificationChannelType.measurement,
        payload: notifPayload,
        includeActions: true,
      );
    } else {
      await scheduler.scheduleSingleNotification(
        notificationId: notificationId,
        title: 'Time to record $typeName',
        body: body,
        time: schedule.time,
        channelType: NotificationChannelType.measurement,
        payload: notifPayload,
        includeActions: true,
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typeAsync = ref.watch(
      measurementTypeProvider(widget.measurementTypeId),
    );

    final typeName = typeAsync.valueOrNull?.name ?? 'Measurement';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? l10n.editMeasurementSchedule
              : l10n.addMeasurementSchedule,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              typeName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildScheduleTypeSelector(l10n),
            const SizedBox(height: AppSpacing.md),
            if (_scheduleType == ScheduleType.intervalDays) ...[
              _buildIntervalDaysField(l10n),
              const SizedBox(height: AppSpacing.md),
            ],
            _buildTimeField(l10n),
            const SizedBox(height: AppSpacing.md),
            _buildDateRow(l10n),
            const SizedBox(height: AppSpacing.md),
            _buildActiveToggle(l10n),
            const SizedBox(height: AppSpacing.md),
            _buildInstructionsField(l10n),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTypeSelector(AppLocalizations l10n) {
    return SegmentedButton<ScheduleType>(
      segments: [
        ButtonSegment(
          value: ScheduleType.daily,
          label: Text(l10n.daily),
        ),
        ButtonSegment(
          value: ScheduleType.intervalDays,
          label: Text(l10n.everyNDaysLabel),
        ),
      ],
      selected: {_scheduleType},
      onSelectionChanged: (selected) {
        setState(() => _scheduleType = selected.first);
      },
    );
  }

  Widget _buildIntervalDaysField(AppLocalizations l10n) {
    return TextFormField(
      initialValue: _intervalDays.toString(),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: l10n.intervalDays,
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        final parsed = int.tryParse(value);
        if (parsed != null && parsed > 0) {
          _intervalDays = parsed;
        }
      },
    );
  }

  Widget _buildTimeField(AppLocalizations l10n) {
    return InkWell(
      onTap: () async {
        final parts = _time.split(':');
        final initial = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 8,
          minute: int.tryParse(parts[1]) ?? 0,
        );
        final picked = await showTimePicker(
          context: context,
          initialTime: initial,
        );
        if (picked != null) {
          setState(() {
            _time =
                '${picked.hour.toString().padLeft(2, '0')}:'
                '${picked.minute.toString().padLeft(2, '0')}';
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.scheduledTime,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(_time),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _DatePickerField(
            label: l10n.startDate,
            selectedDate: _startDate,
            onDateSelected: (date) => setState(() => _startDate = date),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _DatePickerField(
            label: l10n.endDate,
            selectedDate: _endDate,
            onDateSelected: (date) => setState(() => _endDate = date),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveToggle(AppLocalizations l10n) {
    return SwitchListTile(
      title: Text(l10n.active),
      value: _active,
      onChanged: (value) => setState(() => _active = value),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildInstructionsField(AppLocalizations l10n) {
    return TextFormField(
      controller: _instructionsController,
      decoration: InputDecoration(
        labelText: l10n.instructions,
        border: const OutlineInputBorder(),
      ),
      maxLines: 2,
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;

  const _DatePickerField({
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
        );
        onDateSelected(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate != null
                  ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                  : label,
            ),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }
}
