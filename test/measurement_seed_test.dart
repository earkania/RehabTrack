import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/data/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.test();
  });

  tearDown(() async {
    await db.close();
  });

  group('Measurement type seeding', () {
    test('seeds 6 system measurement types', () async {
      await _seedMeasurementTypesV4(db);
      final types = await db.measurementDao.getMeasurementTypes(null);

      expect(types.length, 6);
    });

    test('seeds blood_pressure type with correct fields', () async {
      await _seedMeasurementTypesV4(db);
      final type = await db.measurementDao.getMeasurementTypeByKey(
        'blood_pressure',
      );

      expect(type, isNotNull);
      expect(type!.name, 'Blood Pressure');
      expect(type.unit, 'mmHg');
      expect(type.isSystem, isTrue);
      expect(type.key, 'blood_pressure');
      expect(type.measurementCategory, 'vital');
    });

    test('seeds pulse type with correct fields', () async {
      await _seedMeasurementTypesV4(db);
      final type = await db.measurementDao.getMeasurementTypeByKey(
        'pulse',
      );

      expect(type, isNotNull);
      expect(type!.name, 'Pulse');
      expect(type.unit, 'bpm');
      expect(type.key, 'pulse');
    });

    test('seeds weight type with correct fields', () async {
      await _seedMeasurementTypesV4(db);
      final type = await db.measurementDao.getMeasurementTypeByKey(
        'weight',
      );

      expect(type, isNotNull);
      expect(type!.name, 'Weight');
      expect(type.unit, 'kg');
      expect(type.key, 'weight');
    });

    test('seeds blood_glucose type with correct fields', () async {
      await _seedMeasurementTypesV4(db);
      final type = await db.measurementDao.getMeasurementTypeByKey(
        'blood_glucose',
      );

      expect(type, isNotNull);
      expect(type!.name, 'Blood Glucose');
      expect(type.unit, 'mmol/L');
      expect(type.key, 'blood_glucose');
    });

    test('seeds spo2 type with correct fields', () async {
      await _seedMeasurementTypesV4(db);
      final type = await db.measurementDao.getMeasurementTypeByKey(
        'spo2',
      );

      expect(type, isNotNull);
      expect(type!.name, 'SpO2');
      expect(type.unit, '%');
      expect(type.key, 'spo2');
    });

    test('seeds temperature type with correct fields', () async {
      await _seedMeasurementTypesV4(db);
      final type = await db.measurementDao.getMeasurementTypeByKey(
        'temperature',
      );

      expect(type, isNotNull);
      expect(type!.name, 'Temperature');
      expect(type.unit, '°C');
      expect(type.key, 'temperature');
    });
  });

  group('Measurement type fields seeding', () {
    test('seeds blood_pressure fields correctly', () async {
      await _seedMeasurementTypesV4(db);
      final type = await db.measurementDao.getMeasurementTypeByKey(
        'blood_pressure',
      );
      final fields = await db.measurementDao.getFieldsForType(type!.id);

      expect(fields.length, 3);
      expect(fields[0].fieldKey, 'systolic');
      expect(fields[0].label, 'Systolic');
      expect(fields[0].defaultUnit, 'mmHg');
      expect(fields[0].required, isTrue);
      expect(fields[0].minimumValue, 40.0);
      expect(fields[0].maximumValue, 300.0);
      expect(fields[0].decimalPlaces, 0);

      expect(fields[1].fieldKey, 'diastolic');
      expect(fields[1].label, 'Diastolic');
      expect(fields[1].required, isTrue);

      expect(fields[2].fieldKey, 'pulse');
      expect(fields[2].label, 'Pulse');
      expect(fields[2].required, isFalse);
    });

    test('seeds pulse field correctly', () async {
      await _seedMeasurementTypesV4(db);
      final type = await db.measurementDao.getMeasurementTypeByKey(
        'pulse',
      );
      final fields = await db.measurementDao.getFieldsForType(type!.id);

      expect(fields.length, 1);
      expect(fields[0].fieldKey, 'pulse');
      expect(fields[0].defaultUnit, 'bpm');
      expect(fields[0].required, isTrue);
    });

    test('seeds weight field correctly', () async {
      await _seedMeasurementTypesV4(db);
      final type = await db.measurementDao.getMeasurementTypeByKey(
        'weight',
      );
      final fields = await db.measurementDao.getFieldsForType(type!.id);

      expect(fields.length, 1);
      expect(fields[0].fieldKey, 'weight');
      expect(fields[0].defaultUnit, 'kg');
      expect(fields[0].decimalPlaces, 1);
      expect(fields[0].required, isTrue);
    });

    test('seeds blood_glucose field correctly', () async {
      await _seedMeasurementTypesV4(db);
      final type = await db.measurementDao.getMeasurementTypeByKey(
        'blood_glucose',
      );
      final fields = await db.measurementDao.getFieldsForType(type!.id);

      expect(fields.length, 1);
      expect(fields[0].fieldKey, 'glucose');
      expect(fields[0].defaultUnit, 'mmol/L');
      expect(fields[0].decimalPlaces, 1);
      expect(fields[0].required, isTrue);
    });

    test('seeds spo2 fields correctly', () async {
      await _seedMeasurementTypesV4(db);
      final type = await db.measurementDao.getMeasurementTypeByKey(
        'spo2',
      );
      final fields = await db.measurementDao.getFieldsForType(type!.id);

      expect(fields.length, 2);
      expect(fields[0].fieldKey, 'spo2');
      expect(fields[0].required, isTrue);

      expect(fields[1].fieldKey, 'pulse');
      expect(fields[1].required, isFalse);
    });

    test('seeds temperature field correctly', () async {
      await _seedMeasurementTypesV4(db);
      final type = await db.measurementDao.getMeasurementTypeByKey(
        'temperature',
      );
      final fields = await db.measurementDao.getFieldsForType(type!.id);

      expect(fields.length, 1);
      expect(fields[0].fieldKey, 'temperature');
      expect(fields[0].defaultUnit, '°C');
      expect(fields[0].decimalPlaces, 1);
      expect(fields[0].required, isTrue);
    });
  });

  group('Idempotent seeding', () {
    test('does not duplicate types on re-seed', () async {
      await _seedMeasurementTypesV4(db);
      final types1 = await db.measurementDao.getMeasurementTypes(null);
      expect(types1.length, 6);

      await _seedMeasurementTypesV4(db);

      final types2 = await db.measurementDao.getMeasurementTypes(null);
      expect(types2.length, 6);
    });

    test('does not duplicate fields on re-seed', () async {
      await _seedMeasurementTypesV4(db);
      final type = await db.measurementDao.getMeasurementTypeByKey(
        'blood_pressure',
      );
      final fields1 = await db.measurementDao.getFieldsForType(type!.id);
      expect(fields1.length, 3);

      await _seedMeasurementTypesV4(db);

      final fields2 = await db.measurementDao.getFieldsForType(type.id);
      expect(fields2.length, 3);
    });
  });

  group('Data integrity', () {
    test('system types are marked as system', () async {
      await _seedMeasurementTypesV4(db);
      final types = await db.measurementDao.getMeasurementTypes(null);
      for (final type in types) {
        expect(type.isSystem, isTrue);
      }
    });

    test('all types are active', () async {
      await _seedMeasurementTypesV4(db);
      final types = await db.measurementDao.getMeasurementTypes(null);
      for (final type in types) {
        expect(type.active, isTrue);
      }
    });

    test('types have correct display order', () async {
      await _seedMeasurementTypesV4(db);
      final types = await db.measurementDao.getMeasurementTypes(null);
      expect(types[0].key, 'blood_pressure');
      expect(types[0].displayOrder, 0);
      expect(types[1].key, 'pulse');
      expect(types[1].displayOrder, 1);
      expect(types[2].key, 'weight');
      expect(types[2].displayOrder, 2);
      expect(types[3].key, 'blood_glucose');
      expect(types[3].displayOrder, 3);
      expect(types[4].key, 'spo2');
      expect(types[4].displayOrder, 4);
      expect(types[5].key, 'temperature');
      expect(types[5].displayOrder, 5);
    });
  });

  group('Duplicate cleanup migration', () {
    test('deactivates old keyless duplicate types', () async {
      await _seedMeasurementTypesV4(db);

      final now = DateTime.now();
      await db.into(db.measurementTypes).insert(
        MeasurementTypesCompanion.insert(
          name: 'Blood Pressure',
          unit: 'mmHg',
          measurementCategory: 'vital',
          isSystem: const Value(true),
          active: const Value(true),
          createdAt: now,
          updatedAt: now,
        ),
      );

      final typesBefore = await db.measurementDao.getMeasurementTypes(null);
      expect(typesBefore.where((t) => t.name == 'Blood Pressure').length, 2);

      await AppDatabase.cleanupDuplicateMeasurementTypes(db);

      final typesAfter = await db.measurementDao.getMeasurementTypes(null);
      final bpTypes = typesAfter.where((t) => t.name == 'Blood Pressure');
      expect(bpTypes.length, 2);
      expect(bpTypes.where((t) => t.active).length, 1);
      expect(bpTypes.where((t) => !t.active).length, 1);
    });

    test('migrates records from duplicate to canonical type', () async {
      await _seedMeasurementTypesV4(db);

      final now = DateTime.now();
      final dupTypeId = await db.into(db.measurementTypes).insert(
        MeasurementTypesCompanion.insert(
          name: 'Pulse',
          unit: 'bpm',
          measurementCategory: 'vital',
          isSystem: const Value(true),
          active: const Value(true),
          createdAt: now,
          updatedAt: now,
        ),
      );

      final canonicalType = await db.measurementDao.getMeasurementTypeByKey(
        'pulse',
      );

      await db.into(db.measurementRecords).insert(
        MeasurementRecordsCompanion.insert(
          profileId: 1,
          measurementTypeId: dupTypeId,
          timestamp: now,
          valuePrimary: 72,
          unit: 'bpm',
          createdAt: now,
          updatedAt: Value(now),
        ),
      );

      await AppDatabase.cleanupDuplicateMeasurementTypes(db);

      final records = await (db.select(db.measurementRecords)
            ..where((r) =>
                r.measurementTypeId.equals(canonicalType!.id)))
          .get();
      expect(records.length, 1);

      final dupRecords = await (db.select(db.measurementRecords)
            ..where((r) => r.measurementTypeId.equals(dupTypeId)))
          .get();
      expect(dupRecords.length, 0);
    });

    test('consolidates Heart Rate into Pulse', () async {
      await _seedMeasurementTypesV4(db);

      final now = DateTime.now();
      final hrTypeId = await db.into(db.measurementTypes).insert(
        MeasurementTypesCompanion.insert(
          name: 'Heart Rate',
          unit: 'bpm',
          measurementCategory: 'vital',
          isSystem: const Value(true),
          active: const Value(true),
          createdAt: now,
          updatedAt: now,
        ),
      );

      final pulseType = await db.measurementDao.getMeasurementTypeByKey(
        'pulse',
      );

      await db.into(db.measurementRecords).insert(
        MeasurementRecordsCompanion.insert(
          profileId: 1,
          measurementTypeId: hrTypeId,
          timestamp: now,
          valuePrimary: 80,
          unit: 'bpm',
          createdAt: now,
          updatedAt: Value(now),
        ),
      );

      await AppDatabase.cleanupDuplicateMeasurementTypes(db);

      final hrAfter = await (db.select(db.measurementTypes)
            ..where((mt) => mt.name.equals('Heart Rate')))
          .getSingleOrNull();
      expect(hrAfter, isNotNull);
      expect(hrAfter!.active, isFalse);

      final pulseRecords = await (db.select(db.measurementRecords)
            ..where((r) =>
                r.measurementTypeId.equals(pulseType!.id)))
          .get();
      expect(pulseRecords.length, 1);
      expect(pulseRecords.first.valuePrimary, 80);
    });

    test('preserves custom measurement types', () async {
      await _seedMeasurementTypesV4(db);

      final now = DateTime.now();
      final customId = await db.into(db.measurementTypes).insert(
        MeasurementTypesCompanion.insert(
          name: 'Custom Pain Scale',
          unit: 'score',
          measurementCategory: 'custom',
          isSystem: const Value(false),
          active: const Value(true),
          createdAt: now,
          updatedAt: now,
        ),
      );

      await AppDatabase.cleanupDuplicateMeasurementTypes(db);

      final customAfter = await db.measurementDao.getMeasurementType(
        customId,
      );
      expect(customAfter, isNotNull);
      expect(customAfter!.active, isTrue);
    });

    test('ensures canonical types have fields after cleanup', () async {
      await _seedMeasurementTypesV4(db);

      final now = DateTime.now();
      await db.into(db.measurementTypes).insert(
        MeasurementTypesCompanion.insert(
          name: 'Blood Pressure',
          unit: 'mmHg',
          measurementCategory: 'vital',
          isSystem: const Value(true),
          active: const Value(true),
          createdAt: now,
          updatedAt: now,
        ),
      );

      await AppDatabase.cleanupDuplicateMeasurementTypes(db);

      final canonical = await db.measurementDao.getMeasurementTypeByKey(
        'blood_pressure',
      );
      final fields = await db.measurementDao.getFieldsForType(
        canonical!.id,
      );
      expect(fields.length, 3);
    });
  });
}

Future<void> _seedMeasurementTypesV4(AppDatabase db) async {
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
    if (existing != null) continue;

    final typeId = await db.into(db.measurementTypes).insert(
      MeasurementTypesCompanion.insert(
        name: t.name,
        unit: t.unit,
        measurementCategory: t.category,
        isSystem: const Value(true),
        active: const Value(true),
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
