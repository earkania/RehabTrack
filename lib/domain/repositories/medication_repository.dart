import 'package:rehab_track/domain/entities/medication.dart';

abstract class MedicationRepository {
  Stream<List<Medication>> watchMedications(int profileId);
  Stream<List<Medication>> watchActiveMedications(int profileId);
  Future<List<Medication>> getMedications(int profileId);
  Future<Medication?> getMedication(int id);
  Future<int> createMedication(Medication medication);
  Future<void> updateMedication(Medication medication);
  Future<void> deleteMedication(int id);

  Stream<List<MedicationSchedule>> watchSchedules(int medicationId);
  Future<int> createSchedule(MedicationSchedule schedule);
  Future<void> updateSchedule(MedicationSchedule schedule);
  Future<void> deleteSchedule(int id);

  Stream<List<MedicationLog>> watchLogs(
    int scheduleId, {
    DateTime? from,
    DateTime? to,
  });
  Future<List<MedicationLog>> getLogs(
    int scheduleId, {
    DateTime? from,
    DateTime? to,
  });
  Future<int> logDose(MedicationLog log);
  Future<void> updateLog(MedicationLog log);
}
