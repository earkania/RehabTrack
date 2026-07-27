import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';
import 'package:rehab_track/domain/services/today_agenda_service.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';

final selectedAgendaDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final _todayAgendaServiceProvider = Provider<TodayAgendaService>((ref) {
  return TodayAgendaService(
    ref.watch(medicationRepositoryProvider),
    ref.watch(measurementRepositoryProvider),
  );
});

final dailyAgendaProvider =
    FutureProvider.autoDispose<TodayAgenda>((ref) async {
  final profileId = ref.watch(activeProfileIdProvider);
  if (profileId == null) {
    final selectedDate = ref.watch(selectedAgendaDateProvider);
    return TodayAgenda(
      date: selectedDate,
      items: const [],
      summary: const TodaySummary.empty(),
    );
  }
  final service = ref.watch(_todayAgendaServiceProvider);
  final selectedDate = ref.watch(selectedAgendaDateProvider);
  return service.generateAgenda(profileId, selectedDate: selectedDate);
});

final todayAgendaProvider = dailyAgendaProvider;

final dailySummaryProvider = Provider<TodaySummary>((ref) {
  final agenda = ref.watch(dailyAgendaProvider);
  return agenda.when(
    data: (data) => data.summary,
    loading: () => const TodaySummary.empty(),
    error: (_, _) => const TodaySummary.empty(),
  );
});

final todaySummaryProvider = dailySummaryProvider;

final nextDailyItemProvider = Provider<TodayAgendaItem?>((ref) {
  final agenda = ref.watch(dailyAgendaProvider);
  final selectedDate = ref.watch(selectedAgendaDateProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  if (!selectedDate.isAtSameMomentAs(today)) return null;
  return agenda.when(
    data: (data) => data.nextItem(),
    loading: () => null,
    error: (_, _) => null,
  );
});

final nextTodayItemProvider = nextDailyItemProvider;

final dailyItemsProvider = Provider<List<TodayAgendaItem>>((ref) {
  final agenda = ref.watch(dailyAgendaProvider);
  return agenda.when(
    data: (data) => data.items,
    loading: () => const [],
    error: (_, _) => const [],
  );
});

final todayItemsProvider = dailyItemsProvider;
