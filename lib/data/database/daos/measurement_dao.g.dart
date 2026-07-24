// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_dao.dart';

// ignore_for_file: type=lint
mixin _$MeasurementDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $MeasurementTypesTable get measurementTypes =>
      attachedDatabase.measurementTypes;
  $MeasurementTypeFieldsTable get measurementTypeFields =>
      attachedDatabase.measurementTypeFields;
  $MeasurementRecordsTable get measurementRecords =>
      attachedDatabase.measurementRecords;
  $MeasurementRecordValuesTable get measurementRecordValues =>
      attachedDatabase.measurementRecordValues;
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
  $$MeasurementTypeFieldsTableTableManager get measurementTypeFields =>
      $$MeasurementTypeFieldsTableTableManager(
        _db.attachedDatabase,
        _db.measurementTypeFields,
      );
  $$MeasurementRecordsTableTableManager get measurementRecords =>
      $$MeasurementRecordsTableTableManager(
        _db.attachedDatabase,
        _db.measurementRecords,
      );
  $$MeasurementRecordValuesTableTableManager get measurementRecordValues =>
      $$MeasurementRecordValuesTableTableManager(
        _db.attachedDatabase,
        _db.measurementRecordValues,
      );
  $$MeasurementSchedulesTableTableManager get measurementSchedules =>
      $$MeasurementSchedulesTableTableManager(
        _db.attachedDatabase,
        _db.measurementSchedules,
      );
}
