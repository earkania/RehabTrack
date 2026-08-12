import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/core/constants/app_constants.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';
import 'package:rehab_track/domain/services/today_agenda_service.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';

/// Injectable clock so time-dependent Today behavior can be tested.
abstract class TodayClock {
  DateTime now();
}

class SystemTodayClock implements TodayClock {
  @override
  DateTime now() => DateTime.now();
}

final todayClockProvider = Provider<TodayClock>((ref) => SystemTodayClock());

final nowProvider = Provider<DateTime>((ref) => ref.watch(todayClockProvider).now());

final selectedAgendaDateProvider = StateProvider<DateTime>((ref) {
  final now = ref.watch(nowProvider);
  return DateTime(now.year, now.month, now.day);
});

/// The most recent local "current day" the app has synchronized to.
///
/// Used to detect a day change while Today is suspended or between tab
/// switches, so the selected date only advances when it was tracking Today
/// rather than a deliberately chosen historical or future date.
final lastKnownTodayProvider = StateProvider<DateTime>((ref) {
  final now = ref.watch(todayClockProvider).now();
  return DateTime(now.year, now.month, now.day);
});

/// The next local midnight after [now], built from the device-local date
/// components (never UTC, never a manual offset).
DateTime nextLocalMidnight(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  return DateTime(today.year, today.month, today.day + 1);
}

/// Advances [selectedDate] to the new current day when it was tracking the
/// previously-known current day. A deliberately selected past or future date
/// is preserved. Always records the newly observed current day in
/// [onUpdateLastToday].
void syncSelectedDateToCurrentDay({
  required DateTime now,
  required DateTime selectedDate,
  required DateTime lastToday,
  required void Function(DateTime) onAdvance,
  required void Function(DateTime) onUpdateLastToday,
}) {
  final newToday = DateTime(now.year, now.month, now.day);
  if (lastToday.isAtSameMomentAs(newToday)) return;
  if (selectedDate.isAtSameMomentAs(lastToday)) {
    onAdvance(newToday);
  }
  onUpdateLastToday(newToday);
}

final _todayAgendaServiceProvider = Provider<TodayAgendaService>((ref) {
  return TodayAgendaService(
    ref.watch(medicationRepositoryProvider),
    ref.watch(measurementRepositoryProvider),
  );
});

final todayRefreshTickProvider = StateProvider<int>((ref) => 0);

/// The current local minute, kept fresh by a single timer aligned to minute
/// boundaries (opening at 10:23:42 ticks next at 10:24:00).
///
/// All relative-time labels share this provider so exactly one Timer exists
/// while any of them is on screen. It is auto-disposed (and the Timer
/// cancelled) when the last listener goes away.
final currentMinuteProvider = StateProvider.autoDispose<DateTime>((ref) {
  final clock = ref.read(todayClockProvider);
  final now = clock.now();
  final minute = DateTime(now.year, now.month, now.day, now.hour, now.minute);

  Timer? timer;

  void scheduleNext() {
    final current = ref.read(todayClockProvider).now();
    final currentMinute =
        DateTime(current.year, current.month, current.day, current.hour, current.minute);
    final nextMinute = currentMinute.add(const Duration(minutes: 1));
    final delay = nextMinute.difference(current);
    timer = Timer(delay.isNegative ? Duration.zero : delay, () {
      final latest = ref.read(todayClockProvider).now();
      final latestMinute =
          DateTime(latest.year, latest.month, latest.day, latest.hour, latest.minute);
      ref.controller.state = latestMinute;
      scheduleNext();
    });
  }

  scheduleNext();
  ref.onDispose(() => timer?.cancel());
  return minute;
});

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
  final now = ref.watch(todayClockProvider).now();
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
  final now = ref.read(todayClockProvider).now();
  final today = DateTime(now.year, now.month, now.day);
  final selectedDate = ref.watch(selectedAgendaDateProvider);
  if (!selectedDate.isAtSameMomentAs(today)) return;

  final agendaAsync = ref.watch(dailyAgendaProvider);
  final graceMinutes = ref.watch(nextItemGracePeriodProvider);
  final agenda = agendaAsync.valueOrNull;

  final boundaries = <DateTime>[
    nextLocalMidnight(now),
  ];

  final gracePeriod = Duration(minutes: graceMinutes);
  if (agenda != null) {
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
  }

  final future = boundaries.where((d) => d.isAfter(now)).toList()..sort();
  if (future.isEmpty) return;

  final delay = future.first.difference(now);
  if (delay <= Duration.zero) return;

  final timer = Timer(delay, () {
    final container = ref.container;
    syncSelectedDateToCurrentDay(
      now: container.read(todayClockProvider).now(),
      selectedDate: container.read(selectedAgendaDateProvider),
      lastToday: container.read(lastKnownTodayProvider),
      onAdvance: (d) =>
          container.read(selectedAgendaDateProvider.notifier).state = d,
      onUpdateLastToday: (d) =>
          container.read(lastKnownTodayProvider.notifier).state = d,
    );
    container.read(todayRefreshTickProvider.notifier).state++;
  });

  ref.onDispose(timer.cancel);
});
