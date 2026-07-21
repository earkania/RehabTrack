// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_alternatives_dao.dart';

// ignore_for_file: type=lint
mixin _$MedicationAlternativesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $MedicationsTable get medications => attachedDatabase.medications;
  $MedicationAlternativesTable get medicationAlternatives =>
      attachedDatabase.medicationAlternatives;
  MedicationAlternativesDaoManager get managers =>
      MedicationAlternativesDaoManager(this);
}

class MedicationAlternativesDaoManager {
  final _$MedicationAlternativesDaoMixin _db;
  MedicationAlternativesDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db.attachedDatabase, _db.medications);
  $$MedicationAlternativesTableTableManager get medicationAlternatives =>
      $$MedicationAlternativesTableTableManager(
        _db.attachedDatabase,
        _db.medicationAlternatives,
      );
}
