import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/presentation/utils/measurement_formatter.dart';

void main() {
  group('MeasurementFormatter', () {
    group('blood pressure', () {
      test('formats systolic and diastolic', () {
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

      test('formats with optional pulse', () {
        final values = [
          MeasurementRecordValue(
            measurementRecordId: 1,
            fieldKey: 'systolic',
            numericValue: 130,
            unit: 'mmHg',
            displayOrder: 0,
          ),
          MeasurementRecordValue(
            measurementRecordId: 1,
            fieldKey: 'diastolic',
            numericValue: 85,
            unit: 'mmHg',
            displayOrder: 1,
          ),
          MeasurementRecordValue(
            measurementRecordId: 1,
            fieldKey: 'pulse',
            numericValue: 72,
            unit: 'bpm',
            displayOrder: 2,
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
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'pulse',
            label: 'Pulse',
            required: false,
            displayOrder: 2,
            createdAt: DateTime(2024),
          ),
        ];
        final record = MeasurementRecord(
          profileId: 1,
          measurementTypeId: 1,
          timestamp: DateTime(2024),
          valuePrimary: 130,
          unit: 'mmHg',
          createdAt: DateTime(2024),
        );

        final result = MeasurementFormatter.formatRecord(
          record,
          fields,
          values,
        );

        expect(result, '130/85 mmHg, pulse 72 bpm');
      });
    });

    group('pulse', () {
      test('formats pulse value', () {
        final values = [
          MeasurementRecordValue(
            measurementRecordId: 1,
            fieldKey: 'pulse',
            numericValue: 65,
            unit: 'bpm',
            displayOrder: 0,
          ),
        ];
        final fields = [
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'pulse',
            label: 'Pulse',
            displayOrder: 0,
            createdAt: DateTime(2024),
          ),
        ];
        final record = MeasurementRecord(
          profileId: 1,
          measurementTypeId: 1,
          timestamp: DateTime(2024),
          valuePrimary: 65,
          unit: 'bpm',
          createdAt: DateTime(2024),
        );

        final result = MeasurementFormatter.formatRecord(
          record,
          fields,
          values,
        );

        expect(result, '65 bpm');
      });
    });

    group('weight', () {
      test('formats weight with decimal', () {
        final values = [
          MeasurementRecordValue(
            measurementRecordId: 1,
            fieldKey: 'weight',
            numericValue: 82.5,
            unit: 'kg',
            displayOrder: 0,
          ),
        ];
        final fields = [
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'weight',
            label: 'Weight',
            decimalPlaces: 1,
            displayOrder: 0,
            createdAt: DateTime(2024),
          ),
        ];
        final record = MeasurementRecord(
          profileId: 1,
          measurementTypeId: 1,
          timestamp: DateTime(2024),
          valuePrimary: 82.5,
          unit: 'kg',
          createdAt: DateTime(2024),
        );

        final result = MeasurementFormatter.formatRecord(
          record,
          fields,
          values,
        );

        expect(result, '82.5 kg');
      });
    });

    group('blood glucose', () {
      test('formats glucose with decimal', () {
        final values = [
          MeasurementRecordValue(
            measurementRecordId: 1,
            fieldKey: 'glucose',
            numericValue: 5.6,
            unit: 'mmol/L',
            displayOrder: 0,
          ),
        ];
        final fields = [
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'glucose',
            label: 'Glucose',
            decimalPlaces: 1,
            displayOrder: 0,
            createdAt: DateTime(2024),
          ),
        ];
        final record = MeasurementRecord(
          profileId: 1,
          measurementTypeId: 1,
          timestamp: DateTime(2024),
          valuePrimary: 5.6,
          unit: 'mmol/L',
          createdAt: DateTime(2024),
        );

        final result = MeasurementFormatter.formatRecord(
          record,
          fields,
          values,
        );

        expect(result, '5.6 mmol/L');
      });
    });

    group('SpO2', () {
      test('formats SpO2 without pulse', () {
        final values = [
          MeasurementRecordValue(
            measurementRecordId: 1,
            fieldKey: 'spo2',
            numericValue: 98,
            unit: '%',
            displayOrder: 0,
          ),
        ];
        final fields = [
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'spo2',
            label: 'SpO2',
            displayOrder: 0,
            createdAt: DateTime(2024),
          ),
        ];
        final record = MeasurementRecord(
          profileId: 1,
          measurementTypeId: 1,
          timestamp: DateTime(2024),
          valuePrimary: 98,
          unit: '%',
          createdAt: DateTime(2024),
        );

        final result = MeasurementFormatter.formatRecord(
          record,
          fields,
          values,
        );

        expect(result, '98%');
      });

      test('formats SpO2 with pulse', () {
        final values = [
          MeasurementRecordValue(
            measurementRecordId: 1,
            fieldKey: 'spo2',
            numericValue: 97,
            unit: '%',
            displayOrder: 0,
          ),
          MeasurementRecordValue(
            measurementRecordId: 1,
            fieldKey: 'pulse',
            numericValue: 68,
            unit: 'bpm',
            displayOrder: 1,
          ),
        ];
        final fields = [
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'spo2',
            label: 'SpO2',
            displayOrder: 0,
            createdAt: DateTime(2024),
          ),
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'pulse',
            label: 'Pulse',
            required: false,
            displayOrder: 1,
            createdAt: DateTime(2024),
          ),
        ];
        final record = MeasurementRecord(
          profileId: 1,
          measurementTypeId: 1,
          timestamp: DateTime(2024),
          valuePrimary: 97,
          unit: '%',
          createdAt: DateTime(2024),
        );

        final result = MeasurementFormatter.formatRecord(
          record,
          fields,
          values,
        );

        expect(result, '97%, pulse 68 bpm');
      });
    });

    group('temperature', () {
      test('formats temperature with decimal', () {
        final values = [
          MeasurementRecordValue(
            measurementRecordId: 1,
            fieldKey: 'temperature',
            numericValue: 36.6,
            unit: '°C',
            displayOrder: 0,
          ),
        ];
        final fields = [
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'temperature',
            label: 'Temperature',
            decimalPlaces: 1,
            displayOrder: 0,
            createdAt: DateTime(2024),
          ),
        ];
        final record = MeasurementRecord(
          profileId: 1,
          measurementTypeId: 1,
          timestamp: DateTime(2024),
          valuePrimary: 36.6,
          unit: '°C',
          createdAt: DateTime(2024),
        );

        final result = MeasurementFormatter.formatRecord(
          record,
          fields,
          values,
        );

        expect(result, '36.6 °C');
      });
    });

    group('custom multi-field', () {
      test('formats custom fields in display order', () {
        final values = [
          MeasurementRecordValue(
            measurementRecordId: 1,
            fieldKey: 'field_b',
            numericValue: 42,
            unit: 'units',
            displayOrder: 1,
          ),
          MeasurementRecordValue(
            measurementRecordId: 1,
            fieldKey: 'field_a',
            numericValue: 10,
            unit: 'units',
            displayOrder: 0,
          ),
        ];
        final fields = [
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'field_a',
            label: 'Field A',
            decimalPlaces: 0,
            displayOrder: 0,
            createdAt: DateTime(2024),
          ),
          MeasurementTypeField(
            measurementTypeId: 1,
            fieldKey: 'field_b',
            label: 'Field B',
            decimalPlaces: 0,
            displayOrder: 1,
            createdAt: DateTime(2024),
          ),
        ];
        final record = MeasurementRecord(
          profileId: 1,
          measurementTypeId: 1,
          timestamp: DateTime(2024),
          valuePrimary: 10,
          unit: 'units',
          createdAt: DateTime(2024),
        );

        final result = MeasurementFormatter.formatRecord(
          record,
          fields,
          values,
        );

        expect(result, '10 units, 42 units');
      });
    });

    group('edge cases', () {
      test('handles missing optional values gracefully', () {
        final values = [
          MeasurementRecordValue(
            measurementRecordId: 1,
            fieldKey: 'systolic',
            numericValue: 120,
            unit: 'mmHg',
            displayOrder: 0,
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

        expect(result, '--/--');
      });

      test('handles empty values list', () {
        final fields = <MeasurementTypeField>[];
        final values = <MeasurementRecordValue>[];
        final record = MeasurementRecord(
          profileId: 1,
          measurementTypeId: 1,
          timestamp: DateTime(2024),
          valuePrimary: 0,
          unit: '',
          createdAt: DateTime(2024),
        );

        final result = MeasurementFormatter.formatRecord(
          record,
          fields,
          values,
        );

        expect(result, '--');
      });
    });
  });

  group('MeasurementFormatter.formatFieldValue', () {
    test('formats value with decimal places', () {
      final field = MeasurementTypeField(
        measurementTypeId: 1,
        fieldKey: 'weight',
        label: 'Weight',
        decimalPlaces: 1,
        createdAt: DateTime(2024),
      );
      final value = MeasurementRecordValue(
        measurementRecordId: 1,
        fieldKey: 'weight',
        numericValue: 72.5,
        unit: 'kg',
      );

      final result = MeasurementFormatter.formatFieldValue(field, value);

      expect(result, '72.5 kg');
    });

    test('formats value with zero decimal places', () {
      final field = MeasurementTypeField(
        measurementTypeId: 1,
        fieldKey: 'systolic',
        label: 'Systolic',
        decimalPlaces: 0,
        createdAt: DateTime(2024),
      );
      final value = MeasurementRecordValue(
        measurementRecordId: 1,
        fieldKey: 'systolic',
        numericValue: 120,
        unit: 'mmHg',
      );

      final result = MeasurementFormatter.formatFieldValue(field, value);

      expect(result, '120 mmHg');
    });
  });
}
