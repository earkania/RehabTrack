// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_dao.dart';

// ignore_for_file: type=lint
mixin _$MeasurementDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $MeasurementTypesTable get measurementTypes =>
      attachedDatabase.measurementTypes;
  $MeasurementRecordsTable get measurementRecords =>
      attachedDatabase.measurementRecords;
  $MeasurementSchedulesTable get measurementSchedules =>
      attachedDatabase.measurementSchedules;
  MeasurementDaoManager get managers => MeasurementDaoManager(this);
}

class MeasurementDaoManager {
  final _$MeasurementDaoMixin _db;
  MeasurementDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$MeasurementTypesTableTableManager get measurementTypes =>
      $$MeasurementTypesTableTableManager(
        _db.attachedDatabase,
        _db.measurementTypes,
      );
  $$MeasurementRecordsTableTableManager get measurementRecords =>
      $$MeasurementRecordsTableTableManager(
        _db.attachedDatabase,
        _db.measurementRecords,
      );
  $$MeasurementSchedulesTableTableManager get measurementSchedules =>
      $$MeasurementSchedulesTableTableManager(
        _db.attachedDatabase,
        _db.measurementSchedules,
      );
}
