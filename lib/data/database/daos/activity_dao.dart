import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/database/tables/activity_tables.dart';

part 'activity_dao.g.dart';

@DriftAccessor(tables: [Activities, ActivitySessions])
class ActivityDao extends DatabaseAccessor<AppDatabase> with _$ActivityDaoMixin {
  ActivityDao(super.db);

  // ---- Activities ----------------------------------------------------------

  /// Watch all active (non-archived) activities for a profile,
  /// ordered A-Z by name.
  Stream<List<Activity>> watchActiveActivities(int profileId) {
    final query = select(activities)
      ..where((t) => t.profileId.equals(profileId) & t.isArchived.equals(false))
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    return query.watch();
  }

  /// Watch all archived activities for a profile, ordered A-Z by name.
  Stream<List<Activity>> watchArchivedActivities(int profileId) {
    final query = select(activities)
      ..where((t) => t.profileId.equals(profileId) & t.isArchived.equals(true))
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    return query.watch();
  }

  /// Watch all (active + archived) activities for a profile, ordered A-Z.
  Stream<List<Activity>> watchAllActivities(int profileId) {
    final query = select(activities)
      ..where((t) => t.profileId.equals(profileId))
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    return query.watch();
  }

  /// Get an activity by ID and profile ID.
  Future<Activity?> getActivity(int id, int profileId) {
    return (select(activities)
          ..where((t) => t.id.equals(id) & t.profileId.equals(profileId)))
        .getSingleOrNull();
  }

  /// Insert a new activity.
  Future<int> insertActivity(ActivitiesCompanion entry) {
    return into(activities).insert(entry);
  }

  /// Update an existing activity.
  Future<bool> updateActivity(ActivitiesCompanion entry) {
    return update(activities).replace(entry);
  }

  /// Archive or restore an activity.
  Future<int> setActivityArchived(int id, int profileId, bool archived) {
    return (update(activities)
          ..where((t) => t.id.equals(id) & t.profileId.equals(profileId)))
        .write(ActivitiesCompanion(
      isArchived: Value(archived),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Permanently delete an activity. Only allowed when it has no sessions.
  Future<int> deleteActivity(int id, int profileId) {
    return (delete(activities)
          ..where((t) => t.id.equals(id) & t.profileId.equals(profileId)))
        .go();
  }

  /// Search activities by name or description, optionally filtered by
  /// category. Ordered A-Z by name.
  Stream<List<Activity>> searchActivities(
    int profileId, {
    bool includeArchived = false,
    String? query,
    String? category,
  }) {
    var statement = select(activities)
      ..where((t) => t.profileId.equals(profileId));

    if (!includeArchived) {
      statement.where((t) => t.isArchived.equals(false));
    }

    if (query != null && query.isNotEmpty) {
      final searchTerm = '%$query%';
      statement.where(
        (t) => t.name.like(searchTerm) | t.description.like(searchTerm),
      );
    }

    if (category != null && category.isNotEmpty) {
      statement.where((t) => t.category.equals(category));
    }

    statement.orderBy([(t) => OrderingTerm.asc(t.name)]);

    return statement.watch();
  }

  /// Number of sessions recorded for a given activity. Used to guard
  /// permanent deletion: an activity with history cannot be deleted.
  Future<int> countSessionsForActivity(int activityId) {
    return (selectOnly(activitySessions)
          ..addColumns([activitySessions.id.count()])
          ..where(activitySessions.activityId.equals(activityId)))
        .map((row) => row.read(activitySessions.id.count())!)
        .getSingle();
  }

  // ---- Sessions ------------------------------------------------------------

  /// Watch the single active session (running or paused) for a profile,
  /// emitting null when there is none.
  Stream<ActivitySession?> watchActiveSession(int profileId) {
    final query = select(activitySessions)
      ..where(
        (t) =>
            t.profileId.equals(profileId) &
            t.status.isIn(['running', 'paused']),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.id)])
      ..limit(1);
    return query.watch().map((list) => list.isEmpty ? null : list.first);
  }

  /// Get the active session (running or paused) for a profile, if any.
  Future<ActivitySession?> getActiveSession(int profileId) async {
    final rows = await (select(activitySessions)
          ..where(
            (t) =>
                t.profileId.equals(profileId) &
                t.status.isIn(['running', 'paused']),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  /// Get a session by ID and profile ID.
  Future<ActivitySession?> getSession(int id, int profileId) {
    return (select(activitySessions)
          ..where((t) => t.id.equals(id) & t.profileId.equals(profileId)))
        .getSingleOrNull();
  }

  /// Insert a new session.
  Future<int> insertSession(ActivitySessionsCompanion entry) {
    return into(activitySessions).insert(entry);
  }

  /// Update an existing session.
  Future<bool> updateSession(ActivitySessionsCompanion entry) {
    return update(activitySessions).replace(entry);
  }

  /// Watch the completed and cancelled sessions for a profile, newest first.
  Stream<List<ActivitySession>> watchSessionHistory(int profileId) {
    final query = select(activitySessions)
      ..where(
        (t) =>
            t.profileId.equals(profileId) &
            t.status.isIn(['completed', 'cancelled']),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    return query.watch();
  }

  /// Permanently delete a session record.
  Future<int> deleteSession(int id, int profileId) {
    return (delete(activitySessions)
          ..where((t) => t.id.equals(id) & t.profileId.equals(profileId)))
        .go();
  }

  /// Delete all sessions belonging to an activity. Used when the activity is
  /// deleted without history (safety net).
  Future<int> deleteSessionsForActivity(int activityId) {
    return (delete(activitySessions)
          ..where((t) => t.activityId.equals(activityId)))
        .go();
  }
}