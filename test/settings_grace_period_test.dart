import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/screens/settings/settings_screen.dart';

class FakeSettingsRepo implements SettingsRepository {
  final Map<String, String> _store = {};

  @override
  Future<String?> getValue(String key) async => _store[key];

  @override
  Future<void> setValue(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
  }

  @override
  Stream<Map<String, String>> watchAll() async* {
    yield Map.from(_store);
  }

  @override
  Future<Map<String, String>> getAll() async => Map.from(_store);
}

Widget _buildApp({
  required FakeSettingsRepo settings,
  Locale? locale,
}) {
  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(settings),
      currentActiveProfileIdProvider.overrideWith((ref) => null),
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
      home: const SettingsScreen(),
    ),
  );
}

extension PumpGracePeriod on WidgetTester {
  Future<void> pumpGracePeriod({
    required FakeSettingsRepo settings,
    Locale? locale,
  }) async {
    await pumpWidget(_buildApp(settings: settings, locale: locale));
    await pump();
  }
}

void main() {
  group('Settings grace period tile', () {
    testWidgets('shows Next item grace period tile in English', (
      tester,
    ) async {
      final settings = FakeSettingsRepo();
      await tester.pumpGracePeriod(settings: settings);

      expect(find.text('Next item grace period'), findsOneWidget);
      expect(find.text('15 minutes'), findsOneWidget);
    });

    testWidgets('shows Next item grace period tile in Georgian', (
      tester,
    ) async {
      final settings = FakeSettingsRepo();
      await tester.pumpGracePeriod(
        settings: settings,
        locale: const Locale('ka'),
      );

      expect(
        find.text('შემდეგი ჩანაწერის დაყოვნების პერიოდი'),
        findsOneWidget,
      );
      expect(find.text('15 წუთი'), findsOneWidget);
    });

    testWidgets('shows persisted value in subtitle', (tester) async {
      final settings = FakeSettingsRepo();
      await settings.setValue(
        'next_item_grace_period_minutes',
        '30',
      );
      await tester.pumpGracePeriod(settings: settings);
      await tester.pumpAndSettle();

      expect(find.text('30 minutes'), findsOneWidget);
    });

    testWidgets('tapping opens selection dialog', (tester) async {
      final settings = FakeSettingsRepo();
      await tester.pumpGracePeriod(settings: settings);

      await tester.tap(find.text('Next item grace period'));
      await tester.pumpAndSettle();

      final dialog = find.byType(SimpleDialog);
      expect(dialog, findsOneWidget);

      for (final label in ['5 minutes', '10 minutes', '15 minutes', '30 minutes', '60 minutes']) {
        expect(
          find.descendant(of: dialog, matching: find.text(label)),
          findsOneWidget,
        );
      }
    });

    testWidgets('choosing another value updates the tile', (tester) async {
      final settings = FakeSettingsRepo();
      await tester.pumpGracePeriod(settings: settings);

      await tester.tap(find.text('Next item grace period'));
      await tester.pumpAndSettle();

      final dialog = find.byType(SimpleDialog);
      await tester.tap(
        find.descendant(of: dialog, matching: find.text('30 minutes')),
      );
      await tester.pumpAndSettle();

      expect(find.text('30 minutes'), findsOneWidget);
    });

    testWidgets('no overflow on narrow screen', (tester) async {
      final settings = FakeSettingsRepo();
      await tester.binding.setSurfaceSize(const Size(320, 600));

      await tester.pumpGracePeriod(settings: settings);

      final tile = find.text('Next item grace period');
      expect(tile, findsOneWidget);
      expect(
        tester.widget<Text>(tile).overflow,
        isNot(TextOverflow.fade),
      );

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('timer icon is present', (tester) async {
      final settings = FakeSettingsRepo();
      await tester.pumpGracePeriod(settings: settings);

      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });

    testWidgets('chevron right icon is present', (tester) async {
      final settings = FakeSettingsRepo();
      await tester.pumpGracePeriod(settings: settings);

      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });

    testWidgets('section header Today is present', (tester) async {
      final settings = FakeSettingsRepo();
      await tester.pumpGracePeriod(settings: settings);

      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('Georgian layout no overflow on narrow screen', (
      tester,
    ) async {
      final settings = FakeSettingsRepo();
      await tester.binding.setSurfaceSize(const Size(320, 600));

      await tester.pumpGracePeriod(
        settings: settings,
        locale: const Locale('ka'),
      );

      final title = find.text('შემდეგი ჩანაწერის დაყოვნების პერიოდი');
      expect(title, findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('selected option shows filled radio icon in dialog', (
      tester,
    ) async {
      final settings = FakeSettingsRepo();
      await tester.pumpGracePeriod(settings: settings);

      await tester.tap(find.text('Next item grace period'));
      await tester.pumpAndSettle();

      final dialog = find.byType(SimpleDialog);
      final filledRadios = find.descendant(
        of: dialog,
        matching: find.byIcon(Icons.radio_button_checked),
      );
      expect(filledRadios, findsOneWidget);

      final emptyRadios = find.descendant(
        of: dialog,
        matching: find.byIcon(Icons.radio_button_unchecked),
      );
      expect(emptyRadios, findsNWidgets(4));
    });
  });
}
