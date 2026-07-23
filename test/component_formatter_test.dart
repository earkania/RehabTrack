import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/medication_alternative_component.dart';
import 'package:rehab_track/domain/entities/medication_component.dart';
import 'package:rehab_track/presentation/utils/component_formatter.dart';

void main() {
  group('ComponentFormatter.formatComponents', () {
    test('returns empty string for empty list', () {
      expect(ComponentFormatter.formatComponents([]), '');
    });

    test('formats single component with unit', () {
      final components = [
        MedicationComponent(
          medicationId: 1,
          doseAmount: '500',
          doseUnit: 'mg',
          createdAt: DateTime(2026),
        ),
      ];
      expect(ComponentFormatter.formatComponents(components), '500 mg');
    });

    test('formats single component without unit', () {
      final components = [
        MedicationComponent(
          medicationId: 1,
          doseAmount: '500',
          doseUnit: '',
          createdAt: DateTime(2026),
        ),
      ];
      expect(ComponentFormatter.formatComponents(components), '500');
    });

    test('formats multi-component with same unit', () {
      final components = [
        MedicationComponent(
          medicationId: 1,
          doseAmount: '10',
          doseUnit: 'mg',
          createdAt: DateTime(2026),
        ),
        MedicationComponent(
          medicationId: 1,
          doseAmount: '2.5',
          doseUnit: 'mg',
          createdAt: DateTime(2026),
        ),
        MedicationComponent(
          medicationId: 1,
          doseAmount: '10',
          doseUnit: 'mg',
          createdAt: DateTime(2026),
        ),
      ];
      expect(
        ComponentFormatter.formatComponents(components),
        '10 mg/2.5 mg/10 mg',
      );
    });

    test('formats multi-component with different units', () {
      final components = [
        MedicationComponent(
          medicationId: 1,
          doseAmount: '500',
          doseUnit: 'mg',
          createdAt: DateTime(2026),
        ),
        MedicationComponent(
          medicationId: 1,
          doseAmount: '125',
          doseUnit: 'mg',
          createdAt: DateTime(2026),
        ),
      ];
      expect(
        ComponentFormatter.formatComponents(components),
        '500 mg/125 mg',
      );
    });
  });

  group('ComponentFormatter.formatAlternativeComponents', () {
    test('returns empty string for empty list', () {
      expect(
        ComponentFormatter.formatAlternativeComponents([]),
        '',
      );
    });

    test('formats single alternative component', () {
      final components = [
        MedicationAlternativeComponent(
          medicationAlternativeId: 1,
          doseAmount: '250',
          doseUnit: 'mg',
          createdAt: DateTime(2026),
        ),
      ];
      expect(
        ComponentFormatter.formatAlternativeComponents(components),
        '250 mg',
      );
    });

    test('formats multi alternative components', () {
      final components = [
        MedicationAlternativeComponent(
          medicationAlternativeId: 1,
          doseAmount: '10',
          doseUnit: 'mg',
          createdAt: DateTime(2026),
        ),
        MedicationAlternativeComponent(
          medicationAlternativeId: 1,
          doseAmount: '2.5',
          doseUnit: 'mg',
          createdAt: DateTime(2026),
        ),
        MedicationAlternativeComponent(
          medicationAlternativeId: 1,
          doseAmount: '10',
          doseUnit: 'mg',
          createdAt: DateTime(2026),
        ),
      ];
      expect(
        ComponentFormatter.formatAlternativeComponents(components),
        '10 mg/2.5 mg/10 mg',
      );
    });
  });

  group('ComponentFormatter.formatComponentsDetailed', () {
    test('returns empty string for empty list', () {
      expect(ComponentFormatter.formatComponentsDetailed([]), '');
    });

    test('formats single named component', () {
      final components = [
        MedicationComponent(
          medicationId: 1,
          componentName: 'Paracetamol',
          doseAmount: '500',
          doseUnit: 'mg',
          createdAt: DateTime(2026),
        ),
      ];
      expect(
        ComponentFormatter.formatComponentsDetailed(components),
        'Paracetamol 500 mg',
      );
    });

    test('formats single unnamed component', () {
      final components = [
        MedicationComponent(
          medicationId: 1,
          doseAmount: '500',
          doseUnit: 'mg',
          createdAt: DateTime(2026),
        ),
      ];
      expect(
        ComponentFormatter.formatComponentsDetailed(components),
        '500 mg',
      );
    });

    test('formats multi-component with names', () {
      final components = [
        MedicationComponent(
          medicationId: 1,
          componentName: 'Aspirin',
          doseAmount: '10',
          doseUnit: 'mg',
          createdAt: DateTime(2026),
        ),
        MedicationComponent(
          medicationId: 1,
          componentName: 'Clopidogrel',
          doseAmount: '2.5',
          doseUnit: 'mg',
          createdAt: DateTime(2026),
        ),
      ];
      expect(
        ComponentFormatter.formatComponentsDetailed(components),
        'Aspirin 10 mg + Clopidogrel 2.5 mg',
      );
    });

    test('formats multi-component with mix of named and unnamed', () {
      final components = [
        MedicationComponent(
          medicationId: 1,
          componentName: 'Aspirin',
          doseAmount: '10',
          doseUnit: 'mg',
          createdAt: DateTime(2026),
        ),
        MedicationComponent(
          medicationId: 1,
          doseAmount: '2.5',
          doseUnit: 'mg',
          createdAt: DateTime(2026),
        ),
      ];
      expect(
        ComponentFormatter.formatComponentsDetailed(components),
        'Aspirin 10 mg + 2.5 mg',
      );
    });
  });

  group('ComponentFormatter.formatAlternativeComponentsDetailed', () {
    test('returns empty string for empty list', () {
      expect(
        ComponentFormatter.formatAlternativeComponentsDetailed([]),
        '',
      );
    });

    test('formats single named alternative component', () {
      final components = [
        MedicationAlternativeComponent(
          medicationAlternativeId: 1,
          componentName: 'Ibuprofen',
          doseAmount: '250',
          doseUnit: 'mg',
          createdAt: DateTime(2026),
        ),
      ];
      expect(
        ComponentFormatter.formatAlternativeComponentsDetailed(components),
        'Ibuprofen 250 mg',
      );
    });

    test('formats multi-component with names', () {
      final components = [
        MedicationAlternativeComponent(
          medicationAlternativeId: 1,
          componentName: 'A',
          doseAmount: '10',
          doseUnit: 'mg',
          createdAt: DateTime(2026),
        ),
        MedicationAlternativeComponent(
          medicationAlternativeId: 1,
          componentName: 'B',
          doseAmount: '2.5',
          doseUnit: 'mg',
          createdAt: DateTime(2026),
        ),
      ];
      expect(
        ComponentFormatter.formatAlternativeComponentsDetailed(components),
        'A 10 mg + B 2.5 mg',
      );
    });
  });
}
