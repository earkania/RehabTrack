import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/medication_provider.dart';
import 'package:rehab_track/presentation/widgets/medication/medication_form.dart';

class EditMedicationScreen extends ConsumerStatefulWidget {
  final int medicationId;

  const EditMedicationScreen({super.key, required this.medicationId});

  @override
  ConsumerState<EditMedicationScreen> createState() =>
      _EditMedicationScreenState();
}

class _EditMedicationScreenState extends ConsumerState<EditMedicationScreen> {
  bool _isSaving = false;

  Future<void> _onSave(MedicationFormData data) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final medicationAsync =
          ref.read(medicationProvider(widget.medicationId));
      final current = medicationAsync.value;
      if (current == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.error)),
          );
        }
        return;
      }

      final updated = current.copyWith(
        name: data.name,
        description: data.description.isNotEmpty ? data.description : null,
        doseAmount: data.doseAmount.isNotEmpty ? data.doseAmount : null,
        doseUnit: data.doseUnit.isNotEmpty ? data.doseUnit : null,
        active: data.active,
        startDate: data.startDate,
        endDate: data.endDate,
        notes: data.notes.isNotEmpty ? data.notes : null,
        updatedAt: DateTime.now(),
      );

      final repo = ref.read(medicationRepositoryProvider);
      await repo.updateMedication(updated);

      if (mounted) {
        ref.invalidate(medicationProvider(widget.medicationId));
        ref.invalidate(medicationListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.medicationUpdated)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.error)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final medicationAsync =
        ref.watch(medicationProvider(widget.medicationId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editMedication),
      ),
      body: medicationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(l10n.error),
        ),
        data: (medication) {
          if (medication == null) {
            return Center(child: Text(l10n.error));
          }

          return MedicationForm(
            initialData: MedicationFormData.fromMedication(medication),
            onSave: _onSave,
            isLoading: _isSaving,
            saveButtonLabel: l10n.save,
          );
        },
      ),
    );
  }
}
