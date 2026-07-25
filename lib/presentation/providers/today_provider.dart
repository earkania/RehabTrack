import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';
import 'package:rehab_track/domain/services/today_agenda_service.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';

final _todayAgendaServiceProvider = Provider<TodayAgendaService>((ref) {
  return TodayAgendaService(
    ref.watch(medicationRepositoryProvider),
    ref.watch(measurementRepositoryProvider),
  );
});

final todayAgendaProvider =
    FutureProvider.autoDispose<TodayAgenda>((ref) async {
  final profileId = ref.watch(activeProfileIdProvider);
  if (profileId == null) {
    return TodayAgenda(
      date: DateTime.now(),
      items: const [],
      summary: const TodaySummary.empty(),
    );
  }
  final service = ref.watch(_todayAgendaServiceProvider);
  return service.generateAgenda(profileId);
});

final todaySummaryProvider = Provider<TodaySummary>((ref) {
  final agenda = ref.watch(todayAgendaProvider);
  return agenda.when(
    data: (data) => data.summary,
    loading: () => const TodaySummary.empty(),
    error: (_, __) => const TodaySummary.empty(),
  );
});

final nextTodayItemProvider = Provider<TodayAgendaItem?>((ref) {
  final agenda = ref.watch(todayAgendaProvider);
  return agenda.when(
    data: (data) => data.nextItem(),
    loading: () => null,
    error: (_, __) => null,
  );
});

final todayItemsProvider = Provider<List<TodayAgendaItem>>((ref) {
  final agenda = ref.watch(todayAgendaProvider);
  return agenda.when(
    data: (data) => data.items,
    loading: () => const [],
    error: (_, __) => const [],
  );
});
