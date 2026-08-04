import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/app.dart';
import 'package:rehab_track/presentation/screens/records/doctor_visits_screen.dart';
import 'package:rehab_track/presentation/widgets/dashboard/module_grid_tile.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RehabTrackApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> goToRecordsTab(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.folder_outlined));
    await tester.pump();
    await tester.pumpAndSettle();
  }

  group('Doctor Visits routing', () {
    testWidgets('Records dashboard shows the Doctor Visits tile',
        (tester) async {
      await pumpApp(tester);
      await goToRecordsTab(tester);

      expect(find.text('Doctor Visits'), findsOneWidget);
      expect(
        find.widgetWithText(ModuleGridTile, 'Doctor Visits'),
        findsOneWidget,
      );
    });

    testWidgets('Doctor Visits tile opens the list screen and back returns',
        (tester) async {
      await pumpApp(tester);
      await goToRecordsTab(tester);

      await tester.tap(find.widgetWithText(ModuleGridTile, 'Doctor Visits'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.byType(DoctorVisitsScreen), findsOneWidget);
      expect(find.bySubtype<SegmentedButton<dynamic>>(), findsWidgets);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(ModuleGridTile), findsWidgets);
    });

    testWidgets('FAB opens the add visit route', (tester) async {
      await pumpApp(tester);
      await goToRecordsTab(tester);

      await tester.tap(find.widgetWithText(ModuleGridTile, 'Doctor Visits'));
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Add Doctor Visit'), findsOneWidget);
    });
  });
}
