import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/domain/entities/adherence_stats.dart';
import 'package:rehab_track/domain/entities/history_period.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/domain/entities/medication_alternative.dart';
import 'package:rehab_track/domain/entities/medication_alternative_component.dart';
import 'package:rehab_track/domain/entities/medication_component.dart';
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

final medicationAlternativesProvider =
    StreamProvider.autoDispose.family<List<MedicationAlternative>, int>(
        (ref, medicationId) {
  final repo = ref.watch(medicationRepositoryProvider);
  return repo.watchAlternatives(medicationId);
});

final medicationAlternativeProvider =
    FutureProvider.autoDispose.family<MedicationAlternative?, int>(
        (ref, alternativeId) async {
  final repo = ref.watch(medicationRepositoryProvider);
  return repo.getAlternative(alternativeId);
});

final medicationComponentsProvider =
    StreamProvider.autoDispose.family<List<MedicationComponent>, int>(
        (ref, medicationId) {
  final repo = ref.watch(medicationRepositoryProvider);
  return repo.watchComponents(medicationId);
});

final medicationAlternativeComponentsProvider =
    StreamProvider.autoDispose.family<List<MedicationAlternativeComponent>, int>(
        (ref, alternativeId) {
  final repo = ref.watch(medicationRepositoryProvider);
  return repo.watchAlternativeComponents(alternativeId);
});

final _medicationScheduleLogsProvider = FutureProvider.autoDispose
    .family<List<MedicationLog>, ({int scheduleId, HistoryPeriod period})>(
        (ref, params) async {
  final repo = ref.watch(medicationRepositoryProvider);
  return repo.getLogs(params.scheduleId, from: params.period.from);
});

final medicationAllLogsProvider = FutureProvider.autoDispose
    .family<List<MedicationLog>, ({int medicationId, HistoryPeriod period})>(
        (ref, params) async {
  final repo = ref.watch(medicationRepositoryProvider);
  final schedules = await repo.watchSchedules(params.medicationId).first;
  final allLogs = <MedicationLog>[];
  for (final schedule in schedules) {
    if (schedule.id == null) continue;
    final logs = await ref.read(
      _medicationScheduleLogsProvider(
        (scheduleId: schedule.id!, period: params.period),
      ).future,
    );
    allLogs.addAll(logs);
  }
  allLogs.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
  return allLogs;
});

final medicationAdherenceStatsProvider = Provider.autoDispose
    .family<AdherenceStats, ({int medicationId, HistoryPeriod period})>(
        (ref, params) {
  final logsAsync = ref.watch(
    medicationAllLogsProvider(
      (medicationId: params.medicationId, period: params.period),
    ),
  );
  return logsAsync.when(
    data: (logs) => AdherenceStats.fromLogs(logs),
    loading: () => AdherenceStats.empty,
    error: (_, _) => AdherenceStats.empty,
  );
});
