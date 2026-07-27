import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/domain/entities/measurement.dart';

void main() {
  late db.AppDatabase database;

  setUp(() {
    database = db.AppDatabase.test();
  });

  tearDown(() async {
    await database.close();
  });

  group('MeasurementRecord irregularHeartbeatDetected', () {
    test('constructor accepts null value', () {
      final record = MeasurementRecord(
        profileId: 1,
        measurementTypeId: 1,
        timestamp: DateTime(2024),
        valuePrimary: 120,
        unit: 'mmHg',
        createdAt: DateTime(2024),
      );
      expect(record.irregularHeartbeatDetected, isNull);
    });

    test('constructor accepts true value', () {
      final record = MeasurementRecord(
        profileId: 1,
        measurementTypeId: 1,
        timestamp: DateTime(2024),
        valuePrimary: 120,
        unit: 'mmHg',
        irregularHeartbeatDetected: true,
        createdAt: DateTime(2024),
      );
      expect(record.irregularHeartbeatDetected, isTrue);
    });

    test('constructor accepts false value', () {
      final record = MeasurementRecord(
        profileId: 1,
        measurementTypeId: 1,
        timestamp: DateTime(2024),
        valuePrimary: 120,
        unit: 'mmHg',
        irregularHeartbeatDetected: false,
        createdAt: DateTime(2024),
      );
      expect(record.irregularHeartbeatDetected, isFalse);
    });

    test('copyWith preserves irregularHeartbeatDetected by default', () {
      final original = MeasurementRecord(
        profileId: 1,
        measurementTypeId: 1,
        timestamp: DateTime(2024),
        valuePrimary: 120,
        unit: 'mmHg',
        irregularHeartbeatDetected: true,
        createdAt: DateTime(2024),
      );

      final copied = original.copyWith(
        valuePrimary: 130,
      );

      expect(copied.irregularHeartbeatDetected, isTrue);
      expect(copied.valuePrimary, 130);
    });

    test('copyWith can change irregularHeartbeatDetected to false', () {
      final original = MeasurementRecord(
        profileId: 1,
        measurementTypeId: 1,
        timestamp: DateTime(2024),
        valuePrimary: 120,
        unit: 'mmHg',
        irregularHeartbeatDetected: true,
        createdAt: DateTime(2024),
      );

      final copied = original.copyWith(
        irregularHeartbeatDetected: false,
      );

      expect(copied.irregularHeartbeatDetected, isFalse);
    });

    test('copyWith can clear irregularHeartbeatDetected to null', () {
      final original = MeasurementRecord(
        profileId: 1,
        measurementTypeId: 1,
        timestamp: DateTime(2024),
        valuePrimary: 120,
        unit: 'mmHg',
        irregularHeartbeatDetected: true,
        createdAt: DateTime(2024),
      );

      final copied = original.copyWith(
        clearIrregularHeartbeat: true,
      );

      expect(copied.irregularHeartbeatDetected, isNull);
    });

    test('copyWith preserves null irregularHeartbeatDetected', () {
      final original = MeasurementRecord(
        profileId: 1,
        measurementTypeId: 1,
        timestamp: DateTime(2024),
        valuePrimary: 120,
        unit: 'mmHg',
        createdAt: DateTime(2024),
      );

      final copied = original.copyWith(
        valuePrimary: 130,
      );

      expect(copied.irregularHeartbeatDetected, isNull);
    });
  });

  group('Schema v7 migration - irregularHeartbeatDetected column', () {
    test('new database creates MeasurementRecords with nullable boolean column', () async {
      final tables = database.allTables;
      final recordsTable = tables.firstWhere(
        (t) => t.actualTableName == 'measurement_records',
      );
      expect(recordsTable, isNotNull);
    });

    test('existing blood-pressure record defaults to null after migration', () async {
      await _seedMeasurementTypesV4(database);

      final bpType = await database.measurementDao.getMeasurementTypeByKey(
        'blood_pressure',
      );
      expect(bpType, isNotNull);

      final profileId = await database.into(database.profiles).insert(
        db.ProfilesCompanion.insert(
          firstName: 'Test',
          lastName: 'User',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      );

      final recordId = await database.into(database.measurementRecords).insert(
        db.MeasurementRecordsCompanion.insert(
          profileId: profileId,
          measurementTypeId: bpType!.id,
          timestamp: DateTime(2024),
          valuePrimary: 120,
          unit: 'mmHg',
          createdAt: DateTime(2024),
        ),
      );

      final record = await database.measurementDao.getRecord(recordId);
      expect(record, isNotNull);
      expect(record!.irregularHeartbeatDetected, isNull);
    });

    test('blood-pressure record can be created with irregularHeartbeatDetected = true', () async {
      await _seedMeasurementTypesV4(database);

      final bpType = await database.measurementDao.getMeasurementTypeByKey(
        'blood_pressure',
      );
      final profileId = await database.into(database.profiles).insert(
        db.ProfilesCompanion.insert(
          firstName: 'Test',
          lastName: 'User',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      );

      final recordId = await database.into(database.measurementRecords).insert(
        db.MeasurementRecordsCompanion.insert(
          profileId: profileId,
          measurementTypeId: bpType!.id,
          timestamp: DateTime(2024),
          valuePrimary: 120,
          unit: 'mmHg',
          irregularHeartbeatDetected: const Value(true),
          createdAt: DateTime(2024),
        ),
      );

      final record = await database.measurementDao.getRecord(recordId);
      expect(record, isNotNull);
      expect(record!.irregularHeartbeatDetected, isTrue);
    });

    test('blood-pressure record can be created with irregularHeartbeatDetected = false', () async {
      await _seedMeasurementTypesV4(database);

      final bpType = await database.measurementDao.getMeasurementTypeByKey(
        'blood_pressure',
      );
      final profileId = await database.into(database.profiles).insert(
        db.ProfilesCompanion.insert(
          firstName: 'Test',
          lastName: 'User',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      );

      final recordId = await database.into(database.measurementRecords).insert(
        db.MeasurementRecordsCompanion.insert(
          profileId: profileId,
          measurementTypeId: bpType!.id,
          timestamp: DateTime(2024),
          valuePrimary: 130,
          unit: 'mmHg',
          irregularHeartbeatDetected: const Value(false),
          createdAt: DateTime(2024),
        ),
      );

      final record = await database.measurementDao.getRecord(recordId);
      expect(record, isNotNull);
      expect(record!.irregularHeartbeatDetected, isFalse);
    });

    test('weight record irregularHeartbeatDetected defaults to null', () async {
      await _seedMeasurementTypesV4(database);

      final weightType = await database.measurementDao.getMeasurementTypeByKey(
        'weight',
      );
      final profileId = await database.into(database.profiles).insert(
        db.ProfilesCompanion.insert(
          firstName: 'Test',
          lastName: 'User',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      );

      final recordId = await database.into(database.measurementRecords).insert(
        db.MeasurementRecordsCompanion.insert(
          profileId: profileId,
          measurementTypeId: weightType!.id,
          timestamp: DateTime(2024),
          valuePrimary: 75,
          unit: 'kg',
          createdAt: DateTime(2024),
        ),
      );

      final record = await database.measurementDao.getRecord(recordId);
      expect(record, isNotNull);
      expect(record!.irregularHeartbeatDetected, isNull);
    });

    test('irregularHeartbeatDetected can be updated from true to false', () async {
      await _seedMeasurementTypesV4(database);

      final bpType = await database.measurementDao.getMeasurementTypeByKey(
        'blood_pressure',
      );
      final profileId = await database.into(database.profiles).insert(
        db.ProfilesCompanion.insert(
          firstName: 'Test',
          lastName: 'User',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      );

      final recordId = await database.into(database.measurementRecords).insert(
        db.MeasurementRecordsCompanion.insert(
          profileId: profileId,
          measurementTypeId: bpType!.id,
          timestamp: DateTime(2024),
          valuePrimary: 120,
          unit: 'mmHg',
          irregularHeartbeatDetected: const Value(true),
          createdAt: DateTime(2024),
        ),
      );

      await (database.update(database.measurementRecords)
            ..where((r) => r.id.equals(recordId)))
          .write(
        db.MeasurementRecordsCompanion(
          irregularHeartbeatDetected: const Value(false),
        ),
      );

      final record = await database.measurementDao.getRecord(recordId);
      expect(record!.irregularHeartbeatDetected, isFalse);
    });

    test('irregularHeartbeatDetected can be updated from false to null', () async {
      await _seedMeasurementTypesV4(database);

      final bpType = await database.measurementDao.getMeasurementTypeByKey(
        'blood_pressure',
      );
      final profileId = await database.into(database.profiles).insert(
        db.ProfilesCompanion.insert(
          firstName: 'Test',
          lastName: 'User',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      );

      final recordId = await database.into(database.measurementRecords).insert(
        db.MeasurementRecordsCompanion.insert(
          profileId: profileId,
          measurementTypeId: bpType!.id,
          timestamp: DateTime(2024),
          valuePrimary: 120,
          unit: 'mmHg',
          irregularHeartbeatDetected: const Value(false),
          createdAt: DateTime(2024),
        ),
      );

      await (database.update(database.measurementRecords)
            ..where((r) => r.id.equals(recordId)))
          .write(
        db.MeasurementRecordsCompanion(
          irregularHeartbeatDetected: const Value(null),
        ),
      );

      final record = await database.measurementDao.getRecord(recordId);
      expect(record!.irregularHeartbeatDetected, isNull);
    });

    test('non-blood-pressure records are unaffected', () async {
      await _seedMeasurementTypesV4(database);

      final pulseType = await database.measurementDao.getMeasurementTypeByKey(
        'pulse',
      );
      final profileId = await database.into(database.profiles).insert(
        db.ProfilesCompanion.insert(
          firstName: 'Test',
          lastName: 'User',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      );

      final recordId = await database.into(database.measurementRecords).insert(
        db.MeasurementRecordsCompanion.insert(
          profileId: profileId,
          measurementTypeId: pulseType!.id,
          timestamp: DateTime(2024),
          valuePrimary: 72,
          unit: 'bpm',
          createdAt: DateTime(2024),
        ),
      );

      final record = await database.measurementDao.getRecord(recordId);
      expect(record, isNotNull);
      expect(record!.irregularHeartbeatDetected, isNull);
    });
  });
}

Future<void> _seedMeasurementTypesV4(db.AppDatabase database) async {
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
    final existing = await (database.select(database.measurementTypes)
          ..where((mt) => mt.key.equals(t.key)))
        .getSingleOrNull();
    if (existing != null) continue;

    final typeId = await database.into(database.measurementTypes).insert(
      db.MeasurementTypesCompanion.insert(
        name: t.name,
        unit: t.unit,
        measurementCategory: t.category,
        key: Value(t.key),
        displayOrder: Value(t.order),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
    );

    if (t.key == 'blood_pressure') {
      final fields = [
        (key: 'systolic', label: 'Systolic', unit: 'mmHg', order: 0, min: 40.0, max: 300.0),
        (key: 'diastolic', label: 'Diastolic', unit: 'mmHg', order: 1, min: 20.0, max: 200.0),
        (key: 'pulse', label: 'Pulse', unit: 'bpm', order: 2, min: 30.0, max: 250.0),
      ];
      for (final f in fields) {
        await database.into(database.measurementTypeFields).insert(
          db.MeasurementTypeFieldsCompanion.insert(
            measurementTypeId: typeId,
            fieldKey: f.key,
            label: f.label,
            defaultUnit: Value(f.unit),
            required: f.key != 'pulse' ? const Value(true) : const Value(false),
            minimumValue: Value(f.min),
            maximumValue: Value(f.max),
            decimalPlaces: const Value(0),
            displayOrder: Value(f.order),
            createdAt: now,
          ),
        );
      }
    } else if (t.key == 'pulse') {
      await database.into(database.measurementTypeFields).insert(
        db.MeasurementTypeFieldsCompanion.insert(
          measurementTypeId: typeId,
          fieldKey: 'pulse',
          label: 'Pulse',
          defaultUnit: const Value('bpm'),
          required: const Value(true),
          minimumValue: const Value(30),
          maximumValue: const Value(250),
          decimalPlaces: const Value(0),
          createdAt: now,
        ),
      );
    } else if (t.key == 'weight') {
      await database.into(database.measurementTypeFields).insert(
        db.MeasurementTypeFieldsCompanion.insert(
          measurementTypeId: typeId,
          fieldKey: 'weight',
          label: 'Weight',
          defaultUnit: const Value('kg'),
          required: const Value(true),
          minimumValue: const Value(1),
          maximumValue: const Value(500),
          decimalPlaces: const Value(1),
          createdAt: now,
        ),
      );
    } else if (t.key == 'blood_glucose') {
      await database.into(database.measurementTypeFields).insert(
        db.MeasurementTypeFieldsCompanion.insert(
          measurementTypeId: typeId,
          fieldKey: 'glucose',
          label: 'Blood Glucose',
          defaultUnit: const Value('mmol/L'),
          required: const Value(true),
          minimumValue: const Value(1),
          maximumValue: const Value(50),
          decimalPlaces: const Value(1),
          createdAt: now,
        ),
      );
    } else if (t.key == 'spo2') {
      await database.into(database.measurementTypeFields).insert(
        db.MeasurementTypeFieldsCompanion.insert(
          measurementTypeId: typeId,
          fieldKey: 'spo2',
          label: 'SpO2',
          defaultUnit: const Value('%'),
          required: const Value(true),
          minimumValue: const Value(50),
          maximumValue: const Value(100),
          decimalPlaces: const Value(0),
          createdAt: now,
        ),
      );
    } else if (t.key == 'temperature') {
      await database.into(database.measurementTypeFields).insert(
        db.MeasurementTypeFieldsCompanion.insert(
          measurementTypeId: typeId,
          fieldKey: 'temperature',
          label: 'Temperature',
          defaultUnit: const Value('°C'),
          required: const Value(true),
          minimumValue: const Value(30),
          maximumValue: const Value(45),
          decimalPlaces: const Value(1),
          createdAt: now,
        ),
      );
    }
  }
}
