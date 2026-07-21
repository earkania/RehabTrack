import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:rehab_track/data/database/tables/profile_table.dart';
import 'package:rehab_track/data/database/tables/medication_tables.dart';
import 'package:rehab_track/data/database/tables/measurement_tables.dart';
import 'package:rehab_track/data/database/tables/exercise_tables.dart';
import 'package:rehab_track/data/database/tables/doctor_tables.dart';
import 'package:rehab_track/data/database/tables/document_table.dart';
import 'package:rehab_track/data/database/tables/diet_tables.dart';
import 'package:rehab_track/data/database/tables/health_template_table.dart';
import 'package:rehab_track/data/database/tables/app_setting_table.dart';
import 'package:rehab_track/data/database/seed_data.dart';
import 'package:rehab_track/data/database/daos/profile_dao.dart';
import 'package:rehab_track/data/database/daos/medication_dao.dart';
import 'package:rehab_track/data/database/daos/measurement_dao.dart';
import 'package:rehab_track/data/database/daos/exercise_dao.dart';
import 'package:rehab_track/data/database/daos/doctor_dao.dart';
import 'package:rehab_track/data/database/daos/document_dao.dart';
import 'package:rehab_track/data/database/daos/diet_dao.dart';
import 'package:rehab_track/data/database/daos/health_template_dao.dart';
import 'package:rehab_track/data/database/daos/app_setting_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Profiles,
    Medications,
    MedicationSchedules,
    MedicationLogs,
    MeasurementTypes,
    MeasurementRecords,
    MeasurementSchedules,
    ExerciseTypes,
    ExerciseGoals,
    ExerciseLogs,
    Doctors,
    DoctorVisits,
    DocumentAttachments,
    DietPlans,
    DietItems,
    HealthTemplates,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  ProfileDao get profileDao => ProfileDao(this);
  MedicationDao get medicationDao => MedicationDao(this);
  MeasurementDao get measurementDao => MeasurementDao(this);
  ExerciseDao get exerciseDao => ExerciseDao(this);
  DoctorDao get doctorDao => DoctorDao(this);
  DocumentDao get documentDao => DocumentDao(this);
  DietDao get dietDao => DietDao(this);
  HealthTemplateDao get healthTemplateDao =>
      HealthTemplateDao(this);
  AppSettingDao get appSettingDao => AppSettingDao(this);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await seedDatabase(this);
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'rehabtrack.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
