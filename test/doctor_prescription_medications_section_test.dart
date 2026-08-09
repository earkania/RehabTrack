import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/doctor_prescription.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/screens/records/doctor_prescription_medications_section.dart';

void main() {
  DoctorPrescriptionMedication medication(String name) =>
      DoctorPrescriptionMedication(
        id: 1,
        prescriptionId: 1,
        profileId: 1,
        medicationName: name,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

  Widget build(List<DoctorPrescriptionMedication> initial,
      ValueChanged<List<DoctorPrescriptionMedication>> onChanged) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: DoctorPrescriptionMedicationsEditor(
          initialMedications: initial,
          onChanged: onChanged,
        ),
      ),
    );
  }

  ValueChanged<List<DoctorPrescriptionMedication>> onChange() => (_) {};

  testWidgets('editor shows medications when later passed in via update',
      (tester) async {
    await tester.pumpWidget(build(const [], onChange()));

    expect(find.text('No medications in this prescription'), findsOneWidget);

    await tester.pumpWidget(build([medication('Clopidogrel')], onChange()));
    await tester.pump();

    expect(find.text('Clopidogrel'), findsOneWidget);
    expect(find.text('No medications in this prescription'), findsNothing);
  });

  testWidgets('editor preserves user edits after unrelated rebuild',
      (tester) async {
    await tester.pumpWidget(build([medication('Clopidogrel')], onChange()));
    await tester.pump();
    expect(find.text('Clopidogrel'), findsOneWidget);

    // Simulate a user-initiated removal so the widget marks itself dirty.
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Clopidogrel'), findsNothing);

    // Parent rebuilds with a stale external list; dirty state must win.
    await tester.pumpWidget(build([medication('Clopidogrel')], onChange()));
    await tester.pump();
    expect(find.text('Clopidogrel'), findsNothing);
  });
}