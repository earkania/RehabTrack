import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/domain/entities/medication_alternative.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/medication_provider.dart';
import 'package:rehab_track/presentation/widgets/medication/medication_alternative_form.dart';

class AddAlternativeScreen extends ConsumerStatefulWidget {
  final int medicationId;

  const AddAlternativeScreen({super.key, required this.medicationId});

  @override
  ConsumerState<AddAlternativeScreen> createState() =>
      _AddAlternativeScreenState();
}

class _AddAlternativeScreenState extends ConsumerState<AddAlternativeScreen> {
  bool _isSaving = false;

  Future<void> _onSave(MedicationAlternativeFormData data) async {
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

      final alternative = MedicationAlternative(
        medicationId: widget.medicationId,
        name: data.name,
        doseAmount: data.doseAmount.isNotEmpty ? data.doseAmount : null,
        doseUnit: data.doseUnit.isNotEmpty ? data.doseUnit : null,
        doctorApproved: data.doctorApproved,
        notes: data.notes.isNotEmpty ? data.notes : null,
        createdAt: DateTime.now(),
      );

      final repo = ref.read(medicationRepositoryProvider);
      await repo.createAlternative(alternative);

      if (mounted) {
        ref.invalidate(
            medicationAlternativesProvider(widget.medicationId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.alternativeAdded)),
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
        title: Text(l10n.addAlternative),
      ),
      body: MedicationAlternativeForm(
        initialData: MedicationAlternativeFormData(),
        onSave: _onSave,
        isLoading: _isSaving,
        saveButtonLabel: l10n.save,
      ),
    );
  }
}
