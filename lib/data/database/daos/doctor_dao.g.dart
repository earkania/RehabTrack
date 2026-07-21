// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_dao.dart';

// ignore_for_file: type=lint
mixin _$DoctorDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $DoctorsTable get doctors => attachedDatabase.doctors;
  $DoctorVisitsTable get doctorVisits => attachedDatabase.doctorVisits;
  DoctorDaoManager get managers => DoctorDaoManager(this);
}

class DoctorDaoManager {
  final _$DoctorDaoMixin _db;
  DoctorDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$DoctorsTableTableManager get doctors =>
      $$DoctorsTableTableManager(_db.attachedDatabase, _db.doctors);
  $$DoctorVisitsTableTableManager get doctorVisits =>
      $$DoctorVisitsTableTableManager(_db.attachedDatabase, _db.doctorVisits);
}
