import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/schedule_config.dart';
import 'package:rehab_track/domain/repositories/measurement_repository.dart';

class MeasurementRepositoryImpl implements MeasurementRepository {
  final db.AppDatabase _database;

  MeasurementRepositoryImpl(this._database);

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
  Future<int> createMeasurementType(MeasurementType type) async {
    final now = DateTime.now();
    return _database.measurementDao.insertMeasurementType(
      db.MeasurementTypesCompanion.insert(
        name: type.name,
        unit: type.unit,
        measurementCategory: type.measurementCategory,
        isSystem: Value(type.isSystem),
        active: Value(type.active),
        profileId: Value(type.profileId),
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
        measurementCategory:
            Value(type.measurementCategory),
        isSystem: Value(type.isSystem),
        active: Value(type.active),
        profileId: Value(type.profileId),
      ),
    );
  }

  @override
  Future<void> deleteMeasurementType(int id) async {
    await _database.measurementDao.deleteMeasurementType(id);
  }

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
  Future<int> createRecord(MeasurementRecord record) async {
    return _database.measurementDao.insertRecord(
      db.MeasurementRecordsCompanion.insert(
        profileId: record.profileId,
        measurementTypeId: record.measurementTypeId,
        timestamp: record.timestamp,
        valuePrimary: record.valuePrimary,
        valueSecondary: Value(record.valueSecondary),
        valueTertiary: Value(record.valueTertiary),
        unit: record.unit,
        notes: Value(record.notes),
        createdAt: record.createdAt,
      ),
    );
  }

  @override
  Future<void> deleteRecord(int id) async {
    await _database.measurementDao.deleteRecord(id);
  }

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

  MeasurementType _typeToDomain(db.MeasurementType row) {
    return MeasurementType(
      id: row.id,
      profileId: row.profileId,
      name: row.name,
      unit: row.unit,
      measurementCategory: row.measurementCategory,
      isSystem: row.isSystem,
      active: row.active,
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
