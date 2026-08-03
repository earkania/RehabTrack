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

  Future<void> goToProfileTab(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.person_outlined));
    await tester.pump();
    await tester.pumpAndSettle();
  }

  group('Care Contacts routing', () {
    testWidgets('Profile dashboard shows the Care Contacts tile',
        (tester) async {
      await pumpApp(tester);
      await goToProfileTab(tester);

      expect(find.text('Care Contacts'), findsOneWidget);
      expect(
        find.widgetWithText(ModuleGridTile, 'Care Contacts'),
        findsOneWidget,
      );
    });

    testWidgets('Care Contacts tile opens the contacts list and back returns',
        (tester) async {
      await pumpApp(tester);
      await goToProfileTab(tester);

      await tester.tap(find.widgetWithText(ModuleGridTile, 'Care Contacts'));
      await tester.pump();
      await tester.pumpAndSettle();

      // The contacts list screen is shown.
      expect(find.text('Care Contacts'), findsWidgets);
      expect(find.byType(TextField), findsWidgets);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // Back on the Profile dashboard.
      expect(find.text('Care Contacts'), findsOneWidget);
    });

    testWidgets('FAB opens the add contact route', (tester) async {
      await pumpApp(tester);
      await goToProfileTab(tester);

      await tester.tap(find.widgetWithText(ModuleGridTile, 'Care Contacts'));
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // The add screen shows the contact-type selector sheet.
      expect(find.text('Select Contact Type'), findsOneWidget);
      expect(find.text('Doctor or Specialist'), findsWidgets);
      expect(find.text('Insurance Company'), findsWidgets);

      // Dismiss the sheet so the test can end cleanly.
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    });
  });
}
