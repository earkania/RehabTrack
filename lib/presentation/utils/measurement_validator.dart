import 'package:rehab_track/domain/entities/measurement.dart';

class MeasurementValidator {
  MeasurementValidator._();

  static List<String> validateRecord({
    required List<MeasurementTypeField> fields,
    required Map<String, String> values,
  }) {
    final errors = <String>[];

    for (final field in fields) {
      final raw = values[field.fieldKey];
      if (field.required && (raw == null || raw.trim().isEmpty)) {
        errors.add('${field.label} is required');
        continue;
      }
      if (raw == null || raw.trim().isEmpty) continue;

      final parsed = double.tryParse(raw.trim());
      if (parsed == null) {
        errors.add('${field.label} must be a valid number');
        continue;
      }

      if (field.minimumValue != null && parsed < field.minimumValue!) {
        errors.add(
          '${field.label} must be at least ${_fmt(field.minimumValue!, field.decimalPlaces)}',
        );
      }
      if (field.maximumValue != null && parsed > field.maximumValue!) {
        errors.add(
          '${field.label} must be at most ${_fmt(field.maximumValue!, field.decimalPlaces)}',
        );
      }
    }

    final sysRaw = values['systolic'];
    final diaRaw = values['diastolic'];
    if (sysRaw != null && diaRaw != null) {
      final sys = double.tryParse(sysRaw.trim());
      final dia = double.tryParse(diaRaw.trim());
      if (sys != null && dia != null && sys <= dia) {
        errors.add('Systolic should be greater than diastolic');
      }
    }

    return errors;
  }

  static String? validateField(MeasurementTypeField field, String? raw) {
    if (field.required && (raw == null || raw.trim().isEmpty)) {
      return '${field.label} is required';
    }
    if (raw == null || raw.trim().isEmpty) return null;

    final parsed = double.tryParse(raw.trim());
    if (parsed == null) {
      return '${field.label} must be a valid number';
    }

    if (field.minimumValue != null && parsed < field.minimumValue!) {
      return '${field.label} must be at least ${_fmt(field.minimumValue!, field.decimalPlaces)}';
    }
    if (field.maximumValue != null && parsed > field.maximumValue!) {
      return '${field.label} must be at most ${_fmt(field.maximumValue!, field.decimalPlaces)}';
    }

    return null;
  }

  static bool hasRequiredValues({
    required List<MeasurementTypeField> fields,
    required Map<String, String> values,
  }) {
    for (final field in fields) {
      if (field.required) {
        final raw = values[field.fieldKey];
        if (raw == null || raw.trim().isEmpty) return false;
      }
    }
    return true;
  }

  static String _fmt(double value, int decimals) {
    if (decimals == 0) return value.toInt().toString();
    return value.toStringAsFixed(decimals);
  }
}
