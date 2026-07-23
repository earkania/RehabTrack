import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/widgets/common/date_field.dart';

class MedicationFormData {
  String name;
  String description;
  String doseAmount;
  String doseUnit;
  bool active;
  DateTime? startDate;
  DateTime? endDate;
  String notes;

  MedicationFormData({
    this.name = '',
    this.description = '',
    this.doseAmount = '',
    this.doseUnit = '',
    this.active = true,
    this.startDate,
    this.endDate,
    this.notes = '',
  });

  factory MedicationFormData.fromMedication(Medication m) {
    return MedicationFormData(
      name: m.name,
      description: m.description ?? '',
      doseAmount: m.doseAmount ?? '',
      doseUnit: m.doseUnit ?? '',
      active: m.active,
      startDate: m.startDate,
      endDate: m.endDate,
      notes: m.notes ?? '',
    );
  }
}

class MedicationForm extends StatefulWidget {
  final MedicationFormData initialData;
  final ValueChanged<MedicationFormData> onSave;
  final bool isLoading;
  final String saveButtonLabel;

  const MedicationForm({
    super.key,
    required this.initialData,
    required this.onSave,
    this.isLoading = false,
    required this.saveButtonLabel,
  });

  @override
  State<MedicationForm> createState() => _MedicationFormState();
}

class _MedicationFormState extends State<MedicationForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _doseAmountController;
  late final TextEditingController _doseUnitController;
  late final TextEditingController _notesController;
  late bool _active;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _nameController = TextEditingController(text: d.name);
    _descriptionController = TextEditingController(text: d.description);
    _doseAmountController = TextEditingController(text: d.doseAmount);
    _doseUnitController = TextEditingController(text: d.doseUnit);
    _notesController = TextEditingController(text: d.notes);
    _active = d.active;
    _startDate = d.startDate;
    _endDate = d.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _doseAmountController.dispose();
    _doseUnitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(
      MedicationFormData(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        doseAmount: _doseAmountController.text.trim(),
        doseUnit: _doseUnitController.text.trim(),
        active: _active,
        startDate: _startDate,
        endDate: _endDate,
        notes: _notesController.text.trim(),
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart ? (_startDate ?? now) : (_endDate ?? now);
    final firstDate =
        isStart ? DateTime(2000) : (_startDate ?? DateTime(2000));
    final lastDate = DateTime(2100);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
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
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: l10n.description,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
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
            title: Text(l10n.active),
            value: _active,
            onChanged: (value) => setState(() => _active = value),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DateField(
                  label: l10n.startDate,
                  date: _startDate,
                  onTap: () => _pickDate(isStart: true),
                  onClear: () => setState(() => _startDate = null),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DateField(
                  label: l10n.endDate,
                  date: _endDate,
                  onTap: () => _pickDate(isStart: false),
                  onClear: () => setState(() => _endDate = null),
                ),
              ),
            ],
          ),
          if (_endDate != null &&
              _startDate != null &&
              _endDate!.isBefore(_startDate!))
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.endDateBeforeStartDate,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 16),
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
