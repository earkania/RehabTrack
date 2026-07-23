import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/database/tables/medication_tables.dart';

part 'medication_components_dao.g.dart';

@DriftAccessor(tables: [MedicationComponents])
class MedicationComponentsDao
    extends DatabaseAccessor<AppDatabase>
    with _$MedicationComponentsDaoMixin {
  MedicationComponentsDao(super.db);

  Stream<List<MedicationComponent>> watchComponents(int medicationId) {
    return (select(medicationComponents)
      ..where((t) => t.medicationId.equals(medicationId))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();
  }

  Future<List<MedicationComponent>> getComponents(int medicationId) {
    return (select(medicationComponents)
      ..where((t) => t.medicationId.equals(medicationId))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
  }

  Future<MedicationComponent?> getComponent(int id) {
    return (select(medicationComponents)
      ..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertComponent(
    MedicationComponentsCompanion entry,
  ) {
    return into(medicationComponents).insert(entry);
  }

  Future<bool> updateComponent(
    MedicationComponentsCompanion entry,
  ) {
    return update(medicationComponents).replace(entry);
  }

  Future<int> deleteComponent(int id) {
    return (delete(medicationComponents)
      ..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteComponentsForMedication(int medicationId) {
    return (delete(medicationComponents)
      ..where((t) => t.medicationId.equals(medicationId))).go();
  }

  Future<void> replaceAllComponents(
    int medicationId,
    List<MedicationComponentsCompanion> components,
  ) async {
    await transaction(() async {
      await deleteComponentsForMedication(medicationId);
      for (final component in components) {
        await into(medicationComponents).insert(component);
      }
    });
  }
}
