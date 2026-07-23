import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/database/tables/medication_tables.dart';

part 'medication_alternative_components_dao.g.dart';

@DriftAccessor(tables: [MedicationAlternativeComponents])
class MedicationAlternativeComponentsDao
    extends DatabaseAccessor<AppDatabase>
    with _$MedicationAlternativeComponentsDaoMixin {
  MedicationAlternativeComponentsDao(super.db);

  Stream<List<MedicationAlternativeComponent>> watchComponents(
    int alternativeId,
  ) {
    return (select(medicationAlternativeComponents)
      ..where((t) => t.medicationAlternativeId.equals(alternativeId))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();
  }

  Future<List<MedicationAlternativeComponent>> getComponents(
    int alternativeId,
  ) {
    return (select(medicationAlternativeComponents)
      ..where((t) => t.medicationAlternativeId.equals(alternativeId))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
  }

  Future<MedicationAlternativeComponent?> getComponent(int id) {
    return (select(medicationAlternativeComponents)
      ..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertComponent(
    MedicationAlternativeComponentsCompanion entry,
  ) {
    return into(medicationAlternativeComponents).insert(entry);
  }

  Future<bool> updateComponent(
    MedicationAlternativeComponentsCompanion entry,
  ) {
    return update(medicationAlternativeComponents).replace(entry);
  }

  Future<int> deleteComponent(int id) {
    return (delete(medicationAlternativeComponents)
      ..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteComponentsForAlternative(int alternativeId) {
    return (delete(medicationAlternativeComponents)
      ..where((t) =>
          t.medicationAlternativeId.equals(alternativeId))).go();
  }

  Future<void> replaceAllComponents(
    int alternativeId,
    List<MedicationAlternativeComponentsCompanion> components,
  ) async {
    await transaction(() async {
      await deleteComponentsForAlternative(alternativeId);
      for (final component in components) {
        await into(medicationAlternativeComponents).insert(component);
      }
    });
  }
}
