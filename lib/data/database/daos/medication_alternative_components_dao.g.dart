// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_alternative_components_dao.dart';

// ignore_for_file: type=lint
mixin _$MedicationAlternativeComponentsDaoMixin
    on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $MedicationsTable get medications => attachedDatabase.medications;
  $MedicationAlternativesTable get medicationAlternatives =>
      attachedDatabase.medicationAlternatives;
  $MedicationAlternativeComponentsTable get medicationAlternativeComponents =>
      attachedDatabase.medicationAlternativeComponents;
  MedicationAlternativeComponentsDaoManager get managers =>
      MedicationAlternativeComponentsDaoManager(this);
}

class MedicationAlternativeComponentsDaoManager {
  final _$MedicationAlternativeComponentsDaoMixin _db;
  MedicationAlternativeComponentsDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db.attachedDatabase, _db.medications);
  $$MedicationAlternativesTableTableManager get medicationAlternatives =>
      $$MedicationAlternativesTableTableManager(
        _db.attachedDatabase,
        _db.medicationAlternatives,
      );
  $$MedicationAlternativeComponentsTableTableManager
  get medicationAlternativeComponents =>
      $$MedicationAlternativeComponentsTableTableManager(
        _db.attachedDatabase,
        _db.medicationAlternativeComponents,
      );
}
