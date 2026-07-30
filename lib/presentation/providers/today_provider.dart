import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/core/constants/app_constants.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';
import 'package:rehab_track/domain/services/today_agenda_service.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';

final nowProvider = Provider<DateTime>((ref) => DateTime.now());

final selectedAgendaDateProvider = StateProvider<DateTime>((ref) {
  final now = ref.watch(nowProvider);
  return DateTime(now.year, now.month, now.day);
});

final _todayAgendaServiceProvider = Provider<TodayAgendaService>((ref) {
  return TodayAgendaService(
    ref.watch(medicationRepositoryProvider),
    ref.watch(measurementRepositoryProvider),
  );
});

final todayRefreshTickProvider = StateProvider<int>((ref) => 0);

final dailyAgendaProvider =
    FutureProvider.autoDispose<TodayAgenda>((ref) async {
  ref.watch(todayRefreshTickProvider);
  final profileId = ref.watch(currentActiveProfileIdProvider);
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
  final graceMinutes = ref.watch(nextItemGracePeriodProvider);
  return service.generateAgenda(
    profileId,
    selectedDate: selectedDate,
    gracePeriod: Duration(minutes: graceMinutes),
  );
});

final todayAgendaProvider = dailyAgendaProvider;

final nextItemGracePeriodProvider = StateNotifierProvider<NextItemGracePeriodNotifier, int>((ref) {
  return NextItemGracePeriodNotifier(ref.read(settingsRepositoryProvider));
});

class NextItemGracePeriodNotifier extends StateNotifier<int> {
  final SettingsRepository _settingsRepository;
  Future<void>? _loadFuture;

  NextItemGracePeriodNotifier(this._settingsRepository) : super(15) {
    _loadFuture = _load();
  }

  Future<void> get ready => _loadFuture ?? Future.value();

  Future<void> _load() async {
    final raw =
        await _settingsRepository.getValue(AppConstants.nextItemGracePeriodSettingsKey);
    if (raw != null) {
      final parsed = int.tryParse(raw);
      if (parsed != null && parsed > 0) {
        state = parsed;
      }
    }
  }

  Future<void> setGracePeriod(int minutes) async {
    if (minutes <= 0) return;
    state = minutes;
    await _settingsRepository.setValue(
      AppConstants.nextItemGracePeriodSettingsKey,
      minutes.toString(),
    );
  }
}

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
  final gracePeriodMinutes = ref.watch(nextItemGracePeriodProvider);
  final now = ref.watch(nowProvider);
  final today = DateTime(now.year, now.month, now.day);
  if (!selectedDate.isAtSameMomentAs(today)) return null;
  return agenda.when(
    data: (data) => data.nextItem(now: now, graceWindow: Duration(minutes: gracePeriodMinutes)),
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

final todayAutoRefreshProvider = Provider.autoDispose<void>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final selectedDate = ref.watch(selectedAgendaDateProvider);
  if (!selectedDate.isAtSameMomentAs(today)) return;

  final agendaAsync = ref.watch(dailyAgendaProvider);
  final graceMinutes = ref.watch(nextItemGracePeriodProvider);
  final agenda = agendaAsync.valueOrNull;
  if (agenda == null || agenda.items.isEmpty) return;

  final gracePeriod = Duration(minutes: graceMinutes);
  final boundaries = <DateTime>[
    today.add(const Duration(days: 1)),
  ];

  for (final item in agenda.items) {
    if (item.isCompleted) continue;
    final effective = item.effectiveTime;
    if (effective.isAfter(now)) {
      boundaries.add(effective);
    }
    final overdueAt = effective.add(gracePeriod);
    if (overdueAt.isAfter(now)) {
      boundaries.add(overdueAt);
    }
  }

  final future = boundaries.where((d) => d.isAfter(now)).toList()..sort();
  if (future.isEmpty) return;

  final delay = future.first.difference(now);
  if (delay <= Duration.zero) return;

  final timer = Timer(delay, () {
    ref.read(todayRefreshTickProvider.notifier).state++;
  });

  ref.onDispose(timer.cancel);
});
