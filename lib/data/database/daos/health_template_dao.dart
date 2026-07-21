import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/database/tables/health_template_table.dart';

part 'health_template_dao.g.dart';

@DriftAccessor(tables: [HealthTemplates])
class HealthTemplateDao extends DatabaseAccessor<AppDatabase>
    with _$HealthTemplateDaoMixin {
  HealthTemplateDao(super.db);

  Stream<List<HealthTemplate>> watchAll() {
    return (select(healthTemplates)
      ..orderBy([
        (t) => OrderingTerm.asc(t.name),
      ])).watch();
  }

  Future<List<HealthTemplate>> getAll() {
    return (select(healthTemplates)
      ..orderBy([
        (t) => OrderingTerm.asc(t.name),
      ])).get();
  }

  Future<HealthTemplate?> getById(int id) {
    return (select(healthTemplates)
      ..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertTemplate(HealthTemplatesCompanion entry) {
    return into(healthTemplates).insert(entry);
  }

  Future<bool> updateTemplate(HealthTemplatesCompanion entry) {
    return update(healthTemplates).replace(entry);
  }

  Future<int> deleteTemplate(int id) {
    return (delete(healthTemplates)
      ..where((t) => t.id.equals(id))).go();
  }
}
