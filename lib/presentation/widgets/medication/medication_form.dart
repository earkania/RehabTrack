import 'package:flutter/material.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/domain/entities/medication_component.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/theme/app_spacing.dart';
import 'package:rehab_track/presentation/widgets/common/date_field.dart';
import 'package:rehab_track/presentation/widgets/medication/medication_components_form.dart';

class MedicationFormData {
  String name;
  String description;
  List<MedicationComponent> components;
  bool active;
  DateTime? startDate;
  DateTime? endDate;
  String notes;

  MedicationFormData({
    this.name = '',
    this.description = '',
    this.components = const [],
    this.active = true,
    this.startDate,
    this.endDate,
    this.notes = '',
  });

  factory MedicationFormData.fromMedication(Medication m) {
    return MedicationFormData(
      name: m.name,
      description: m.description ?? '',
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
  final List<MedicationComponent> existingComponents;

  const MedicationForm({
    super.key,
    required this.initialData,
    required this.onSave,
    this.isLoading = false,
    required this.saveButtonLabel,
    this.existingComponents = const [],
  });

  @override
  State<MedicationForm> createState() => _MedicationFormState();
}

class _MedicationFormState extends State<MedicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _componentsFormKey = GlobalKey<MedicationComponentsFormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _notesController;
  late bool _active;
  DateTime? _startDate;
  DateTime? _endDate;
  late List<MedicationComponent> _components;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _nameController = TextEditingController(text: d.name);
    _descriptionController = TextEditingController(text: d.description);
    _notesController = TextEditingController(text: d.notes);
    _active = d.active;
    _startDate = d.startDate;
    _endDate = d.endDate;
    _components = List<MedicationComponent>.from(
      widget.existingComponents.isNotEmpty
          ? widget.existingComponents
          : d.components,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(
      MedicationFormData(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        components: _components,
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
          AppSpacing.mdH,
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: l10n.description,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
          ),
          AppSpacing.mdH,
          MedicationComponentsForm.forMedication(
            key: _componentsFormKey,
            components: _components,
            onChanged: (value) => setState(() => _components = value),
          ),
          AppSpacing.mdH,
          SwitchListTile(
            title: Text(l10n.active),
            value: _active,
            onChanged: (value) => setState(() => _active = value),
            contentPadding: EdgeInsets.zero,
          ),
          AppSpacing.smH,
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
              AppSpacing.mdW,
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
          AppSpacing.mdH,
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: l10n.notes,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          AppSpacing.lgH,
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
