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
import 'package:rehab_track/data/database/daos/medication_alternatives_dao.dart';
import 'package:rehab_track/data/database/daos/medication_components_dao.dart';
import 'package:rehab_track/data/database/daos/medication_alternative_components_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Profiles,
    Medications,
    MedicationSchedules,
    MedicationLogs,
    MedicationAlternatives,
    MedicationComponents,
    MedicationAlternativeComponents,
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
  MedicationAlternativesDao get medicationAlternativesDao =>
      MedicationAlternativesDao(this);
  MedicationComponentsDao get medicationComponentsDao =>
      MedicationComponentsDao(this);
  MedicationAlternativeComponentsDao
      get medicationAlternativeComponentsDao =>
      MedicationAlternativeComponentsDao(this);
  MeasurementDao get measurementDao => MeasurementDao(this);
  ExerciseDao get exerciseDao => ExerciseDao(this);
  DoctorDao get doctorDao => DoctorDao(this);
  DocumentDao get documentDao => DocumentDao(this);
  DietDao get dietDao => DietDao(this);
  HealthTemplateDao get healthTemplateDao =>
      HealthTemplateDao(this);
  AppSettingDao get appSettingDao => AppSettingDao(this);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await seedDatabase(this);
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(medications, medications.doseAmount);
        await m.addColumn(medications, medications.doseUnit);
        await m.createTable(medicationAlternatives);
      }
      if (from < 3) {
        await m.createTable(medicationComponents);
        await m.createTable(medicationAlternativeComponents);

        // Migrate existing medication dose data into component rows.
        final meds = await select(medications).get();
        for (final med in meds) {
          if (med.doseAmount != null && med.doseAmount!.isNotEmpty) {
            await into(medicationComponents).insert(
              MedicationComponentsCompanion.insert(
                medicationId: med.id,
                doseAmount: med.doseAmount!,
                doseUnit: med.doseUnit ?? '',
                sortOrder: const Value(0),
                createdAt: DateTime.now(),
              ),
            );
          }
        }

        // Migrate existing alternative dose data into component rows.
        final alts = await select(medicationAlternatives).get();
        for (final alt in alts) {
          if (alt.doseAmount != null && alt.doseAmount!.isNotEmpty) {
            await into(medicationAlternativeComponents).insert(
              MedicationAlternativeComponentsCompanion.insert(
                medicationAlternativeId: alt.id,
                doseAmount: alt.doseAmount!,
                doseUnit: alt.doseUnit ?? '',
                sortOrder: const Value(0),
                createdAt: DateTime.now(),
              ),
            );
          }
        }
      }
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
