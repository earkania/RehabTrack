import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/data/repositories/measurement_repository_impl.dart';
import 'package:rehab_track/domain/entities/measurement.dart';

void main() {
  late db.AppDatabase database;
  late MeasurementRepositoryImpl repo;

  setUp(() async {
    database = db.AppDatabase.test();
    repo = MeasurementRepositoryImpl(database);
    await _seedMeasurementTypes(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('Measurement edit diagnosis', () {
    test('updateRecord via repository should succeed', () async {
      final profileId = await database.into(database.profiles).insert(
        db.ProfilesCompanion.insert(
          firstName: 'Test',
          lastName: 'User',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      );

      final bpType =
          await database.measurementDao.getMeasurementTypeByKey('blood_pressure');
      expect(bpType, isNotNull);

      final now = DateTime(2024);
      final recordId = await repo.createRecord(
        MeasurementRecord(
          profileId: profileId,
          measurementTypeId: bpType!.id,
          timestamp: now,
          valuePrimary: 120,
          unit: 'mmHg',
          createdAt: now,
        ),
        [
          MeasurementRecordValue(
            measurementRecordId: 0,
            fieldKey: 'systolic',
            numericValue: 120,
            unit: 'mmHg',
            displayOrder: 0,
          ),
          MeasurementRecordValue(
            measurementRecordId: 0,
            fieldKey: 'diastolic',
            numericValue: 80,
            unit: 'mmHg',
            displayOrder: 1,
          ),
        ],
      );

      final created = await repo.getRecord(recordId);
      expect(created, isNotNull);
      expect(created!.valuePrimary, 120);

      final createdValues = await repo.getValuesForRecord(recordId);
      expect(createdValues.length, 2);

      // Now try to update the record
      final updatedRecord = created.copyWith(
        timestamp: DateTime(2024, 6, 15),
        valuePrimary: 130,
        unit: 'mmHg',
        updatedAt: DateTime.now(),
      );

      final updatedValues = [
        MeasurementRecordValue(
          measurementRecordId: recordId,
          fieldKey: 'systolic',
          numericValue: 130,
          unit: 'mmHg',
          displayOrder: 0,
        ),
        MeasurementRecordValue(
          measurementRecordId: recordId,
          fieldKey: 'diastolic',
          numericValue: 85,
          unit: 'mmHg',
          displayOrder: 1,
        ),
      ];

      // This should NOT throw
      try {
        await repo.updateRecord(updatedRecord, updatedValues);
      } catch (e) {
        fail('updateRecord threw: $e');
      }

      // Verify the update
      final afterUpdate = await repo.getRecord(recordId);
      expect(afterUpdate, isNotNull);
      expect(afterUpdate!.valuePrimary, 130);
      expect(afterUpdate.id, recordId);

      final afterValues = await repo.getValuesForRecord(recordId);
      expect(afterValues.length, 2);

      final sysValue = afterValues.firstWhere((v) => v.fieldKey == 'systolic');
      expect(sysValue.numericValue, 130);

      final diaValue = afterValues.firstWhere((v) => v.fieldKey == 'diastolic');
      expect(diaValue.numericValue, 85);
    });

    test('updateRecord preserves createdAt and irregularHeartbeatDetected',
        () async {
      final profileId = await database.into(database.profiles).insert(
        db.ProfilesCompanion.insert(
          firstName: 'Test',
          lastName: 'User',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      );

      final bpType =
          await database.measurementDao.getMeasurementTypeByKey('blood_pressure');
      expect(bpType, isNotNull);

      final recordId = await repo.createRecord(
        MeasurementRecord(
          profileId: profileId,
          measurementTypeId: bpType!.id,
          timestamp: DateTime(2024, 1, 1),
          valuePrimary: 120,
          unit: 'mmHg',
          irregularHeartbeatDetected: true,
          createdAt: DateTime(2024, 1, 1, 10, 30),
        ),
        [
          MeasurementRecordValue(
            measurementRecordId: 0,
            fieldKey: 'systolic',
            numericValue: 120,
            unit: 'mmHg',
            displayOrder: 0,
          ),
          MeasurementRecordValue(
            measurementRecordId: 0,
            fieldKey: 'diastolic',
            numericValue: 80,
            unit: 'mmHg',
            displayOrder: 1,
          ),
        ],
      );

      final created = await repo.getRecord(recordId);
      expect(created, isNotNull); // ignore: is_not_null
      expect(created!.irregularHeartbeatDetected, true);
      final createdAt = created.createdAt;

      // Update the record
      final updatedRecord = created.copyWith(
        valuePrimary: 140,
        irregularHeartbeatDetected: false,
        updatedAt: DateTime.now(),
      );

      await repo.updateRecord(updatedRecord, [
        MeasurementRecordValue(
          measurementRecordId: recordId,
          fieldKey: 'systolic',
          numericValue: 140,
          unit: 'mmHg',
          displayOrder: 0,
        ),
        MeasurementRecordValue(
          measurementRecordId: recordId,
          fieldKey: 'diastolic',
          numericValue: 90,
          unit: 'mmHg',
          displayOrder: 1,
        ),
      ]);

      final after = await repo.getRecord(recordId);
      expect(after, isNotNull);
      expect(after!.id, recordId);
      expect(after.createdAt, createdAt);
      expect(after.irregularHeartbeatDetected, false);
      expect(after.valuePrimary, 140);
    });

    test('updateRecord replaces values without duplicates', () async {
      final profileId = await database.into(database.profiles).insert(
        db.ProfilesCompanion.insert(
          firstName: 'Test',
          lastName: 'User',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      );

      final bpType =
          await database.measurementDao.getMeasurementTypeByKey('blood_pressure');
      expect(bpType, isNotNull);

      final recordId = await repo.createRecord(
        MeasurementRecord(
          profileId: profileId,
          measurementTypeId: bpType!.id,
          timestamp: DateTime(2024),
          valuePrimary: 120,
          unit: 'mmHg',
          createdAt: DateTime(2024),
        ),
        [
          MeasurementRecordValue(
            measurementRecordId: 0,
            fieldKey: 'systolic',
            numericValue: 120,
            unit: 'mmHg',
            displayOrder: 0,
          ),
          MeasurementRecordValue(
            measurementRecordId: 0,
            fieldKey: 'diastolic',
            numericValue: 80,
            unit: 'mmHg',
            displayOrder: 1,
          ),
        ],
      );

      // Update once
      final created = (await repo.getRecord(recordId))!;
      await repo.updateRecord(
        created.copyWith(valuePrimary: 130, updatedAt: DateTime.now()),
        [
          MeasurementRecordValue(
            measurementRecordId: recordId,
            fieldKey: 'systolic',
            numericValue: 130,
            unit: 'mmHg',
            displayOrder: 0,
          ),
          MeasurementRecordValue(
            measurementRecordId: recordId,
            fieldKey: 'diastolic',
            numericValue: 85,
            unit: 'mmHg',
            displayOrder: 1,
          ),
        ],
      );

      // Update again
      final updated = (await repo.getRecord(recordId))!;
      await repo.updateRecord(
        updated.copyWith(valuePrimary: 140, updatedAt: DateTime.now()),
        [
          MeasurementRecordValue(
            measurementRecordId: recordId,
            fieldKey: 'systolic',
            numericValue: 140,
            unit: 'mmHg',
            displayOrder: 0,
          ),
          MeasurementRecordValue(
            measurementRecordId: recordId,
            fieldKey: 'diastolic',
            numericValue: 90,
            unit: 'mmHg',
            displayOrder: 1,
          ),
        ],
      );

      // Verify no duplicate values
      final values = await repo.getValuesForRecord(recordId);
      expect(values.length, 2);

      final sysValue = values.firstWhere((v) => v.fieldKey == 'systolic');
      expect(sysValue.numericValue, 140);

      final diaValue = values.firstWhere((v) => v.fieldKey == 'diastolic');
      expect(diaValue.numericValue, 90);
    });
  });
}

Future<void> _seedMeasurementTypes(db.AppDatabase database) async {
  final now = DateTime(2024);

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
      await _insertField(database, typeId, 'systolic', 'Systolic', 'mmHg', 0, true);
      await _insertField(database, typeId, 'diastolic', 'Diastolic', 'mmHg', 1, true);
      await _insertField(database, typeId, 'pulse', 'Pulse', 'bpm', 2, false);
    } else if (t.key == 'pulse') {
      await _insertField(database, typeId, 'pulse', 'Pulse', 'bpm', 0, true);
    } else if (t.key == 'weight') {
      await _insertField(database, typeId, 'weight', 'Weight', 'kg', 0, true);
    } else if (t.key == 'blood_glucose') {
      await _insertField(database, typeId, 'glucose', 'Glucose', 'mmol/L', 0, true);
    } else if (t.key == 'spo2') {
      await _insertField(database, typeId, 'spo2', 'SpO2', '%', 0, true);
      await _insertField(database, typeId, 'pulse', 'Pulse', 'bpm', 1, false);
    } else if (t.key == 'temperature') {
      await _insertField(database, typeId, 'temperature', 'Temperature', '°C', 0, true);
    }
  }
}

Future<void> _insertField(
  db.AppDatabase database,
  int typeId,
  String fieldKey,
  String label,
  String unit,
  int displayOrder,
  bool required,
) async {
  await database.into(database.measurementTypeFields).insert(
    db.MeasurementTypeFieldsCompanion.insert(
      measurementTypeId: typeId,
      fieldKey: fieldKey,
      label: label,
      defaultUnit: Value(unit),
      required: Value(required),
      displayOrder: Value(displayOrder),
      createdAt: DateTime(2024),
    ),
  );
}
