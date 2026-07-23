import 'package:flutter/material.dart';
import 'package:rehab_track/domain/entities/medication_alternative_component.dart';
import 'package:rehab_track/domain/entities/medication_component.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/theme/app_spacing.dart';

enum _EditorMode { medication, alternative }

class MedicationComponentsForm extends StatefulWidget {
  final List<MedicationComponent> medicationComponents;
  final List<MedicationAlternativeComponent> alternativeComponents;
  final ValueChanged<List<MedicationComponent>>? onMedicationComponentsChanged;
  final ValueChanged<List<MedicationAlternativeComponent>>?
      onAlternativeComponentsChanged;
  final bool isReadOnly;

  const MedicationComponentsForm({
    super.key,
    this.medicationComponents = const [],
    this.alternativeComponents = const [],
    this.onMedicationComponentsChanged,
    this.onAlternativeComponentsChanged,
    this.isReadOnly = false,
  });

  factory MedicationComponentsForm.forMedication({
    Key? key,
    required List<MedicationComponent> components,
    ValueChanged<List<MedicationComponent>>? onChanged,
    bool isReadOnly = false,
  }) {
    return MedicationComponentsForm(
      key: key,
      medicationComponents: components,
      onMedicationComponentsChanged: onChanged,
      isReadOnly: isReadOnly,
    );
  }

  factory MedicationComponentsForm.forAlternative({
    Key? key,
    required List<MedicationAlternativeComponent> components,
    ValueChanged<List<MedicationAlternativeComponent>>? onChanged,
    bool isReadOnly = false,
  }) {
    return MedicationComponentsForm(
      key: key,
      alternativeComponents: components,
      onAlternativeComponentsChanged: onChanged,
      isReadOnly: isReadOnly,
    );
  }

  @override
  MedicationComponentsFormState createState() =>
      MedicationComponentsFormState();
}

class MedicationComponentsFormState extends State<MedicationComponentsForm> {
  late List<_EditableComponent> _editableComponents;
  final Map<int, TextEditingController> _nameControllers = {};
  final Map<int, TextEditingController> _doseAmountControllers = {};
  final Map<int, TextEditingController> _doseUnitControllers = {};
  final Map<int, FocusNode> _focusNodes = {};

  int _nextLocalId = 0;

  _EditorMode get _mode => widget.medicationComponents.isNotEmpty ||
          widget.onMedicationComponentsChanged != null
      ? _EditorMode.medication
      : _EditorMode.alternative;

  @override
  void initState() {
    super.initState();
    _editableComponents = _mode == _EditorMode.medication
        ? widget.medicationComponents
            .map((c) => _EditableComponent(
                  localId: _nextLocalId++,
                  dbId: c.id,
                  name: c.componentName ?? '',
                  doseAmount: c.doseAmount,
                  doseUnit: c.doseUnit,
                  sortOrder: c.sortOrder,
                ))
            .toList()
        : widget.alternativeComponents
            .map((c) => _EditableComponent(
                  localId: _nextLocalId++,
                  dbId: c.id,
                  name: c.componentName ?? '',
                  doseAmount: c.doseAmount,
                  doseUnit: c.doseUnit,
                  sortOrder: c.sortOrder,
                ))
            .toList();
    if (_editableComponents.isEmpty) {
      _editableComponents.add(_EditableComponent(
        localId: _nextLocalId++,
        sortOrder: 0,
      ));
    }
    _createControllersForAll();
  }

  @override
  void dispose() {
    for (final c in _nameControllers.values) {
      c.dispose();
    }
    for (final c in _doseAmountControllers.values) {
      c.dispose();
    }
    for (final c in _doseUnitControllers.values) {
      c.dispose();
    }
    for (final fn in _focusNodes.values) {
      fn.dispose();
    }
    super.dispose();
  }

  void _createControllersForAll() {
    for (final ec in _editableComponents) {
      _createControllersFor(ec);
    }
  }

  void _createControllersFor(_EditableComponent ec) {
    _nameControllers[ec.localId] = TextEditingController(text: ec.name);
    _doseAmountControllers[ec.localId] =
        TextEditingController(text: ec.doseAmount);
    _doseUnitControllers[ec.localId] =
        TextEditingController(text: ec.doseUnit);
    _focusNodes[ec.localId] = FocusNode();
  }

  void _disposeControllersFor(_EditableComponent ec) {
    _nameControllers.remove(ec.localId)?.dispose();
    _doseAmountControllers.remove(ec.localId)?.dispose();
    _doseUnitControllers.remove(ec.localId)?.dispose();
    _focusNodes.remove(ec.localId)?.dispose();
  }

  void _notifyChanged() {
    if (_mode == _EditorMode.medication) {
      widget.onMedicationComponentsChanged?.call(
        _editableComponents
            .map((e) => MedicationComponent(
                  id: e.dbId,
                  medicationId: 0,
                  componentName: e.name.isEmpty ? null : e.name,
                  doseAmount: e.doseAmount,
                  doseUnit: e.doseUnit,
                  sortOrder: e.sortOrder,
                  createdAt: DateTime.now(),
                ))
            .toList(),
      );
    } else {
      widget.onAlternativeComponentsChanged?.call(
        _editableComponents
            .map((e) => MedicationAlternativeComponent(
                  id: e.dbId,
                  medicationAlternativeId: 0,
                  componentName: e.name.isEmpty ? null : e.name,
                  doseAmount: e.doseAmount,
                  doseUnit: e.doseUnit,
                  sortOrder: e.sortOrder,
                  createdAt: DateTime.now(),
                ))
            .toList(),
      );
    }
  }

  void _addComponent() {
    setState(() {
      _editableComponents.add(_EditableComponent(
        localId: _nextLocalId++,
        sortOrder: _editableComponents.length,
      ));
      _createControllersFor(_editableComponents.last);
    });
    _notifyChanged();
  }

  void _removeComponent(int index) {
    if (_editableComponents.length <= 1) return;
    final ec = _editableComponents[index];
    setState(() {
      _disposeControllersFor(ec);
      _editableComponents.removeAt(index);
      for (var i = 0; i < _editableComponents.length; i++) {
        _editableComponents[i].sortOrder = i;
      }
    });
    _notifyChanged();
  }

  List<String> validate(AppLocalizations l10n) {
    final errors = <String>[];
    for (var i = 0; i < _editableComponents.length; i++) {
      final c = _editableComponents[i];
      if (c.doseAmount.isEmpty) {
        errors.add('Component ${i + 1}: ${l10n.invalidDose}');
      }
    }
    return errors;
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
            Flexible(
              child: Text(
                l10n.dosageComponents,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            if (!widget.isReadOnly)
              TextButton.icon(
                onPressed: _addComponent,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.addComponent),
              ),
          ],
        ),
        AppSpacing.smH,
        ...List.generate(_editableComponents.length, (index) {
          return _buildComponentRow(context, index);
        }),
      ],
    );
  }

  Widget _buildComponentRow(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final component = _editableComponents[index];
    final nameController = _nameControllers[component.localId]!;
    final doseAmountController =
        _doseAmountControllers[component.localId]!;
    final doseUnitController = _doseUnitControllers[component.localId]!;

    return Padding(
      key: ValueKey(component.localId),
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: l10n.componentNameOptional,
              hintText: 'e.g. Paracetamol',
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              component.name = value;
              _notifyChanged();
            },
          ),
          AppSpacing.xsH,
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: doseAmountController,
                  decoration: InputDecoration(
                    labelText: l10n.doseAmount,
                    hintText: 'e.g. 10',
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    component.doseAmount = value;
                    _notifyChanged();
                  },
                ),
              ),
              AppSpacing.smW,
              Expanded(
                child: TextFormField(
                  controller: doseUnitController,
                  decoration: InputDecoration(
                    labelText: l10n.doseUnit,
                    hintText: 'mg',
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    component.doseUnit = value;
                    _notifyChanged();
                  },
                ),
              ),
              if (_editableComponents.length > 1) ...[
                AppSpacing.smW,
                IconButton(
                  onPressed: widget.isReadOnly
                      ? null
                      : () => _removeComponent(index),
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  tooltip: l10n.removeComponent,
                ),
              ] else
                const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditableComponent {
  final int localId;
  int? dbId;
  String name;
  String doseAmount;
  String doseUnit;
  int sortOrder;

  _EditableComponent({
    required this.localId,
    this.dbId,
    this.name = '',
    this.doseAmount = '',
    this.doseUnit = '',
    this.sortOrder = 0,
  });
}
