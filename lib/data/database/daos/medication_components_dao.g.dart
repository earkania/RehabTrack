// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_components_dao.dart';

// ignore_for_file: type=lint
mixin _$MedicationComponentsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $MedicationsTable get medications => attachedDatabase.medications;
  $MedicationComponentsTable get medicationComponents =>
      attachedDatabase.medicationComponents;
  MedicationComponentsDaoManager get managers =>
      MedicationComponentsDaoManager(this);
}

class MedicationComponentsDaoManager {
  final _$MedicationComponentsDaoMixin _db;
  MedicationComponentsDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db.attachedDatabase, _db.medications);
  $$MedicationComponentsTableTableManager get medicationComponents =>
      $$MedicationComponentsTableTableManager(
        _db.attachedDatabase,
        _db.medicationComponents,
      );
}
