import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/presentation/utils/measurement_validator.dart';

void main() {
  group('MeasurementValidator', () {
    group('required fields', () {
      test('returns error for missing required field', () {
        final fields = [
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'systolic',
            label: 'Systolic',
            required: true,
            createdAt: DateTime(2024),
          ),
        ];
        final values = <String, String>{};

        final errors = MeasurementValidator.validateRecord(
          fields: fields,
          values: values,
        );

        expect(errors, contains('Systolic is required'));
      });

      test('returns no error for missing optional field', () {
        final fields = [
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'pulse',
            label: 'Pulse',
            required: false,
            createdAt: DateTime(2024),
          ),
        ];
        final values = <String, String>{};

        final errors = MeasurementValidator.validateRecord(
          fields: fields,
          values: values,
        );

        expect(errors, isEmpty);
      });

      test('returns no error when required field is provided', () {
        final fields = [
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'systolic',
            label: 'Systolic',
            required: true,
            createdAt: DateTime(2024),
          ),
        ];
        final values = {'systolic': '120'};

        final errors = MeasurementValidator.validateRecord(
          fields: fields,
          values: values,
        );

        expect(errors, isEmpty);
      });
    });

    group('numeric validation', () {
      test('returns error for non-numeric value', () {
        final fields = [
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'weight',
            label: 'Weight',
            required: true,
            createdAt: DateTime(2024),
          ),
        ];
        final values = {'weight': 'abc'};

        final errors = MeasurementValidator.validateRecord(
          fields: fields,
          values: values,
        );

        expect(errors, contains('Weight must be a valid number'));
      });

      test('accepts decimal values', () {
        final fields = [
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'weight',
            label: 'Weight',
            required: true,
            decimalPlaces: 1,
            createdAt: DateTime(2024),
          ),
        ];
        final values = {'weight': '72.5'};

        final errors = MeasurementValidator.validateRecord(
          fields: fields,
          values: values,
        );

        expect(errors, isEmpty);
      });
    });

    group('minimum and maximum values', () {
      test('returns error below minimum', () {
        final fields = [
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'spo2',
            label: 'SpO2',
            required: true,
            minimumValue: 50,
            maximumValue: 100,
            decimalPlaces: 0,
            createdAt: DateTime(2024),
          ),
        ];
        final values = {'spo2': '40'};

        final errors = MeasurementValidator.validateRecord(
          fields: fields,
          values: values,
        );

        expect(errors, contains('SpO2 must be at least 50'));
      });

      test('returns error above maximum', () {
        final fields = [
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'spo2',
            label: 'SpO2',
            required: true,
            minimumValue: 50,
            maximumValue: 100,
            decimalPlaces: 0,
            createdAt: DateTime(2024),
          ),
        ];
        final values = {'spo2': '110'};

        final errors = MeasurementValidator.validateRecord(
          fields: fields,
          values: values,
        );

        expect(errors, contains('SpO2 must be at most 100'));
      });

      test('accepts value within range', () {
        final fields = [
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'spo2',
            label: 'SpO2',
            required: true,
            minimumValue: 50,
            maximumValue: 100,
            decimalPlaces: 0,
            createdAt: DateTime(2024),
          ),
        ];
        final values = {'spo2': '98'};

        final errors = MeasurementValidator.validateRecord(
          fields: fields,
          values: values,
        );

        expect(errors, isEmpty);
      });
    });

    group('blood pressure relationship', () {
      test('warns when systolic equals diastolic', () {
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
        final values = {'systolic': '120', 'diastolic': '120'};

        final errors = MeasurementValidator.validateRecord(
          fields: fields,
          values: values,
        );

        expect(
          errors,
          contains('Systolic should be greater than diastolic'),
        );
      });

      test('warns when systolic less than diastolic', () {
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
        final values = {'systolic': '80', 'diastolic': '120'};

        final errors = MeasurementValidator.validateRecord(
          fields: fields,
          values: values,
        );

        expect(
          errors,
          contains('Systolic should be greater than diastolic'),
        );
      });

      test('no error when systolic greater than diastolic', () {
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
    });

    group('validateField', () {
      test('returns null for valid value', () {
        final field = MeasurementTypeField(
          measurementTypeId: 1,
          fieldKey: 'weight',
          label: 'Weight',
          required: true,
          minimumValue: 1,
          maximumValue: 500,
          createdAt: DateTime(2024),
        );

        final error = MeasurementValidator.validateField(field, '72.5');

        expect(error, isNull);
      });

      test('returns error for empty required field', () {
        final field = MeasurementTypeField(
          measurementTypeId: 1,
          fieldKey: 'weight',
          label: 'Weight',
          required: true,
          createdAt: DateTime(2024),
        );

        final error = MeasurementValidator.validateField(field, '');

        expect(error, 'Weight is required');
      });

      test('returns null for empty optional field', () {
        final field = MeasurementTypeField(
          measurementTypeId: 1,
          fieldKey: 'pulse',
          label: 'Pulse',
          required: false,
          createdAt: DateTime(2024),
        );

        final error = MeasurementValidator.validateField(field, '');

        expect(error, isNull);
      });
    });

    group('hasRequiredValues', () {
      test('returns true when all required fields have values', () {
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

        final result = MeasurementValidator.hasRequiredValues(
          fields: fields,
          values: values,
        );

        expect(result, isTrue);
      });

      test('returns false when required field is missing', () {
        final fields = [
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'systolic',
            label: 'Systolic',
            required: true,
            createdAt: DateTime(2024),
          ),
        ];
        final values = <String, String>{};

        final result = MeasurementValidator.hasRequiredValues(
          fields: fields,
          values: values,
        );

        expect(result, isFalse);
      });
    });
  });
}
