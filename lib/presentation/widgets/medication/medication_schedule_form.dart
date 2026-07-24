import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rehab_track/domain/entities/dosage_form.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/domain/entities/schedule_config.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/utils/dosage_form_localizer.dart';
import 'package:rehab_track/presentation/widgets/common/date_field.dart';
import 'package:rehab_track/presentation/widgets/medication/schedule_type_selector.dart';
import 'package:rehab_track/presentation/widgets/medication/time_picker_field.dart';

class ScheduleFormData {
  ScheduleType scheduleType;
  List<String> times;
  int intervalDays;
  double intakeQuantity;
  DosageForm dosageForm;
  String customDosageForm;
  bool active;
  DateTime? startDate;
  DateTime? endDate;
  String instructions;

  ScheduleFormData({
    this.scheduleType = ScheduleType.daily,
    List<String>? times,
    this.intervalDays = 1,
    this.intakeQuantity = 1.0,
    this.dosageForm = DosageForm.tablet,
    this.customDosageForm = '',
    this.active = true,
    this.startDate,
    this.endDate,
    this.instructions = '',
  }) : times = times ?? ['08:00'];

  factory ScheduleFormData.fromSchedule(MedicationSchedule schedule) {
    final config = schedule.scheduleConfig;
    switch (config) {
      case DailySchedule(:final times):
        return ScheduleFormData(
          scheduleType: ScheduleType.daily,
          times: List<String>.from(times),
          intakeQuantity: schedule.intakeQuantity,
          dosageForm: schedule.dosageForm,
          customDosageForm: schedule.customDosageForm ?? '',
          active: schedule.active,
          startDate: schedule.startDate,
          endDate: schedule.endDate,
          instructions: schedule.instructions ?? '',
        );
      case IntervalDaysSchedule(:final intervalDays, :final times):
        return ScheduleFormData(
          scheduleType: ScheduleType.intervalDays,
          times: List<String>.from(times),
          intervalDays: intervalDays,
          intakeQuantity: schedule.intakeQuantity,
          dosageForm: schedule.dosageForm,
          customDosageForm: schedule.customDosageForm ?? '',
          active: schedule.active,
          startDate: schedule.startDate,
          endDate: schedule.endDate,
          instructions: schedule.instructions ?? '',
        );
    }
  }

  ScheduleConfig toScheduleConfig() {
    final sorted = List<String>.from(times)..sort();
    switch (scheduleType) {
      case ScheduleType.daily:
        return DailySchedule(times: sorted);
      case ScheduleType.intervalDays:
        return IntervalDaysSchedule(intervalDays: intervalDays, times: sorted);
    }
  }

  String get scheduleTypeString => switch (scheduleType) {
        ScheduleType.daily => 'daily',
        ScheduleType.intervalDays => 'interval_days',
      };
}

class MedicationScheduleForm extends StatefulWidget {
  final ScheduleFormData initialData;
  final ValueChanged<ScheduleFormData> onSave;
  final bool isLoading;
  final String saveButtonLabel;

  const MedicationScheduleForm({
    super.key,
    required this.initialData,
    required this.onSave,
    this.isLoading = false,
    required this.saveButtonLabel,
  });

  @override
  State<MedicationScheduleForm> createState() => _MedicationScheduleFormState();
}

class _MedicationScheduleFormState extends State<MedicationScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  late ScheduleType _scheduleType;
  late List<String> _times;
  late int _intervalDays;
  late DosageForm _dosageForm;
  late String _customDosageForm;
  late bool _active;
  DateTime? _startDate;
  DateTime? _endDate;
  late final TextEditingController _instructionsController;
  late final TextEditingController _quantityController;
  late final TextEditingController _customDosageController;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _scheduleType = d.scheduleType;
    _times = List<String>.from(d.times);
    _intervalDays = d.intervalDays;
    _dosageForm = d.dosageForm;
    _customDosageForm = d.customDosageForm;
    _active = d.active;
    _startDate = d.startDate;
    _endDate = d.endDate;
    _instructionsController = TextEditingController(text: d.instructions);
    _quantityController =
        TextEditingController(text: _formatQuantity(d.intakeQuantity));
    _customDosageController = TextEditingController(text: _customDosageForm);
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    _quantityController.dispose();
    _customDosageController.dispose();
    super.dispose();
  }

  String _formatQuantity(double qty) {
    if (qty == qty.roundToDouble()) return qty.toInt().toString();
    return qty.toString();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final customForm = _customDosageController.text.trim();
    final qty = double.tryParse(_quantityController.text.trim()) ?? 0;

    widget.onSave(
      ScheduleFormData(
        scheduleType: _scheduleType,
        times: List<String>.from(_times),
        intervalDays: _intervalDays,
        intakeQuantity: qty,
        dosageForm: _dosageForm,
        customDosageForm: _dosageForm == DosageForm.other ? customForm : '',
        active: _active,
        startDate: _startDate,
        endDate: _endDate,
        instructions: _instructionsController.text.trim(),
      ),
    );
  }

  void _applyInstructionChip(String value) {
    _instructionsController.text = value;
  }

  void _addTime() {
    final lastTime = _times.isNotEmpty ? _times.last : '08:00';
    setState(() => _times.add(lastTime));
  }

  void _removeTime(int index) {
    if (_times.length > 1) {
      setState(() => _times.removeAt(index));
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart ? (_startDate ?? now) : (_endDate ?? now);
    final firstDate = isStart ? DateTime(2000) : (_startDate ?? DateTime(2000));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: DateTime(2100),
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
          ScheduleTypeSelector(
            selectedType: _scheduleType,
            onChanged: (type) => setState(() => _scheduleType = type),
          ),
          const SizedBox(height: 24),
          _buildTimeSection(l10n),
          const SizedBox(height: 24),
          _buildIntakeQuantitySection(l10n),
          const SizedBox(height: 24),
          _buildDosageFormSection(l10n),
          const SizedBox(height: 24),
          Text(
            l10n.instructions,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _instructionsController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 8),
          _buildInstructionChips(l10n),
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

  Widget _buildTimeSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectTime,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...List.generate(_times.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TimePickerField(
              time: _times[index],
              onTimeSelected: (time) {
                setState(() => _times[index] = time);
              },
              onRemove: _times.length > 1
                  ? () => _removeTime(index)
                  : null,
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: _addTime,
          icon: const Icon(Icons.add, size: 18),
          label: Text(l10n.addTime),
        ),
      ],
    );
  }

  Widget _buildIntakeQuantitySection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.intakeQuantity,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _quantityController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}$')),
                ],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: '1',
                  suffixText: l10n.perIntake,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.invalidIntakeQuantity;
                  }
                  final qty = double.tryParse(value.trim());
                  if (qty == null || qty <= 0) {
                    return l10n.invalidIntakeQuantity;
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: ['0.25', '0.5', '1', '1.5', '2'].map((qty) {
            return ActionChip(
              label: Text(qty, style: const TextStyle(fontSize: 12)),
              onPressed: () {
                setState(() {
                  _quantityController.text = qty;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDosageFormSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dosageForm,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<DosageForm>(
          initialValue: _dosageForm,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: DosageForm.values.map((form) {
            return DropdownMenuItem(
              value: form,
              child: Text(DosageFormLocalizer.localize(form, l10n)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _dosageForm = value);
            }
          },
        ),
        if (_dosageForm == DosageForm.other) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _customDosageController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: l10n.customDosageForm,
            ),
            validator: (value) {
              if (_dosageForm == DosageForm.other) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.customDosageFormRequired;
                }
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildInstructionChips(AppLocalizations l10n) {
    final chips = [
      l10n.beforeMeal,
      l10n.afterMeal,
      l10n.withMeal,
      l10n.emptyStomach,
      l10n.beforeBedtime,
      l10n.morningOnly,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: chips.map((label) {
        return ActionChip(
          label: Text(label, style: const TextStyle(fontSize: 12)),
          onPressed: () => _applyInstructionChip(label),
        );
      }).toList(),
    );
  }
}
