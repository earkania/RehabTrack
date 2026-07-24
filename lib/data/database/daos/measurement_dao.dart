import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/database/tables/measurement_tables.dart';

part 'measurement_dao.g.dart';

@DriftAccessor(
  tables: [
    MeasurementTypes,
    MeasurementTypeFields,
    MeasurementRecords,
    MeasurementRecordValues,
    MeasurementSchedules,
  ],
)
class MeasurementDao extends DatabaseAccessor<AppDatabase>
    with _$MeasurementDaoMixin {
  MeasurementDao(super.db);

  Stream<List<MeasurementType>> watchActiveMeasurementTypes(
    int? profileId,
  ) {
    final query = select(measurementTypes)
      ..where((t) => t.active.equals(true))
      ..where(
        (t) => profileId != null
            ? t.isSystem.equals(true) | t.profileId.equals(profileId)
            : t.isSystem.equals(true),
      )
      ..orderBy([
        (t) => OrderingTerm.asc(t.displayOrder),
        (t) => OrderingTerm.asc(t.name),
      ]);
    return query.watch();
  }

  Future<List<MeasurementType>> getActiveMeasurementTypes(
    int? profileId,
  ) {
    final query = select(measurementTypes)
      ..where((t) => t.active.equals(true))
      ..where(
        (t) => profileId != null
            ? t.isSystem.equals(true) | t.profileId.equals(profileId)
            : t.isSystem.equals(true),
      )
      ..orderBy([
        (t) => OrderingTerm.asc(t.displayOrder),
        (t) => OrderingTerm.asc(t.name),
      ]);
    return query.get();
  }

  Stream<List<MeasurementType>> watchMeasurementTypes(
    int? profileId,
  ) {
    final query = select(measurementTypes)
      ..where(
        (t) => profileId != null
            ? t.isSystem.equals(true) | t.profileId.equals(profileId)
            : t.isSystem.equals(true),
      )
      ..orderBy([
        (t) => OrderingTerm.asc(t.displayOrder),
        (t) => OrderingTerm.asc(t.name),
      ]);
    return query.watch();
  }

  Future<List<MeasurementType>> getMeasurementTypes(
    int? profileId,
  ) {
    final query = select(measurementTypes)
      ..where(
        (t) => profileId != null
            ? t.isSystem.equals(true) | t.profileId.equals(profileId)
            : t.isSystem.equals(true),
      )
      ..orderBy([
        (t) => OrderingTerm.asc(t.displayOrder),
        (t) => OrderingTerm.asc(t.name),
      ]);
    return query.get();
  }

  Future<MeasurementType?> getMeasurementType(int id) {
    return (select(measurementTypes)
      ..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<MeasurementType?> getMeasurementTypeByKey(String key) {
    return (select(measurementTypes)
      ..where((t) => t.key.equals(key))).getSingleOrNull();
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

  // --- MeasurementTypeFields ---

  Stream<List<MeasurementTypeField>> watchFieldsForType(
    int measurementTypeId,
  ) {
    return (select(measurementTypeFields)
      ..where((t) => t.measurementTypeId.equals(measurementTypeId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.displayOrder),
      ])).watch();
  }

  Future<List<MeasurementTypeField>> getFieldsForType(
    int measurementTypeId,
  ) {
    return (select(measurementTypeFields)
      ..where((t) => t.measurementTypeId.equals(measurementTypeId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.displayOrder),
      ])).get();
  }

  Future<int> insertField(MeasurementTypeFieldsCompanion entry) {
    return into(measurementTypeFields).insert(entry);
  }

  Future<void> replaceFields(
    int measurementTypeId,
    List<MeasurementTypeFieldsCompanion> fields,
  ) async {
    await (delete(measurementTypeFields)
          ..where((t) => t.measurementTypeId.equals(measurementTypeId)))
        .go();
    for (final field in fields) {
      await into(measurementTypeFields).insert(field);
    }
  }

  // --- MeasurementRecords ---

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

  Future<MeasurementRecord?> getRecord(int id) {
    return (select(measurementRecords)
      ..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertRecord(MeasurementRecordsCompanion entry) {
    return into(measurementRecords).insert(entry);
  }

  Future<bool> updateRecord(MeasurementRecordsCompanion entry) {
    return update(measurementRecords).replace(entry);
  }

  Future<int> deleteRecord(int id) {
    return (delete(measurementRecords)
      ..where((t) => t.id.equals(id))).go();
  }

  // --- MeasurementRecordValues ---

  Future<List<MeasurementRecordValue>> getValuesForRecord(
    int measurementRecordId,
  ) {
    return (select(measurementRecordValues)
      ..where((t) => t.measurementRecordId.equals(measurementRecordId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.displayOrder),
      ])).get();
  }

  Stream<List<MeasurementRecordValue>> watchValuesForRecord(
    int measurementRecordId,
  ) {
    return (select(measurementRecordValues)
      ..where((t) => t.measurementRecordId.equals(measurementRecordId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.displayOrder),
      ])).watch();
  }

  Future<void> replaceRecordValues(
    int measurementRecordId,
    List<MeasurementRecordValuesCompanion> values,
  ) async {
    await (delete(measurementRecordValues)
          ..where(
            (t) => t.measurementRecordId.equals(measurementRecordId),
          ))
        .go();
    for (final value in values) {
      await into(measurementRecordValues).insert(value);
    }
  }

  // --- MeasurementSchedules ---

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
