import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/app.dart';
import 'package:rehab_track/data/database/app_database.dart' show AppDatabase;
import 'package:rehab_track/domain/entities/doctor_prescription.dart';
import 'package:rehab_track/l10n/app_localizations_ka.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/doctor_prescription_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/screens/records/doctor_prescription_details_screen.dart';
import 'package:rehab_track/presentation/screens/records/doctor_prescription_form_screen.dart';
import 'package:rehab_track/presentation/screens/records/doctor_prescriptions_screen.dart';
import 'package:rehab_track/presentation/widgets/dashboard/module_grid_tile.dart';

/// Regression tests for the Doctor Prescriptions save-navigation bug.
///
/// Saving used to call context.go(recordsPrescriptions), which rebuilt the
/// stack and left the list as a root route without Back navigation. These
/// tests drive the real app router against an in-memory database and assert
/// that Add/Edit Save pops back into the existing stack instead.
void main() {
  late AppDatabase database;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase.test();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        currentActiveProfileIdProvider.overrideWith((ref) => 7),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    database.close();
  });

  /// Drains drift's zero-duration stream-cleanup timers scheduled when
  /// autoDispose providers are disposed during navigation.
  Future<void> flushTimers(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: RehabTrackApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> goToPrescriptionsList(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.folder_outlined));
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(ModuleGridTile, 'Doctor Prescriptions'),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
  }

  DoctorPrescription prescription(String title) => DoctorPrescription(
        profileId: 7,
        title: title,
        prescriptionDate: DateTime(2026, 1, 15),
        isArchived: false,
        createdAt: DateTime(2026, 1, 15),
        updatedAt: DateTime(2026, 1, 15),
      );

  Future<void> fillTitle(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextFormField).first, text);
    await tester.pump();
  }

  Future<void> tapSave(WidgetTester tester) async {
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    // Drain the saved-snackbar lifecycle (4 s visible + exit animation) so no
    // timers remain pending when the test ends.
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> openDetailsViaMenuEdit(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Prescription'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  group('Doctor Prescriptions save navigation', () {
    testWidgets('TEST 1: add save returns to the list with Back intact',
        (tester) async {
      await pumpApp(tester);
      await goToPrescriptionsList(tester);

      // FAB → Add Prescription form.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      await fillTitle(tester, 'Vitamin D Course');
      await tapSave(tester);

      // Same list instance shows the new record and keeps its Back button.
      expect(find.byType(DoctorPrescriptionsScreen), findsOneWidget);
      expect(find.text('Vitamin D Course'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);

      // Back returns to the Records dashboard (stack was never destroyed).
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(ModuleGridTile), findsWidgets);
      expect(find.byType(DoctorPrescriptionsScreen), findsNothing);

      await flushTimers(tester);
    });

    testWidgets('TEST 2: edit from details returns to refreshed details',
        (tester) async {
      final repo = container.read(doctorPrescriptionRepositoryProvider);
      await repo.createPrescription(prescription('Old Name'), const []);

      await pumpApp(tester);
      await goToPrescriptionsList(tester);

      // List → Details.
      await tester.tap(find.text('Old Name'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(DoctorPrescriptionDetailsScreen), findsOneWidget);

      // Details menu → Edit Prescription.
      await openDetailsViaMenuEdit(tester);
      expect(find.byType(DoctorPrescriptionFormScreen), findsOneWidget);

      // Change the name and save.
      await fillTitle(tester, 'New Name');
      await tapSave(tester);

      // Preferred behavior: back on Details showing updated values.
      expect(find.byType(DoctorPrescriptionDetailsScreen), findsOneWidget);
      expect(find.byType(DoctorPrescriptionFormScreen), findsNothing);
      expect(find.text('New Name'), findsOneWidget);
      expect(find.text('Old Name'), findsNothing);
      expect(find.byType(BackButton), findsOneWidget);

      // Details → List → Records, no duplicates anywhere.
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(DoctorPrescriptionsScreen), findsOneWidget);
      expect(find.text('New Name'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(ModuleGridTile), findsWidgets);

      await flushTimers(tester);
    });

    testWidgets('TEST 3: repeated edits keep the stack clean',
        (tester) async {
      final repo = container.read(doctorPrescriptionRepositoryProvider);
      await repo.createPrescription(prescription('First Name'), const []);

      await pumpApp(tester);
      await goToPrescriptionsList(tester);
      await tester.tap(find.text('First Name'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      for (final updated in ['Second Name', 'Third Name']) {
        await openDetailsViaMenuEdit(tester);
        await fillTitle(tester, updated);
        await tapSave(tester);

        expect(find.byType(DoctorPrescriptionDetailsScreen), findsOneWidget);
        expect(find.byType(DoctorPrescriptionFormScreen), findsNothing);
        expect(find.text(updated), findsOneWidget);
      }

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(DoctorPrescriptionsScreen), findsOneWidget);
      expect(find.byType(DoctorPrescriptionDetailsScreen), findsNothing);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(ModuleGridTile), findsWidgets);

      await flushTimers(tester);
    });

    testWidgets('TEST 4: adding several prescriptions in a row stays correct',
        (tester) async {
      await pumpApp(tester);
      await goToPrescriptionsList(tester);

      for (final title in ['First Rx', 'Second Rx']) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        await fillTitle(tester, title);
        await tapSave(tester);

        expect(find.byType(DoctorPrescriptionsScreen), findsOneWidget);
        expect(find.text(title), findsOneWidget);
        expect(find.byType(BackButton), findsOneWidget);
      }

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(ModuleGridTile), findsWidgets);

      await flushTimers(tester);
    });

    testWidgets('TEST 5: cancelling add/edit leaves data untouched',
        (tester) async {
      final repo = container.read(doctorPrescriptionRepositoryProvider);
      await repo.createPrescription(prescription('Kept Name'), const []);

      await pumpApp(tester);
      await goToPrescriptionsList(tester);

      // Cancel Add via back.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(DoctorPrescriptionsScreen), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);

      // Cancel Edit via back; details unchanged.
      await tester.tap(find.text('Kept Name'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await openDetailsViaMenuEdit(tester);
      await fillTitle(tester, 'Discarded Name');
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(DoctorPrescriptionDetailsScreen), findsOneWidget);
      expect(find.text('Kept Name'), findsOneWidget);
      expect(find.text('Discarded Name'), findsNothing);

      await flushTimers(tester);
    });
  });

  test('Georgian localization provides the flow strings', () {
    final ka = AppLocalizationsKa();
    expect(ka.prescriptionSaved, isNotEmpty);
    expect(ka.addDoctorPrescription, isNotEmpty);
    expect(ka.editDoctorPrescription, isNotEmpty);
    expect(ka.doctorPrescriptions, isNotEmpty);
  });
}
