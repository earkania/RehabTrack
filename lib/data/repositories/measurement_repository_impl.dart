import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/schedule_config.dart';
import 'package:rehab_track/domain/repositories/measurement_repository.dart';

class MeasurementRepositoryImpl implements MeasurementRepository {
  final db.AppDatabase _database;

  MeasurementRepositoryImpl(this._database);

  @override
  Stream<List<MeasurementType>> watchActiveMeasurementTypes(
    int? profileId,
  ) {
    return _database.measurementDao
        .watchActiveMeasurementTypes(profileId)
        .map((rows) => rows.map(_typeToDomain).toList());
  }

  @override
  Stream<List<MeasurementType>> watchMeasurementTypes(
    int? profileId,
  ) {
    return _database.measurementDao
        .watchMeasurementTypes(profileId)
        .map((rows) => rows.map(_typeToDomain).toList());
  }

  @override
  Future<List<MeasurementType>> getMeasurementTypes(
    int? profileId,
  ) async {
    final rows = await _database.measurementDao
        .getMeasurementTypes(profileId);
    return rows.map(_typeToDomain).toList();
  }

  @override
  Future<MeasurementType?> getMeasurementType(int id) async {
    final row =
        await _database.measurementDao.getMeasurementType(id);
    return row != null ? _typeToDomain(row) : null;
  }

  @override
  Future<MeasurementType?> getMeasurementTypeByKey(
    String key,
  ) async {
    final row = await _database.measurementDao
        .getMeasurementTypeByKey(key);
    return row != null ? _typeToDomain(row) : null;
  }

  @override
  Future<int> createMeasurementType(MeasurementType type) async {
    final now = DateTime.now();
    return _database.measurementDao.insertMeasurementType(
      db.MeasurementTypesCompanion.insert(
        name: type.name,
        unit: type.unit,
        defaultUnit: Value(type.defaultUnit),
        measurementCategory: type.measurementCategory,
        isSystem: Value(type.isSystem),
        active: Value(type.active),
        profileId: Value(type.profileId),
        key: Value(type.key),
        displayOrder: Value(type.displayOrder),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  Future<void> updateMeasurementType(MeasurementType type) async {
    await _database.measurementDao.updateMeasurementType(
      db.MeasurementTypesCompanion(
        id: Value(type.id!),
        name: Value(type.name),
        unit: Value(type.unit),
        defaultUnit: Value(type.defaultUnit),
        measurementCategory:
            Value(type.measurementCategory),
        isSystem: Value(type.isSystem),
        active: Value(type.active),
        profileId: Value(type.profileId),
        key: Value(type.key),
        displayOrder: Value(type.displayOrder),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deactivateMeasurementType(int id) async {
    await _database.measurementDao.updateMeasurementType(
      db.MeasurementTypesCompanion(
        id: Value(id),
        active: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // --- Fields ---

  @override
  Stream<List<MeasurementTypeField>> watchFieldsForType(
    int measurementTypeId,
  ) {
    return _database.measurementDao
        .watchFieldsForType(measurementTypeId)
        .map((rows) => rows.map(_fieldToDomain).toList());
  }

  @override
  Future<List<MeasurementTypeField>> getFieldsForType(
    int measurementTypeId,
  ) async {
    final rows = await _database.measurementDao
        .getFieldsForType(measurementTypeId);
    return rows.map(_fieldToDomain).toList();
  }

  // --- Records ---

  @override
  Stream<List<MeasurementRecord>> watchRecords(
    int profileId, {
    int? typeId,
    DateTime? from,
    DateTime? to,
  }) {
    return _database.measurementDao
        .watchRecords(
          profileId,
          typeId: typeId,
          from: from,
          to: to,
        )
        .map((rows) => rows.map(_recordToDomain).toList());
  }

  @override
  Future<List<MeasurementRecord>> getRecords(
    int profileId, {
    int? typeId,
    DateTime? from,
    DateTime? to,
  }) async {
    final rows = await _database.measurementDao.getRecords(
      profileId,
      typeId: typeId,
      from: from,
      to: to,
    );
    return rows.map(_recordToDomain).toList();
  }

  @override
  Future<MeasurementRecord?> getRecord(int id) async {
    final row = await _database.measurementDao.getRecord(id);
    return row != null ? _recordToDomain(row) : null;
  }

  @override
  Future<int> createRecord(
    MeasurementRecord record,
    List<MeasurementRecordValue> values,
  ) async {
    return _database.transaction(() async {
      final now = DateTime.now();
      final recordId = await _database.measurementDao.insertRecord(
        db.MeasurementRecordsCompanion.insert(
          profileId: record.profileId,
          measurementTypeId: record.measurementTypeId,
          timestamp: record.timestamp,
          valuePrimary: record.valuePrimary,
          valueSecondary: Value(record.valueSecondary),
          valueTertiary: Value(record.valueTertiary),
          unit: record.unit,
          notes: Value(record.notes),
          createdAt: now,
          updatedAt: Value(now),
        ),
      );
      if (values.isNotEmpty) {
        await _database.measurementDao.replaceRecordValues(
          recordId,
          values
              .map(
                (v) => db.MeasurementRecordValuesCompanion.insert(
                  measurementRecordId: recordId,
                  fieldKey: v.fieldKey,
                  numericValue: v.numericValue,
                  unit: v.unit,
                  displayOrder: Value(v.displayOrder),
                ),
              )
              .toList(),
        );
      }
      return recordId;
    });
  }

  @override
  Future<void> updateRecord(
    MeasurementRecord record,
    List<MeasurementRecordValue> values,
  ) async {
    await _database.transaction(() async {
      await _database.measurementDao.updateRecord(
        db.MeasurementRecordsCompanion(
          id: Value(record.id!),
          profileId: Value(record.profileId),
          measurementTypeId: Value(record.measurementTypeId),
          timestamp: Value(record.timestamp),
          valuePrimary: Value(record.valuePrimary),
          valueSecondary: Value(record.valueSecondary),
          valueTertiary: Value(record.valueTertiary),
          unit: Value(record.unit),
          notes: Value(record.notes),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _database.measurementDao.replaceRecordValues(
        record.id!,
        values
            .map(
              (v) => db.MeasurementRecordValuesCompanion(
                id: v.id != null ? Value(v.id!) : const Value.absent(),
                measurementRecordId: Value(record.id!),
                fieldKey: Value(v.fieldKey),
                numericValue: Value(v.numericValue),
                unit: Value(v.unit),
                displayOrder: Value(v.displayOrder),
              ),
            )
            .toList(),
      );
    });
  }

  @override
  Future<void> deleteRecord(int id) async {
    await _database.transaction(() async {
      await _database.measurementDao.deleteRecord(id);
    });
  }

  // --- Record Values ---

  @override
  Future<List<MeasurementRecordValue>> getValuesForRecord(
    int measurementRecordId,
  ) async {
    final rows = await _database.measurementDao
        .getValuesForRecord(measurementRecordId);
    return rows.map(_recordValueToDomain).toList();
  }

  // --- Schedules ---

  @override
  Stream<List<MeasurementSchedule>> watchSchedules(
    int profileId,
  ) {
    return _database.measurementDao
        .watchSchedules(profileId)
        .map((rows) => rows.map(_scheduleToDomain).toList());
  }

  @override
  Future<int> createSchedule(MeasurementSchedule schedule) async {
    return _database.measurementDao.insertSchedule(
      db.MeasurementSchedulesCompanion.insert(
        profileId: schedule.profileId,
        measurementTypeId: schedule.measurementTypeId,
        scheduleConfig:
            schedule.scheduleConfig.toJsonString(),
        startDate: Value(schedule.startDate),
        endDate: Value(schedule.endDate),
        active: Value(schedule.active),
      ),
    );
  }

  @override
  Future<void> updateSchedule(MeasurementSchedule schedule) async {
    await _database.measurementDao.updateSchedule(
      db.MeasurementSchedulesCompanion(
        id: Value(schedule.id!),
        profileId: Value(schedule.profileId),
        measurementTypeId:
            Value(schedule.measurementTypeId),
        scheduleConfig:
            Value(schedule.scheduleConfig.toJsonString()),
        startDate: Value(schedule.startDate),
        endDate: Value(schedule.endDate),
        active: Value(schedule.active),
      ),
    );
  }

  @override
  Future<void> deleteSchedule(int id) async {
    await _database.measurementDao.deleteSchedule(id);
  }

  // --- Mappers ---

  MeasurementType _typeToDomain(db.MeasurementType row) {
    return MeasurementType(
      id: row.id,
      profileId: row.profileId,
      key: row.key,
      name: row.name,
      unit: row.unit,
      defaultUnit: row.defaultUnit,
      measurementCategory: row.measurementCategory,
      isSystem: row.isSystem,
      active: row.active,
      displayOrder: row.displayOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  MeasurementTypeField _fieldToDomain(
    db.MeasurementTypeField row,
  ) {
    return MeasurementTypeField(
      id: row.id,
      measurementTypeId: row.measurementTypeId,
      fieldKey: row.fieldKey,
      label: row.label,
      defaultUnit: row.defaultUnit,
      required: row.required,
      minimumValue: row.minimumValue,
      maximumValue: row.maximumValue,
      decimalPlaces: row.decimalPlaces,
      displayOrder: row.displayOrder,
      createdAt: row.createdAt,
    );
  }

  MeasurementRecord _recordToDomain(db.MeasurementRecord row) {
    return MeasurementRecord(
      id: row.id,
      profileId: row.profileId,
      measurementTypeId: row.measurementTypeId,
      timestamp: row.timestamp,
      valuePrimary: row.valuePrimary,
      valueSecondary: row.valueSecondary,
      valueTertiary: row.valueTertiary,
      unit: row.unit,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  MeasurementRecordValue _recordValueToDomain(
    db.MeasurementRecordValue row,
  ) {
    return MeasurementRecordValue(
      id: row.id,
      measurementRecordId: row.measurementRecordId,
      fieldKey: row.fieldKey,
      numericValue: row.numericValue,
      unit: row.unit,
      displayOrder: row.displayOrder,
    );
  }

  MeasurementSchedule _scheduleToDomain(
    db.MeasurementSchedule row,
  ) {
    return MeasurementSchedule(
      id: row.id,
      profileId: row.profileId,
      measurementTypeId: row.measurementTypeId,
      scheduleConfig:
          ScheduleConfig.fromJsonString(row.scheduleConfig),
      startDate: row.startDate,
      endDate: row.endDate,
      active: row.active,
    );
  }
}
