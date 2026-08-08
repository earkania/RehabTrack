import 'dart:io';

import 'package:rehab_track/domain/restore/reminder_rebuild_report.dart';

/// The app-specific operations a restore needs, abstracted so the restore
/// engine can be unit-tested without Flutter or a live database.
///
/// Implementations must keep failures internal and propagate them as
/// [RestoreEnvironmentFailure] so the engine can map them to structured
/// [RestoreResult] categories. No personal data may be written to logs or
/// passed back to the caller by an implementation.
abstract class RestoreEnvironment {
  /// The application documents directory that hosts `rehabtrack.sqlite` and
  /// the managed file directories (profile images, care-contact images, lab
  /// analysis attachments) each live directly under it.
  Future<Directory> documentsDirectory();

  /// Produces a consistent snapshot of the live database into [destinationPath]
  /// (e.g. via SQLite `VACUUM INTO`). Used for the pre-restore safety snapshot.
  Future<void> snapshotLiveDatabase(File destinationPath);

  /// Returns the current allowlisted preference values as `{key: stringValue}`.
  Future<Map<String, String>> captureSupportedPreferences();

  /// Applies the given allowlisted preference values, replacing the current
  /// supported set with exactly these values (keys absent are removed).
  Future<void> applyPreferences(Map<String, String> values);

  /// Closes the live database and pauses database-backed services so the file
  /// can be replaced. After this call nothing may read or write the live DB.
  Future<void> pauseLiveDatabase();

  /// Reopens the database against the (replaced) live file.
  Future<void> reopenDatabase();

  /// Reinitializes database-backed services and providers against the reopened
  /// database.
  Future<void> reinitializeProviders();

  /// Whether the restored state can be read successfully (database queries and
  /// preferences). Implementations must not surface content to the caller.
  Future<bool> verifyRestoredState();

  /// Cancels currently scheduled RehabTrack notifications. Called after a
  /// successful restore; reminders are rebuilt in a later phase.
  Future<void> cancelScheduledNotifications();

  /// Rebuilds the future reminder schedule (medication, measurement and
  /// doctor-visit) from the restored data, using the app's normal scheduling
  /// logic and notification-ID scheme. Returns a non-sensitive tally.
  ///
  /// Implementations must not declare success for data-restore purposes when
  /// reminders cannot be rebuilt; they should report failure through a
  /// [ReminderRebuildReport] or by throwing [RestoreEnvironmentFailure].
  Future<ReminderRebuildReport> rebuildScheduledNotifications();

  /// Whether the currently scheduled RehabTrack notifications use distinct
  /// notification IDs (no duplicates). Implementations must not surface
  /// content; this returns only a boolean verdict.
  Future<bool> verifyScheduledNotificationsNoDuplicates();
}

/// A recoverable failure from a [RestoreEnvironment] operation.
class RestoreEnvironmentFailure implements Exception {
  /// Optional non-sensitive diagnostic reason.
  final String? reason;

  const RestoreEnvironmentFailure({this.reason});

  @override
  String toString() =>
      'RestoreEnvironmentFailure${reason == null ? '' : ': $reason'}';
}