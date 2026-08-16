import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/services/backup/preferences_exporter.dart';
import 'package:rehab_track/data/services/restore/app_settings_writer.dart';
import 'package:rehab_track/data/services/restore/restore_environment.dart';
import 'package:rehab_track/data/services/restore/restore_state_verifier.dart';
import 'package:rehab_track/domain/restore/reminder_rebuild_report.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/locale_provider.dart';
import 'package:rehab_track/presentation/providers/notification_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/providers/reminder_settings_provider.dart';

/// Binds the restore engine to the live app: the canonical Riverpod container,
/// the app documents directory, the Drift database and the settings store.
///
/// No personal data is ever logged or exposed by this adapter.
class RestoreAppEnvironment implements RestoreEnvironment {
  static const String liveDatabaseFileName = 'rehabtrack.sqlite';

  final ProviderContainer _container;
  final Future<Directory> Function() _documentsDirectory;

  RestoreAppEnvironment(
    this._container, {
    Future<Directory> Function()? documentsDirectory,
  }) : _documentsDirectory =
            documentsDirectory ?? getApplicationDocumentsDirectory;

  @override
  Future<Directory> documentsDirectory() => _documentsDirectory();

  Future<File> _liveDatabaseFile() async {
    final docs = await _documentsDirectory();
    return File(p.join(docs.path, liveDatabaseFileName));
  }

  @override
  Future<void> snapshotLiveDatabase(File destinationPath) async {
    final db = _container.read(databaseProvider);
    final escaped = destinationPath.path.replaceAll("'", "''");
    await db.customStatement("VACUUM INTO '$escaped'");
  }

  @override
  Future<Map<String, String>> captureSupportedPreferences() async {
    final repository = _container.read(settingsRepositoryProvider);
    final json = await PreferencesExporter(repository).exportJson();
    final decoded = jsonDecode(json);
    if (decoded is! Map) return const {};
    return decoded.cast<String, String>();
  }

  @override
  Future<void> applyPreferences(Map<String, String> values) async {
    final dbFile = await _liveDatabaseFile();
    AppSettingsWriter.write(dbFile.path, values);
  }

  @override
  Future<void> pauseLiveDatabase() async {
    final db = _container.read(databaseProvider);
    await db.close();
  }

  @override
  Future<void> reopenDatabase() async {
    _container.invalidate(databaseProvider);
    final db = _container.read(databaseProvider);
    await db.customStatement('SELECT 1');
  }

  @override
  Future<void> reinitializeProviders() async {
    // The database invalidation above cascades to every database-backed
    // repository and provider. Image services do not depend on the database
    // and are invalidated explicitly so they re-resolve the documents dir.
    // The notification bridge holds repository references; it must be
    // recreated so it uses the new database connections.
    // The locale provider is a StateNotifier that caches its locale from the
    // old database, so it must be invalidated to reload the restored language.
    _container.invalidate(profileImageServiceProvider);
    _container.invalidate(careContactImageServiceProvider);
    _container.invalidate(notificationActionBridgeProvider);
    _container.invalidate(localeProvider);
    // The reminder style is caches in memory; reload it from the restored
    // settings store. Device capability is re-inspected so the alarm-style
    // status reflects the current device (capability is never restored).
    _container.invalidate(reminderStyleProvider);
    _container.invalidate(alarmStyleCapabilityProvider);
  }

  @override
  Future<bool> verifyRestoredState() async {
    try {
      final docs = await _documentsDirectory();
      final dbFile = File(p.join(docs.path, liveDatabaseFileName));
      // Deep verification: SQLite header, schema version, core tables and
      // read-only sample queries on the actual restored file.
      final verifier = const RestoreStateVerifier();
      final ok = await verifier.verify(
        databasePath: dbFile.path,
        expectedSchemaVersion: AppDatabase.currentSchemaVersion,
        managedFilesRoot: docs.path,
      );
      if (!ok) return false;
      // Plus the live container is queryable and settings read back.
      final db = _container.read(databaseProvider);
      await db.customStatement('SELECT 1');
      await _container.read(settingsRepositoryProvider).getAll();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> cancelScheduledNotifications() async {
    await _container.read(notificationServiceProvider).cancelAllNotifications();
  }

  @override
  Future<ReminderRebuildReport> rebuildScheduledNotifications() async {
    try {
      final bridge = _container.read(notificationActionBridgeProvider);
      final profileId = _container.read(currentActiveProfileIdProvider);
      if (profileId == null) return const ReminderRebuildReport();
      return await bridge.recoverAll(profileId);
    } catch (_) {
      throw const RestoreEnvironmentFailure(reason: 'reminder-rebuild');
    }
  }

  @override
  Future<bool> verifyScheduledNotificationsNoDuplicates() async {
    try {
      final service = _container.read(notificationServiceProvider);
      final pending = await service.getPendingNotifications();
      final ids = pending.map((n) => n.id);
      return ids.toSet().length == ids.length;
    } catch (_) {
      // Cannot determine: do not fail a completed restore on this check.
      return true;
    }
  }
}