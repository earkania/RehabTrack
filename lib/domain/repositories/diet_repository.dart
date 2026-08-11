import 'package:rehab_track/domain/entities/diet.dart';

/// Repository interface for the Diet module (Food Guidance + General
/// Guidance). All queries are scoped to a Patient Profile.
abstract class DietRepository {
  // ---- Food items ---------------------------------------------------------

  /// Watch active food items for a profile (A-Z by name).
  Stream<List<DietItem>> watchActiveFoodItems(int profileId);

  /// Watch archived food items for a profile (A-Z by name).
  Stream<List<DietItem>> watchArchivedFoodItems(int profileId);

  /// Get a food item by ID and profile ID.
  Future<DietItem?> getFoodItem(int id, int profileId);

  /// Create a new food item.
  Future<DietItem> createFoodItem(DietItem item);

  /// Update an existing food item.
  Future<DietItem> updateFoodItem(DietItem item);

  /// Archive a food item.
  Future<void> archiveFoodItem(int id, int profileId);

  /// Restore an archived food item.
  Future<void> restoreFoodItem(int id, int profileId);

  /// Permanently delete a food item.
  Future<void> deleteFoodItem(int id, int profileId);

  /// Search food items by name, food group, notes or source, optionally
  /// filtered by category.
  Stream<List<DietItem>> searchFoodItems(
    int profileId, {
    bool includeArchived = false,
    String? query,
    String? category,
  });

  // ---- Guidance rules -----------------------------------------------------

  /// Watch active guidance rules for a profile (sort order, then title).
  Stream<List<DietGuidanceRule>> watchActiveGuidanceRules(int profileId);

  /// Watch archived guidance rules for a profile.
  Stream<List<DietGuidanceRule>> watchArchivedGuidanceRules(int profileId);

  /// Get a guidance rule by ID and profile ID.
  Future<DietGuidanceRule?> getGuidanceRule(int id, int profileId);

  /// Create a new guidance rule.
  Future<DietGuidanceRule> createGuidanceRule(DietGuidanceRule rule);

  /// Update an existing guidance rule.
  Future<DietGuidanceRule> updateGuidanceRule(DietGuidanceRule rule);

  /// Archive a guidance rule.
  Future<void> archiveGuidanceRule(int id, int profileId);

  /// Restore an archived guidance rule.
  Future<void> restoreGuidanceRule(int id, int profileId);

  /// Permanently delete a guidance rule.
  Future<void> deleteGuidanceRule(int id, int profileId);

  /// Search guidance rules by title, description or source, optionally
  /// filtered by category.
  Stream<List<DietGuidanceRule>> searchGuidanceRules(
    int profileId, {
    bool includeArchived = false,
    String? query,
    String? category,
  });
}
