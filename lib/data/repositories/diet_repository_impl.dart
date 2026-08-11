import 'package:rehab_track/data/database/app_database.dart'
    hide DietItem, DietGuidanceRule;
import 'package:rehab_track/data/database/daos/diet_dao.dart';
import 'package:rehab_track/domain/entities/diet.dart';
import 'package:rehab_track/domain/repositories/diet_repository.dart';

/// Drift implementation of [DietRepository].
class DietRepositoryImpl implements DietRepository {
  final AppDatabase _database;

  DietRepositoryImpl(this._database);

  DietDao get _dao => _database.dietDao;

  @override
  Stream<List<DietItem>> watchActiveFoodItems(int profileId) {
    return _dao.watchActiveFoodItems(profileId).map(
      (list) => list.map(DietItem.fromDb).toList(),
    );
  }

  @override
  Stream<List<DietItem>> watchArchivedFoodItems(int profileId) {
    return _dao.watchArchivedFoodItems(profileId).map(
      (list) => list.map(DietItem.fromDb).toList(),
    );
  }

  @override
  Future<DietItem?> getFoodItem(int id, int profileId) {
    return _dao.getFoodItem(id, profileId).then((dbModel) {
      if (dbModel == null) return null;
      return DietItem.fromDb(dbModel);
    });
  }

  @override
  Future<DietItem> createFoodItem(DietItem item) async {
    final id = await _dao.insertFoodItem(item.toCompanion());
    return (await getFoodItem(id, item.profileId))!;
  }

  @override
  Future<DietItem> updateFoodItem(DietItem item) async {
    await _dao.updateFoodItem(item.toUpdateCompanion());
    return (await getFoodItem(item.id!, item.profileId))!;
  }

  @override
  Future<void> archiveFoodItem(int id, int profileId) async {
    await _dao.setFoodItemArchived(id, profileId, true);
  }

  @override
  Future<void> restoreFoodItem(int id, int profileId) async {
    await _dao.setFoodItemArchived(id, profileId, false);
  }

  @override
  Future<void> deleteFoodItem(int id, int profileId) async {
    await _dao.deleteFoodItem(id, profileId);
  }

  @override
  Stream<List<DietItem>> searchFoodItems(
    int profileId, {
    bool includeArchived = false,
    String? query,
    String? category,
  }) {
    return _dao
        .searchFoodItems(
          profileId,
          includeArchived: includeArchived,
          query: query,
          category: category,
        )
        .map((list) => list.map(DietItem.fromDb).toList());
  }

  @override
  Stream<List<DietGuidanceRule>> watchActiveGuidanceRules(int profileId) {
    return _dao.watchActiveGuidanceRules(profileId).map(
      (list) => list.map(DietGuidanceRule.fromDb).toList(),
    );
  }

  @override
  Stream<List<DietGuidanceRule>> watchArchivedGuidanceRules(int profileId) {
    return _dao.watchArchivedGuidanceRules(profileId).map(
      (list) => list.map(DietGuidanceRule.fromDb).toList(),
    );
  }

  @override
  Future<DietGuidanceRule?> getGuidanceRule(int id, int profileId) {
    return _dao.getGuidanceRule(id, profileId).then((dbModel) {
      if (dbModel == null) return null;
      return DietGuidanceRule.fromDb(dbModel);
    });
  }

  @override
  Future<DietGuidanceRule> createGuidanceRule(DietGuidanceRule rule) async {
    final id = await _dao.insertGuidanceRule(rule.toCompanion());
    return (await getGuidanceRule(id, rule.profileId))!;
  }

  @override
  Future<DietGuidanceRule> updateGuidanceRule(DietGuidanceRule rule) async {
    await _dao.updateGuidanceRule(rule.toUpdateCompanion());
    return (await getGuidanceRule(rule.id!, rule.profileId))!;
  }

  @override
  Future<void> archiveGuidanceRule(int id, int profileId) async {
    await _dao.setGuidanceRuleArchived(id, profileId, true);
  }

  @override
  Future<void> restoreGuidanceRule(int id, int profileId) async {
    await _dao.setGuidanceRuleArchived(id, profileId, false);
  }

  @override
  Future<void> deleteGuidanceRule(int id, int profileId) async {
    await _dao.deleteGuidanceRule(id, profileId);
  }

  @override
  Stream<List<DietGuidanceRule>> searchGuidanceRules(
    int profileId, {
    bool includeArchived = false,
    String? query,
    String? category,
  }) {
    return _dao
        .searchGuidanceRules(
          profileId,
          includeArchived: includeArchived,
          query: query,
          category: category,
        )
        .map((list) => list.map(DietGuidanceRule.fromDb).toList());
  }
}
