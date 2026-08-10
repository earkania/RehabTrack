import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/doctor_prescription.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/domain/entities/medication_alternative.dart';
import 'package:rehab_track/domain/entities/medication_alternative_component.dart';
import 'package:rehab_track/domain/entities/medication_component.dart';
import 'package:rehab_track/domain/repositories/medication_repository.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/screens/records/doctor_prescription_medications_section.dart';

class _FakeMedicationRepository implements MedicationRepository {
  _FakeMedicationRepository(this.activeMedications);

  final List<Medication> activeMedications;

  @override
  Future<List<Medication>> getActiveMedications(int profileId) async =>
      activeMedications.where((m) => m.profileId == profileId).toList();

  @override
  Future<List<Medication>> getMedications(int profileId) async =>
      activeMedications
          .where((m) => m.profileId == profileId)
          .toList();

  @override
  Future<Medication?> getMedication(int id) async =>
      activeMedications.where((m) => m.id == id).firstOrNull;

  @override
  Future<List<MedicationSchedule>> getSchedulesForMedication(
    int medicationId,
  ) async =>
      [];

  @override
  Stream<List<Medication>> watchMedications(int profileId) => Stream.value([]);

  @override
  Stream<List<Medication>> watchActiveMedications(int profileId) =>
      Stream.value(activeMedications);

  @override
  Future<int> createMedication(Medication medication) async => 1;

  @override
  Future<void> updateMedication(Medication medication) async {}

  @override
  Future<void> deleteMedication(int id) async {}

  @override
  Stream<List<MedicationSchedule>> watchSchedules(int medicationId) =>
      Stream.value(const []);

  @override
  Future<MedicationSchedule?> getSchedule(int id) async => null;

  @override
  Future<int> createSchedule(MedicationSchedule schedule) async => 1;

  @override
  Future<void> updateSchedule(MedicationSchedule schedule) async {}

  @override
  Future<void> deleteSchedule(int id) async {}

  @override
  Stream<List<MedicationLog>> watchLogs(
    int scheduleId, {
    DateTime? from,
    DateTime? to,
  }) =>
      Stream.value(const []);

  @override
  Future<List<MedicationLog>> getLogs(
    int scheduleId, {
    DateTime? from,
    DateTime? to,
  }) async =>
      [];

  @override
  Future<MedicationLog?> getLogForOccurrence(
    int scheduleId,
    DateTime scheduledTime,
  ) async =>
      null;

  @override
  Future<int> logDose(MedicationLog log) async => 1;

  @override
  Future<void> updateLog(MedicationLog log) async {}

  @override
  Future<void> cancelReminderNotification(
    int scheduleId,
    DateTime scheduledTime,
  ) async {}

  @override
  Future<void> deleteLogForOccurrence(
    int scheduleId,
    DateTime scheduledTime,
  ) async {}

  @override
  Stream<List<MedicationAlternative>> watchAlternatives(int medicationId) =>
      Stream.value(const []);

  @override
  Future<List<MedicationAlternative>> getAlternatives(int medicationId) async =>
      [];

  @override
  Future<MedicationAlternative?> getAlternative(int id) async => null;

  @override
  Future<int> createAlternative(MedicationAlternative alternative) async => 1;

  @override
  Future<void> updateAlternative(MedicationAlternative alternative) async {}

  @override
  Future<void> deleteAlternative(int id) async {}

  @override
  Stream<List<MedicationComponent>> watchComponents(int medicationId) =>
      Stream.value(const []);

  @override
  Future<List<MedicationComponent>> getComponents(int medicationId) async => [];

  @override
  Future<void> replaceMedicationComponents(
    int medicationId,
    List<MedicationComponent> components,
  ) async {}

  @override
  Stream<List<MedicationAlternativeComponent>> watchAlternativeComponents(
    int alternativeId,
  ) =>
      Stream.value(const []);

  @override
  Future<List<MedicationAlternativeComponent>> getAlternativeComponents(
    int alternativeId,
  ) async =>
      [];

  @override
  Future<void> replaceAlternativeComponents(
    int alternativeId,
    List<MedicationAlternativeComponent> components,
  ) async {}
}

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

  Widget buildWithSource(
    List<Medication> active, {
    List<DoctorPrescriptionMedication> initial = const [],
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: DoctorPrescriptionMedicationsEditor(
          initialMedications: initial,
          prescriptionId: 5,
          profileId: 3,
          medicationRepository: _FakeMedicationRepository(active),
          onChanged: onChange(),
        ),
      ),
    );
  }

  Medication activeMedication() => Medication(
        id: 10,
        profileId: 3,
        name: 'Amlodipine',
        doseAmount: '5',
        doseUnit: 'mg',
        active: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

  testWidgets('add medication offers choose-from and manual entry choices',
      (tester) async {
    await tester.pumpWidget(buildWithSource([activeMedication()]));

    await tester.tap(find.text('Add Medication'));
    await tester.pumpAndSettle();

    expect(find.text('Choose from My Medications'), findsOneWidget);
    expect(find.text('Enter Manually'), findsOneWidget);
  });

  testWidgets('choosing a medication prefills the editor sheet',
      (tester) async {
    await tester.pumpWidget(buildWithSource([activeMedication()]));

    await tester.tap(find.text('Add Medication'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose from My Medications'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Amlodipine'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Medication'), findsNothing);
    expect(find.text('Amlodipine'), findsWidgets);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('mg'), findsOneWidget);
  });

  testWidgets('manual entry opens the blank editor sheet', (tester) async {
    await tester.pumpWidget(buildWithSource([]));

    await tester.tap(find.text('Add Medication'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enter Manually'));
    await tester.pumpAndSettle();

    expect(find.text('e.g., Amoxicillin'), findsOneWidget);
  });

  testWidgets('no active medications shows empty state with manual fallback',
      (tester) async {
    await tester.pumpWidget(buildWithSource([]));

    await tester.tap(find.text('Add Medication'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose from My Medications'));
    await tester.pumpAndSettle();

    expect(find.text('No active medications available'), findsOneWidget);
    await tester.tap(find.text('Enter Manually'));
    await tester.pumpAndSettle();

    expect(find.text('e.g., Amoxicillin'), findsOneWidget);
  });

  testWidgets('picker is scoped to the prescription profile', (tester) async {
    final now = DateTime(2026, 1, 1);
    final otherProfileMed = Medication(
      id: 20,
      profileId: 4,
      name: 'Metformin',
      active: true,
      createdAt: now,
      updatedAt: now,
    );
    await tester.pumpWidget(buildWithSource([
      activeMedication(),
      otherProfileMed,
    ]));

    await tester.tap(find.text('Add Medication'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose from My Medications'));
    await tester.pumpAndSettle();

    expect(find.text('Amlodipine'), findsOneWidget);
    expect(find.text('Metformin'), findsNothing);
  });
}