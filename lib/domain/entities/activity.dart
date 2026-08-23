import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart'
    hide Activity, ActivitySession;

/// Categories for an [Activity]. Stable values are persisted; localized
/// labels are mapped at the UI layer.
enum ActivityCategory {
  exercise('exercise'),
  rehabilitation('rehabilitation'),
  physiotherapy('physiotherapy'),
  generalWellness('general_wellness'),
  other('other');

  const ActivityCategory(this.value);

  final String value;

  static ActivityCategory fromValue(String value) {
    for (final category in ActivityCategory.values) {
      if (category.value == value) return category;
    }
    return ActivityCategory.other;
  }
}

/// Modes in which a session can run. Stable values are persisted.
///
/// [timedInterval] runs alternating work/rest countdown cycles.
enum SessionMode {
  timedSession('timed_session'),
  timedInterval('timed_interval'),
  untimed('untimed'),
  paused('paused');

  const SessionMode(this.value);

  final String value;

  static SessionMode fromValue(String value) {
    for (final mode in SessionMode.values) {
      if (mode.value == value) return mode;
    }
    return SessionMode.untimed;
  }
}

/// Lifecycle state of a session. Stable values are persisted.
enum SessionStatus {
  running('running'),
  paused('paused'),
  completed('completed'),
  cancelled('cancelled');

  const SessionStatus(this.value);

  final String value;

  bool get isActive => this == SessionStatus.running || this == SessionStatus.paused;

  static SessionStatus fromValue(String value) {
    for (final status in SessionStatus.values) {
      if (status.value == value) return status;
    }
    return SessionStatus.cancelled;
  }
}

/// Rehabilitation activity domain entity.
class Activity {
  final int? id;
  final int profileId;
  final String name;
  final String category;
  final String? description;
  final int? recommendedTimeMinutes;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Activity({
    this.id,
    required this.profileId,
    required this.name,
    required this.category,
    this.description,
    this.recommendedTimeMinutes,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  ActivityCategory get categoryEnum => ActivityCategory.fromValue(category);

  Activity copyWith({
    int? id,
    int? profileId,
    String? name,
    String? category,
    String? description,
    int? recommendedTimeMinutes,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Activity(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      recommendedTimeMinutes: recommendedTimeMinutes ?? this.recommendedTimeMinutes,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert from a database model.
  static Activity fromDb(dynamic dbModel) {
    return Activity(
      id: dbModel.id,
      profileId: dbModel.profileId,
      name: dbModel.name,
      category: dbModel.category,
      description: dbModel.description,
      recommendedTimeMinutes: dbModel.recommendedTimeMinutes,
      isArchived: dbModel.isArchived,
      createdAt: dbModel.createdAt,
      updatedAt: dbModel.updatedAt,
    );
  }

  /// Convert to a database companion for insertion.
  ActivitiesCompanion toCompanion({bool includeId = false}) {
    return ActivitiesCompanion(
      id: includeId && id != null ? Value(id!) : const Value.absent(),
      profileId: Value(profileId),
      name: Value(name),
      category: Value(category),
      description: Value(description),
      recommendedTimeMinutes: Value(recommendedTimeMinutes),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  /// Convert to a database companion for update.
  ActivitiesCompanion toUpdateCompanion() {
    return ActivitiesCompanion(
      id: Value(id!),
      profileId: Value(profileId),
      name: Value(name),
      category: Value(category),
      description: Value(description),
      recommendedTimeMinutes: Value(recommendedTimeMinutes),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(DateTime.now()),
    );
  }
}

/// A recorded run of an [Activity].
class ActivitySession {
  final int? id;
  final int activityId;
  final int profileId;
  final String mode;
  final int? plannedDurationSeconds;
  final int? restDurationSeconds;
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime? completedAt;
  final String status;
  final int accumulatedSeconds;
  final DateTime? lastResumedAt;
  final int completedIntervals;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ActivitySession({
    this.id,
    required this.activityId,
    required this.profileId,
    required this.mode,
    this.plannedDurationSeconds,
    this.restDurationSeconds,
    required this.startedAt,
    this.endedAt,
    this.completedAt,
    required this.status,
    required this.accumulatedSeconds,
    this.lastResumedAt,
    this.completedIntervals = 0,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  SessionMode get modeEnum => SessionMode.fromValue(mode);
  SessionStatus get statusEnum => SessionStatus.fromValue(status);

  bool get isActive => statusEnum.isActive;

  /// Current elapsed time in seconds for an active session.
  ///
  /// While running, the time since [lastResumedAt] is added to the accumulated
  /// seconds. Paused sessions return only the accumulated seconds.
  int elapsedSecondsAt(DateTime now) {
    final base = accumulatedSeconds;
    if (statusEnum == SessionStatus.running && lastResumedAt != null) {
      final delta = now.difference(lastResumedAt!).inSeconds;
      return base + (delta > 0 ? delta : 0);
    }
    return base;
  }

  /// Recommended duration normalized to seconds.
  int? get plannedDurationInSeconds => plannedDurationSeconds;

  ActivitySession copyWith({
    int? id,
    int? activityId,
    int? profileId,
    String? mode,
    int? plannedDurationSeconds,
    int? restDurationSeconds,
    bool clearPlannedDuration = false,
    bool clearRestDuration = false,
    DateTime? startedAt,
    DateTime? endedAt,
    bool clearEndedAt = false,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    String? status,
    int? accumulatedSeconds,
    DateTime? lastResumedAt,
    bool clearLastResumedAt = false,
    int? completedIntervals,
    String? notes,
    bool clearNotes = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ActivitySession(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      profileId: profileId ?? this.profileId,
      mode: mode ?? this.mode,
      plannedDurationSeconds: clearPlannedDuration
          ? null
          : plannedDurationSeconds ?? this.plannedDurationSeconds,
      restDurationSeconds: clearRestDuration
          ? null
          : restDurationSeconds ?? this.restDurationSeconds,
      startedAt: startedAt ?? this.startedAt,
      endedAt: clearEndedAt ? null : endedAt ?? this.endedAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      status: status ?? this.status,
      accumulatedSeconds: accumulatedSeconds ?? this.accumulatedSeconds,
      lastResumedAt: clearLastResumedAt ? null : lastResumedAt ?? this.lastResumedAt,
      completedIntervals: completedIntervals ?? this.completedIntervals,
      notes: clearNotes ? null : notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert from a database model.
  static ActivitySession fromDb(dynamic dbModel) {
    return ActivitySession(
      id: dbModel.id,
      activityId: dbModel.activityId,
      profileId: dbModel.profileId,
      mode: dbModel.mode,
      plannedDurationSeconds: dbModel.plannedDurationSeconds,
      restDurationSeconds: dbModel.restDurationSeconds,
      startedAt: dbModel.startedAt,
      endedAt: dbModel.endedAt,
      completedAt: dbModel.completedAt,
      status: dbModel.status,
      accumulatedSeconds: dbModel.accumulatedSeconds,
      lastResumedAt: dbModel.lastResumedAt,
      completedIntervals: dbModel.completedIntervals,
      notes: dbModel.notes,
      createdAt: dbModel.createdAt,
      updatedAt: dbModel.updatedAt,
    );
  }

  /// Convert to a database companion for insertion.
  ActivitySessionsCompanion toCompanion({bool includeId = false}) {
    return ActivitySessionsCompanion(
      id: includeId && id != null ? Value(id!) : const Value.absent(),
      activityId: Value(activityId),
      profileId: Value(profileId),
      mode: Value(mode),
      plannedDurationSeconds: Value(plannedDurationSeconds),
      restDurationSeconds: Value(restDurationSeconds),
      startedAt: Value(startedAt),
      endedAt: Value(endedAt),
      completedAt: Value(completedAt),
      status: Value(status),
      accumulatedSeconds: Value(accumulatedSeconds),
      lastResumedAt: Value(lastResumedAt),
      completedIntervals: Value(completedIntervals),
      notes: Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  /// Convert to a database companion for update.
  ActivitySessionsCompanion toUpdateCompanion() {
    return ActivitySessionsCompanion(
      id: Value(id!),
      activityId: Value(activityId),
      profileId: Value(profileId),
      mode: Value(mode),
      plannedDurationSeconds: Value(plannedDurationSeconds),
      restDurationSeconds: Value(restDurationSeconds),
      startedAt: Value(startedAt),
      endedAt: Value(endedAt),
      completedAt: Value(completedAt),
      status: Value(status),
      accumulatedSeconds: Value(accumulatedSeconds),
      lastResumedAt: Value(lastResumedAt),
      completedIntervals: Value(completedIntervals),
      notes: Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(DateTime.now()),
    );
  }
}