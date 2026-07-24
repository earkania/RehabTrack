import 'package:rehab_track/domain/entities/measurement.dart';

class MeasurementFormatter {
  MeasurementFormatter._();

  static String formatRecord(
    MeasurementRecord record,
    List<MeasurementTypeField> fields,
    List<MeasurementRecordValue> values, {
    String pulseLabel = 'pulse',
  }) {
    final valueMap = <String, MeasurementRecordValue>{};
    for (final v in values) {
      valueMap[v.fieldKey] = v;
    }

    final orderedFields =
        List<MeasurementTypeField>.from(fields)
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    final key = _detectTypeKey(record, orderedFields);
    return switch (key) {
      'blood_pressure' => _formatBloodPressure(valueMap, pulseLabel: pulseLabel),
      'pulse' => _formatPulse(valueMap),
      'weight' => _formatWeight(valueMap),
      'blood_glucose' => _formatBloodGlucose(valueMap),
      'spo2' => _formatSpO2(valueMap, pulseLabel: pulseLabel),
      'temperature' => _formatTemperature(valueMap),
      _ => _formatGeneric(orderedFields, valueMap),
    };
  }

  static String formatRecordSummary(
    MeasurementType type,
    List<MeasurementTypeField> fields,
    List<MeasurementRecordValue> values, {
    String pulseLabel = 'pulse',
  }) {
    final valueMap = <String, MeasurementRecordValue>{};
    for (final v in values) {
      valueMap[v.fieldKey] = v;
    }

    final key = type.key;
    return switch (key) {
      'blood_pressure' => _formatBloodPressure(valueMap, pulseLabel: pulseLabel),
      'pulse' => _formatPulse(valueMap),
      'weight' => _formatWeight(valueMap),
      'blood_glucose' => _formatBloodGlucose(valueMap),
      'spo2' => _formatSpO2(valueMap, pulseLabel: pulseLabel),
      'temperature' => _formatTemperature(valueMap),
      _ => _formatGeneric(fields, valueMap),
    };
  }

  static String formatFieldValue(
    MeasurementTypeField field,
    MeasurementRecordValue value,
  ) {
    final formatted = _formatNumber(value.numericValue, field.decimalPlaces);
    return '$formatted ${value.unit}';
  }

  static String formatFieldValueByKey(
    String fieldKey,
    double numericValue,
    String unit,
    int decimalPlaces,
  ) {
    final formatted = _formatNumber(numericValue, decimalPlaces);
    return '$formatted $unit';
  }

  static String _formatBloodPressure(
    Map<String, MeasurementRecordValue> values, {
    String pulseLabel = 'pulse',
  }) {
    final sys = values['systolic'];
    final dia = values['diastolic'];
    final pulse = values['pulse'];

    if (sys == null || dia == null) return '--/--';

    final sysStr = _formatNumber(sys.numericValue, 0);
    final diaStr = _formatNumber(dia.numericValue, 0);
    final unit = sys.unit;
    final result = '$sysStr/$diaStr $unit';

    if (pulse != null) {
      final pulseStr = _formatNumber(pulse.numericValue, 0);
      return '$result, $pulseLabel $pulseStr ${pulse.unit}';
    }
    return result;
  }

  static String _formatPulse(
    Map<String, MeasurementRecordValue> values,
  ) {
    final pulse = values['pulse'];
    if (pulse == null) return '-- bpm';
    final formatted = _formatNumber(pulse.numericValue, 0);
    return '$formatted bpm';
  }

  static String _formatWeight(
    Map<String, MeasurementRecordValue> values,
  ) {
    final weight = values['weight'];
    if (weight == null) return '--';
    final formatted = _formatNumber(weight.numericValue, 1);
    return '$formatted ${weight.unit}';
  }

  static String _formatBloodGlucose(
    Map<String, MeasurementRecordValue> values,
  ) {
    final glucose = values['glucose'];
    if (glucose == null) return '--';
    final formatted = _formatNumber(glucose.numericValue, 1);
    return '$formatted ${glucose.unit}';
  }

  static String _formatSpO2(
    Map<String, MeasurementRecordValue> values, {
    String pulseLabel = 'pulse',
  }) {
    final spo2 = values['spo2'];
    final pulse = values['pulse'];
    if (spo2 == null) return '--%';
    final formatted = _formatNumber(spo2.numericValue, 0);
    final result = '$formatted%';
    if (pulse != null) {
      final pulseStr = _formatNumber(pulse.numericValue, 0);
      return '$result, $pulseLabel $pulseStr ${pulse.unit}';
    }
    return result;
  }

  static String _formatTemperature(
    Map<String, MeasurementRecordValue> values,
  ) {
    final temp = values['temperature'];
    if (temp == null) return '--';
    final formatted = _formatNumber(temp.numericValue, 1);
    return '$formatted ${temp.unit}';
  }

  static String _formatGeneric(
    List<MeasurementTypeField> fields,
    Map<String, MeasurementRecordValue> values,
  ) {
    final parts = <String>[];
    for (final field in fields) {
      final value = values[field.fieldKey];
      if (value == null) continue;
      final formatted =
          _formatNumber(value.numericValue, field.decimalPlaces);
      parts.add('$formatted ${value.unit}');
    }
    return parts.isEmpty ? '--' : parts.join(', ');
  }

  static String _detectTypeKey(
    MeasurementRecord record,
    List<MeasurementTypeField> fields,
  ) {
    final keys = fields.map((f) => f.fieldKey).toSet();
    if (keys.contains('systolic') && keys.contains('diastolic')) {
      return 'blood_pressure';
    }
    if (keys.contains('spo2')) return 'spo2';
    if (keys.contains('glucose')) return 'blood_glucose';
    if (keys.contains('weight')) return 'weight';
    if (keys.contains('temperature')) return 'temperature';
    if (keys.contains('pulse')) return 'pulse';
    return 'unknown';
  }

  static String _formatNumber(double value, int decimals) {
    if (decimals == 0) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(decimals);
  }
}
