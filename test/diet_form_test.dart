import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/diet.dart';
import 'package:rehab_track/domain/repositories/diet_repository.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/diet_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/screens/health/diet_food_form_screen.dart';
import 'package:rehab_track/presentation/screens/health/diet_guidance_form_screen.dart';

class FakeDietRepository implements DietRepository {
  final List<DietItem> _foods = [];
  final List<DietGuidanceRule> _rules = [];

  Stream<List<DietItem>> _foodStream(int profileId, {bool archived = false}) =>
      Stream.value(_foods
          .where((f) =>
              f.profileId == profileId && f.isArchived == archived)
          .toList());
  Stream<List<DietGuidanceRule>> _ruleStream(int profileId,
          {bool archived = false}) =>
      Stream.value(_rules
          .where((r) =>
              r.profileId == profileId && r.isArchived == archived)
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

  setUp(() {
    repo = FakeDietRepository();
  });

  Widget buildFoodForm({Locale? locale}) {
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
        home: const DietFoodFormScreen(),
      ),
    );
  }

  Widget buildGuidanceForm({Locale? locale}) {
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
        home: const DietGuidanceFormScreen(),
      ),
    );
  }

  group('DietFoodFormScreen', () {
    testWidgets('requires a name in English', (tester) async {
      await tester.pumpWidget(buildFoodForm());
      await tester.pump();

      await tester.tap(find.text('Save Food'));
      await tester.pump();

      expect(find.text('Food name is required'), findsOneWidget);
    });

    testWidgets('requires a name in Georgian', (tester) async {
      await tester.pumpWidget(buildFoodForm(locale: const Locale('ka')));
      await tester.pump();

      await tester.tap(find.text('საკვების შენახვა'));
      await tester.pump();

      expect(find.text('საკვების დასახელება სავალდებულოა'), findsOneWidget);
    });

    testWidgets('renders category dropdown options', (tester) async {
      await tester.pumpWidget(buildFoodForm());
      await tester.pump();

      await tester.tap(find.text('Allowed'));
      await tester.pumpAndSettle();

      expect(find.text('Caution'), findsOneWidget);
      expect(find.text('Avoid'), findsOneWidget);
    });
  });

  group('DietGuidanceFormScreen', () {
    testWidgets('requires a title in English', (tester) async {
      await tester.pumpWidget(buildGuidanceForm());
      await tester.pump();

      await tester.tap(find.text('Save Guidance'));
      await tester.pump();

      expect(find.text('Title is required'), findsOneWidget);
    });

    testWidgets('requires a title in Georgian', (tester) async {
      await tester.pumpWidget(buildGuidanceForm(locale: const Locale('ka')));
      await tester.pump();

      await tester.tap(find.text('რეკომენდაციის შენახვა'));
      await tester.pump();

      expect(find.text('სათაური სავალდებულოა'), findsOneWidget);
    });

    testWidgets('renders category dropdown options', (tester) async {
      await tester.pumpWidget(buildGuidanceForm());
      await tester.pump();

      await tester.tap(find.text('Diet'));
      await tester.pumpAndSettle();

      expect(find.text('Smoking'), findsOneWidget);
      expect(find.text('Hydration'), findsOneWidget);
      expect(find.text('Caffeine'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
    });
  });
}