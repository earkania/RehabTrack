import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/database/tables/diet_tables.dart';

part 'diet_dao.g.dart';

@DriftAccessor(tables: [DietPlans, DietItems])
class DietDao extends DatabaseAccessor<AppDatabase>
    with _$DietDaoMixin {
  DietDao(super.db);

  Stream<List<DietPlan>> watchDietPlans(int profileId) {
    return (select(dietPlans)
      ..where((t) => t.profileId.equals(profileId))
      ..orderBy([
        (t) => OrderingTerm.desc(t.active),
        (t) => OrderingTerm.asc(t.title),
      ])).watch();
  }

  Future<List<DietPlan>> getDietPlans(int profileId) {
    return (select(dietPlans)
      ..where((t) => t.profileId.equals(profileId))).get();
  }

  Future<int> insertDietPlan(DietPlansCompanion entry) {
    return into(dietPlans).insert(entry);
  }

  Future<bool> updateDietPlan(DietPlansCompanion entry) {
    return update(dietPlans).replace(entry);
  }

  Future<int> deleteDietPlan(int id) {
    return (delete(dietPlans)
      ..where((t) => t.id.equals(id))).go();
  }

  Stream<List<DietItem>> watchDietItems(int dietPlanId) {
    return (select(dietItems)
      ..where((t) => t.dietPlanId.equals(dietPlanId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.category),
        (t) => OrderingTerm.asc(t.itemText),
      ])).watch();
  }

  Future<List<DietItem>> getDietItems(int dietPlanId) {
    return (select(dietItems)
      ..where((t) => t.dietPlanId.equals(dietPlanId))).get();
  }

  Future<int> insertDietItem(DietItemsCompanion entry) {
    return into(dietItems).insert(entry);
  }

  Future<bool> updateDietItem(DietItemsCompanion entry) {
    return update(dietItems).replace(entry);
  }

  Future<int> deleteDietItem(int id) {
    return (delete(dietItems)
      ..where((t) => t.id.equals(id))).go();
  }
}
