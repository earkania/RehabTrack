import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/app.dart';
import 'package:rehab_track/presentation/screens/health/diet_screen.dart';
import 'package:rehab_track/presentation/screens/health/diet_food_form_screen.dart';
import 'package:rehab_track/presentation/widgets/dashboard/module_grid_tile.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RehabTrackApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> goToHealthTab(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.health_and_safety_outlined));
    await tester.pump();
    await tester.pumpAndSettle();
  }

  Future<void> goToDietScreen(WidgetTester tester) async {
    await goToHealthTab(tester);
    await tester.tap(find.widgetWithText(ModuleGridTile, 'Diet'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
  }

  group('Diet routing', () {
    testWidgets('Health dashboard shows the Diet tile', (tester) async {
      await pumpApp(tester);
      await goToHealthTab(tester);

      expect(find.text('Diet'), findsWidgets);
      expect(find.widgetWithText(ModuleGridTile, 'Diet'), findsOneWidget);
    });

    testWidgets('Diet tile opens the Diet screen and back returns',
        (tester) async {
      await pumpApp(tester);
      await goToDietScreen(tester);

      expect(find.byType(DietScreen), findsOneWidget);
      expect(find.text('No active profile'), findsWidgets);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(ModuleGridTile), findsWidgets);
    });

    testWidgets('Foods FAB opens the add food route without an active profile',
        (tester) async {
      await pumpApp(tester);
      await goToDietScreen(tester);

      expect(find.byType(FloatingActionButton), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(DietFoodFormScreen), findsOneWidget);
      expect(find.text('Food Name'), findsOneWidget);
    });

    testWidgets('no overflow on a narrow screen without an active profile',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpApp(tester);
      await goToDietScreen(tester);

      expect(tester.takeException(), isNull);
    });
  });

  group('Diet Food form', () {
    testWidgets('requires a name before saving', (tester) async {
      await pumpApp(tester);
      await goToDietScreen(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      await tester.tap(find.text('Save Food'));
      await tester.pump();
      expect(find.text('Food name is required'), findsOneWidget);
    });
  });
}