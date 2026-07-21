import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/tables/profile_table.dart';

class ExerciseTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id)();
  TextColumn get name => text()();
  TextColumn get unit => text()();
  TextColumn get notes => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

class ExerciseGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id)();
  IntColumn get exerciseTypeId =>
      integer().references(ExerciseTypes, #id)();
  RealColumn get targetValue => real()();
  TextColumn get targetUnit => text()();
  TextColumn get frequency => text().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

class ExerciseLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id)();
  IntColumn get exerciseTypeId =>
      integer().references(ExerciseTypes, #id)();
  DateTimeColumn get logDate => dateTime()();
  IntColumn get durationMinutes => integer().nullable()();
  RealColumn get distance => real().nullable()();
  IntColumn get calories => integer().nullable()();
  TextColumn get notes => text().nullable()();
}
