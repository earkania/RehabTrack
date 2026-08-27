import 'package:rehab_track/domain/entities/activity.dart';

/// Repository interface for the Activities module. All queries are scoped to
/// a Patient Profile.
abstract class ActivityRepository {
  // ---- Activities ----------------------------------------------------------

  /// Watch active (non-archived) activities for a profile (A-Z by name).
  Stream<List<Activity>> watchActiveActivities(int profileId);

  /// Watch archived activities for a profile (A-Z by name).
  Stream<List<Activity>> watchArchivedActivities(int profileId);

  /// Watch all activities (active and archived) for a profile (A-Z by name).
  /// Used by history screens to resolve activity names for sessions.
  Stream<List<Activity>> watchAllActivities(int profileId);

  /// Get an activity by ID and profile ID.
  Future<Activity?> getActivity(int id, int profileId);

  /// Create a new activity.
  Future<Activity> createActivity(Activity activity);

  /// Update an existing activity.
  Future<Activity> updateActivity(Activity activity);

  /// Archive an activity. Its session history stays accessible.
  Future<void> archiveActivity(int id, int profileId);

  /// Restore an archived activity.
  Future<void> restoreActivity(int id, int profileId);

  /// Permanently delete an activity.
  ///
  /// Throws [StateError] when the activity has recorded sessions; those must
  /// be archived/kept, not deleted.
  Future<void> deleteActivity(int id, int profileId);

  /// Number of recorded sessions for an activity.
  Future<int> countSessionsForActivity(int activityId);

  /// Search activities by name or description, optionally filtered by
  /// category.
  Stream<List<Activity>> searchActivities(
    int profileId, {
    bool includeArchived = false,
    String? query,
    String? category,
  });

  // ---- Sessions ------------------------------------------------------------

  /// Watch the active session (running or paused) for a profile, or null.
  Stream<ActivitySession?> watchActiveSession(int profileId);

  /// Get the active session (running or paused) for a profile, or null.
  Future<ActivitySession?> getActiveSession(int profileId);

  /// Get a session by ID and profile ID.
  Future<ActivitySession?> getSession(int id, int profileId);

  /// Watch the completed/cancelled session history for a profile, newest
  /// first.
  Stream<List<ActivitySession>> watchSessionHistory(int profileId);

  /// One-shot fetch of finished (completed/cancelled) sessions started within
  /// the half-open range [startInclusive, endExclusive), newest first.
  /// Running or paused sessions are never included.
  Future<List<ActivitySession>> getSessionsBetween(
    int profileId,
    DateTime startInclusive,
    DateTime endExclusive,
  );

  /// Start a new session for an activity.
  ///
  /// [plannedDurationSeconds] and [restDurationSeconds] carry the timer
  /// configuration for timed modes. An already-active session for the same
  /// profile must be finished before a new one can start.
  Future<ActivitySession> startSession(
    int activityId,
    int profileId, {
    required String mode,
    int? plannedDurationSeconds,
    int? restDurationSeconds,
    DateTime? now,
  });

  /// Pause an active session.
  Future<ActivitySession> pauseSession(int sessionId, int profileId, {DateTime? now});

  /// Resume a paused session.
  Future<ActivitySession> resumeSession(int sessionId, int profileId, {DateTime? now});

  /// Complete a session and record it.
  ///
  /// A session currently paused is stored with [SessionMode.paused]. A timed
  /// countdown that expired without being paused or resumed is stored with
  /// [SessionMode.untimed]. All other completions keep their mode.
  ///
  /// [notes] holds the completion label/text recorded by the patient.
  Future<ActivitySession> completeSession(
    int sessionId,
    int profileId, {
    String? notes,
    bool countdownExpired = false,
    DateTime? now,
  });

  /// Cancel an active session without recording a completion.
  Future<ActivitySession> cancelSession(int sessionId, int profileId, {DateTime? now});

  /// Permanently delete a session record.
  Future<void> deleteSession(int sessionId, int profileId);
}