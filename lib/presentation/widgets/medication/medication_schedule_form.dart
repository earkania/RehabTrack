import 'package:flutter/material.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/domain/entities/schedule_config.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/widgets/medication/schedule_type_selector.dart';
import 'package:rehab_track/presentation/widgets/medication/time_picker_field.dart';

class ScheduleFormData {
  ScheduleType scheduleType;
  String dailyTime;
  List<String> fixedTimes;
  int intervalDays;
  String intervalTime;
  bool active;
  DateTime? startDate;
  DateTime? endDate;
  String instructions;

  ScheduleFormData({
    this.scheduleType = ScheduleType.daily,
    this.dailyTime = '08:00',
    List<String>? fixedTimes,
    this.intervalDays = 1,
    this.intervalTime = '08:00',
    this.active = true,
    this.startDate,
    this.endDate,
    this.instructions = '',
  }) : fixedTimes = fixedTimes ?? ['08:00'];

  factory ScheduleFormData.fromSchedule(MedicationSchedule schedule) {
    final config = schedule.scheduleConfig;
    switch (config) {
      case DailySchedule(:final time):
        return ScheduleFormData(
          scheduleType: ScheduleType.daily,
          dailyTime: time,
          active: schedule.active,
          startDate: schedule.startDate,
          endDate: schedule.endDate,
          instructions: schedule.instructions ?? '',
        );
      case FixedTimesSchedule(:final times):
        return ScheduleFormData(
          scheduleType: ScheduleType.fixedTimes,
          fixedTimes: List<String>.from(times),
          active: schedule.active,
          startDate: schedule.startDate,
          endDate: schedule.endDate,
          instructions: schedule.instructions ?? '',
        );
      case IntervalDaysSchedule(:final interval, :final time):
        return ScheduleFormData(
          scheduleType: ScheduleType.intervalDays,
          intervalDays: interval,
          intervalTime: time,
          active: schedule.active,
          startDate: schedule.startDate,
          endDate: schedule.endDate,
          instructions: schedule.instructions ?? '',
        );
    }
  }

  ScheduleConfig toScheduleConfig() {
    switch (scheduleType) {
      case ScheduleType.daily:
        return DailySchedule(time: dailyTime);
      case ScheduleType.fixedTimes:
        final sorted = List<String>.from(fixedTimes)
          ..sort((a, b) => a.compareTo(b));
        return FixedTimesSchedule(times: sorted);
      case ScheduleType.intervalDays:
        return IntervalDaysSchedule(interval: intervalDays, time: intervalTime);
    }
  }

  String get scheduleTypeString => switch (scheduleType) {
        ScheduleType.daily => 'daily',
        ScheduleType.fixedTimes => 'fixed_times',
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
  late String _dailyTime;
  late List<String> _fixedTimes;
  late int _intervalDays;
  late String _intervalTime;
  late bool _active;
  DateTime? _startDate;
  DateTime? _endDate;
  late final TextEditingController _instructionsController;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _scheduleType = d.scheduleType;
    _dailyTime = d.dailyTime;
    _fixedTimes = List<String>.from(d.fixedTimes);
    _intervalDays = d.intervalDays;
    _intervalTime = d.intervalTime;
    _active = d.active;
    _startDate = d.startDate;
    _endDate = d.endDate;
    _instructionsController = TextEditingController(text: d.instructions);
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(
      ScheduleFormData(
        scheduleType: _scheduleType,
        dailyTime: _dailyTime,
        fixedTimes: _fixedTimes,
        intervalDays: _intervalDays,
        intervalTime: _intervalTime,
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
                child: _DateField(
                  label: l10n.startDate,
                  date: _startDate,
                  onTap: () => _pickDate(isStart: true),
                  onClear: () => setState(() => _startDate = null),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateField(
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
                '${l10n.endDate} >= ${l10n.startDate}',
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
    switch (_scheduleType) {
      case ScheduleType.daily:
        return _buildDailySection(l10n);
      case ScheduleType.fixedTimes:
        return _buildFixedTimesSection(l10n);
      case ScheduleType.intervalDays:
        return _buildIntervalSection(l10n);
    }
  }

  Widget _buildDailySection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectTime,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TimePickerField(
          time: _dailyTime,
          onTimeSelected: (time) => setState(() => _dailyTime = time),
        ),
      ],
    );
  }

  Widget _buildFixedTimesSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectTime,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...List.generate(_fixedTimes.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TimePickerField(
              time: _fixedTimes[index],
              onTimeSelected: (time) {
                setState(() => _fixedTimes[index] = time);
              },
              onRemove: _fixedTimes.length > 1
                  ? () => setState(() => _fixedTimes.removeAt(index))
                  : null,
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: () {
            final lastTime = _fixedTimes.isNotEmpty ? _fixedTimes.last : '08:00';
            setState(() => _fixedTimes.add(lastTime));
          },
          icon: const Icon(Icons.add, size: 18),
          label: Text(l10n.addTime),
        ),
      ],
    );
  }

  Widget _buildIntervalSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.intervalDays,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('${l10n.intervalDays.split('(').first.trim()}: '),
            Expanded(
              child: Slider(
                value: _intervalDays.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                label: _intervalDays.toString(),
                onChanged: (value) {
                  setState(() => _intervalDays = value.round());
                },
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(
                _intervalDays.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(' ${l10n.days}'),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          l10n.selectTime,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TimePickerField(
          time: _intervalTime,
          onTimeSelected: (time) => setState(() => _intervalTime = time),
        ),
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

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayText = date != null
        ? '${date!.day.toString().padLeft(2, '0')}.${date!.month.toString().padLeft(2, '0')}.${date!.year}'
        : label;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: date != null && onClear != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: onClear,
                )
              : const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          displayText,
          style: TextStyle(
            color: date != null ? null : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
