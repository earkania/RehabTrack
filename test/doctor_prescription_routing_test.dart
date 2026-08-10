import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/app.dart';
import 'package:rehab_track/presentation/screens/records/doctor_prescriptions_screen.dart';
import 'package:rehab_track/presentation/screens/records/doctor_prescription_form_screen.dart';
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

  group('Doctor Prescriptions routing', () {
    testWidgets('Records dashboard shows the Doctor Prescriptions tile',
        (tester) async {
      await pumpApp(tester);
      await goToRecordsTab(tester);

      expect(find.text('Doctor Prescriptions'), findsOneWidget);
      expect(
        find.widgetWithText(ModuleGridTile, 'Doctor Prescriptions'),
        findsOneWidget,
      );
    });

    testWidgets('Doctor Prescriptions tile opens the list screen and back '
        'returns', (tester) async {
      await pumpApp(tester);
      await goToRecordsTab(tester);

      await tester.tap(
        find.widgetWithText(ModuleGridTile, 'Doctor Prescriptions'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.byType(DoctorPrescriptionsScreen), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('No active profile'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(ModuleGridTile), findsWidgets);
    });

    testWidgets('FAB opens the add prescription route', (tester) async {
      await pumpApp(tester);
      await goToRecordsTab(tester);

      await tester.tap(
        find.widgetWithText(ModuleGridTile, 'Doctor Prescriptions'),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Add Prescription'), findsOneWidget);
      expect(find.text('Prescription Name'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Add Medication'),
        300,
        scrollable: find
            .descendant(
              of: find.byType(DoctorPrescriptionFormScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.text('Medications'), findsOneWidget);
      expect(find.text('Add Medication'), findsOneWidget);
    });
  });
}