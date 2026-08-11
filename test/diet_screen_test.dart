import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/diet.dart';
import 'package:rehab_track/domain/repositories/diet_repository.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/diet_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/screens/health/diet_screen.dart';

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
  Future<void> archiveFoodItem(int id, int profileId) async {
    final index = _foods.indexWhere((f) => f.id == id && f.profileId == profileId);
    if (index >= 0) {
      _foods[index] = _foods[index].copyWith(isArchived: true);
    }
  }

  @override
  Future<void> restoreFoodItem(int id, int profileId) async {
    final index = _foods.indexWhere((f) => f.id == id && f.profileId == profileId);
    if (index >= 0) {
      _foods[index] = _foods[index].copyWith(isArchived: false);
    }
  }

  @override
  Future<void> deleteFoodItem(int id, int profileId) async {
    _foods.removeWhere((f) => f.id == id && f.profileId == profileId);
  }

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
    final list = _rules
        .where((r) => r.profileId == profileId && !r.isArchived)
        .toList()
      ..sort((a, b) {
        final aOrder = a.sortOrder ?? 0;
        final bOrder = b.sortOrder ?? 0;
        if (aOrder != bOrder) return aOrder.compareTo(bOrder);
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });
    yield list;
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
  Future<void> archiveGuidanceRule(int id, int profileId) async {
    final index = _rules.indexWhere((r) => r.id == id && r.profileId == profileId);
    if (index >= 0) {
      _rules[index] = _rules[index].copyWith(isArchived: true);
    }
  }

  @override
  Future<void> restoreGuidanceRule(int id, int profileId) async {
    final index = _rules.indexWhere((r) => r.id == id && r.profileId == profileId);
    if (index >= 0) {
      _rules[index] = _rules[index].copyWith(isArchived: false);
    }
  }

  @override
  Future<void> deleteGuidanceRule(int id, int profileId) async {
    _rules.removeWhere((r) => r.id == id && r.profileId == profileId);
  }

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
        final haystack = [r.title, r.description ?? '', r.source ?? '']
            .join(' ')
            .toLowerCase();
        if (!haystack.contains(q)) return false;
      }
      return true;
    }).toList();
  }
}

void main() {
  late FakeDietRepository repo;

  setUp(() {
    repo = FakeDietRepository();
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

  Widget buildApp({Locale? locale}) {
    return ProviderScope(
      overrides: [
        dietRepositoryProvider.overrideWithValue(repo),
        currentActiveProfileIdProvider.overrideWith((ref) => 7),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: const DietScreen(),
      ),
    );
  }

  Future<void> pumpDiet(WidgetTester tester, {Locale? locale}) async {
    await tester.pumpWidget(buildApp(locale: locale));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
  }

  group('DietScreen foods section', () {
    testWidgets('lists food items with their categories', (tester) async {
      repo.addFood(makeFood(id: 1, name: 'Apples', category: 'allowed'));
      repo.addFood(makeFood(id: 2, name: 'Chocolate', category: 'avoid'));

      await pumpDiet(tester);

      expect(find.text('Apples'), findsOneWidget);
      expect(find.text('Chocolate'), findsOneWidget);
      expect(find.text('Allowed'), findsWidgets);
      expect(find.text('Avoid'), findsWidgets);
    });

    testWidgets('empty state shows a prompt and add action', (tester) async {
      await pumpDiet(tester);

      expect(find.text('No food guidance yet'), findsOneWidget);
      expect(find.text('Add Food'), findsOneWidget);
    });

    testWidgets('search narrows the food list', (tester) async {
      repo.addFood(makeFood(id: 1, name: 'Apples', category: 'allowed'));
      repo.addFood(makeFood(id: 2, name: 'Bananas', category: 'allowed'));

      await pumpDiet(tester);
      await tester.enterText(find.byType(TextField), 'app');
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Apples'), findsOneWidget);
      expect(find.text('Bananas'), findsNothing);
    });

    testWidgets('archived toggle shows archived foods and hides FAB',
        (tester) async {
      repo.addFood(makeFood(id: 1, name: 'Old Snack', isArchived: true));
      repo.addFood(makeFood(id: 2, name: 'Apples'));

      await pumpDiet(tester);
      expect(find.text('Old Snack'), findsNothing);

      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Old Snack'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('no overflow on a narrow screen with foods listed',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      repo.addFood(makeFood(id: 1, name: 'Apples', category: 'allowed'));
      repo.addFood(makeFood(id: 2, name: 'Chocolate', category: 'avoid'));

      await pumpDiet(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Georgian locale renders foods labels', (tester) async {
      repo.addFood(makeFood(id: 1, name: 'Apples', category: 'allowed'));
      repo.addFood(
        makeFood(id: 2, name: 'Bad Snack', category: 'avoid'),
      );

      await pumpDiet(tester, locale: const Locale('ka'));

      expect(find.text('საკვები'), findsOneWidget);
      expect(find.text('დასაშვები'), findsWidgets);
      expect(find.text('აკრძალული'), findsWidgets);
    });
  });

  group('DietScreen guidance section', () {
    testWidgets('switches to guidance and lists rules in title order',
        (tester) async {
      repo.addRule(makeRule(id: 1, title: 'Drink water', category: 'hydration'));

      await pumpDiet(tester);
      await tester.tap(find.text('General Guidance'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Drink water'), findsOneWidget);
      expect(find.text('Search general guidance'), findsOneWidget);
    });

    testWidgets('switching back to foods preserves the foods list',
        (tester) async {
      repo.addFood(makeFood(id: 1, name: 'Apples'));
      repo.addRule(makeRule(id: 1, title: 'Drink water'));

      await pumpDiet(tester);
      expect(find.text('Apples'), findsOneWidget);

      await tester.tap(find.text('General Guidance'));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Drink water'), findsOneWidget);
      expect(find.text('Apples'), findsNothing);

      await tester.tap(find.text('Foods'));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Apples'), findsOneWidget);
    });

    testWidgets('archived toggle in guidance section shows archived rules',
        (tester) async {
      repo.addRule(makeRule(id: 1, title: 'Old rule', isArchived: true));
      repo.addRule(makeRule(id: 2, title: 'Active rule'));

      await pumpDiet(tester);
      await tester.tap(find.text('General Guidance'));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Old rule'), findsNothing);

      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Old rule'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });
}