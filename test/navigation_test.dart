import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/app.dart';
import 'package:rehab_track/presentation/widgets/dashboard/module_grid_tile.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RehabTrackApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> goToTab(WidgetTester tester, IconData icon) async {
    await tester.tap(find.byIcon(icon));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('five-section navigation', () {
    testWidgets('bottom bar shows all five destinations', (tester) async {
      await pumpApp(tester);

      // Today is the initially selected tab, so it renders its label.
      expect(find.text('Today'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.health_and_safety_outlined), findsOneWidget);
      expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('Health dashboard shows four module tiles', (tester) async {
      await pumpApp(tester);
      await goToTab(tester, Icons.health_and_safety_outlined);

      expect(find.text('Medications'), findsWidgets);
      expect(find.text('Measurements'), findsWidgets);
      expect(find.text('Activities'), findsWidgets);
      expect(find.text('Diet'), findsWidgets);
    });

    testWidgets('Records dashboard shows three module tiles', (tester) async {
      await pumpApp(tester);
      await goToTab(tester, Icons.folder_outlined);

      expect(find.text('Lab Analyses'), findsWidgets);
      expect(find.text('Doctor Visits'), findsWidgets);
      expect(find.text('Reports'), findsWidgets);
    });

    testWidgets('Profile dashboard shows four module tiles', (tester) async {
      await pumpApp(tester);
      await goToTab(tester, Icons.person_outlined);

      expect(find.text('Patient Profile'), findsWidgets);
      expect(find.text('Doctors'), findsWidgets);
      expect(find.text('Emergency Contacts'), findsWidgets);
      expect(find.text('Medical Notes'), findsWidgets);
    });

    testWidgets('Profile Patient Profile tile opens the screen and back returns',
        (tester) async {
      await pumpApp(tester);
      await goToTab(tester, Icons.person_outlined);

      await tester.tap(
        find.widgetWithText(ModuleGridTile, 'Patient Profile'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // The Patient Profile screen (AppBar title) is shown.
      expect(find.text('Patient Profile'), findsWidgets);

      await tester.pageBack();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Back on the Profile dashboard.
      expect(find.text('Doctors'), findsWidgets);
    });

    testWidgets('placeholder tile opens placeholder screen and back returns',
        (tester) async {
      await pumpApp(tester);
      await goToTab(tester, Icons.health_and_safety_outlined);

      await tester.tap(find.text('Activities'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Coming soon'), findsOneWidget);

      await tester.pageBack();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Back on the Health dashboard.
      expect(find.text('Diet'), findsWidgets);
    });

    testWidgets('tapping the selected tab keeps its dashboard', (tester) async {
      await pumpApp(tester);
      await goToTab(tester, Icons.health_and_safety_outlined);
      // Health is now selected, so its filled icon is shown.
      await tester.tap(find.byIcon(Icons.health_and_safety));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Measurements'), findsWidgets);
      expect(find.text('Diet'), findsWidgets);
    });
  });
}
