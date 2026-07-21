import 'package:rehab_track/domain/entities/exercise.dart';

abstract class ExerciseRepository {
  Stream<List<ExerciseType>> watchTypes(int profileId);
  Future<List<ExerciseType>> getTypes(int profileId);
  Future<int> createType(ExerciseType type);
  Future<void> updateType(ExerciseType type);
  Future<void> deleteType(int id);

  Stream<List<ExerciseGoal>> watchGoals(int profileId);
  Future<List<ExerciseGoal>> getGoals(int profileId);
  Future<int> createGoal(ExerciseGoal goal);
  Future<void> updateGoal(ExerciseGoal goal);
  Future<void> deleteGoal(int id);

  Stream<List<ExerciseLog>> watchLogs(
    int profileId, {
    DateTime? from,
    DateTime? to,
  });
  Future<List<ExerciseLog>> getLogs(
    int profileId, {
    DateTime? from,
    DateTime? to,
  });
  Future<int> createLog(ExerciseLog log);
  Future<void> deleteLog(int id);
}
