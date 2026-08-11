import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/data/repositories/diet_repository_impl.dart';
import 'package:rehab_track/domain/entities/diet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late db.AppDatabase database;
  late DietRepositoryImpl repository;
  late Directory tempDir;

  setUp(() async {
    database = db.AppDatabase.test();
    repository = DietRepositoryImpl(database);
    tempDir = Directory.systemTemp.createTempSync('diet_repo_test_');
  });

  tearDown(() async {
    await database.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Future<int> insertProfile({String firstName = 'John'}) {
    return database.into(database.profiles).insert(
      db.ProfilesCompanion.insert(
        firstName: firstName,
        lastName: 'Doe',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        isPrimary: const Value(true),
        isActive: const Value(true),
      ),
    );
  }

  DietItem makeFoodItem({
    int? id,
    required int profileId,
    String name = 'Apples',
    String category = 'allowed',
    String? foodGroup,
    String? notes,
    String? source,
    bool isArchived = false,
  }) {
    return DietItem(
      id: id,
      profileId: profileId,
      name: name,
      category: category,
      foodGroup: foodGroup,
      notes: notes,
      source: source,
      isArchived: isArchived,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
  }

  DietGuidanceRule makeGuidanceRule({
    int? id,
    required int profileId,
    String title = 'Drink water',
    String category = 'hydration',
    String? description,
    String? source,
    int? sortOrder,
    bool isArchived = false,
  }) {
    return DietGuidanceRule(
      id: id,
      profileId: profileId,
      title: title,
      category: category,
      description: description,
      source: source,
      sortOrder: sortOrder,
      isArchived: isArchived,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
  }

  group('food items', () {
    test('create and read a food item', () async {
      final profileId = await insertProfile();
      final created = await repository.createFoodItem(
        makeFoodItem(profileId: profileId),
      );

      expect(created.id, isNotNull);
      final fetched = await repository.getFoodItem(created.id!, profileId);
      expect(fetched!.name, 'Apples');
      expect(fetched.category, 'allowed');
      expect(fetched.isArchived, false);
    });

    test('update a food item', () async {
      final profileId = await insertProfile();
      final created = await repository.createFoodItem(
        makeFoodItem(profileId: profileId),
      );

      final updated = await repository.updateFoodItem(
        created.copyWith(
          name: 'Green Apples',
          category: 'caution',
          notes: 'Eat with skin',
        ),
      );
      expect(updated.name, 'Green Apples');
      expect(updated.category, 'caution');
      expect(updated.notes, 'Eat with skin');
    });

    test('archive and restore a food item', () async {
      final profileId = await insertProfile();
      final created = await repository.createFoodItem(
        makeFoodItem(profileId: profileId),
      );

      await repository.archiveFoodItem(created.id!, profileId);
      final archived = await repository.getFoodItem(created.id!, profileId);
      expect(archived!.isArchived, true);

      await repository.restoreFoodItem(created.id!, profileId);
      final restored = await repository.getFoodItem(created.id!, profileId);
      expect(restored!.isArchived, false);
    });

    test('watchActiveFoodItems excludes archived and sorts A-Z', () async {
      final profileId = await insertProfile();
      await repository.createFoodItem(
        makeFoodItem(profileId: profileId, name: 'Banana'),
      );
      final archivedItem = await repository.createFoodItem(
        makeFoodItem(profileId: profileId, name: 'Apple'),
      );
      await repository.archiveFoodItem(archivedItem.id!, profileId);

      final active = await repository
          .watchActiveFoodItems(profileId)
          .first;
      expect(active.map((e) => e.name), ['Banana']);

      final archived = await repository
          .watchArchivedFoodItems(profileId)
          .first;
      expect(archived.map((e) => e.name), ['Apple']);
    });

    test('permanently deletes a food item', () async {
      final profileId = await insertProfile();
      final created = await repository.createFoodItem(
        makeFoodItem(profileId: profileId),
      );

      await repository.deleteFoodItem(created.id!, profileId);
      final fetched = await repository.getFoodItem(created.id!, profileId);
      expect(fetched, isNull);
    });

    test('search filters by name and category', () async {
      final profileId = await insertProfile();
      await repository.createFoodItem(
        makeFoodItem(profileId: profileId, name: 'Apple', category: 'allowed'),
      );
      await repository.createFoodItem(
        makeFoodItem(
          profileId: profileId,
          name: 'Chocolate',
          category: 'avoid',
          foodGroup: 'Sweets',
        ),
      );
      await repository.createFoodItem(
        makeFoodItem(profileId: profileId, name: 'Coffee', category: 'caution'),
      );
      final archivedItem = await repository.createFoodItem(
        makeFoodItem(profileId: profileId, name: 'Candy Apple', category: 'avoid'),
      );
      await repository.archiveFoodItem(archivedItem.id!, profileId);

      final byName = await repository
          .searchFoodItems(profileId, query: 'app')
          .first;
      expect(byName.map((e) => e.name), ['Apple']);

      final byGroup = await repository
          .searchFoodItems(profileId, query: 'sweet')
          .first;
      expect(byGroup.map((e) => e.name), ['Chocolate']);

      final byCategory = await repository
          .searchFoodItems(profileId, category: 'caution')
          .first;
      expect(byCategory.map((e) => e.name), ['Coffee']);

      // Archived items are excluded by default but included when requested.
      final active = await repository
          .searchFoodItems(profileId, query: 'app')
          .first;
      expect(active.map((e) => e.name), ['Apple']);

      final withArchived = await repository
          .searchFoodItems(profileId, includeArchived: true, query: 'app')
          .first;
      expect(withArchived.map((e) => e.name), ['Apple', 'Candy Apple']);
    });

    test('food items are scoped to their profile', () async {
      final profileA = await insertProfile(firstName: 'Alice');
      final profileB = await insertProfile(firstName: 'Bob');

      await repository.createFoodItem(
        makeFoodItem(profileId: profileA, name: 'Avocado'),
      );

      final itemsB = await repository.watchActiveFoodItems(profileB).first;
      expect(itemsB, isEmpty);

      final fetched = await repository.getFoodItem(999, profileA);
      expect(fetched, isNull);
    });
  });

  group('guidance rules', () {
    test('create and read a guidance rule', () async {
      final profileId = await insertProfile();
      final created = await repository.createGuidanceRule(
        makeGuidanceRule(profileId: profileId, title: 'Drink water daily'),
      );

      expect(created.id, isNotNull);
      final fetched =
          await repository.getGuidanceRule(created.id!, profileId);
      expect(fetched!.title, 'Drink water daily');
      expect(fetched.category, 'hydration');
    });

    test('update a guidance rule', () async {
      final profileId = await insertProfile();
      final created = await repository.createGuidanceRule(
        makeGuidanceRule(profileId: profileId),
      );

      final updated = await repository.updateGuidanceRule(
        created.copyWith(title: 'Drink 2L daily', description: 'Steady intake'),
      );
      expect(updated.title, 'Drink 2L daily');
      expect(updated.description, 'Steady intake');
    });

    test('archive and restore a guidance rule', () async {
      final profileId = await insertProfile();
      final created = await repository.createGuidanceRule(
        makeGuidanceRule(profileId: profileId),
      );

      await repository.archiveGuidanceRule(created.id!, profileId);
      final archived = await repository.getGuidanceRule(created.id!, profileId);
      expect(archived!.isArchived, true);

      await repository.restoreGuidanceRule(created.id!, profileId);
      final restored = await repository.getGuidanceRule(created.id!, profileId);
      expect(restored!.isArchived, false);
    });

    test('watchActiveGuidanceRules orders by sortOrder then title', () async {
      final profileId = await insertProfile();
      await repository.createGuidanceRule(
        makeGuidanceRule(profileId: profileId, title: 'Zebra rule', sortOrder: 2),
      );
      await repository.createGuidanceRule(
        makeGuidanceRule(profileId: profileId, title: 'Alpha rule'),
      );
      await repository.createGuidanceRule(
        makeGuidanceRule(profileId: profileId, title: 'Middle rule', sortOrder: 1),
      );

      final active = await repository.watchActiveGuidanceRules(profileId).first;
      expect(active.map((e) => e.title), ['Alpha rule', 'Middle rule', 'Zebra rule']);
    });

    test('search filters by title and category', () async {
      final profileId = await insertProfile();
      await repository.createGuidanceRule(
        makeGuidanceRule(
          profileId: profileId,
          title: 'No smoking indoors',
          category: 'smoking',
        ),
      );
      await repository.createGuidanceRule(
        makeGuidanceRule(
          profileId: profileId,
          title: 'Limit coffee',
          category: 'caffeine',
          description: 'Max two cups',
        ),
      );

      final byTitle = await repository
          .searchGuidanceRules(profileId, query: 'smok')
          .first;
      expect(byTitle.map((e) => e.title), ['No smoking indoors']);

      final byDescription = await repository
          .searchGuidanceRules(profileId, query: 'two cups')
          .first;
      expect(byDescription.map((e) => e.title), ['Limit coffee']);

      final byCategory = await repository
          .searchGuidanceRules(profileId, category: 'caffeine')
          .first;
      expect(byCategory.map((e) => e.title), ['Limit coffee']);
    });

    test('permanently deletes a guidance rule', () async {
      final profileId = await insertProfile();
      final created = await repository.createGuidanceRule(
        makeGuidanceRule(profileId: profileId),
      );

      await repository.deleteGuidanceRule(created.id!, profileId);
      final fetched = await repository.getGuidanceRule(created.id!, profileId);
      expect(fetched, isNull);
    });
  });
}
