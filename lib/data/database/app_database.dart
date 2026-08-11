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
import 'package:rehab_track/data/database/tables/care_contact_table.dart';
import 'package:rehab_track/data/database/tables/doctor_visit_records_table.dart';
import 'package:rehab_track/data/database/tables/document_table.dart';
import 'package:rehab_track/data/database/tables/diet_tables.dart';
import 'package:rehab_track/data/database/tables/health_template_table.dart';
import 'package:rehab_track/data/database/tables/app_setting_table.dart';
import 'package:rehab_track/data/database/tables/profile_reference_range_tables.dart';
import 'package:rehab_track/data/database/tables/lab_analysis_tables.dart';
import 'package:rehab_track/data/database/tables/doctor_prescription_tables.dart';
import 'package:rehab_track/data/database/seed_data.dart';
import 'package:rehab_track/data/database/daos/profile_dao.dart';
import 'package:rehab_track/data/database/daos/medication_dao.dart';
import 'package:rehab_track/data/database/daos/measurement_dao.dart';
import 'package:rehab_track/data/database/daos/exercise_dao.dart';
import 'package:rehab_track/data/database/daos/doctor_dao.dart';
import 'package:rehab_track/data/database/daos/care_contact_dao.dart';
import 'package:rehab_track/data/database/daos/document_dao.dart';
import 'package:rehab_track/data/database/daos/diet_dao.dart';
import 'package:rehab_track/data/database/daos/health_template_dao.dart';
import 'package:rehab_track/data/database/daos/app_setting_dao.dart';
import 'package:rehab_track/data/database/daos/medication_alternatives_dao.dart';
import 'package:rehab_track/data/database/daos/medication_components_dao.dart';
import 'package:rehab_track/data/database/daos/medication_alternative_components_dao.dart';
import 'package:rehab_track/data/database/daos/doctor_visit_dao.dart';
import 'package:rehab_track/data/database/daos/lab_analysis_dao.dart';
import 'package:rehab_track/data/database/daos/doctor_prescription_dao.dart';

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
    MeasurementTypeFields,
    MeasurementRecords,
    MeasurementRecordValues,
    MeasurementSchedules,
    MeasurementReminderLogs,
    ExerciseTypes,
    ExerciseGoals,
    ExerciseLogs,
    Doctors,
    DoctorVisits,
    CareContacts,
    DoctorVisitRecords,
    DocumentAttachments,
    DietItems,
    DietGuidanceRules,
    HealthTemplates,
    AppSettings,
    ProfileReferenceRanges,
    LabAnalyses,
    LabAnalysisAttachments,
    DoctorPrescriptions,
    DoctorPrescriptionAttachments,
    DoctorPrescriptionMedications,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Canonical current schema version used by the backup/restore validator.
  static const int currentSchemaVersion = 18;

  AppDatabase() : super(_openConnection());

  AppDatabase.test() : super(NativeDatabase.memory());

  /// Connects to an arbitrary executor; used by migration and data-integrity
  /// tests that need a file-backed database.
  AppDatabase.forTesting(super.executor);

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
  CareContactDao get careContactDao => CareContactDao(this);
  DoctorVisitDao get doctorVisitDao => DoctorVisitDao(this);
DocumentDao get documentDao => DocumentDao(this);
  DietDao get dietDao => DietDao(this);
  HealthTemplateDao get healthTemplateDao => HealthTemplateDao(this);
  AppSettingDao get appSettingDao => AppSettingDao(this);
  LabAnalysisDao get labAnalysisDao => LabAnalysisDao(this);
  DoctorPrescriptionDao get doctorPrescriptionDao =>
      DoctorPrescriptionDao(this);

  @override
  int get schemaVersion => currentSchemaVersion;

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
      if (from < 4) {
        await m.addColumn(measurementTypes, measurementTypes.key);
        await m.addColumn(measurementTypes, measurementTypes.defaultUnit);
        await m.addColumn(
          measurementTypes,
          measurementTypes.displayOrder,
        );
        await m.addColumn(measurementRecords, measurementRecords.updatedAt);
        await m.createTable(measurementTypeFields);
        await m.createTable(measurementRecordValues);
        await _seedMeasurementTypesV4(this);
      }
      if (from < 5) {
        await cleanupDuplicateMeasurementTypes(this);
      }
      if (from < 6) {
        // Destructive migration for Phase 4E: Schedule Redesign
        // Drop old medication schedules and logs (test data only)
        await m.deleteTable(medicationSchedules.actualTableName);
        await m.deleteTable(medicationLogs.actualTableName);
        // Recreate with new columns (intakeQuantity, dosageForm, customDosageForm)
        await m.createTable(medicationSchedules);
        await m.createTable(medicationLogs);
      }
      if (from < 7) {
        // Phase 5A: Irregular heartbeat indicator for blood-pressure readings
        await m.addColumn(
          measurementRecords,
          measurementRecords.irregularHeartbeatDetected,
        );
      }
      if (from < 8) {
        // Phase 5A.1: Profile-specific reference ranges
        await m.createTable(profileReferenceRanges);
      }
      if (from < 9) {
        // Phase 5C: Measurement schedules - add instructions, createdAt, updatedAt
        await m.addColumn(
          measurementSchedules,
          measurementSchedules.instructions,
        );
        await m.addColumn(
          measurementSchedules,
          measurementSchedules.createdAt,
        );
        await m.addColumn(
          measurementSchedules,
          measurementSchedules.updatedAt,
        );
        // Backfill existing rows with default timestamps
        final now = DateTime.now();
        final existingSchedules = await select(measurementSchedules).get();
        for (final s in existingSchedules) {
          await (update(measurementSchedules)
                ..where((t) => t.id.equals(s.id)))
              .write(MeasurementSchedulesCompanion(
            createdAt: Value(now),
            updatedAt: Value(now),
          ));
        }
        // Create measurement reminder logs table
        await m.createTable(measurementReminderLogs);
      }
      if (from < 10) {
        // Phase 5C refinement: one time per measurement schedule
        // Destructive migration: drop and recreate measurement schedules + reminder logs
        await m.deleteTable(measurementReminderLogs.actualTableName);
        await m.deleteTable(measurementSchedules.actualTableName);
        await m.createTable(measurementSchedules);
        await m.createTable(measurementReminderLogs);
      }
      if (from < 11) {
        // Phase 6D: Link reminder logs to measurement records
        await m.addColumn(
          measurementReminderLogs,
          measurementReminderLogs.measurementRecordId,
        );
      }
      if (from < 12) {
        // Phase 7A: Patient Profiles - extend Profiles table
        await m.addColumn(profiles, profiles.phone);
        await m.addColumn(profiles, profiles.email);
        await m.addColumn(profiles, profiles.address);
        await m.addColumn(profiles, profiles.relationshipToOwner);
        await m.addColumn(profiles, profiles.isPrimary);
        await m.addColumn(profiles, profiles.isActive);
        await m.addColumn(profiles, profiles.photoPath);
      }
      if (from < 13) {
        // Phase 8A: Care Contacts - shared table for medical professionals
        // and healthcare organizations
        await m.createTable(careContacts);
      }
      if (from < 14) {
        // Phase 8B: Doctor visit records
        await m.createTable(doctorVisitRecords);
      }
      if (from < 15) {
        // Lab Analyses module - document archive for lab results
        await m.createTable(labAnalyses);
        await m.createTable(labAnalysisAttachments);
      }
      if (from < 16) {
        // Doctor Prescriptions module - document archive for prescriptions
        await m.createTable(doctorPrescriptions);
        await m.createTable(doctorPrescriptionAttachments);
      }
      if (from < 17) {
        // Structured medications belonging to a doctor prescription
        await m.createTable(doctorPrescriptionMedications);
      }
      if (from < 18) {
        // Diet module: replace the legacy (unused) DietPlans/DietItems
        // scaffolding with the patient-managed DietItems (profile-owned,
        // name/category/foodGroup/notes/source/isArchived/timestamps) and
        // the new DietGuidanceRules table. Both target tables are dropped
        // first (guarded by IF EXISTS) so the migration is idempotent.
        await m.deleteTable('diet_items');
        await m.deleteTable('diet_plans');
        await m.deleteTable('diet_guidance_rules');
        await m.createTable(dietItems);
        await m.createTable(dietGuidanceRules);
        await m.createIndex(dietItemsProfileIdx);
        await m.createIndex(dietItemsCategoryIdx);
        await m.createIndex(dietItemsArchivedIdx);
        await m.createIndex(dietItemsNameIdx);
        await m.createIndex(dietGuidanceRulesProfileIdx);
        await m.createIndex(dietGuidanceRulesCategoryIdx);
        await m.createIndex(dietGuidanceRulesArchivedIdx);
        await m.createIndex(dietGuidanceRulesTitleIdx);
        await m.createIndex(dietGuidanceRulesSortIdx);
      }
    },
  );

  static Future<void> _seedMeasurementTypesV4(AppDatabase db) async {
    final now = DateTime.now();

    final types = <({String key, String name, String unit, String category, int order})>[
      (key: 'blood_pressure', name: 'Blood Pressure', unit: 'mmHg', category: 'vital', order: 0),
      (key: 'pulse', name: 'Pulse', unit: 'bpm', category: 'vital', order: 1),
      (key: 'weight', name: 'Weight', unit: 'kg', category: 'body', order: 2),
      (key: 'blood_glucose', name: 'Blood Glucose', unit: 'mmol/L', category: 'metabolic', order: 3),
      (key: 'spo2', name: 'SpO2', unit: '%', category: 'vital', order: 4),
      (key: 'temperature', name: 'Temperature', unit: '°C', category: 'vital', order: 5),
    ];

    for (final t in types) {
      final existing = await (db.select(db.measurementTypes)
            ..where((mt) => mt.key.equals(t.key)))
          .getSingleOrNull();
      if (existing != null) {
        await (db.update(db.measurementTypes)
              ..where((mt) => mt.id.equals(existing.id)))
            .write(MeasurementTypesCompanion(
          key: Value(t.key),
          defaultUnit: Value(t.unit),
          displayOrder: Value(t.order),
          unit: Value(t.unit),
        ));
      } else {
        final typeId = await db.into(db.measurementTypes).insert(
          MeasurementTypesCompanion.insert(
            name: t.name,
            unit: t.unit,
            defaultUnit: Value(t.unit),
            measurementCategory: t.category,
            isSystem: const Value(true),
            active: const Value(true),
            key: Value(t.key),
            displayOrder: Value(t.order),
            createdAt: now,
            updatedAt: now,
          ),
        );
        await _seedFieldsForType(db, typeId, t.key, t.unit);
      }
    }
  }

  static Future<void> _seedFieldsForType(
    AppDatabase db,
    int typeId,
    String typeKey,
    String defaultUnit,
  ) async {
    final now = DateTime.now();
    final fields = _fieldsForType(typeKey, defaultUnit);
    for (final f in fields) {
      await db.into(db.measurementTypeFields).insert(
        MeasurementTypeFieldsCompanion.insert(
          measurementTypeId: typeId,
          fieldKey: f.fieldKey,
          label: f.label,
          defaultUnit: Value(f.unit),
          required: Value(f.required),
          minimumValue: Value(f.min),
          maximumValue: Value(f.max),
          decimalPlaces: Value(f.decimals),
          displayOrder: Value(f.order),
          createdAt: now,
        ),
      );
    }
  }

  static Future<void> cleanupDuplicateMeasurementTypes(
    AppDatabase db,
  ) async {
    final allTypes = await db.select(db.measurementTypes).get();

    final canonicalByKey = <String, MeasurementType>{};
    for (final t in allTypes) {
      if (t.key != null && t.active) {
        canonicalByKey.putIfAbsent(t.key!, () => t);
      }
    }

    final canonicalByName = <String, MeasurementType>{};
    for (final t in allTypes) {
      if (t.key != null && t.active) {
        canonicalByName.putIfAbsent(t.name, () => t);
      }
    }

    final knownKeys = {
      'blood_pressure',
      'pulse',
      'weight',
      'blood_glucose',
      'spo2',
      'temperature',
    };

    for (final t in allTypes) {
      if (!t.active) continue;
      if (!t.isSystem) continue;

      bool isDuplicate = false;

      if (t.key == null) {
        final canonicalByNameExist = canonicalByName[t.name];
        if (canonicalByNameExist != null && canonicalByNameExist.id != t.id) {
          isDuplicate = true;
        }
      } else if (knownKeys.contains(t.key)) {
        final canonical = canonicalByKey[t.key];
        if (canonical != null && canonical.id != t.id) {
          isDuplicate = true;
        }
      }

      if (isDuplicate) {
        final records = await (db.select(db.measurementRecords)
              ..where((r) => r.measurementTypeId.equals(t.id)))
            .get();

        if (records.isNotEmpty) {
          final canonicalType = canonicalByName[t.name] ?? canonicalByKey[t.key!];
          if (canonicalType != null) {
            for (final record in records) {
              await (db.update(db.measurementRecords)
                    ..where((r) => r.id.equals(record.id)))
                  .write(
                MeasurementRecordsCompanion(
                  measurementTypeId: Value(canonicalType.id),
                ),
              );
            }
          }
        }

        await (db.update(db.measurementTypes)
              ..where((mt) => mt.id.equals(t.id)))
            .write(
          MeasurementTypesCompanion(
            active: const Value(false),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    }

    final heartRate = await (db.select(db.measurementTypes)
          ..where((mt) =>
              mt.name.equals('Heart Rate') &
              mt.active.equals(true)))
        .getSingleOrNull();

    if (heartRate != null) {
      final pulseType = await (db.select(db.measurementTypes)
            ..where((mt) =>
                mt.key.equals('pulse') &
                mt.active.equals(true)))
          .getSingleOrNull();

      if (pulseType != null) {
        final hrRecords = await (db.select(db.measurementRecords)
              ..where((r) =>
                  r.measurementTypeId.equals(heartRate.id)))
            .get();

        for (final record in hrRecords) {
          final existingPulse = await (db.select(db.measurementRecords)
                ..where((r) =>
                    r.measurementTypeId.equals(pulseType.id) &
                    r.profileId.equals(record.profileId) &
                    r.timestamp.equals(record.timestamp)))
              .getSingleOrNull();

          if (existingPulse == null) {
            await (db.update(db.measurementRecords)
                  ..where((r) => r.id.equals(record.id)))
                .write(
              MeasurementRecordsCompanion(
                measurementTypeId: Value(pulseType.id),
              ),
            );
          } else {
            await (db.delete(db.measurementRecords)
                  ..where((r) => r.id.equals(record.id)))
                .go();
          }
        }
      } else {
        await (db.update(db.measurementTypes)
              ..where((mt) => mt.id.equals(heartRate.id)))
            .write(
          MeasurementTypesCompanion(
            key: const Value('pulse'),
            updatedAt: Value(DateTime.now()),
          ),
        );
        await _seedFieldsForType(db, heartRate.id, 'pulse', 'bpm');
      }

      if (pulseType != null) {
        await (db.update(db.measurementTypes)
              ..where((mt) => mt.id.equals(heartRate.id)))
            .write(
          MeasurementTypesCompanion(
            active: const Value(false),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    }

    for (final key in knownKeys) {
      final type = await (db.select(db.measurementTypes)
            ..where((mt) =>
                mt.key.equals(key) &
                mt.active.equals(true)))
          .getSingleOrNull();

      if (type != null) {
        final fields = await (db.select(db.measurementTypeFields)
              ..where((f) =>
                  f.measurementTypeId.equals(type.id)))
            .get();

        if (fields.isEmpty) {
          await _seedFieldsForType(db, type.id, key, type.unit);
        }
      }
    }
  }

  static List<_FieldSpec> _fieldsForType(
    String typeKey,
    String defaultUnit,
  ) {
    return switch (typeKey) {
      'blood_pressure' => [
        _FieldSpec('systolic', 'Systolic', 'mmHg', true, 40.0, 300.0, 0, 0),
        _FieldSpec('diastolic', 'Diastolic', 'mmHg', true, 20.0, 200.0, 0, 1),
        _FieldSpec('pulse', 'Pulse', 'bpm', false, 30.0, 250.0, 0, 2),
      ],
      'pulse' => [
        _FieldSpec('pulse', 'Pulse', 'bpm', true, 30.0, 250.0, 0, 0),
      ],
      'weight' => [
        _FieldSpec('weight', 'Weight', defaultUnit, true, 1.0, 500.0, 1, 0),
      ],
      'blood_glucose' => [
        _FieldSpec('glucose', 'Glucose', defaultUnit, true, 0.5, 50.0, 1, 0),
      ],
      'spo2' => [
        _FieldSpec('spo2', 'SpO2', '%', true, 50.0, 100.0, 0, 0),
        _FieldSpec('pulse', 'Pulse', 'bpm', false, 30.0, 250.0, 0, 1),
      ],
      'temperature' => [
        _FieldSpec(
          'temperature',
          'Temperature',
          defaultUnit,
          true,
          30.0,
          45.0,
          1,
          0,
        ),
      ],
      _ => [],
    };
  }
}

class _FieldSpec {
  final String fieldKey;
  final String label;
  final String unit;
  final bool required;
  final double? min;
  final double? max;
  final int decimals;
  final int order;

  const _FieldSpec(
    this.fieldKey,
    this.label,
    this.unit,
    this.required,
    this.min,
    this.max,
    this.decimals,
    this.order,
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'rehabtrack.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
