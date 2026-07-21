import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/database/tables/exercise_tables.dart';

part 'exercise_dao.g.dart';

@DriftAccessor(
  tables: [ExerciseTypes, ExerciseGoals, ExerciseLogs],
)
class ExerciseDao extends DatabaseAccessor<AppDatabase>
    with _$ExerciseDaoMixin {
  ExerciseDao(super.db);

  Stream<List<ExerciseType>> watchTypes(int profileId) {
    return (select(exerciseTypes)
      ..where((t) => t.profileId.equals(profileId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.name),
      ])).watch();
  }

  Future<List<ExerciseType>> getTypes(int profileId) {
    return (select(exerciseTypes)
      ..where((t) => t.profileId.equals(profileId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.name),
      ])).get();
  }

  Future<int> insertType(ExerciseTypesCompanion entry) {
    return into(exerciseTypes).insert(entry);
  }

  Future<bool> updateType(ExerciseTypesCompanion entry) {
    return update(exerciseTypes).replace(entry);
  }

  Future<int> deleteType(int id) {
    return (delete(exerciseTypes)
      ..where((t) => t.id.equals(id))).go();
  }

  Stream<List<ExerciseGoal>> watchGoals(int profileId) {
    return (select(exerciseGoals)
      ..where((t) => t.profileId.equals(profileId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.exerciseTypeId),
      ])).watch();
  }

  Future<List<ExerciseGoal>> getGoals(int profileId) {
    return (select(exerciseGoals)
      ..where((t) => t.profileId.equals(profileId))).get();
  }

  Future<int> insertGoal(ExerciseGoalsCompanion entry) {
    return into(exerciseGoals).insert(entry);
  }

  Future<bool> updateGoal(ExerciseGoalsCompanion entry) {
    return update(exerciseGoals).replace(entry);
  }

  Future<int> deleteGoal(int id) {
    return (delete(exerciseGoals)
      ..where((t) => t.id.equals(id))).go();
  }

  Stream<List<ExerciseLog>> watchLogs(
    int profileId, {
    DateTime? from,
    DateTime? to,
  }) {
    final query = select(exerciseLogs)
      ..where((t) => t.profileId.equals(profileId));
    if (from != null) {
      query.where((t) => t.logDate.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((t) => t.logDate.isSmallerOrEqualValue(to));
    }
    query.orderBy([
      (t) => OrderingTerm.desc(t.logDate),
    ]);
    return query.watch();
  }

  Future<List<ExerciseLog>> getLogs(
    int profileId, {
    DateTime? from,
    DateTime? to,
  }) {
    final query = select(exerciseLogs)
      ..where((t) => t.profileId.equals(profileId));
    if (from != null) {
      query.where((t) => t.logDate.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((t) => t.logDate.isSmallerOrEqualValue(to));
    }
    query.orderBy([
      (t) => OrderingTerm.desc(t.logDate),
    ]);
    return query.get();
  }

  Future<int> insertLog(ExerciseLogsCompanion entry) {
    return into(exerciseLogs).insert(entry);
  }

  Future<int> deleteLog(int id) {
    return (delete(exerciseLogs)
      ..where((t) => t.id.equals(id))).go();
  }
}
