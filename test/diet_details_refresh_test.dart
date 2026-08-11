import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/entities/diet.dart';
import 'package:rehab_track/domain/repositories/diet_repository.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/diet_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/screens/health/diet_food_details_screen.dart';
import 'package:rehab_track/presentation/screens/health/diet_food_form_screen.dart';
import 'package:rehab_track/presentation/screens/health/diet_guidance_details_screen.dart';
import 'package:rehab_track/presentation/screens/health/diet_guidance_form_screen.dart';

class FakeDietRepository implements DietRepository {
  final List<DietItem> _foods = [];
  final List<DietGuidanceRule> _rules = [];

  void addFood(DietItem item) => _foods.add(item);
  void addRule(DietGuidanceRule rule) => _rules.add(rule);

  Stream<List<DietItem>> _foodStream(int profileId, {bool archived = false}) =>
      Stream.value(_foods
          .where((f) => f.profileId == profileId && f.isArchived == archived)
          .toList());

  Stream<List<DietGuidanceRule>> _ruleStream(int profileId,
          {bool archived = false}) =>
      Stream.value(_rules
          .where((r) => r.profileId == profileId && r.isArchived == archived)
          .toList());

  @override
  Stream<List<DietItem>> watchActiveFoodItems(int profileId) =>
      _foodStream(profileId);

  @override
  Stream<List<DietItem>> watchArchivedFoodItems(int profileId) =>
      _foodStream(profileId, archived: true);

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
  }) =>
      _foodStream(profileId, archived: includeArchived);

  @override
  Stream<List<DietGuidanceRule>> watchActiveGuidanceRules(int profileId) =>
      _ruleStream(profileId);

  @override
  Stream<List<DietGuidanceRule>> watchArchivedGuidanceRules(int profileId) =>
      _ruleStream(profileId, archived: true);

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
  }) =>
      _ruleStream(profileId, archived: includeArchived);
}

void main() {
  late FakeDietRepository repo;
  late GoRouter router;

  setUp(() {
    repo = FakeDietRepository();
  });

  Widget buildApp({Widget Function(GoRouterState state)? detail}) {
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/diet',
          builder: (context, state) => detail!(state),
        ),
        GoRoute(
          path: '/health/diet/foods/:id',
          builder: (context, state) => DietFoodDetailsScreen(
            foodId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/health/diet/foods/:id/edit',
          builder: (context, state) => DietFoodFormScreen(
            foodId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/health/diet/guidance/:id',
          builder: (context, state) => DietGuidanceDetailsScreen(
            ruleId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/health/diet/guidance/:id/edit',
          builder: (context, state) => DietGuidanceFormScreen(
            ruleId: int.parse(state.pathParameters['id']!),
          ),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        dietRepositoryProvider.overrideWithValue(repo),
        currentActiveProfileIdProvider.overrideWith((ref) => 7),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }

  group('details refresh after edit', () {
    testWidgets('Guidance details reloads edited values after returning',
        (tester) async {
      final now = DateTime(2026);
      repo.addRule(DietGuidanceRule(
        id: 1,
        profileId: 7,
        title: 'Drink water',
        category: 'hydration',
        isArchived: false,
        createdAt: now,
        updatedAt: now,
      ));

      await tester.pumpWidget(buildApp(
        detail: (state) => const Scaffold(
          body: Center(child: Text('start')),
        ),
      ));
      await tester.pumpAndSettle();

      // Open the guidance details screen directly.
      router.go('/health/diet/guidance/1');
      await tester.pumpAndSettle();
      expect(find.text('Drink water'), findsOneWidget);

      // Edit the rule, changing the title.
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit Guidance'));
      await tester.pumpAndSettle();
      expect(find.byType(DietGuidanceFormScreen), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, 'Drink 2L daily');
      await tester.tap(find.text('Update Guidance'));
      await tester.pumpAndSettle();

      // Back on details, the new title is shown (reloaded, not stale).
      expect(find.byType(DietGuidanceDetailsScreen), findsOneWidget);
      expect(find.text('Drink 2L daily'), findsOneWidget);
      expect(find.text('Drink water'), findsNothing);
    });

    testWidgets('Food details reloads edited values after returning',
        (tester) async {
      final now = DateTime(2026);
      repo.addFood(DietItem(
        id: 1,
        profileId: 7,
        name: 'Apples',
        category: 'allowed',
        isArchived: false,
        createdAt: now,
        updatedAt: now,
      ));

      await tester.pumpWidget(buildApp(
        detail: (state) => const Scaffold(
          body: Center(child: Text('start')),
        ),
      ));
      await tester.pumpAndSettle();

      router.go('/health/diet/foods/1');
      await tester.pumpAndSettle();
      expect(find.text('Apples'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit Food'));
      await tester.pumpAndSettle();
      expect(find.byType(DietFoodFormScreen), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, 'Green Apples');
      await tester.tap(find.text('Update Food'));
      await tester.pumpAndSettle();

      expect(find.byType(DietFoodDetailsScreen), findsOneWidget);
      expect(find.text('Green Apples'), findsOneWidget);
      expect(find.text('Apples'), findsNothing);
    });
  });
}