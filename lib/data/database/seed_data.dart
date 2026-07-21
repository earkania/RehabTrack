import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart';

Future<void> seedDatabase(AppDatabase db) async {
  await _seedMeasurementTypes(db);
  await _seedHealthTemplates(db);
}

Future<void> _seedMeasurementTypes(AppDatabase db) async {
  final now = DateTime.now();

  final builtInTypes = [
    MeasurementTypesCompanion.insert(
      name: 'Blood Pressure',
      unit: 'mmHg',
      measurementCategory: 'vital',
      isSystem: const Value(true),
      createdAt: now,
      updatedAt: now,
    ),
    MeasurementTypesCompanion.insert(
      name: 'Heart Rate',
      unit: 'bpm',
      measurementCategory: 'vital',
      isSystem: const Value(true),
      createdAt: now,
      updatedAt: now,
    ),
    MeasurementTypesCompanion.insert(
      name: 'Weight',
      unit: 'kg',
      measurementCategory: 'body',
      isSystem: const Value(true),
      createdAt: now,
      updatedAt: now,
    ),
    MeasurementTypesCompanion.insert(
      name: 'Blood Glucose',
      unit: 'mg/dL',
      measurementCategory: 'metabolic',
      isSystem: const Value(true),
      createdAt: now,
      updatedAt: now,
    ),
    MeasurementTypesCompanion.insert(
      name: 'Temperature',
      unit: '\u00b0C',
      measurementCategory: 'vital',
      isSystem: const Value(true),
      createdAt: now,
      updatedAt: now,
    ),
  ];

  for (final type in builtInTypes) {
    await db.into(db.measurementTypes).insert(type);
  }
}

Future<void> _seedHealthTemplates(AppDatabase db) async {
  final cardiacConfig = jsonEncode({
    'modules': ['measurement', 'medication', 'exercise'],
    'measurements': [
      {'type': 'Blood Pressure', 'schedule': 'daily_morning'},
      {'type': 'Heart Rate', 'schedule': 'daily_morning'},
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
