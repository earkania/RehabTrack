import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/database/tables/measurement_tables.dart';

part 'measurement_dao.g.dart';

@DriftAccessor(
  tables: [
    MeasurementTypes,
    MeasurementRecords,
    MeasurementSchedules,
  ],
)
class MeasurementDao extends DatabaseAccessor<AppDatabase>
    with _$MeasurementDaoMixin {
  MeasurementDao(super.db);

  Stream<List<MeasurementType>> watchMeasurementTypes(int? profileId) {
    final query = select(measurementTypes)
      ..where((t) => t.isSystem.equals(true));
    if (profileId != null) {
      query.where(
        (t) => t.profileId.equals(profileId),
      );
    }
    query.orderBy([
      (t) => OrderingTerm.asc(t.isSystem),
      (t) => OrderingTerm.asc(t.name),
    ]);
    return query.watch();
  }

  Future<List<MeasurementType>> getMeasurementTypes(int? profileId) {
    final query = select(measurementTypes)
      ..where((t) => t.isSystem.equals(true));
    if (profileId != null) {
      query.where(
        (t) => t.profileId.equals(profileId),
      );
    }
    query.orderBy([
      (t) => OrderingTerm.asc(t.isSystem),
      (t) => OrderingTerm.asc(t.name),
    ]);
    return query.get();
  }

  Future<MeasurementType?> getMeasurementType(int id) {
    return (select(measurementTypes)
      ..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertMeasurementType(
    MeasurementTypesCompanion entry,
  ) {
    return into(measurementTypes).insert(entry);
  }

  Future<bool> updateMeasurementType(
    MeasurementTypesCompanion entry,
  ) {
    return update(measurementTypes).replace(entry);
  }

  Future<int> deleteMeasurementType(int id) {
    return (delete(measurementTypes)
      ..where((t) => t.id.equals(id))).go();
  }

  Stream<List<MeasurementRecord>> watchRecords(
    int profileId, {
    int? typeId,
    DateTime? from,
    DateTime? to,
  }) {
    final query = select(measurementRecords)
      ..where((t) => t.profileId.equals(profileId));
    if (typeId != null) {
      query.where((t) => t.measurementTypeId.equals(typeId));
    }
    if (from != null) {
      query.where((t) => t.timestamp.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((t) => t.timestamp.isSmallerOrEqualValue(to));
    }
    query.orderBy([
      (t) => OrderingTerm.desc(t.timestamp),
    ]);
    return query.watch();
  }

  Future<List<MeasurementRecord>> getRecords(
    int profileId, {
    int? typeId,
    DateTime? from,
    DateTime? to,
  }) {
    final query = select(measurementRecords)
      ..where((t) => t.profileId.equals(profileId));
    if (typeId != null) {
      query.where((t) => t.measurementTypeId.equals(typeId));
    }
    if (from != null) {
      query.where((t) => t.timestamp.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((t) => t.timestamp.isSmallerOrEqualValue(to));
    }
    query.orderBy([
      (t) => OrderingTerm.desc(t.timestamp),
    ]);
    return query.get();
  }

  Future<int> insertRecord(MeasurementRecordsCompanion entry) {
    return into(measurementRecords).insert(entry);
  }

  Future<int> deleteRecord(int id) {
    return (delete(measurementRecords)
      ..where((t) => t.id.equals(id))).go();
  }

  Stream<List<MeasurementSchedule>> watchSchedules(int profileId) {
    return (select(measurementSchedules)
      ..where((t) => t.profileId.equals(profileId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.measurementTypeId),
      ])).watch();
  }

  Future<int> insertSchedule(
    MeasurementSchedulesCompanion entry,
  ) {
    return into(measurementSchedules).insert(entry);
  }

  Future<bool> updateSchedule(
    MeasurementSchedulesCompanion entry,
  ) {
    return update(measurementSchedules).replace(entry);
  }

  Future<int> deleteSchedule(int id) {
    return (delete(measurementSchedules)
      ..where((t) => t.id.equals(id))).go();
  }
}
