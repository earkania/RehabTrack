import 'package:rehab_track/domain/entities/blood_pressure_component_status.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/domain/services/reading_status_calculator.dart';

class BloodPressureStatusEvaluator {
  BloodPressureStatusEvaluator._();

  static BloodPressureComponentStatus evaluate({
    required Map<String, double> fieldValues,
    required MeasurementRanges ranges,
  }) {
    final overall = ReadingStatusCalculator.calculate(
      typeKey: 'blood_pressure',
      fieldValues: fieldValues,
      ranges: ranges,
    );

    final sysStatus = _evaluateField(
      fieldKey: 'systolic',
      fieldValues: fieldValues,
      ranges: ranges,
    );

    final diaStatus = _evaluateField(
      fieldKey: 'diastolic',
      fieldValues: fieldValues,
      ranges: ranges,
    );

    final pulseVal = fieldValues['pulse'];
    final pulseStatus = pulseVal != null
        ? _evaluateField(
            fieldKey: 'pulse',
            fieldValues: fieldValues,
            ranges: ranges,
          )
        : null;

    return BloodPressureComponentStatus(
      overallStatus: overall,
      systolicStatus: sysStatus,
      diastolicStatus: diaStatus,
      pulseStatus: pulseStatus,
    );
  }

  static ReadingStatus _evaluateField({
    required String fieldKey,
    required Map<String, double> fieldValues,
    required MeasurementRanges ranges,
  }) {
    return ReadingStatusCalculator.calculateFieldValue(
      fieldKey: fieldKey,
      value: fieldValues[fieldKey],
      ranges: ranges,
    );
  }
}
