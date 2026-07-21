import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/database/tables/medication_tables.dart';

part 'medication_alternatives_dao.g.dart';

@DriftAccessor(tables: [MedicationAlternatives])
class MedicationAlternativesDao
    extends DatabaseAccessor<AppDatabase>
    with _$MedicationAlternativesDaoMixin {
  MedicationAlternativesDao(super.db);

  Stream<List<MedicationAlternative>> watchAlternatives(
    int medicationId,
  ) {
    return (select(medicationAlternatives)
      ..where((t) => t.medicationId.equals(medicationId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.name),
      ])).watch();
  }

  Future<List<MedicationAlternative>> getAlternatives(
    int medicationId,
  ) {
    return (select(medicationAlternatives)
      ..where((t) => t.medicationId.equals(medicationId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.name),
      ])).get();
  }

  Future<MedicationAlternative?> getAlternative(int id) {
    return (select(medicationAlternatives)
      ..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertAlternative(
    MedicationAlternativesCompanion entry,
  ) {
    return into(medicationAlternatives).insert(entry);
  }

  Future<bool> updateAlternative(
    MedicationAlternativesCompanion entry,
  ) {
    return update(medicationAlternatives).replace(entry);
  }

  Future<int> deleteAlternative(int id) {
    return (delete(medicationAlternatives)
      ..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteAlternativesForMedication(int medicationId) {
    return (delete(medicationAlternatives)
      ..where((t) => t.medicationId.equals(medicationId))).go();
  }
}
