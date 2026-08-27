import 'package:drift/drift.dart' show Value;
import 'package:rehab_track/data/database/app_database.dart'
    hide Activity, ActivitySession;
import 'package:rehab_track/data/database/daos/activity_dao.dart';
import 'package:rehab_track/domain/entities/activity.dart';
import 'package:rehab_track/domain/repositories/activity_repository.dart';

/// Drift implementation of [ActivityRepository].
class ActivityRepositoryImpl implements ActivityRepository {
  final AppDatabase _database;

  ActivityRepositoryImpl(this._database);

  ActivityDao get _dao => _database.activityDao;

  @override
  Stream<List<Activity>> watchActiveActivities(int profileId) {
    return _dao
        .watchActiveActivities(profileId)
        .map((list) => list.map(Activity.fromDb).toList());
  }

  @override
  Stream<List<Activity>> watchArchivedActivities(int profileId) {
    return _dao
        .watchArchivedActivities(profileId)
        .map((list) => list.map(Activity.fromDb).toList());
  }

  @override
  Stream<List<Activity>> watchAllActivities(int profileId) {
    return _dao
        .watchAllActivities(profileId)
        .map((list) => list.map(Activity.fromDb).toList());
  }

  @override
  Future<Activity?> getActivity(int id, int profileId) {
    return _dao.getActivity(id, profileId).then((dbModel) {
      if (dbModel == null) return null;
      return Activity.fromDb(dbModel);
    });
  }

  @override
  Future<Activity> createActivity(Activity activity) async {
    final id = await _dao.insertActivity(activity.toCompanion());
    return (await getActivity(id, activity.profileId))!;
  }

  @override
  Future<Activity> updateActivity(Activity activity) async {
    await _dao.updateActivity(activity.toUpdateCompanion());
    return (await getActivity(activity.id!, activity.profileId))!;
  }

  @override
  Future<void> archiveActivity(int id, int profileId) async {
    await _dao.setActivityArchived(id, profileId, true);
  }

  @override
  Future<void> restoreActivity(int id, int profileId) async {
    await _dao.setActivityArchived(id, profileId, false);
  }

  @override
  Future<int> countSessionsForActivity(int activityId) {
    return _dao.countSessionsForActivity(activityId);
  }

  @override
  Future<void> deleteActivity(int id, int profileId) async {
    final count = await _dao.countSessionsForActivity(id);
    if (count > 0) {
      throw StateError(
        'Activity $id has $count recorded session(s) and cannot be deleted. '
        'Archive it instead.',
      );
    }
    await _dao.deleteActivity(id, profileId);
  }

  @override
  Stream<List<Activity>> searchActivities(
    int profileId, {
    bool includeArchived = false,
    String? query,
    String? category,
  }) {
    return _dao
        .searchActivities(
          profileId,
          includeArchived: includeArchived,
          query: query,
          category: category,
        )
        .map((list) => list.map(Activity.fromDb).toList());
  }

  @override
  Stream<ActivitySession?> watchActiveSession(int profileId) {
    return _dao
        .watchActiveSession(profileId)
        .map((dbModel) => dbModel == null ? null : ActivitySession.fromDb(dbModel));
  }

  @override
  Future<ActivitySession?> getActiveSession(int profileId) async {
    final session = await _dao.getActiveSession(profileId);
    return session == null ? null : ActivitySession.fromDb(session);
  }

  @override
  Future<ActivitySession?> getSession(int id, int profileId) {
    return _dao.getSession(id, profileId).then((dbModel) {
      if (dbModel == null) return null;
      return ActivitySession.fromDb(dbModel);
    });
  }

  @override
  Stream<List<ActivitySession>> watchSessionHistory(int profileId) {
    return _dao
        .watchSessionHistory(profileId)
        .map((list) => list.map(ActivitySession.fromDb).toList());
  }

  @override
  Future<List<ActivitySession>> getSessionsBetween(
    int profileId,
    DateTime startInclusive,
    DateTime endExclusive,
  ) async {
    final rows =
        await _dao.getSessionsBetween(profileId, startInclusive, endExclusive);
    return rows.map(ActivitySession.fromDb).toList();
  }

  @override
  Future<ActivitySession> startSession(
    int activityId,
    int profileId, {
    required String mode,
    int? plannedDurationSeconds,
    int? restDurationSeconds,
    DateTime? now,
  }) async {
    final nowEffective = now ?? DateTime.now();
    final existing = await _dao.getActiveSession(profileId);
    if (existing != null) {
      // Only a fresh profile can hold an active session; the caller is
      // expected to finish or cancel it first. If one leaks, cancel it here
      // so a new session can start.
      final nowCancel = nowEffective;
      await _dao.updateSession(
        ActivitySessionsCompanion(
          id: Value(existing.id),
          profileId: Value(profileId),
          activityId: Value(existing.activityId),
          mode: Value(existing.mode),
          startedAt: Value(existing.startedAt),
          endedAt: Value(nowCancel),
          completedAt: const Value(null),
          status: const Value('cancelled'),
          accumulatedSeconds: Value(existing.accumulatedSeconds),
          lastResumedAt: const Value(null),
          completedIntervals: Value(existing.completedIntervals),
          notes: Value(existing.notes),
          createdAt: Value(existing.createdAt),
          updatedAt: Value(nowCancel),
        ),
      );
    }
    final id = await _dao.insertSession(
      ActivitySessionsCompanion.insert(
        activityId: activityId,
        profileId: profileId,
        mode: mode,
        plannedDurationSeconds: Value(plannedDurationSeconds),
        restDurationSeconds: Value(restDurationSeconds),
        startedAt: nowEffective,
        status: 'running',
        lastResumedAt: Value(nowEffective),
        createdAt: nowEffective,
        updatedAt: nowEffective,
      ),
    );
    return (await getSession(id, profileId))!;
  }

  @override
  Future<ActivitySession> pauseSession(
    int sessionId,
    int profileId, {
    DateTime? now,
  }) async {
    final nowEffective = now ?? DateTime.now();
    final session = await getSession(sessionId, profileId);
    if (session == null || !session.isActive) {
      throw StateError('Session $sessionId is not active');
    }
    if (session.statusEnum == SessionStatus.paused) return session;

    final elapsed = session.elapsedSecondsAt(nowEffective);
    await _dao.updateSession(
      ActivitySessionsCompanion(
        id: Value(session.id!),
        profileId: Value(profileId),
        activityId: Value(session.activityId),
        mode: Value(session.mode),
        startedAt: Value(session.startedAt),
        endedAt: Value(session.endedAt),
        completedAt: Value(session.completedAt),
        status: const Value('paused'),
        accumulatedSeconds: Value(elapsed),
        lastResumedAt: const Value(null),
        completedIntervals: Value(session.completedIntervals),
        notes: Value(session.notes),
        createdAt: Value(session.createdAt),
        updatedAt: Value(nowEffective),
      ),
    );
    return (await getSession(sessionId, profileId))!;
  }

  @override
  Future<ActivitySession> resumeSession(
    int sessionId,
    int profileId, {
    DateTime? now,
  }) async {
    final nowEffective = now ?? DateTime.now();
    final session = await getSession(sessionId, profileId);
    if (session == null || !session.isActive) {
      throw StateError('Session $sessionId is not active');
    }
    if (session.statusEnum == SessionStatus.running) return session;

    await _dao.updateSession(
      ActivitySessionsCompanion(
        id: Value(session.id!),
        profileId: Value(profileId),
        activityId: Value(session.activityId),
        mode: Value(session.mode),
        startedAt: Value(session.startedAt),
        endedAt: Value(session.endedAt),
        completedAt: Value(session.completedAt),
        status: const Value('running'),
        accumulatedSeconds: Value(session.accumulatedSeconds),
        lastResumedAt: Value(nowEffective),
        completedIntervals: Value(session.completedIntervals),
        notes: Value(session.notes),
        createdAt: Value(session.createdAt),
        updatedAt: Value(nowEffective),
      ),
    );
    return (await getSession(sessionId, profileId))!;
  }

  @override
  Future<ActivitySession> completeSession(
    int sessionId,
    int profileId, {
    String? notes,
    bool countdownExpired = false,
    DateTime? now,
  }) async {
    final nowEffective = now ?? DateTime.now();
    final session = await getSession(sessionId, profileId);
    if (session == null || !session.isActive) {
      throw StateError('Session $sessionId is not active');
    }

    final elapsed = session.elapsedSecondsAt(nowEffective);
    final wasPaused = session.statusEnum == SessionStatus.paused;

    String effectiveMode;
    if (wasPaused) {
      // Stopped while paused — the activity was not really performed.
      effectiveMode = SessionMode.paused.value;
    } else if (countdownExpired &&
        session.modeEnum == SessionMode.timedSession &&
        session.accumulatedSeconds == 0) {
      // A timed countdown that ran to zero without any pause records as a
      // manually-finished session.
      effectiveMode = SessionMode.untimed.value;
    } else {
      effectiveMode = session.mode;
    }

    await _dao.updateSession(
      ActivitySessionsCompanion(
        id: Value(session.id!),
        profileId: Value(profileId),
        activityId: Value(session.activityId),
        mode: Value(effectiveMode),
        startedAt: Value(session.startedAt),
        endedAt: Value(nowEffective),
        completedAt: Value(nowEffective),
        status: const Value('completed'),
        accumulatedSeconds: Value(elapsed),
        lastResumedAt: const Value(null),
        completedIntervals: Value(session.completedIntervals),
        notes: Value(notes ?? session.notes),
        createdAt: Value(session.createdAt),
        updatedAt: Value(nowEffective),
      ),
    );
    return (await getSession(sessionId, profileId))!;
  }

  @override
  Future<ActivitySession> cancelSession(
    int sessionId,
    int profileId, {
    DateTime? now,
  }) async {
    final nowEffective = now ?? DateTime.now();
    final session = await getSession(sessionId, profileId);
    if (session == null || !session.isActive) {
      throw StateError('Session $sessionId is not active');
    }

    final elapsed = session.elapsedSecondsAt(nowEffective);
    await _dao.updateSession(
      ActivitySessionsCompanion(
        id: Value(session.id!),
        profileId: Value(profileId),
        activityId: Value(session.activityId),
        mode: Value(session.mode),
        startedAt: Value(session.startedAt),
        endedAt: Value(nowEffective),
        completedAt: const Value(null),
        status: const Value('cancelled'),
        accumulatedSeconds: Value(elapsed),
        lastResumedAt: const Value(null),
        completedIntervals: Value(session.completedIntervals),
        notes: Value(session.notes),
        createdAt: Value(session.createdAt),
        updatedAt: Value(nowEffective),
      ),
    );
    return (await getSession(sessionId, profileId))!;
  }

  @override
  Future<void> deleteSession(int sessionId, int profileId) async {
    await _dao.deleteSession(sessionId, profileId);
  }
}