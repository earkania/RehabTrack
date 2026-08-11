import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/diet.dart';
import 'package:rehab_track/domain/repositories/diet_repository.dart';
import 'package:rehab_track/presentation/providers/diet_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';

class FakeDietRepository implements DietRepository {
  final List<DietItem> _foods = [];
  final List<DietGuidanceRule> _rules = [];

  void addFood(DietItem item) => _foods.add(item);
  void addRule(DietGuidanceRule rule) => _rules.add(rule);

  @override
  Stream<List<DietItem>> watchActiveFoodItems(int profileId) async* {
    yield _foods
        .where((f) => f.profileId == profileId && !f.isArchived)
        .toList();
  }

  @override
  Stream<List<DietItem>> watchArchivedFoodItems(int profileId) async* {
    yield _foods
        .where((f) => f.profileId == profileId && f.isArchived)
        .toList();
  }

  @override
  Future<DietItem?> getFoodItem(int id, int profileId) async {
    for (final f in _foods) {
      if (f.id == id && f.profileId == profileId) return f;
    }
    return null;
  }

  @override
  Future<DietItem> createFoodItem(DietItem item) async {
    final copy = item.copyWith(id: _foods.length + 1);
    _foods.add(copy);
    return copy;
  }

  @override
  Future<DietItem> updateFoodItem(DietItem item) async {
    final index = _foods.indexWhere((f) => f.id == item.id);
    _foods[index] = item;
    return item;
  }

  @override
  Future<void> archiveFoodItem(int id, int profileId) async {}

  @override
  Future<void> restoreFoodItem(int id, int profileId) async {}

  @override
  Future<void> deleteFoodItem(int id, int profileId) async {}

  @override
  Stream<List<DietItem>> searchFoodItems(
    int profileId, {
    bool includeArchived = false,
    String? query,
    String? category,
  }) async* {
    yield _foods.where((f) {
      if (f.profileId != profileId) return false;
      if (!includeArchived && f.isArchived) return false;
      if (category != null && f.category != category) return false;
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        final haystack = [
          f.name,
          f.foodGroup ?? '',
          f.notes ?? '',
          f.source ?? '',
        ].join(' ').toLowerCase();
        if (!haystack.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  @override
  Stream<List<DietGuidanceRule>> watchActiveGuidanceRules(int profileId) async* {
    yield _rules
        .where((r) => r.profileId == profileId && !r.isArchived)
        .toList();
  }

  @override
  Stream<List<DietGuidanceRule>> watchArchivedGuidanceRules(int profileId) async* {
    yield _rules
        .where((r) => r.profileId == profileId && r.isArchived)
        .toList();
  }

  @override
  Future<DietGuidanceRule?> getGuidanceRule(int id, int profileId) async {
    for (final r in _rules) {
      if (r.id == id && r.profileId == profileId) return r;
    }
    return null;
  }

  @override
  Future<DietGuidanceRule> createGuidanceRule(DietGuidanceRule rule) async {
    final copy = rule.copyWith(id: _rules.length + 1);
    _rules.add(copy);
    return copy;
  }

  @override
  Future<DietGuidanceRule> updateGuidanceRule(DietGuidanceRule rule) async {
    final index = _rules.indexWhere((r) => r.id == rule.id);
    _rules[index] = rule;
    return rule;
  }

  @override
  Future<void> archiveGuidanceRule(int id, int profileId) async {}

  @override
  Future<void> restoreGuidanceRule(int id, int profileId) async {}

  @override
  Future<void> deleteGuidanceRule(int id, int profileId) async {}

  @override
  Stream<List<DietGuidanceRule>> searchGuidanceRules(
    int profileId, {
    bool includeArchived = false,
    String? query,
    String? category,
  }) async* {
    yield _rules.where((r) {
      if (r.profileId != profileId) return false;
      if (!includeArchived && r.isArchived) return false;
      if (category != null && r.category != category) return false;
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        final haystack = [
          r.title,
          r.description ?? '',
          r.source ?? '',
        ].join(' ').toLowerCase();
        if (!haystack.contains(q)) return false;
      }
      return true;
    }).toList();
  }
}

void main() {
  late FakeDietRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = FakeDietRepository();
    container = ProviderContainer(
      overrides: [
        dietRepositoryProvider.overrideWithValue(repo),
        currentActiveProfileIdProvider.overrideWith((ref) => 7),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  DietItem makeFood({
    int id = 1,
    int profileId = 7,
    String name = 'Apples',
    String category = 'allowed',
    String? foodGroup,
    bool isArchived = false,
  }) {
    final now = DateTime(2026);
    return DietItem(
      id: id,
      profileId: profileId,
      name: name,
      category: category,
      foodGroup: foodGroup,
      isArchived: isArchived,
      createdAt: now,
      updatedAt: now,
    );
  }

  DietGuidanceRule makeRule({
    int id = 1,
    int profileId = 7,
    String title = 'Drink water',
    String category = 'hydration',
    int? sortOrder,
    bool isArchived = false,
  }) {
    final now = DateTime(2026);
    return DietGuidanceRule(
      id: id,
      profileId: profileId,
      title: title,
      category: category,
      sortOrder: sortOrder,
      isArchived: isArchived,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('food items', () {
    test('dietFoodItemsProvider emits active foods for the active profile',
        () async {
      repo.addFood(makeFood(id: 1, name: 'Apple'));
      repo.addFood(makeFood(id: 2, name: 'Chocolate', isArchived: true));
      repo.addFood(makeFood(id: 3, name: 'Banana', profileId: 99));

      final value = await container.read(dietFoodItemsProvider(7).future);
      expect(value.map((f) => f.name), ['Apple']);
    });

    test('archivedDietFoodItemsProvider emits archived foods only', () async {
      repo.addFood(makeFood(id: 1, name: 'Apple'));
      repo.addFood(makeFood(id: 2, name: 'Chocolate', isArchived: true));

      final value = await container.read(archivedDietFoodItemsProvider(7).future);
      expect(value.map((f) => f.name), ['Chocolate']);
    });

    test('dietFoodItemByIdProvider finds a food for the profile', () async {
      repo.addFood(makeFood(id: 5, name: 'Avocado'));

      final value = await container
          .read(dietFoodItemByIdProvider((id: 5, profileId: 7)).future);
      expect(value!.name, 'Avocado');
    });

    test('dietFoodSearchProvider filters by query and category', () async {
      repo.addFood(makeFood(id: 1, name: 'Apple', category: 'allowed'));
      repo.addFood(makeFood(id: 2, name: 'Chocolate', category: 'avoid'));
      repo.addFood(makeFood(id: 3, name: 'Green Tea', category: 'caution'));

      container.read(dietFoodSearchQueryProvider.notifier).state = 'green';
      var value = await container.read(dietFoodSearchProvider(7).future);
      expect(value.map((f) => f.name), ['Green Tea']);

      container.read(dietFoodSearchQueryProvider.notifier).state = '';
      container.read(dietFoodCategoryFilterProvider.notifier).state = 'avoid';
      value = await container.read(dietFoodSearchProvider(7).future);
      expect(value.map((f) => f.name), ['Chocolate']);
    });

    test('sortedDietFoodItemsProvider sorts by name A-Z', () async {
      repo.addFood(makeFood(id: 1, name: 'Banana'));
      repo.addFood(makeFood(id: 2, name: 'apple'));
      repo.addFood(makeFood(id: 3, name: 'Cherry'));

      final value = await container.read(sortedDietFoodItemsProvider(7).future);
      expect(value.map((f) => f.name), ['apple', 'Banana', 'Cherry']);
    });

    test('sortedDietFoodItemsProvider sorts by name Z-A', () async {
      repo.addFood(makeFood(id: 1, name: 'Banana'));
      repo.addFood(makeFood(id: 2, name: 'apple'));

      container.read(dietFoodSortProvider.notifier).state =
          DietFoodSort.alphabeticalZA;
      final value = await container.read(sortedDietFoodItemsProvider(7).future);
      expect(value.map((f) => f.name), ['Banana', 'apple']);
    });

    test('sortedDietFoodItemsProvider sorts by category', () async {
      repo.addFood(makeFood(id: 1, name: 'Zucchini', category: 'allowed'));
      repo.addFood(makeFood(id: 2, name: 'Apple', category: 'avoid'));
      repo.addFood(makeFood(id: 3, name: 'Cherry', category: 'caution'));

      container.read(dietFoodSortProvider.notifier).state = DietFoodSort.byCategory;
      final value = await container.read(sortedDietFoodItemsProvider(7).future);
      expect(value.map((f) => f.name), ['Zucchini', 'Cherry', 'Apple']);
    });
  });

  group('guidance rules', () {
    test('dietGuidanceRulesProvider emits active rules', () async {
      repo.addRule(makeRule(id: 1, title: 'Drink water'));
      repo.addRule(makeRule(id: 2, title: 'No smoking', isArchived: true));

      final value = await container.read(dietGuidanceRulesProvider(7).future);
      expect(value.map((r) => r.title), ['Drink water']);
    });

    test('archivedDietGuidanceRulesProvider emits archived rules', () async {
      repo.addRule(makeRule(id: 1, title: 'Drink water'));
      repo.addRule(makeRule(id: 2, title: 'No smoking', isArchived: true));

      final value =
          await container.read(archivedDietGuidanceRulesProvider(7).future);
      expect(value.map((r) => r.title), ['No smoking']);
    });

    test('dietGuidanceRuleByIdProvider finds a rule for the profile', () async {
      repo.addRule(makeRule(id: 9, title: 'Limit coffee'));

      final value = await container
          .read(dietGuidanceRuleByIdProvider((id: 9, profileId: 7)).future);
      expect(value!.title, 'Limit coffee');
    });

    test('dietGuidanceSearchProvider filters by query and category', () async {
      repo.addRule(makeRule(
        id: 1,
        title: 'No smoking indoors',
        category: 'smoking',
      ));
      repo.addRule(makeRule(
        id: 2,
        title: 'Limit coffee',
        category: 'caffeine',
      ));
      repo.addRule(makeRule(
        id: 3,
        title: 'Avoid binge drinking',
        category: 'alcohol',
      ));

      container.read(dietGuidanceSearchQueryProvider.notifier).state = 'smok';
      var value = await container.read(dietGuidanceSearchProvider(7).future);
      expect(value.map((r) => r.title), ['No smoking indoors']);

      container.read(dietGuidanceSearchQueryProvider.notifier).state = '';
      container.read(dietGuidanceCategoryFilterProvider.notifier).state =
          'caffeine';
      value = await container.read(dietGuidanceSearchProvider(7).future);
      expect(value.map((r) => r.title), ['Limit coffee']);

      container.read(dietGuidanceCategoryFilterProvider.notifier).state =
          'alcohol';
      value = await container.read(dietGuidanceSearchProvider(7).future);
      expect(value.map((r) => r.title), ['Avoid binge drinking']);
    });
  });

  group('section switch', () {
    test('activeDietSectionProvider defaults to foods', () {
      expect(container.read(activeDietSectionProvider), DietSection.foods);
    });

    test('activeDietSectionProvider can switch to guidance', () {
      container.read(activeDietSectionProvider.notifier).state =
          DietSection.guidance;
      expect(container.read(activeDietSectionProvider), DietSection.guidance);
    });
  });
}
