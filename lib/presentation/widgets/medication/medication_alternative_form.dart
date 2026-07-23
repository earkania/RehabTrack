import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rehab_track/domain/entities/medication_alternative.dart';
import 'package:rehab_track/l10n/app_localizations.dart';

class MedicationAlternativeFormData {
  String name;
  String doseAmount;
  String doseUnit;
  bool doctorApproved;
  String notes;

  MedicationAlternativeFormData({
    this.name = '',
    this.doseAmount = '',
    this.doseUnit = '',
    this.doctorApproved = false,
    this.notes = '',
  });

  factory MedicationAlternativeFormData.fromAlternative(
    MedicationAlternative alternative,
  ) {
    return MedicationAlternativeFormData(
      name: alternative.name,
      doseAmount: alternative.doseAmount ?? '',
      doseUnit: alternative.doseUnit ?? '',
      doctorApproved: alternative.doctorApproved,
      notes: alternative.notes ?? '',
    );
  }
}

class MedicationAlternativeForm extends StatefulWidget {
  final MedicationAlternativeFormData initialData;
  final ValueChanged<MedicationAlternativeFormData> onSave;
  final bool isLoading;
  final String saveButtonLabel;

  const MedicationAlternativeForm({
    super.key,
    required this.initialData,
    required this.onSave,
    this.isLoading = false,
    required this.saveButtonLabel,
  });

  @override
  State<MedicationAlternativeForm> createState() =>
      _MedicationAlternativeFormState();
}

class _MedicationAlternativeFormState extends State<MedicationAlternativeForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _doseAmountController;
  late final TextEditingController _doseUnitController;
  late final TextEditingController _notesController;
  late bool _doctorApproved;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _nameController = TextEditingController(text: d.name);
    _doseAmountController = TextEditingController(text: d.doseAmount);
    _doseUnitController = TextEditingController(text: d.doseUnit);
    _notesController = TextEditingController(text: d.notes);
    _doctorApproved = d.doctorApproved;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseAmountController.dispose();
    _doseUnitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(
      MedicationAlternativeFormData(
        name: _nameController.text.trim(),
        doseAmount: _doseAmountController.text.trim(),
        doseUnit: _doseUnitController.text.trim(),
        doctorApproved: _doctorApproved,
        notes: _notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.medicationName,
              border: const OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.nameRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _doseAmountController,
                  decoration: InputDecoration(
                    labelText: l10n.doseAmount,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      final num = double.tryParse(value.trim());
                      if (num == null || num <= 0) {
                        return l10n.invalidDose;
                      }
                    }
                    return null;
                  },
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
                  textCapitalization: TextCapitalization.none,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(l10n.doctorApproved),
            value: _doctorApproved,
            onChanged: (value) => setState(() => _doctorApproved = value),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: l10n.notes,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: widget.isLoading ? null : _save,
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.saveButtonLabel),
          ),
        ],
      ),
    );
  }
}
