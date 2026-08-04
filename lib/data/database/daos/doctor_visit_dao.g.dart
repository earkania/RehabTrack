// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_visit_dao.dart';

// ignore_for_file: type=lint
mixin _$DoctorVisitDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $CareContactsTable get careContacts => attachedDatabase.careContacts;
  $DoctorVisitRecordsTable get doctorVisitRecords =>
      attachedDatabase.doctorVisitRecords;
  DoctorVisitDaoManager get managers => DoctorVisitDaoManager(this);
}

class DoctorVisitDaoManager {
  final _$DoctorVisitDaoMixin _db;
  DoctorVisitDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$CareContactsTableTableManager get careContacts =>
      $$CareContactsTableTableManager(_db.attachedDatabase, _db.careContacts);
  $$DoctorVisitRecordsTableTableManager get doctorVisitRecords =>
      $$DoctorVisitRecordsTableTableManager(
        _db.attachedDatabase,
        _db.doctorVisitRecords,
      );
}
