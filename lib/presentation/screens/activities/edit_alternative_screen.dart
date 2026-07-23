import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/medication_provider.dart';
import 'package:rehab_track/presentation/widgets/medication/medication_alternative_form.dart';

class EditAlternativeScreen extends ConsumerStatefulWidget {
  final int medicationId;
  final int alternativeId;

  const EditAlternativeScreen({
    super.key,
    required this.medicationId,
    required this.alternativeId,
  });

  @override
  ConsumerState<EditAlternativeScreen> createState() =>
      _EditAlternativeScreenState();
}

class _EditAlternativeScreenState extends ConsumerState<EditAlternativeScreen> {
  bool _isSaving = false;

  Future<void> _onSave(MedicationAlternativeFormData data) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final alternativeAsync =
          ref.read(medicationAlternativeProvider(widget.alternativeId));
      final current = alternativeAsync.value;
      if (current == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.error)),
          );
        }
        return;
      }

      if (current.medicationId != widget.medicationId) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.error)),
          );
        }
        return;
      }

      final updated = current.copyWith(
        name: data.name,
        doctorApproved: data.doctorApproved,
        notes: data.notes.isNotEmpty ? data.notes : null,
      );

      final repo = ref.read(medicationRepositoryProvider);
      await repo.updateAlternative(updated);

      final components = data.components
          .map((c) =>
              c.copyWith(medicationAlternativeId: widget.alternativeId))
          .toList();
      await repo.replaceAlternativeComponents(
        widget.alternativeId,
        components,
      );

      if (mounted) {
        ref.invalidate(
            medicationAlternativesProvider(widget.medicationId));
        ref.invalidate(medicationAlternativeProvider(widget.alternativeId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.alternativeUpdated)),
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

  void _confirmDelete(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAlternative),
        content: Text(l10n.confirmDeleteAlternative),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (!mounted) return;
              await _deleteAlternative(context, l10n);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAlternative(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    try {
      final repo = ref.read(medicationRepositoryProvider);
      await repo.deleteAlternative(widget.alternativeId);

      if (mounted) {
        ref.invalidate(
            medicationAlternativesProvider(widget.medicationId));
        ref.invalidate(medicationAlternativeProvider(widget.alternativeId));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.alternativeDeleted)),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final alternativeAsync =
        ref.watch(medicationAlternativeProvider(widget.alternativeId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editAlternative),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, l10n),
          ),
        ],
      ),
      body: alternativeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(l10n.error),
        ),
        data: (alternative) {
          if (alternative == null) {
            return Center(child: Text(l10n.error));
          }

          if (alternative.medicationId != widget.medicationId) {
            return Center(child: Text(l10n.error));
          }

          return _EditAlternativeBody(
            alternative: alternative,
            medicationId: widget.medicationId,
            alternativeId: widget.alternativeId,
            onSave: _onSave,
            isSaving: _isSaving,
          );
        },
      ),
    );
  }
}

class _EditAlternativeBody extends ConsumerWidget {
  final dynamic alternative;
  final int medicationId;
  final int alternativeId;
  final void Function(MedicationAlternativeFormData) onSave;
  final bool isSaving;

  const _EditAlternativeBody({
    required this.alternative,
    required this.medicationId,
    required this.alternativeId,
    required this.onSave,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final componentsAsync = ref.watch(
      medicationAlternativeComponentsProvider(alternativeId),
    );

    return componentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text(l10n.error)),
      data: (components) {
        final initialData =
            MedicationAlternativeFormData.fromAlternative(alternative);
        return MedicationAlternativeForm(
          initialData: initialData,
          existingComponents: components,
          onSave: onSave,
          isLoading: isSaving,
          saveButtonLabel: l10n.save,
        );
      },
    );
  }
}
