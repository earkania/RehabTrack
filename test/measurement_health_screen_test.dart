import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/presentation/utils/measurement_formatter.dart';
import 'package:rehab_track/presentation/utils/measurement_validator.dart';
import 'package:rehab_track/domain/entities/measurement.dart';

void main() {
  group('MeasurementFormatter integration', () {
    test('formats blood pressure correctly', () {
      final values = [
        MeasurementRecordValue(
          measurementRecordId: 1,
          fieldKey: 'systolic',
          numericValue: 120,
          unit: 'mmHg',
          displayOrder: 0,
        ),
        MeasurementRecordValue(
          measurementRecordId: 1,
          fieldKey: 'diastolic',
          numericValue: 80,
          unit: 'mmHg',
          displayOrder: 1,
        ),
      ];
      final fields = [
        MeasurementTypeField(
          measurementTypeId: 1,
          fieldKey: 'systolic',
          label: 'Systolic',
          displayOrder: 0,
          createdAt: DateTime(2024),
        ),
        MeasurementTypeField(
          measurementTypeId: 1,
          fieldKey: 'diastolic',
          label: 'Diastolic',
          displayOrder: 1,
          createdAt: DateTime(2024),
        ),
      ];
      final record = MeasurementRecord(
        profileId: 1,
        measurementTypeId: 1,
        timestamp: DateTime(2024),
        valuePrimary: 120,
        unit: 'mmHg',
        createdAt: DateTime(2024),
      );

      final result = MeasurementFormatter.formatRecord(
        record,
        fields,
        values,
      );

      expect(result, '120/80 mmHg');
    });

    test('validates blood pressure fields', () {
      final fields = [
        MeasurementTypeField(
          measurementTypeId: 1,
          fieldKey: 'systolic',
          label: 'Systolic',
          required: true,
          createdAt: DateTime(2024),
        ),
        MeasurementTypeField(
          measurementTypeId: 1,
          fieldKey: 'diastolic',
          label: 'Diastolic',
          required: true,
          createdAt: DateTime(2024),
        ),
      ];
      final values = {'systolic': '120', 'diastolic': '80'};

      final errors = MeasurementValidator.validateRecord(
        fields: fields,
        values: values,
      );

      expect(errors, isEmpty);
    });

    test('validates required fields', () {
      final fields = [
        MeasurementTypeField(
          measurementTypeId: 1,
          fieldKey: 'weight',
          label: 'Weight',
          required: true,
          createdAt: DateTime(2024),
        ),
      ];
      final values = <String, String>{};

      final errors = MeasurementValidator.validateRecord(
        fields: fields,
        values: values,
      );

      expect(errors, isNotEmpty);
    });
  });
}
