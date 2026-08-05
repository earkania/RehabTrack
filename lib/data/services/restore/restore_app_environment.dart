import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:rehab_track/data/services/backup/preferences_exporter.dart';
import 'package:rehab_track/data/services/restore/app_settings_writer.dart';
import 'package:rehab_track/data/services/restore/restore_environment.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/notification_provider.dart';

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
    _container.invalidate(profileImageServiceProvider);
    _container.invalidate(careContactImageServiceProvider);
  }

  @override
  Future<bool> verifyRestoredState() async {
    try {
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
}