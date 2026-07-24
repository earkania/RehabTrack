import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/measurement_provider.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/theme/app_spacing.dart';
import 'package:rehab_track/presentation/utils/measurement_localizer.dart';
import 'package:rehab_track/presentation/utils/measurement_validator.dart';

class MeasurementEditScreen extends ConsumerStatefulWidget {
  final int recordId;

  const MeasurementEditScreen({
    super.key,
    required this.recordId,
  });

  @override
  ConsumerState<MeasurementEditScreen> createState() =>
      _MeasurementEditScreenState();
}

class _MeasurementEditScreenState
    extends ConsumerState<MeasurementEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _controllers = <String, TextEditingController>{};
  final _focusNodes = <String, FocusNode>{};
  DateTime _measuredAt = DateTime.now();
  bool _isSaving = false;
  bool _initialized = false;
  MeasurementRecord? _record;

  @override
  void dispose() {
    _notesController.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final f in _focusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recordAsync = ref.watch(
      measurementRecordProvider(widget.recordId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editMeasurement),
      ),
      body: recordAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.error)),
        data: (record) {
          if (record == null) return Center(child: Text(l10n.error));
          _record = record;

          final typeAsync = ref.watch(
            measurementTypeProvider(record.measurementTypeId),
          );
          final fieldsAsync = ref.watch(
            measurementTypeFieldsProvider(record.measurementTypeId),
          );
          final valuesAsync = ref.watch(
            measurementRecordValuesProvider(record.id!),
          );

          return typeAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.error)),
            data: (type) {
              if (type == null) return Center(child: Text(l10n.error));

              return fieldsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Center(child: Text(l10n.error)),
                data: (fields) {
                  return valuesAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, _) => Center(child: Text(l10n.error)),
                    data: (values) {
                      _ensureControllers(fields, record, values);
                      return _buildForm(
                        context,
                        l10n,
                        type,
                        fields,
                        values,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _ensureControllers(
    List<MeasurementTypeField> fields,
    MeasurementRecord record,
    List<MeasurementRecordValue> values,
  ) {
    if (_initialized) return;
    _initialized = true;

    _measuredAt = record.timestamp;
    _notesController.text = record.notes ?? '';

    final valueMap = <String, MeasurementRecordValue>{};
    for (final v in values) {
      valueMap[v.fieldKey] = v;
    }

    for (final field in fields) {
      final existing = valueMap[field.fieldKey];
      _controllers[field.fieldKey] = TextEditingController(
        text: existing != null
            ? _valueString(field, existing)
            : '',
      );
      _focusNodes[field.fieldKey] = FocusNode();
    }
  }

  String _valueString(
    MeasurementTypeField field,
    MeasurementRecordValue value,
  ) {
    if (field.decimalPlaces == 0) {
      return value.numericValue.toInt().toString();
    }
    return value.numericValue.toStringAsFixed(field.decimalPlaces);
  }

  Widget _buildForm(
    BuildContext context,
    AppLocalizations l10n,
    MeasurementType type,
    List<MeasurementTypeField> fields,
    List<MeasurementRecordValue> values,
  ) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            MeasurementLocalizer.typeName(l10n, type.key),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          AppSpacing.lgH,
          ...fields.map((field) => _buildField(field, l10n)),
          AppSpacing.mdH,
          _buildDateTimeField(context, l10n),
          AppSpacing.mdH,
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: l10n.notes,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          AppSpacing.lgH,
          FilledButton(
            onPressed:
                _isSaving ? null : () => _save(context, l10n, type, fields),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Widget _buildField(MeasurementTypeField field, AppLocalizations l10n) {
    final controller = _controllers[field.fieldKey]!;
    final label = MeasurementLocalizer.fieldName(l10n, field.fieldKey);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        controller: controller,
        focusNode: _focusNodes[field.fieldKey],
        decoration: InputDecoration(
          labelText: '$label (${field.defaultUnit ?? ''})',
          border: const OutlineInputBorder(),
          suffixText: field.defaultUnit,
        ),
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        validator: (value) =>
            MeasurementValidator.validateField(field, value),
      ),
    );
  }

  Widget _buildDateTimeField(BuildContext context, AppLocalizations l10n) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today),
      title: Text(
        '${_measuredAt.day}.${_measuredAt.month}.${_measuredAt.year} '
        '${_measuredAt.hour.toString().padLeft(2, '0')}:${_measuredAt.minute.toString().padLeft(2, '0')}',
      ),
      subtitle: Text(l10n.measuredAt),
      trailing: const Icon(Icons.edit_calendar),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _measuredAt,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null && context.mounted) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(_measuredAt),
          );
          setState(() {
            _measuredAt = DateTime(
              date.year,
              date.month,
              date.day,
              time?.hour ?? _measuredAt.hour,
              time?.minute ?? _measuredAt.minute,
            );
          });
        }
      },
    );
  }

  Future<void> _save(
    BuildContext context,
    AppLocalizations l10n,
    MeasurementType type,
    List<MeasurementTypeField> fields,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final record = _record!;
      final values = <MeasurementRecordValue>[];
      double? primaryValue;
      String primaryUnit = type.unit;

      for (final field in fields) {
        final raw = _controllers[field.fieldKey]!.text.trim();
        if (raw.isEmpty) continue;
        final numericValue = double.parse(raw);
        final unit = field.defaultUnit ?? type.unit;
        if (primaryValue == null) {
          primaryValue = numericValue;
          primaryUnit = unit;
        }
        values.add(MeasurementRecordValue(
          measurementRecordId: record.id!,
          fieldKey: field.fieldKey,
          numericValue: numericValue,
          unit: unit,
          displayOrder: field.displayOrder,
        ));
      }

      if (primaryValue == null) return;

      final updatedRecord = record.copyWith(
        timestamp: _measuredAt,
        valuePrimary: primaryValue,
        unit: primaryUnit,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        updatedAt: DateTime.now(),
      );

      final repo = ref.read(measurementRepositoryProvider);
      await repo.updateRecord(updatedRecord, values);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.measurementUpdated)),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToSaveMeasurement)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
