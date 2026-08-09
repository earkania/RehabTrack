import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:rehab_track/domain/entities/doctor_prescription.dart';
import 'package:rehab_track/l10n/app_localizations.dart';

/// Editable list of medications belonging to a doctor prescription.
///
/// Used on the add/edit form. New and edited medications are surfaced through
/// [onChanged]; the caller persists them together with the prescription.
class DoctorPrescriptionMedicationsEditor extends StatefulWidget {
  const DoctorPrescriptionMedicationsEditor({
    super.key,
    this.initialMedications = const [],
    required this.onChanged,
  });

  final List<DoctorPrescriptionMedication> initialMedications;
  final ValueChanged<List<DoctorPrescriptionMedication>> onChanged;

  @override
  State<DoctorPrescriptionMedicationsEditor> createState() =>
      _DoctorPrescriptionMedicationsEditorState();
}

class _DoctorPrescriptionMedicationsEditorState
    extends State<DoctorPrescriptionMedicationsEditor> {
  late List<DoctorPrescriptionMedication> _medications;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _medications = List.of(widget.initialMedications);
  }

  @override
  void didUpdateWidget(covariant DoctorPrescriptionMedicationsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_dirty &&
        !listEquals(
            oldWidget.initialMedications, widget.initialMedications)) {
      _medications = List.of(widget.initialMedications);
    }
  }

  void _emit() => widget.onChanged(List.of(_medications));

  Future<void> _edit({DoctorPrescriptionMedication? medication}) async {
    final result = await showModalBottomSheet<DoctorPrescriptionMedication>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _MedicationEditorSheet(
        prescriptionId: medication?.prescriptionId ?? 0,
        profileId: medication?.profileId ?? 0,
        initial: medication,
      ),
    );
    if (result == null) return;
    setState(() {
      _dirty = true;
      if (medication != null) {
        final index = _medications.indexOf(medication);
        if (index >= 0) _medications[index] = result;
      } else {
        _medications.add(result);
      }
      _emit();
    });
  }

  Future<void> _remove(DoctorPrescriptionMedication medication) async {
    final confirmed = await _confirmRemove(medication);
    if (confirmed != true) return;
    setState(() {
      _dirty = true;
      _medications.removeWhere((m) => m.id == medication.id);
      _emit();
    });
  }

  Future<bool?> _confirmRemove(DoctorPrescriptionMedication medication) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeMedication),
        content: Text(medication.medicationName),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.medications,
              style: theme.textTheme.titleMedium,
            ),
            if (_medications.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                '(${_medications.length})',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (_medications.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              l10n.noMedicationsInPrescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ..._medications.map((m) => _MedicationTile(
                medication: m,
                onEdit: () => _edit(medication: m),
                onRemove: () => _remove(m),
              )),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => _edit(),
            icon: const Icon(Icons.add),
            label: Text(l10n.addMedication),
          ),
        ),
      ],
    );
  }
}

/// Read-only medication list for the details screen. Hidden when empty via
/// [isEmpty].
class DoctorPrescriptionMedicationsList extends StatelessWidget {
  const DoctorPrescriptionMedicationsList({
    super.key,
    required this.medications,
  });

  final List<DoctorPrescriptionMedication> medications;

  bool get isEmpty => medications.isEmpty;
  int get length => medications.length;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medicationsCount(medications.length),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...medications.map(
          (m) => _MedicationCard(medication: m),
        ),
      ],
    );
  }
}

class _MedicationTile extends StatelessWidget {
  const _MedicationTile({
    required this.medication,
    required this.onEdit,
    required this.onRemove,
  });

  final DoctorPrescriptionMedication medication;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final subtitle = _medicationSubtitle(medication);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.medication_outlined),
        title: Text(
          medication.medicationName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: subtitle.isEmpty
            ? null
            : Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
              onPressed: onEdit,
              tooltip: l10n.editMedication,
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              onPressed: onRemove,
              tooltip: l10n.removeMedication,
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  const _MedicationCard({required this.medication});

  final DoctorPrescriptionMedication medication;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = _medicationSubtitle(medication);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.medication_outlined),
        title: Text(medication.medicationName),
        subtitle: subtitle.isEmpty
            ? null
            : Text(
                subtitle,
                style: theme.textTheme.bodyMedium,
              ),
      ),
    );
  }
}

String _medicationSubtitle(DoctorPrescriptionMedication medication) {
  final parts = <String>[
    if (medication.doseAmount != null && medication.doseAmount!.trim().isNotEmpty)
      '${medication.doseAmount!.trim()}${medication.doseUnit ?? ''}'.trim(),
    if (medication.frequency != null && medication.frequency!.trim().isNotEmpty)
      medication.frequency!.trim(),
    if (medication.timing != null && medication.timing!.trim().isNotEmpty)
      medication.timing!.trim(),
    if (medication.duration != null && medication.duration!.trim().isNotEmpty)
      medication.duration!.trim(),
  ];
  return parts.join(' · ');
}

/// Bottom-sheet editor for a single prescription medication.
class _MedicationEditorSheet extends StatefulWidget {
  const _MedicationEditorSheet({
    required this.prescriptionId,
    required this.profileId,
    this.initial,
  });

  final int prescriptionId;
  final int profileId;
  final DoctorPrescriptionMedication? initial;

  @override
  State<_MedicationEditorSheet> createState() => _MedicationEditorSheetState();
}

class _MedicationEditorSheetState extends State<_MedicationEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _doseAmountController = TextEditingController();
  final _doseUnitController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _timingController = TextEditingController();
  final _durationController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.medicationName ?? '');
    _doseAmountController.text = initial?.doseAmount ?? '';
    _doseUnitController.text = initial?.doseUnit ?? '';
    _frequencyController.text = initial?.frequency ?? '';
    _timingController.text = initial?.timing ?? '';
    _durationController.text = initial?.duration ?? '';
    _instructionsController.text = initial?.instructions ?? '';
    _notesController.text = initial?.notes ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseAmountController.dispose();
    _doseUnitController.dispose();
    _frequencyController.dispose();
    _timingController.dispose();
    _durationController.dispose();
    _instructionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _trimmedOrNull(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final initial = widget.initial;
    final now = DateTime.now();
    final medication = DoctorPrescriptionMedication(
      id: initial?.id,
      prescriptionId: widget.prescriptionId,
      profileId: widget.profileId,
      medicationName: _nameController.text.trim(),
      doseAmount: _trimmedOrNull(_doseAmountController),
      doseUnit: _trimmedOrNull(_doseUnitController),
      frequency: _trimmedOrNull(_frequencyController),
      timing: _trimmedOrNull(_timingController),
      duration: _trimmedOrNull(_durationController),
      instructions: _trimmedOrNull(_instructionsController),
      notes: _trimmedOrNull(_notesController),
      sortOrder: initial?.sortOrder ?? 0,
      createdAt: initial?.createdAt ?? now,
      updatedAt: now,
    );
    Navigator.pop(context, medication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.initial == null
                    ? l10n.addMedication
                    : l10n.editMedication,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.medicationName,
                  hintText: l10n.medicationNameHint,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.medicationNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _doseAmountController,
                      decoration: InputDecoration(
                        labelText: l10n.doseAmount,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _doseUnitController,
                      decoration: InputDecoration(
                        labelText: l10n.doseUnit,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _frequencyController,
                decoration: InputDecoration(
                  labelText: l10n.frequency,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _timingController,
                decoration: InputDecoration(
                  labelText: l10n.timing,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(
                  labelText: l10n.duration,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _instructionsController,
                decoration: InputDecoration(
                  labelText: l10n.instructions,
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.medicationNotes,
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _save,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}