import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/medication_provider.dart';
import 'package:rehab_track/presentation/widgets/medication/medication_schedule_form.dart';

class AddScheduleScreen extends ConsumerStatefulWidget {
  final int medicationId;

  const AddScheduleScreen({super.key, required this.medicationId});

  @override
  ConsumerState<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends ConsumerState<AddScheduleScreen> {
  bool _isSaving = false;

  Future<void> _onSave(ScheduleFormData data) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final medicationAsync =
          ref.read(medicationProvider(widget.medicationId));
      final medication = medicationAsync.value;
      if (medication == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.error)),
          );
        }
        return;
      }

      final schedule = MedicationSchedule(
        medicationId: widget.medicationId,
        scheduleType: data.scheduleTypeString,
        scheduleConfig: data.toScheduleConfig(),
        startDate: data.startDate,
        endDate: data.endDate,
        instructions:
            data.instructions.isNotEmpty ? data.instructions : null,
        active: data.active,
      );

      final repo = ref.read(medicationRepositoryProvider);
      await repo.createSchedule(schedule);

      if (mounted) {
        ref.invalidate(medicationSchedulesProvider(widget.medicationId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.scheduleAdded)),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addSchedule),
      ),
      body: MedicationScheduleForm(
        initialData: ScheduleFormData(),
        onSave: _onSave,
        isLoading: _isSaving,
        saveButtonLabel: l10n.save,
      ),
    );
  }
}
