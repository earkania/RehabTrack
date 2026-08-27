import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/data/repositories/activity_repository_impl.dart';
import 'package:rehab_track/data/repositories/care_contact_repository_impl.dart';
import 'package:rehab_track/data/repositories/diet_repository_impl.dart';
import 'package:rehab_track/data/repositories/doctor_prescription_repository_impl.dart';
import 'package:rehab_track/data/repositories/doctor_visit_repository_impl.dart';
import 'package:rehab_track/data/repositories/lab_analysis_repository_impl.dart';
import 'package:rehab_track/data/repositories/medication_repository_impl.dart';
import 'package:rehab_track/data/repositories/measurement_repository_impl.dart';
import 'package:rehab_track/data/repositories/profile_repository_impl.dart';
import 'package:rehab_track/data/repositories/reference_range_repository_impl.dart';
import 'package:rehab_track/domain/entities/report_configuration.dart';
import 'package:rehab_track/domain/entities/report_date_range.dart';
import 'package:rehab_track/domain/entities/report_section.dart';
import 'package:rehab_track/domain/services/report_builder.dart';

void main() {
  late db.AppDatabase database;
  late ReportBuilder builder;

  final now = DateTime(2026, 8, 24, 12);
  late int pid;

  setUp(() {
    database = db.AppDatabase.test();
    builder = ReportBuilder(
      profileRepository: ProfileRepositoryImpl(database),
      medicationRepository: MedicationRepositoryImpl(database),
      measurementRepository: MeasurementRepositoryImpl(database),
      doctorVisitRepository: DoctorVisitRepositoryImpl(database),
      doctorPrescriptionRepository:
          DoctorPrescriptionRepositoryImpl(database),
      labAnalysisRepository: LabAnalysisRepositoryImpl(database),
      dietRepository: DietRepositoryImpl(database),
      activityRepository: ActivityRepositoryImpl(database),
      careContactRepository: CareContactRepositoryImpl(database),
      referenceRangeRepository: ReferenceRangeRepositoryImpl(database),
    );
  });

  tearDown(() async {
    await database.close();
  });

  Future<int> insertProfile() => database.into(database.profiles).insert(
        db.ProfilesCompanion.insert(
          firstName: 'Nino',
          lastName: 'Beridze',
          birthDate: Value(DateTime(1990, 5, 1)),
          gender: const Value('female'),
          bloodType: const Value('A+'),
          heightCm: const Value(170.0),
          weightKg: const Value(65.0),
          allergies: const Value('Penicillin'),
          emergencyContactName: const Value('Mother'),
          emergencyContactPhone: const Value('+995 555'),
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
          isPrimary: const Value(true),
          isActive: const Value(true),
        ),
      );

  Future<int> insertContact(String displayName) =>
      database.into(database.careContacts).insert(
            db.CareContactsCompanion.insert(
              profileId: pid,
              contactType: 'doctor',
              displayName: displayName,
              createdAt: DateTime(2026),
              updatedAt: DateTime(2026),
            ),
          );

  Future<void> insertBloodPressureData() async {
    final typeId =
        await database.into(database.measurementTypes).insert(
              db.MeasurementTypesCompanion.insert(
                profileId: Value(pid),
                key: const Value<String?>('blood_pressure'),
                name: 'Blood Pressure',
                unit: 'mmHg',
                measurementCategory: 'cardiovascular',
                displayOrder: const Value(0),
                createdAt: DateTime(2026),
                updatedAt: DateTime(2026),
              ),
            );
    for (final entry in [
      ('systolic', 0),
      ('diastolic', 1),
      ('pulse', 2),
    ]) {
      await database.into(database.measurementTypeFields).insert(
            db.MeasurementTypeFieldsCompanion.insert(
              measurementTypeId: typeId,
              fieldKey: entry.$1,
              label: entry.$1,
              defaultUnit:
                  Value(entry.$1 == 'pulse' ? 'bpm' : 'mmHg'),
              displayOrder: Value(entry.$2),
              createdAt: DateTime(2026),
            ),
          );
    }
    final recordId = await database.into(database.measurementRecords).insert(
          db.MeasurementRecordsCompanion.insert(
            profileId: pid,
            measurementTypeId: typeId,
            timestamp: DateTime(2026, 8, 20, 9),
            valuePrimary: 120,
            valueSecondary: const Value(80),
            valueTertiary: const Value(70),
            unit: 'mmHg',
            createdAt: DateTime(2026),
          ),
        );
    for (final v in [
      ('systolic', 120.0, 0),
      ('diastolic', 80.0, 1),
      ('pulse', 70.0, 2),
    ]) {
      await database.into(database.measurementRecordValues).insert(
            db.MeasurementRecordValuesCompanion.insert(
              measurementRecordId: recordId,
              fieldKey: v.$1,
              numericValue: v.$2,
              unit: v.$1 == 'pulse' ? 'bpm' : 'mmHg',
              displayOrder: Value(v.$3),
            ),
          );
    }
    // Out-of-range record (before the period).
    await database.into(database.measurementRecords).insert(
          db.MeasurementRecordsCompanion.insert(
            profileId: pid,
            measurementTypeId: typeId,
            timestamp: DateTime(2026, 8, 1, 9),
            valuePrimary: 200,
            unit: 'mmHg',
            createdAt: DateTime(2026),
          ),
        );
  }

  test('builds all sections with canonical ordering and range filtering',
      () async {
    pid = await insertProfile();

    // Medications
    final medId = await database.into(database.medications).insert(
          db.MedicationsCompanion.insert(
            profileId: pid,
            name: 'Aspirin',
            doseAmount: const Value('100'),
            doseUnit: const Value('mg'),
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        );
    await database.into(database.medicationSchedules).insert(
          db.MedicationSchedulesCompanion.insert(
            medicationId: medId,
            scheduleType: 'daily',
            scheduleConfig: '{"type":"daily","times":["21:00","09:00"]}',
            instructions: const Value('After meals'),
          ),
        );

    await insertBloodPressureData();

    // Doctor visits + contacts
    final doctorId = await insertContact('Dr. Smith');
    final clinicId = await insertContact('City Clinic');
    await database.into(database.doctorVisitRecords).insert(
          db.DoctorVisitRecordsCompanion.insert(
            profileId: pid,
            visitType: 'planned',
            status: 'completed',
            scheduledDateTime: DateTime(2026, 8, 20, 10),
            doctorContactId: Value(doctorId),
            organizationContactId: Value(clinicId),
            reason: const Value('Follow-up'),
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        );

    // Prescription with medication and attachment
    final rxId = await database.into(database.doctorPrescriptions).insert(
          db.DoctorPrescriptionsCompanion.insert(
            profileId: pid,
            title: 'Cardio Rx',
            prescriptionDate: DateTime(2026, 8, 20),
            doctorContactId: Value(doctorId),
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        );
    await database.into(database.doctorPrescriptionMedications).insert(
          db.DoctorPrescriptionMedicationsCompanion.insert(
            prescriptionId: rxId,
            profileId: pid,
            medicationName: 'Bisoprolol',
            frequency: const Value('Once daily'),
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        );
    await database.into(database.doctorPrescriptionAttachments).insert(
          db.DoctorPrescriptionAttachmentsCompanion.insert(
            prescriptionId: rxId,
            profileId: pid,
            fileType: 'pdf',
            managedRelativePath: 'x/y.pdf',
            originalFileName: 'rx.pdf',
            displayName: 'Prescription Scan.pdf',
            mimeType: 'application/pdf',
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        );

    // Lab analysis with attachment
    final labId = await database.into(database.labAnalyses).insert(
          db.LabAnalysesCompanion.insert(
            profileId: pid,
            title: 'Blood Panel',
            category: 'laboratory',
            analysisDate: DateTime(2026, 8, 18),
            laboratoryContactId: Value(clinicId),
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        );
    await database.into(database.labAnalysisAttachments).insert(
          db.LabAnalysisAttachmentsCompanion.insert(
            analysisId: labId,
            profileId: pid,
            fileType: 'image',
            managedRelativePath: 'x/y.png',
            originalFileName: 'panel.png',
            displayName: 'Results Photo.png',
            mimeType: 'image/png',
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        );

    // Diet
    await database.into(database.dietGuidanceRules).insert(
          db.DietGuidanceRulesCompanion.insert(
            profileId: pid,
            title: 'No smoking',
            category: 'smoking',
            description: const Value('Avoid entirely'),
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        );
    await database.into(database.dietItems).insert(
          db.DietItemsCompanion.insert(
            profileId: pid,
            name: 'Oatmeal',
            category: 'allowed',
            foodGroup: const Value('grains'),
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        );

    // Activities
    final activityId = await database.into(database.activities).insert(
          db.ActivitiesCompanion.insert(
            profileId: pid,
            name: 'Knee exercises',
            category: 'rehabilitation',
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        );
    await database.into(database.activitySessions).insert(
          db.ActivitySessionsCompanion.insert(
            activityId: activityId,
            profileId: pid,
            mode: 'timed_session',
            startedAt: DateTime(2026, 8, 19, 8),
            status: 'completed',
            accumulatedSeconds: const Value(900),
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        );
    await database.into(database.activitySessions).insert(
          db.ActivitySessionsCompanion.insert(
            activityId: activityId,
            profileId: pid,
            mode: 'timed_session',
            startedAt: DateTime(2026, 8, 22, 8),
            endedAt: Value(DateTime(2026, 8, 22, 8, 5)),
            status: 'cancelled',
            accumulatedSeconds: const Value(300),
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        );

    final config = ReportConfiguration(
      dateRangeType: ReportDateRangeType.last7Days,
      profileId: pid,
    );
    final data = await builder.build(config, now: now);

    expect(data.generatedAt, now);
    expect(data.profileSummary!.fullName, 'Nino Beridze');
    expect(data.profileSummary!.gender, 'female');
    expect(data.profileSummary!.heightCm, 170.0);
    expect(data.profileSummary!.weightKg, 65.0);
    expect(data.profileSummary!.bmi, closeTo(65 / (1.7 * 1.7), 0.01));

    // Medications: active only, schedule times normalized+sorted.
    expect(data.medications, hasLength(1));
    expect(data.medications.first.name, 'Aspirin');
    expect(data.medications.first.scheduleSummary, '09:00, 21:00');
    expect(data.medications.first.instructions, 'After meals');

    // Measurements: BP component order fixed; out-of-range record excluded.
    expect(data.measurements, hasLength(1));
    final bp = data.measurements.single;
    expect(
      bp.components.map((c) => c.label).toList(),
      ['systolic', 'diastolic', 'pulse'],
    );
    expect(bp.readingCountInRange, 1);
    expect(bp.components.first.minimum, 120);
    expect(bp.isTruncated, isFalse);

    // Visits: contact names resolved.
    expect(data.doctorVisits, hasLength(1));
    expect(data.doctorVisits.first.doctorName, 'Dr. Smith');
    expect(data.doctorVisits.first.organizationName, 'City Clinic');
    expect(data.doctorVisits.first.status, 'completed');

    // Prescriptions: meds + attachment names only.
    expect(data.doctorPrescriptions, hasLength(1));
    final rx = data.doctorPrescriptions.single;
    expect(rx.medications.single.name, 'Bisoprolol');
    expect(rx.attachmentNames, ['Prescription Scan.pdf']);

    expect(data.labAnalyses, hasLength(1));
    expect(data.labAnalyses.single.attachmentNames, ['Results Photo.png']);
    expect(data.labAnalyses.single.laboratoryName, 'City Clinic');

    // Diet grouped by stable categories.
    expect(data.diet!.guidanceByCategory['smoking'], isNotNull);
    expect(data.diet!.foodsByCategory['allowed']!.single.name, 'Oatmeal');

    // Activities: both finished sessions counted.
    expect(data.activitySessions, hasLength(2));
    expect(data.activityStats!.sessionCount, 2);
    expect(data.activityStats!.completedCount, 1);
    expect(data.activityStats!.cancelledCount, 1);
    expect(data.activityStats!.totalActiveDuration,
        const Duration(seconds: 1200));
  });

  test('unselected sections stay empty; selected-only data is prepared',
      () async {
    pid = await insertProfile();
    await insertBloodPressureData();

    final config = ReportConfiguration(
      dateRangeType: ReportDateRangeType.allTime,
      selectedSections: {ReportSection.measurements},
      profileId: pid,
    );
    final data = await builder.build(config, now: now);

    expect(data.profileSummary, isNull);
    expect(data.medications, isEmpty);
    expect(data.measurements, hasLength(1));
    expect(data.doctorVisits, isEmpty);
    expect(data.isEmptySection(ReportSection.profile), isTrue);
    expect(data.isEmptySection(ReportSection.measurements), isFalse);
  });

  test('truncates reading rows to 200 latest per type with counts',
      () async {
    pid = await insertProfile();
    final typeId =
        await database.into(database.measurementTypes).insert(
              db.MeasurementTypesCompanion.insert(
                profileId: Value(pid),
                name: 'Weight',
                unit: 'kg',
                measurementCategory: 'general',
                key: const Value<String?>('weight'),
                createdAt: DateTime(2026),
                updatedAt: DateTime(2026),
              ),
            );
    for (var i = 0; i < ReportBuilder.maxReadingRowsPerType + 20; i++) {
      await database.into(database.measurementRecords).insert(
            db.MeasurementRecordsCompanion.insert(
              profileId: pid,
              measurementTypeId: typeId,
              timestamp: DateTime(2026, 8, 1).add(Duration(hours: i)),
              valuePrimary: 60 + i * 0.1,
              unit: 'kg',
              createdAt: DateTime(2026),
            ),
          );
    }

    final config = ReportConfiguration(
      dateRangeType: ReportDateRangeType.allTime,
      selectedSections: {ReportSection.measurements},
      profileId: pid,
    );
    final data = await builder.build(config, now: now);

    final weight = data.measurements.single;
    expect(weight.totalReadingCount, 220);
    expect(weight.includedReadingCount, 200);
    expect(weight.readings, hasLength(200));
    expect(weight.isTruncated, isTrue);
    // Newest-first: first row must be the last inserted reading.
    expect(weight.readings.first.measuredAt.hour,
        DateTime(2026, 8, 1).add(const Duration(hours: 219)).hour);
  });

  test('legacy records without component rows map positionally', () async {
    pid = await insertProfile();
    final typeId =
        await database.into(database.measurementTypes).insert(
              db.MeasurementTypesCompanion.insert(
                profileId: Value(pid),
                name: 'Weight',
                unit: 'kg',
                measurementCategory: 'general',
                key: const Value<String?>('weight'),
                createdAt: DateTime(2026),
                updatedAt: DateTime(2026),
              ),
            );
    await database.into(database.measurementTypeFields).insert(
          db.MeasurementTypeFieldsCompanion.insert(
            measurementTypeId: typeId,
            fieldKey: 'weight',
            label: 'Weight',
            defaultUnit: const Value('kg'),
            createdAt: DateTime(2026),
          ),
        );
    await database.into(database.measurementRecords).insert(
          db.MeasurementRecordsCompanion.insert(
            profileId: pid,
            measurementTypeId: typeId,
            timestamp: DateTime(2026, 8, 10, 9),
            valuePrimary: 72.5,
            unit: 'kg',
            createdAt: DateTime(2026),
          ),
        );

    final config = ReportConfiguration(
      dateRangeType: ReportDateRangeType.custom,
      customStartDate: DateTime(2026, 8, 10),
      customEndDate: DateTime(2026, 8, 10),
      selectedSections: {ReportSection.measurements},
      profileId: pid,
    );
    final data = await builder.build(config, now: now);

    final weight = data.measurements.single;
    expect(weight.readingCountInRange, 1);
    expect(weight.components.single.label, 'Weight');
    expect(weight.components.single.minimum, 72.5);
    expect(weight.readings.single.values.single.value, 72.5);
    // Custom single-day range includes that whole day.
    expect(weight.readings.single.measuredAt.day, 10);
  });
}
