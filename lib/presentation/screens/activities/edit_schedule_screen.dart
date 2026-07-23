import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/medication_provider.dart';
import 'package:rehab_track/presentation/widgets/medication/medication_schedule_form.dart';

class EditScheduleScreen extends ConsumerStatefulWidget {
  final int medicationId;
  final int scheduleId;

  const EditScheduleScreen({
    super.key,
    required this.medicationId,
    required this.scheduleId,
  });

  @override
  ConsumerState<EditScheduleScreen> createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends ConsumerState<EditScheduleScreen> {
  bool _isSaving = false;
  ScheduleFormData? _initialData;
  bool _initialized = false;

  Future<void> _onSave(ScheduleFormData data) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final scheduleAsync =
          ref.read(medicationScheduleProvider(widget.scheduleId));
      final current = scheduleAsync.value;
      if (current == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.error)),
          );
        }
        return;
      }

      final updated = current.copyWith(
        scheduleType: data.scheduleTypeString,
        scheduleConfig: data.toScheduleConfig(),
        startDate: data.startDate,
        endDate: data.endDate,
        instructions:
            data.instructions.isNotEmpty ? data.instructions : null,
        active: data.active,
      );

      final repo = ref.read(medicationRepositoryProvider);
      await repo.updateSchedule(updated);

      if (mounted) {
        ref.invalidate(medicationSchedulesProvider(widget.medicationId));
        ref.invalidate(medicationScheduleProvider(widget.scheduleId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.scheduleUpdated)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.failedToSaveSchedule)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _confirmDelete(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteSchedule),
        content: Text(l10n.deleteScheduleConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _deleteSchedule(l10n);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSchedule(AppLocalizations l10n) async {
    try {
      final repo = ref.read(medicationRepositoryProvider);
      await repo.deleteSchedule(widget.scheduleId);

      if (mounted) {
        ref.invalidate(medicationSchedulesProvider(widget.medicationId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.scheduleDeleted)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n.failedToDeleteSchedule)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheduleAsync =
        ref.watch(medicationScheduleProvider(widget.scheduleId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editSchedule),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, l10n),
            tooltip: l10n.deleteSchedule,
          ),
        ],
      ),
      body: scheduleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(l10n.error)),
        data: (schedule) {
          if (schedule == null) {
            return Center(child: Text(l10n.error));
          }

          if (!_initialized) {
            _initialData = ScheduleFormData.fromSchedule(schedule);
            _initialized = true;
          }

          return MedicationScheduleForm(
            initialData: _initialData!,
            onSave: _onSave,
            isLoading: _isSaving,
            saveButtonLabel: l10n.save,
          );
        },
      ),
    );
  }
}
