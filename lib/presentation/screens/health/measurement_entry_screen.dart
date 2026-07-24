import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/measurement_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/theme/app_spacing.dart';
import 'package:rehab_track/presentation/utils/measurement_localizer.dart';
import 'package:rehab_track/presentation/utils/measurement_validator.dart';

class MeasurementEntryScreen extends ConsumerStatefulWidget {
  final int measurementTypeId;

  const MeasurementEntryScreen({
    super.key,
    required this.measurementTypeId,
  });

  @override
  ConsumerState<MeasurementEntryScreen> createState() =>
      _MeasurementEntryScreenState();
}

class _MeasurementEntryScreenState
    extends ConsumerState<MeasurementEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _controllers = <String, TextEditingController>{};
  final _focusNodes = <String, FocusNode>{};
  DateTime _measuredAt = DateTime.now();
  bool _isSaving = false;
  bool _initialized = false;

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
    final typeId = widget.measurementTypeId;
    final typeAsync = ref.watch(measurementTypeProvider(typeId));
    final fieldsAsync = ref.watch(measurementTypeFieldsProvider(typeId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addMeasurement),
      ),
      body: typeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.error),
              AppSpacing.smH,
              FilledButton.tonal(
                onPressed: () => context.pop(),
                child: Text(l10n.back),
              ),
            ],
          ),
        ),
        data: (type) {
          if (type == null) {
            return Center(child: Text(l10n.error));
          }
          return fieldsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.error)),
            data: (fields) {
              _ensureControllers(fields);
              return _buildForm(context, l10n, type, fields);
            },
          );
        },
      ),
    );
  }

  void _ensureControllers(List<MeasurementTypeField> fields) {
    if (_initialized) return;
    for (final field in fields) {
      _controllers[field.fieldKey] = TextEditingController();
      _focusNodes[field.fieldKey] = FocusNode();
    }
    _initialized = true;
  }

  Widget _buildForm(
    BuildContext context,
    AppLocalizations l10n,
    MeasurementType type,
    List<MeasurementTypeField> fields,
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
            onPressed: _isSaving ? null : () => _save(context, l10n, type, fields),
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
        validator: (value) => MeasurementValidator.validateField(field, value),
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
      final profileId = ref.read(activeProfileIdProvider);
      if (profileId == null) return;

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
          measurementRecordId: 0,
          fieldKey: field.fieldKey,
          numericValue: numericValue,
          unit: unit,
          displayOrder: field.displayOrder,
        ));
      }

      if (primaryValue == null) return;

      final record = MeasurementRecord(
        profileId: profileId,
        measurementTypeId: type.id!,
        timestamp: _measuredAt,
        valuePrimary: primaryValue,
        unit: primaryUnit,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      final repo = ref.read(measurementRepositoryProvider);
      await repo.createRecord(record, values);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.measurementAdded)),
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
