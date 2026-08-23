import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rehab_track/data/database/daos/activity_dao.dart';
import 'package:rehab_track/data/repositories/activity_repository_impl.dart';
import 'package:rehab_track/domain/entities/activity.dart';
import 'package:rehab_track/domain/repositories/activity_repository.dart';

import 'database_provider.dart';

/// Provider for ActivityDao.
final activityDaoProvider = Provider<ActivityDao>((ref) {
  final database = ref.watch(databaseProvider);
  return database.activityDao;
});

/// Provider for ActivityRepository.
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return ActivityRepositoryImpl(database);
});

// ---- Activities ------------------------------------------------------------

/// Active (non-archived) activities for a profile.
final activeActivitiesProvider =
    StreamProvider.autoDispose.family<List<Activity>, int>((ref, profileId) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.watchActiveActivities(profileId);
});

/// Archived activities for a profile.
final archivedActivitiesProvider =
    StreamProvider.autoDispose.family<List<Activity>, int>((ref, profileId) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.watchArchivedActivities(profileId);
});

/// All activities (active + archived) for a profile.
final allActivitiesProvider =
    StreamProvider.autoDispose.family<List<Activity>, int>((ref, profileId) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.watchAllActivities(profileId);
});

/// Search query for activities.
final activitySearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

/// Category filter for activities: null = all.
final activityCategoryFilterProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);

/// Sort order for activities.
enum ActivitySort {
  alphabeticalAZ,
  alphabeticalZA,
  byCategory,
}

/// Sort order provider.
final activitySortProvider =
    StateProvider.autoDispose<ActivitySort>((ref) => ActivitySort.alphabeticalAZ);

/// Search + category-filtered activities for a profile, sorted.
final filteredActivitiesProvider =
    StreamProvider.autoDispose.family<List<Activity>, int>((ref, profileId) {
  final repository = ref.watch(activityRepositoryProvider);
  final query = ref.watch(activitySearchQueryProvider);
  final category = ref.watch(activityCategoryFilterProvider);
  final sort = ref.watch(activitySortProvider);

  final stream = repository.searchActivities(
    profileId,
    query: query.isEmpty ? null : query,
    category: category,
  );
  return stream.map((list) => sortActivities(list, sort));
});

/// Sorts a list of activities by the given [sort] order.
List<Activity> sortActivities(List<Activity> list, ActivitySort sort) {
  final sorted = List<Activity>.from(list);
  switch (sort) {
    case ActivitySort.alphabeticalAZ:
      sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      break;
    case ActivitySort.alphabeticalZA:
      sorted.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      break;
    case ActivitySort.byCategory:
      sorted.sort((a, b) {
        final categoryCompare = _activityCategoryOrder(a.category)
            .compareTo(_activityCategoryOrder(b.category));
        if (categoryCompare != 0) return categoryCompare;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      break;
  }
  return sorted;
}

/// Single activity by ID and profile ID.
final activityByIdProvider =
    FutureProvider.autoDispose.family<Activity?, ({int id, int profileId})>(
        (ref, params) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.getActivity(params.id, params.profileId);
});

// ---- Sessions --------------------------------------------------------------

/// The single active (running or paused) session for a profile, or null.
final activeSessionProvider =
    StreamProvider.autoDispose.family<ActivitySession?, int>((ref, profileId) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.watchActiveSession(profileId);
});

/// The activity belonging to the active session for a profile, if any.
final activeSessionActivityProvider =
    FutureProvider.autoDispose.family<Activity?, int>((ref, profileId) {
  final session = ref.watch(activeSessionProvider(profileId)).valueOrNull;
  if (session == null) return Future.value(null);
  final repository = ref.watch(activityRepositoryProvider);
  return repository.getActivity(session.activityId, profileId);
});

/// Completed/cancelled session history for a profile, newest first.
final sessionHistoryProvider =
    StreamProvider.autoDispose.family<List<ActivitySession>, int>(
        (ref, profileId) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.watchSessionHistory(profileId);
});

/// Single session by session ID and profile ID.
final sessionByIdProvider =
    FutureProvider.autoDispose.family<ActivitySession?, ({int id, int profileId})>(
        (ref, params) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.getSession(params.id, params.profileId);
});

/// Single activity by session ID and profile ID (for history details).
final activityForSessionProvider =
    FutureProvider.autoDispose.family<Activity?, ({int sessionId, int profileId})>(
        (ref, params) async {
  final repository = ref.watch(activityRepositoryProvider);
  final session =
      await repository.getSession(params.sessionId, params.profileId);
  if (session == null) return null;
  return repository.getActivity(session.activityId, params.profileId);
});

/// Ticks once per second with the current time. Drives live session timers;
/// disposed automatically when no screen is listening.
final currentTimeProvider = StreamProvider.autoDispose<DateTime>((ref) {
  return Stream.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now(),
  );
});

int _activityCategoryOrder(String category) {
  switch (category) {
    case 'exercise':
      return 0;
    case 'rehabilitation':
      return 1;
    case 'physiotherapy':
      return 2;
    case 'general_wellness':
      return 3;
    default:
      return 4;
  }
}