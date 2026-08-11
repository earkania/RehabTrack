import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/database/tables/diet_tables.dart';

part 'diet_dao.g.dart';

@DriftAccessor(tables: [DietItems, DietGuidanceRules])
class DietDao extends DatabaseAccessor<AppDatabase> with _$DietDaoMixin {
  DietDao(super.db);

  // ---- Food items ---------------------------------------------------------

  /// Watch all active food items for a profile, ordered A-Z by name.
  Stream<List<DietItem>> watchActiveFoodItems(int profileId) {
    final query = select(dietItems)
      ..where((t) => t.profileId.equals(profileId) & t.isArchived.equals(false))
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    return query.watch();
  }

  /// Watch all archived food items for a profile, ordered A-Z by name.
  Stream<List<DietItem>> watchArchivedFoodItems(int profileId) {
    final query = select(dietItems)
      ..where((t) => t.profileId.equals(profileId) & t.isArchived.equals(true))
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    return query.watch();
  }

  /// Get a food item by ID and profile ID.
  Future<DietItem?> getFoodItem(int id, int profileId) {
    return (select(dietItems)
          ..where((t) => t.id.equals(id) & t.profileId.equals(profileId)))
        .getSingleOrNull();
  }

  /// Insert a new food item.
  Future<int> insertFoodItem(DietItemsCompanion entry) {
    return into(dietItems).insert(entry);
  }

  /// Update an existing food item.
  Future<bool> updateFoodItem(DietItemsCompanion entry) {
    return update(dietItems).replace(entry);
  }

  /// Archive or restore a food item.
  Future<int> setFoodItemArchived(int id, int profileId, bool archived) {
    return (update(dietItems)
          ..where((t) => t.id.equals(id) & t.profileId.equals(profileId)))
        .write(DietItemsCompanion(
      isArchived: Value(archived),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Permanently delete a food item.
  Future<int> deleteFoodItem(int id, int profileId) {
    return (delete(dietItems)
          ..where((t) => t.id.equals(id) & t.profileId.equals(profileId)))
        .go();
  }

  /// Search food items by name, food group, notes or source, optionally
  /// filtered by category. Ordered A-Z by name.
  Stream<List<DietItem>> searchFoodItems(
    int profileId, {
    bool includeArchived = false,
    String? query,
    String? category,
  }) {
    var statement = select(dietItems)
      ..where((t) => t.profileId.equals(profileId));

    if (!includeArchived) {
      statement.where((t) => t.isArchived.equals(false));
    }

    if (query != null && query.isNotEmpty) {
      final searchTerm = '%$query%';
      statement.where((t) =>
          t.name.like(searchTerm) |
          t.foodGroup.like(searchTerm) |
          t.notes.like(searchTerm) |
          t.source.like(searchTerm));
    }

    if (category != null && category.isNotEmpty) {
      statement.where((t) => t.category.equals(category));
    }

    statement.orderBy([(t) => OrderingTerm.asc(t.name)]);

    return statement.watch();
  }

  // ---- Guidance rules -----------------------------------------------------

  /// Watch all active guidance rules for a profile.
  ///
  /// Rules with an explicit [DietGuidanceRules.sortOrder] come first (in that
  /// order), followed by remaining rules alphabetically by title.
  Stream<List<DietGuidanceRule>> watchActiveGuidanceRules(int profileId) {
    final query = select(dietGuidanceRules)
      ..where((t) => t.profileId.equals(profileId) & t.isArchived.equals(false))
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.title),
      ]);
    return query.watch();
  }

  /// Watch all archived guidance rules for a profile.
  Stream<List<DietGuidanceRule>> watchArchivedGuidanceRules(int profileId) {
    final query = select(dietGuidanceRules)
      ..where((t) => t.profileId.equals(profileId) & t.isArchived.equals(true))
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.title),
      ]);
    return query.watch();
  }

  /// Get a guidance rule by ID and profile ID.
  Future<DietGuidanceRule?> getGuidanceRule(int id, int profileId) {
    return (select(dietGuidanceRules)
          ..where((t) => t.id.equals(id) & t.profileId.equals(profileId)))
        .getSingleOrNull();
  }

  /// Insert a new guidance rule.
  Future<int> insertGuidanceRule(DietGuidanceRulesCompanion entry) {
    return into(dietGuidanceRules).insert(entry);
  }

  /// Update an existing guidance rule.
  Future<bool> updateGuidanceRule(DietGuidanceRulesCompanion entry) {
    return update(dietGuidanceRules).replace(entry);
  }

  /// Archive or restore a guidance rule.
  Future<int> setGuidanceRuleArchived(int id, int profileId, bool archived) {
    return (update(dietGuidanceRules)
          ..where((t) => t.id.equals(id) & t.profileId.equals(profileId)))
        .write(DietGuidanceRulesCompanion(
      isArchived: Value(archived),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Permanently delete a guidance rule.
  Future<int> deleteGuidanceRule(int id, int profileId) {
    return (delete(dietGuidanceRules)
          ..where((t) => t.id.equals(id) & t.profileId.equals(profileId)))
        .go();
  }

  /// Search guidance rules by title, description or source, optionally
  /// filtered by category. Ordered by sort order then title.
  Stream<List<DietGuidanceRule>> searchGuidanceRules(
    int profileId, {
    bool includeArchived = false,
    String? query,
    String? category,
  }) {
    var statement = select(dietGuidanceRules)
      ..where((t) => t.profileId.equals(profileId));

    if (!includeArchived) {
      statement.where((t) => t.isArchived.equals(false));
    }

    if (query != null && query.isNotEmpty) {
      final searchTerm = '%$query%';
      statement.where((t) =>
          t.title.like(searchTerm) |
          t.description.like(searchTerm) |
          t.source.like(searchTerm));
    }

    if (category != null && category.isNotEmpty) {
      statement.where((t) => t.category.equals(category));
    }

    statement.orderBy([
      (t) => OrderingTerm.asc(t.sortOrder),
      (t) => OrderingTerm.asc(t.title),
    ]);

    return statement.watch();
  }
}
