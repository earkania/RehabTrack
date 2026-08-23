import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/tables/profile_table.dart';

/// Rehabilitation / physical activity item that a patient tracks.
///
/// [category] holds a stable value (`exercise`, `rehabilitation`,
/// `physiotherapy`, `general_wellness` or `other`). Localized labels are
/// mapped at the UI layer and never persisted.
@TableIndex(name: 'activities_profile_idx', columns: {#profileId})
@TableIndex(name: 'activities_category_idx', columns: {#category})
@TableIndex(name: 'activities_archived_idx', columns: {#isArchived})
@TableIndex(name: 'activities_name_idx', columns: {#name})
class Activities extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get description => text().nullable()();
  IntColumn get recommendedTimeMinutes => integer().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// A recorded session run for an [Activities] item.
///
/// A session is created when the user starts it and lives until it is
/// completed or cancelled. At most one session with an active status
/// (`running` or `paused`) may exist per profile at any time.
///
/// [mode] holds a stable value (`timed_session`, `timed_interval`,
/// `untimed` or `paused`). The `paused` value is only ever stored on a
/// completed record: it marks a session that was stopped while paused (the
/// patient did not actually perform the activity).
///
/// [status] holds a stable value (`running`, `paused`, `completed` or
/// `cancelled`).
@TableIndex(name: 'activity_sessions_activity_idx', columns: {#activityId})
@TableIndex(name: 'activity_sessions_profile_idx', columns: {#profileId})
@TableIndex(name: 'activity_sessions_status_idx', columns: {#status})
@TableIndex(name: 'activity_sessions_started_idx', columns: {#startedAt})
class ActivitySessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get activityId =>
      integer().references(Activities, #id, onDelete: KeyAction.cascade)();
  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get mode => text()();
  IntColumn get plannedDurationSeconds => integer().nullable()();
  IntColumn get restDurationSeconds => integer().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get status => text()();
  IntColumn get accumulatedSeconds => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastResumedAt => dateTime().nullable()();
  IntColumn get completedIntervals => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}