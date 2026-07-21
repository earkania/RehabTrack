import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/database/tables/medication_tables.dart';

part 'medication_dao.g.dart';

@DriftAccessor(
  tables: [Medications, MedicationSchedules, MedicationLogs],
)
class MedicationDao extends DatabaseAccessor<AppDatabase>
    with _$MedicationDaoMixin {
  MedicationDao(super.db);

  Stream<List<Medication>> watchMedications(int profileId) {
    return (select(medications)
      ..where((t) => t.profileId.equals(profileId))
      ..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  Stream<List<Medication>> watchActiveMedications(int profileId) {
    return (select(medications)
      ..where((t) =>
          t.profileId.equals(profileId) & t.active.equals(true))
      ..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  Future<List<Medication>> getMedications(int profileId) {
    return (select(medications)
      ..where((t) => t.profileId.equals(profileId))
      ..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  Future<Medication?> getMedication(int id) {
    return (select(medications)
      ..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertMedication(MedicationsCompanion entry) {
    return into(medications).insert(entry);
  }

  Future<bool> updateMedication(MedicationsCompanion entry) {
    return update(medications).replace(entry);
  }

  Future<int> deleteMedication(int id) {
    return (delete(medications)
      ..where((t) => t.id.equals(id))).go();
  }

  Stream<List<MedicationSchedule>> watchSchedules(int medicationId) {
    return (select(medicationSchedules)
      ..where((t) => t.medicationId.equals(medicationId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.startDate),
      ])).watch();
  }

  Future<int> insertSchedule(MedicationSchedulesCompanion entry) {
    return into(medicationSchedules).insert(entry);
  }

  Future<bool> updateSchedule(MedicationSchedulesCompanion entry) {
    return update(medicationSchedules).replace(entry);
  }

  Future<int> deleteSchedule(int id) {
    return (delete(medicationSchedules)
      ..where((t) => t.id.equals(id))).go();
  }

  Stream<List<MedicationLog>> watchLogs(
    int scheduleId, {
    DateTime? from,
    DateTime? to,
  }) {
    final query = select(medicationLogs)
      ..where((t) => t.medicationScheduleId.equals(scheduleId));
    if (from != null) {
      query.where((t) => t.scheduledTime.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((t) => t.scheduledTime.isSmallerOrEqualValue(to));
    }
    query.orderBy([
      (t) => OrderingTerm.desc(t.scheduledTime),
    ]);
    return query.watch();
  }

  Future<List<MedicationLog>> getLogs(
    int scheduleId, {
    DateTime? from,
    DateTime? to,
  }) {
    final query = select(medicationLogs)
      ..where((t) => t.medicationScheduleId.equals(scheduleId));
    if (from != null) {
      query.where((t) => t.scheduledTime.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((t) => t.scheduledTime.isSmallerOrEqualValue(to));
    }
    query.orderBy([
      (t) => OrderingTerm.desc(t.scheduledTime),
    ]);
    return query.get();
  }

  Future<int> insertLog(MedicationLogsCompanion entry) {
    return into(medicationLogs).insert(entry);
  }

  Future<bool> updateLog(MedicationLogsCompanion entry) {
    return update(medicationLogs).replace(entry);
  }
}
