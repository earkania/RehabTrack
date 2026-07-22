import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/medication_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/widgets/medication/medication_form.dart';

class AddMedicationScreen extends ConsumerStatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  ConsumerState<AddMedicationScreen> createState() =>
      _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
  bool _isSaving = false;

  Future<void> _onSave(MedicationFormData data) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final profileId = ref.read(activeProfileIdProvider) ?? 1;
      final now = DateTime.now();
      final medication = Medication(
        profileId: profileId,
        name: data.name,
        description: data.description.isNotEmpty ? data.description : null,
        doseAmount: data.doseAmount.isNotEmpty ? data.doseAmount : null,
        doseUnit: data.doseUnit.isNotEmpty ? data.doseUnit : null,
        active: data.active,
        startDate: data.startDate,
        endDate: data.endDate,
        notes: data.notes.isNotEmpty ? data.notes : null,
        createdAt: now,
        updatedAt: now,
      );

      final repo = ref.read(medicationRepositoryProvider);
      await repo.createMedication(medication);

      if (mounted) {
        ref.invalidate(medicationListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.medicationAdded)),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addMedication),
      ),
      body: MedicationForm(
        initialData: MedicationFormData(),
        onSave: _onSave,
        isLoading: _isSaving,
        saveButtonLabel: l10n.save,
      ),
    );
  }
}
