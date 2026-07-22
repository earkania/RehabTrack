import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/repositories/profile_repository_impl.dart';
import 'package:rehab_track/data/repositories/medication_repository_impl.dart';
import 'package:rehab_track/data/repositories/measurement_repository_impl.dart';
import 'package:rehab_track/data/repositories/exercise_repository_impl.dart';
import 'package:rehab_track/data/repositories/doctor_repository_impl.dart';
import 'package:rehab_track/data/repositories/document_repository_impl.dart';
import 'package:rehab_track/data/repositories/settings_repository_impl.dart';
import 'package:rehab_track/domain/repositories/profile_repository.dart';
import 'package:rehab_track/domain/repositories/medication_repository.dart';
import 'package:rehab_track/domain/repositories/measurement_repository.dart';
import 'package:rehab_track/domain/repositories/exercise_repository.dart';
import 'package:rehab_track/domain/repositories/doctor_repository.dart';
import 'package:rehab_track/domain/repositories/document_repository.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => database.close());
  return database;
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(databaseProvider));
});

final medicationRepositoryProvider =
    Provider<MedicationRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return MedicationRepositoryImpl(db, ref: ref);
});

final measurementRepositoryProvider =
    Provider<MeasurementRepository>((ref) {
  return MeasurementRepositoryImpl(ref.watch(databaseProvider));
});

final exerciseRepositoryProvider =
    Provider<ExerciseRepository>((ref) {
  return ExerciseRepositoryImpl(ref.watch(databaseProvider));
});

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepositoryImpl(ref.watch(databaseProvider));
});

final documentRepositoryProvider =
    Provider<DocumentRepository>((ref) {
  return DocumentRepositoryImpl(ref.watch(databaseProvider));
});

final settingsRepositoryProvider =
    Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(databaseProvider));
});
