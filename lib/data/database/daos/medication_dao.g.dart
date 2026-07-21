// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_dao.dart';

// ignore_for_file: type=lint
mixin _$MedicationDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $MedicationsTable get medications => attachedDatabase.medications;
  $MedicationSchedulesTable get medicationSchedules =>
      attachedDatabase.medicationSchedules;
  $MedicationLogsTable get medicationLogs => attachedDatabase.medicationLogs;
  MedicationDaoManager get managers => MedicationDaoManager(this);
}

class MedicationDaoManager {
  final _$MedicationDaoMixin _db;
  MedicationDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db.attachedDatabase, _db.medications);
  $$MedicationSchedulesTableTableManager get medicationSchedules =>
      $$MedicationSchedulesTableTableManager(
        _db.attachedDatabase,
        _db.medicationSchedules,
      );
  $$MedicationLogsTableTableManager get medicationLogs =>
      $$MedicationLogsTableTableManager(
        _db.attachedDatabase,
        _db.medicationLogs,
      );
}
