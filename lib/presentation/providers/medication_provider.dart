import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';

final medicationListProvider =
    StreamProvider.autoDispose<List<Medication>>((ref) {
  final profileId = ref.watch(activeProfileIdProvider);
  if (profileId == null) {
    return const Stream.empty();
  }
  final repo = ref.watch(medicationRepositoryProvider);
  return repo.watchActiveMedications(profileId);
});

final medicationProvider =
    FutureProvider.autoDispose.family<Medication?, int>((ref, id) async {
  final repo = ref.watch(medicationRepositoryProvider);
  return repo.getMedication(id);
});

final medicationSchedulesProvider =
    StreamProvider.autoDispose.family<List<MedicationSchedule>, int>(
        (ref, medicationId) {
  final repo = ref.watch(medicationRepositoryProvider);
  return repo.watchSchedules(medicationId);
});

final medicationScheduleProvider =
    FutureProvider.autoDispose.family<MedicationSchedule?, int>(
        (ref, scheduleId) async {
  final repo = ref.watch(medicationRepositoryProvider);
  return repo.getSchedule(scheduleId);
});
