import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart';

Future<void> seedDatabase(AppDatabase db) async {
  await _seedMeasurementTypes(db);
  await _seedHealthTemplates(db);
}

Future<void> _seedMeasurementTypes(AppDatabase db) async {
  final now = DateTime.now();

  final types = <({
    String key,
    String name,
    String unit,
    String category,
    int order,
  })>[
    (key: 'blood_pressure', name: 'Blood Pressure', unit: 'mmHg', category: 'vital', order: 0),
    (key: 'pulse', name: 'Pulse', unit: 'bpm', category: 'vital', order: 1),
    (key: 'weight', name: 'Weight', unit: 'kg', category: 'body', order: 2),
    (key: 'blood_glucose', name: 'Blood Glucose', unit: 'mmol/L', category: 'metabolic', order: 3),
    (key: 'spo2', name: 'SpO2', unit: '%', category: 'vital', order: 4),
    (key: 'temperature', name: 'Temperature', unit: '°C', category: 'vital', order: 5),
  ];

  for (final t in types) {
    final existing = await (db.select(db.measurementTypes)
          ..where((mt) => mt.key.equals(t.key)))
        .getSingleOrNull();
    if (existing != null) {
      final existingFields = await db.measurementDao.getFieldsForType(
        existing.id,
      );
      if (existingFields.isEmpty) {
        await _seedFieldsForType(db, existing.id, t.key);
      }
      continue;
    }

    final typeId = await db.into(db.measurementTypes).insert(
      MeasurementTypesCompanion.insert(
        name: t.name,
        unit: t.unit,
        defaultUnit: Value(t.unit),
        measurementCategory: t.category,
        isSystem: const Value(true),
        active: const Value(true),
        key: Value(t.key),
        displayOrder: Value(t.order),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await _seedFieldsForType(db, typeId, t.key);
  }
}

Future<void> _seedFieldsForType(
  AppDatabase db,
  int typeId,
  String typeKey,
) async {
  final now = DateTime.now();
  final existingFields = await db.measurementDao.getFieldsForType(typeId);
  if (existingFields.isNotEmpty) return;

  final fields = _fieldsForType(typeKey);
  for (final f in fields) {
    await db.into(db.measurementTypeFields).insert(
      MeasurementTypeFieldsCompanion.insert(
        measurementTypeId: typeId,
        fieldKey: f.fieldKey,
        label: f.label,
        defaultUnit: Value(f.unit),
        required: Value(f.required),
        minimumValue: Value(f.min),
        maximumValue: Value(f.max),
        decimalPlaces: Value(f.decimals),
        displayOrder: Value(f.order),
        createdAt: now,
      ),
    );
  }
}

List<_FieldSpec> _fieldsForType(String typeKey) {
  return switch (typeKey) {
    'blood_pressure' => [
      _FieldSpec('systolic', 'Systolic', 'mmHg', true, 40.0, 300.0, 0, 0),
      _FieldSpec('diastolic', 'Diastolic', 'mmHg', true, 20.0, 200.0, 0, 1),
      _FieldSpec('pulse', 'Pulse', 'bpm', false, 30.0, 250.0, 0, 2),
    ],
    'pulse' => [
      _FieldSpec('pulse', 'Pulse', 'bpm', true, 30.0, 250.0, 0, 0),
    ],
    'weight' => [
      _FieldSpec('weight', 'Weight', 'kg', true, 1.0, 500.0, 1, 0),
    ],
    'blood_glucose' => [
      _FieldSpec('glucose', 'Glucose', 'mmol/L', true, 0.5, 50.0, 1, 0),
    ],
    'spo2' => [
      _FieldSpec('spo2', 'SpO2', '%', true, 50.0, 100.0, 0, 0),
      _FieldSpec('pulse', 'Pulse', 'bpm', false, 30.0, 250.0, 0, 1),
    ],
    'temperature' => [
      _FieldSpec('temperature', 'Temperature', '°C', true, 30.0, 45.0, 1, 0),
    ],
    _ => [],
  };
}

class _FieldSpec {
  final String fieldKey;
  final String label;
  final String unit;
  final bool required;
  final double? min;
  final double? max;
  final int decimals;
  final int order;

  const _FieldSpec(
    this.fieldKey,
    this.label,
    this.unit,
    this.required,
    this.min,
    this.max,
    this.decimals,
    this.order,
  );
}

Future<void> _seedHealthTemplates(AppDatabase db) async {
  final cardiacConfig = jsonEncode({
    'modules': ['measurement', 'medication', 'exercise'],
    'measurements': [
      {'type': 'Blood Pressure', 'schedule': 'daily_morning'},
      {'type': 'Pulse', 'schedule': 'daily_morning'},
      {'type': 'Weight', 'schedule': 'weekly'},
    ],
    'exercise': {'type': 'Walking', 'target': '5 km daily'},
  });

  final diabetesConfig = jsonEncode({
    'modules': ['measurement', 'medication', 'diet'],
    'measurements': [
      {'type': 'Blood Glucose', 'schedule': 'before_meals'},
      {'type': 'Weight', 'schedule': 'weekly'},
    ],
  });

  final wellnessConfig = jsonEncode({
    'modules': ['measurement', 'exercise'],
    'measurements': [
      {'type': 'Weight', 'schedule': 'weekly'},
    ],
    'exercise': {'type': 'Walking', 'target': '30 minutes daily'},
  });

  final templates = [
    HealthTemplatesCompanion.insert(
      name: 'Cardiac Recovery',
      description:
          'Tracks blood pressure, heart rate, weight, and walking '
          'exercise for cardiac rehabilitation.',
      configurationJson: cardiacConfig,
    ),
    HealthTemplatesCompanion.insert(
      name: 'Diabetes Management',
      description:
          'Monitors blood glucose levels, medications, '
          'and diet guidelines.',
      configurationJson: diabetesConfig,
    ),
    HealthTemplatesCompanion.insert(
      name: 'General Wellness',
      description:
          'Basic weight tracking and exercise logging '
          'for general health.',
      configurationJson: wellnessConfig,
    ),
  ];

  for (final template in templates) {
    await db.into(db.healthTemplates).insert(template);
  }
}
