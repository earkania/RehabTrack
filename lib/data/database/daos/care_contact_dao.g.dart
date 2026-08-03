// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'care_contact_dao.dart';

// ignore_for_file: type=lint
mixin _$CareContactDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $CareContactsTable get careContacts => attachedDatabase.careContacts;
  CareContactDaoManager get managers => CareContactDaoManager(this);
}

class CareContactDaoManager {
  final _$CareContactDaoMixin _db;
  CareContactDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$CareContactsTableTableManager get careContacts =>
      $$CareContactsTableTableManager(_db.attachedDatabase, _db.careContacts);
}
