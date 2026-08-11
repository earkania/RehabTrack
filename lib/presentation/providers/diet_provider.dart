import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rehab_track/data/database/daos/diet_dao.dart';
import 'package:rehab_track/data/repositories/diet_repository_impl.dart';
import 'package:rehab_track/domain/entities/diet.dart';
import 'package:rehab_track/domain/repositories/diet_repository.dart';

import 'database_provider.dart';

/// Provider for DietDao.
final dietDaoProvider = Provider<DietDao>((ref) {
  final database = ref.watch(databaseProvider);
  return database.dietDao;
});

/// Provider for DietRepository.
final dietRepositoryProvider = Provider<DietRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return DietRepositoryImpl(database);
});

// ---- Food items -----------------------------------------------------------

/// Active food items for a profile.
final dietFoodItemsProvider =
    StreamProvider.autoDispose.family<List<DietItem>, int>((ref, profileId) {
  final repository = ref.watch(dietRepositoryProvider);
  return repository.watchActiveFoodItems(profileId);
});

/// Archived food items for a profile.
final archivedDietFoodItemsProvider =
    StreamProvider.autoDispose.family<List<DietItem>, int>((ref, profileId) {
  final repository = ref.watch(dietRepositoryProvider);
  return repository.watchArchivedFoodItems(profileId);
});

/// Search query for food items.
final dietFoodSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

/// Category filter for food items: null = all.
final dietFoodCategoryFilterProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);

/// Sort order for food items.
enum DietFoodSort {
  alphabeticalAZ,
  alphabeticalZA,
  byCategory,
}

/// Sort order provider.
final dietFoodSortProvider =
    StateProvider.autoDispose<DietFoodSort>((ref) => DietFoodSort.alphabeticalAZ);

/// Search + category-filtered food items for a profile.
final dietFoodSearchProvider =
    StreamProvider.autoDispose.family<List<DietItem>, int>((ref, profileId) {
  final repository = ref.watch(dietRepositoryProvider);
  final query = ref.watch(dietFoodSearchQueryProvider);
  final category = ref.watch(dietFoodCategoryFilterProvider);

  return repository.searchFoodItems(
    profileId,
    query: query.isEmpty ? null : query,
    category: category,
  );
});

/// Sorted food items provider.
final sortedDietFoodItemsProvider =
    StreamProvider.autoDispose.family<List<DietItem>, int>((ref, profileId) {
  final repository = ref.watch(dietRepositoryProvider);
  final query = ref.watch(dietFoodSearchQueryProvider);
  final category = ref.watch(dietFoodCategoryFilterProvider);
  final sort = ref.watch(dietFoodSortProvider);

  final stream = repository.searchFoodItems(
    profileId,
    query: query.isEmpty ? null : query,
    category: category,
  );

  return stream.map((list) => sortDietFoodItems(list, sort));
});

/// Sorts a list of food items by the given [sort] order.
List<DietItem> sortDietFoodItems(List<DietItem> list, DietFoodSort sort) {
  final sorted = List<DietItem>.from(list);
  switch (sort) {
    case DietFoodSort.alphabeticalAZ:
      sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      break;
    case DietFoodSort.alphabeticalZA:
      sorted.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      break;
    case DietFoodSort.byCategory:
      sorted.sort((a, b) {
        final categoryCompare = _foodCategoryOrder(a.category)
            .compareTo(_foodCategoryOrder(b.category));
        if (categoryCompare != 0) return categoryCompare;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      break;
  }
  return sorted;
}

/// Single food item by ID and profile ID.
final dietFoodItemByIdProvider =
    FutureProvider.autoDispose.family<DietItem?, ({int id, int profileId})>(
        (ref, params) {
  final repository = ref.watch(dietRepositoryProvider);
  return repository.getFoodItem(params.id, params.profileId);
});

// ---- Guidance rules -------------------------------------------------------

/// Active guidance rules for a profile.
final dietGuidanceRulesProvider =
    StreamProvider.autoDispose.family<List<DietGuidanceRule>, int>(
        (ref, profileId) {
  final repository = ref.watch(dietRepositoryProvider);
  return repository.watchActiveGuidanceRules(profileId);
});

/// Archived guidance rules for a profile.
final archivedDietGuidanceRulesProvider =
    StreamProvider.autoDispose.family<List<DietGuidanceRule>, int>(
        (ref, profileId) {
  final repository = ref.watch(dietRepositoryProvider);
  return repository.watchArchivedGuidanceRules(profileId);
});

/// Search query for guidance rules.
final dietGuidanceSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

/// Category filter for guidance rules: null = all.
final dietGuidanceCategoryFilterProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);

/// Search + category-filtered guidance rules for a profile.
final dietGuidanceSearchProvider =
    StreamProvider.autoDispose.family<List<DietGuidanceRule>, int>(
        (ref, profileId) {
  final repository = ref.watch(dietRepositoryProvider);
  final query = ref.watch(dietGuidanceSearchQueryProvider);
  final category = ref.watch(dietGuidanceCategoryFilterProvider);

  return repository.searchGuidanceRules(
    profileId,
    query: query.isEmpty ? null : query,
    category: category,
  );
});

/// Single guidance rule by ID and profile ID.
final dietGuidanceRuleByIdProvider =
    FutureProvider.autoDispose.family<DietGuidanceRule?, ({int id, int profileId})>(
        (ref, params) {
  final repository = ref.watch(dietRepositoryProvider);
  return repository.getGuidanceRule(params.id, params.profileId);
});

// ---- Section switch -------------------------------------------------------

/// Which top-level section of the Diet screen is active.
enum DietSection { foods, guidance }

/// Active Diet screen section.
final activeDietSectionProvider =
    StateProvider.autoDispose<DietSection>((ref) => DietSection.foods);

int _foodCategoryOrder(String category) {
  switch (category) {
    case 'allowed':
      return 0;
    case 'caution':
      return 1;
    case 'avoid':
      return 2;
    default:
      return 3;
  }
}
