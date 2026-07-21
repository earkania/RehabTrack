import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/domain/entities/exercise.dart';
import 'package:rehab_track/domain/repositories/exercise_repository.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  final db.AppDatabase _database;

  ExerciseRepositoryImpl(this._database);

  @override
  Stream<List<ExerciseType>> watchTypes(int profileId) {
    return _database.exerciseDao
        .watchTypes(profileId)
        .map((rows) => rows.map(_typeToDomain).toList());
  }

  @override
  Future<List<ExerciseType>> getTypes(int profileId) async {
    final rows =
        await _database.exerciseDao.getTypes(profileId);
    return rows.map(_typeToDomain).toList();
  }

  @override
  Future<int> createType(ExerciseType type) async {
    return _database.exerciseDao.insertType(
      db.ExerciseTypesCompanion.insert(
        profileId: type.profileId,
        name: type.name,
        unit: type.unit,
        notes: Value(type.notes),
        active: Value(type.active),
      ),
    );
  }

  @override
  Future<void> updateType(ExerciseType type) async {
    await _database.exerciseDao.updateType(
      db.ExerciseTypesCompanion(
        id: Value(type.id!),
        profileId: Value(type.profileId),
        name: Value(type.name),
        unit: Value(type.unit),
        notes: Value(type.notes),
        active: Value(type.active),
      ),
    );
  }

  @override
  Future<void> deleteType(int id) async {
    await _database.exerciseDao.deleteType(id);
  }

  @override
  Stream<List<ExerciseGoal>> watchGoals(int profileId) {
    return _database.exerciseDao
        .watchGoals(profileId)
        .map((rows) => rows.map(_goalToDomain).toList());
  }

  @override
  Future<List<ExerciseGoal>> getGoals(int profileId) async {
    final rows =
        await _database.exerciseDao.getGoals(profileId);
    return rows.map(_goalToDomain).toList();
  }

  @override
  Future<int> createGoal(ExerciseGoal goal) async {
    return _database.exerciseDao.insertGoal(
      db.ExerciseGoalsCompanion.insert(
        profileId: goal.profileId,
        exerciseTypeId: goal.exerciseTypeId,
        targetValue: goal.targetValue,
        targetUnit: goal.targetUnit,
        frequency: Value(goal.frequency),
        startDate: Value(goal.startDate),
        endDate: Value(goal.endDate),
        active: Value(goal.active),
      ),
    );
  }

  @override
  Future<void> updateGoal(ExerciseGoal goal) async {
    await _database.exerciseDao.updateGoal(
      db.ExerciseGoalsCompanion(
        id: Value(goal.id!),
        profileId: Value(goal.profileId),
        exerciseTypeId: Value(goal.exerciseTypeId),
        targetValue: Value(goal.targetValue),
        targetUnit: Value(goal.targetUnit),
        frequency: Value(goal.frequency),
        startDate: Value(goal.startDate),
        endDate: Value(goal.endDate),
        active: Value(goal.active),
      ),
    );
  }

  @override
  Future<void> deleteGoal(int id) async {
    await _database.exerciseDao.deleteGoal(id);
  }

  @override
  Stream<List<ExerciseLog>> watchLogs(
    int profileId, {
    DateTime? from,
    DateTime? to,
  }) {
    return _database.exerciseDao
        .watchLogs(profileId, from: from, to: to)
        .map((rows) => rows.map(_logToDomain).toList());
  }

  @override
  Future<List<ExerciseLog>> getLogs(
    int profileId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final rows = await _database.exerciseDao.getLogs(
      profileId,
      from: from,
      to: to,
    );
    return rows.map(_logToDomain).toList();
  }

  @override
  Future<int> createLog(ExerciseLog log) async {
    return _database.exerciseDao.insertLog(
      db.ExerciseLogsCompanion.insert(
        profileId: log.profileId,
        exerciseTypeId: log.exerciseTypeId,
        logDate: log.logDate,
        durationMinutes: Value(log.durationMinutes),
        distance: Value(log.distance),
        calories: Value(log.calories),
        notes: Value(log.notes),
      ),
    );
  }

  @override
  Future<void> deleteLog(int id) async {
    await _database.exerciseDao.deleteLog(id);
  }

  ExerciseType _typeToDomain(db.ExerciseType row) {
    return ExerciseType(
      id: row.id,
      profileId: row.profileId,
      name: row.name,
      unit: row.unit,
      notes: row.notes,
      active: row.active,
    );
  }

  ExerciseGoal _goalToDomain(db.ExerciseGoal row) {
    return ExerciseGoal(
      id: row.id,
      profileId: row.profileId,
      exerciseTypeId: row.exerciseTypeId,
      targetValue: row.targetValue,
      targetUnit: row.targetUnit,
      frequency: row.frequency,
      startDate: row.startDate,
      endDate: row.endDate,
      active: row.active,
    );
  }

  ExerciseLog _logToDomain(db.ExerciseLog row) {
    return ExerciseLog(
      id: row.id,
      profileId: row.profileId,
      exerciseTypeId: row.exerciseTypeId,
      logDate: row.logDate,
      durationMinutes: row.durationMinutes,
      distance: row.distance,
      calories: row.calories,
      notes: row.notes,
    );
  }
}
