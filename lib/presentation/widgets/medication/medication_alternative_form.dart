import 'package:flutter/material.dart';
import 'package:rehab_track/domain/entities/medication_alternative.dart';
import 'package:rehab_track/domain/entities/medication_alternative_component.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/theme/app_spacing.dart';
import 'package:rehab_track/presentation/widgets/medication/medication_components_form.dart';

class MedicationAlternativeFormData {
  String name;
  List<MedicationAlternativeComponent> components;
  bool doctorApproved;
  String notes;

  MedicationAlternativeFormData({
    this.name = '',
    this.components = const [],
    this.doctorApproved = false,
    this.notes = '',
  });

  factory MedicationAlternativeFormData.fromAlternative(
    MedicationAlternative alternative,
  ) {
    return MedicationAlternativeFormData(
      name: alternative.name,
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
  final List<MedicationAlternativeComponent> existingComponents;

  const MedicationAlternativeForm({
    super.key,
    required this.initialData,
    required this.onSave,
    this.isLoading = false,
    required this.saveButtonLabel,
    this.existingComponents = const [],
  });

  @override
  State<MedicationAlternativeForm> createState() =>
      _MedicationAlternativeFormState();
}

class _MedicationAlternativeFormState extends State<MedicationAlternativeForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  late bool _doctorApproved;
  late List<MedicationAlternativeComponent> _components;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _nameController = TextEditingController(text: d.name);
    _notesController = TextEditingController(text: d.notes);
    _doctorApproved = d.doctorApproved;
    _components = List<MedicationAlternativeComponent>.from(
      widget.existingComponents.isNotEmpty
          ? widget.existingComponents
          : d.components,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(
      MedicationAlternativeFormData(
        name: _nameController.text.trim(),
        components: _components,
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
          AppSpacing.mdH,
          MedicationComponentsForm.forAlternative(
            components: _components,
            onChanged: (value) => setState(() => _components = value),
          ),
          AppSpacing.mdH,
          SwitchListTile(
            title: Text(l10n.doctorApproved),
            value: _doctorApproved,
            onChanged: (value) => setState(() => _doctorApproved = value),
            contentPadding: EdgeInsets.zero,
          ),
          AppSpacing.smH,
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
