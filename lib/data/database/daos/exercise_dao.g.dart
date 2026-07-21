// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_dao.dart';

// ignore_for_file: type=lint
mixin _$ExerciseDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $ExerciseTypesTable get exerciseTypes => attachedDatabase.exerciseTypes;
  $ExerciseGoalsTable get exerciseGoals => attachedDatabase.exerciseGoals;
  $ExerciseLogsTable get exerciseLogs => attachedDatabase.exerciseLogs;
  ExerciseDaoManager get managers => ExerciseDaoManager(this);
}

class ExerciseDaoManager {
  final _$ExerciseDaoMixin _db;
  ExerciseDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$ExerciseTypesTableTableManager get exerciseTypes =>
      $$ExerciseTypesTableTableManager(_db.attachedDatabase, _db.exerciseTypes);
  $$ExerciseGoalsTableTableManager get exerciseGoals =>
      $$ExerciseGoalsTableTableManager(_db.attachedDatabase, _db.exerciseGoals);
  $$ExerciseLogsTableTableManager get exerciseLogs =>
      $$ExerciseLogsTableTableManager(_db.attachedDatabase, _db.exerciseLogs);
}
