// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_dao.dart';

// ignore_for_file: type=lint
mixin _$ActivityDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $ActivitiesTable get activities => attachedDatabase.activities;
  $ActivitySessionsTable get activitySessions =>
      attachedDatabase.activitySessions;
  ActivityDaoManager get managers => ActivityDaoManager(this);
}

class ActivityDaoManager {
  final _$ActivityDaoMixin _db;
  ActivityDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db.attachedDatabase, _db.activities);
  $$ActivitySessionsTableTableManager get activitySessions =>
      $$ActivitySessionsTableTableManager(
        _db.attachedDatabase,
        _db.activitySessions,
      );
}
