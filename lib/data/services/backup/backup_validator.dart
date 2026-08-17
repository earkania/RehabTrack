import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'package:rehab_track/data/services/backup/backup_archive_reader.dart';
import 'package:rehab_track/data/services/backup/backup_archive_writer.dart';
import 'package:rehab_track/data/services/backup/backup_limits.dart';
import 'package:rehab_track/domain/backup/backup_compatibility.dart';
import 'package:rehab_track/domain/backup/backup_manifest.dart';
import 'package:rehab_track/domain/backup/backup_preview.dart';
import 'package:rehab_track/domain/backup/backup_validation_result.dart';
import 'package:rehab_track/domain/backup/backup_version_policy.dart';
import 'package:rehab_track/domain/backup/restore_phase.dart';

/// Result of validating a backup archive.
class BackupValidationOutcome {
  final BackupValidationResult result;

  /// Populated only when [result] is [BackupValidationResult.valid].
  final BackupPreview? preview;

  final List<BackupWarning> warnings;

  const BackupValidationOutcome({
    required this.result,
    this.preview,
    this.warnings = const [],
  });
}

/// Validates a selected `.rtb` backup archive before any restore happens.
///
/// This class performs **read-only** validation only:
///
/// - archive structure, entry-path safety and duplicate detection
/// - manifest structure and field sanity
/// - backup-format and database-schema compatibility
/// - SHA-256 checksum verification for the database, preferences and every
///   managed file
/// - a read-only SQLite check of `database.sqlite` (header, schema version,
///   core tables and profile count — no migration, no table content exposed)
/// - validation of `preferences.json`
///
/// It never opens or modifies the live database and never applies any backup
/// content.
class BackupValidator {
  const BackupValidator();

  /// Oldest database schema this app can restore. The Drift migration strategy
  /// covers every `from >= 1`; schemas older than this are rejected. Read from
  /// [BackupVersionPolicy] so the value is never duplicated.
  static const int minSupportedDatabaseSchemaVersion =
      BackupVersionPolicy.minSupportedDatabaseSchemaVersion;

  /// Core tables that must exist in every schema version 1..current.
  static const Set<String> coreTables = {
    'profiles',
    'medications',
    'measurement_types',
    'app_settings',
  };

  Future<BackupValidationOutcome> validate({
    required BackupArchiveHandle handle,
    required Directory tempDir,
    required int currentDatabaseSchemaVersion,
    required String currentAppVersion,
    void Function(RestorePhase phase)? onPhase,
  }) async {
    onPhase?.call(RestorePhase.validatingManifest);
    final info = handle.info;

    // Duplicate entries could create ambiguity or overwrite behavior.
    if (info.duplicateEntryNames.isNotEmpty) {
      return const BackupValidationOutcome(
        result: BackupValidationResult.unsafeArchivePath,
      );
    }

    // Entry-path safety: reject traversal, absolute paths and unexpected
    // root entries before reading anything from the archive.
    for (final entry in info.entries) {
      try {
        BackupArchivePath.validate(entry.name);
      } catch (_) {
        return const BackupValidationOutcome(
          result: BackupValidationResult.unsafeArchivePath,
        );
      }
    }

    if (info.entryCount > BackupLimits.maxEntryCount ||
        info.totalUncompressedSize > BackupLimits.maxTotalUncompressedBytes) {
      return const BackupValidationOutcome(
        result: BackupValidationResult.backupTooLarge,
      );
    }

    // --- Manifest ---------------------------------------------------------
    final manifestBytes = handle.content(BackupManifest.manifestFileName);
    if (manifestBytes == null) {
      return const BackupValidationOutcome(
        result: BackupValidationResult.missingManifest,
      );
    }
    if (manifestBytes.length > BackupLimits.maxManifestBytes) {
      return const BackupValidationOutcome(
        result: BackupValidationResult.backupTooLarge,
      );
    }

    BackupManifest manifest;
    try {
      final decoded = jsonDecode(utf8.decode(manifestBytes));
      if (decoded is! Map) {
        return const BackupValidationOutcome(
          result: BackupValidationResult.invalidManifest,
        );
      }
      manifest = BackupManifest.fromJson(decoded.cast<String, Object?>());
    } catch (_) {
      return const BackupValidationOutcome(
        result: BackupValidationResult.invalidManifest,
      );
    }

    // Backup-format compatibility.
    if (manifest.backupFormatVersion < 1) {
      return const BackupValidationOutcome(
        result: BackupValidationResult.invalidManifest,
      );
    }
    if (manifest.backupFormatVersion > BackupManifest.currentFormatVersion) {
      return const BackupValidationOutcome(
        result: BackupValidationResult.unsupportedBackupFormat,
      );
    }

    final manifestProblem = _manifestProblem(manifest);
    if (manifestProblem != null) {
      return BackupValidationOutcome(result: manifestProblem);
    }

    // Required entries.
    if (!info.hasDatabase) {
      return const BackupValidationOutcome(
        result: BackupValidationResult.missingDatabase,
      );
    }
    if (!info.hasPreferences) {
      return const BackupValidationOutcome(
        result: BackupValidationResult.missingPreferences,
      );
    }

    // Managed files present in the archive (files under files/).
    final managedEntries = info.entries
        .where((e) =>
            e.name.startsWith(BackupManifest.filesDirectory) && e.isFile)
        .toList();
    if (managedEntries.length != manifest.fileCount) {
      return const BackupValidationOutcome(
        result: BackupValidationResult.invalidManifest,
      );
    }
    final managedNames = managedEntries.map((e) => e.name).toSet();

    // Every checksum-listed file must exist and be a required file.
    for (final name in manifest.checksums.keys) {
      if (name == BackupManifest.manifestFileName) continue;
      final entry = info.entryByName(name);
      if (!requiredFilesOf(manifest, managedNames).contains(name) ||
          entry == null ||
          !entry.isFile) {
        return const BackupValidationOutcome(
          result: BackupValidationResult.checksumMismatch,
        );
      }
    }
    // Every required file must have a checksum.
    for (final name in requiredFilesOf(manifest, managedNames)) {
      if (!manifest.checksums.containsKey(name)) {
        return const BackupValidationOutcome(
          result: BackupValidationResult.checksumMismatch,
        );
      }
    }

    // --- Checksum verification -------------------------------------------
    onPhase?.call(RestorePhase.verifyingChecksums);
    for (final name in manifest.checksums.keys) {
      final content = handle.content(name);
      if (content == null) {
        return const BackupValidationOutcome(
          result: BackupValidationResult.checksumMismatch,
        );
      }
      final digest = sha256.convert(content).toString();
      if (digest != manifest.checksums[name]) {
        return const BackupValidationOutcome(
          result: BackupValidationResult.checksumMismatch,
        );
      }
    }

    // --- Compatibility ----------------------------------------------------
    onPhase?.call(RestorePhase.checkingCompatibility);
    final schema = manifest.databaseSchemaVersion;
    if (schema > currentDatabaseSchemaVersion) {
      return const BackupValidationOutcome(
        result: BackupValidationResult.newerDatabaseVersion,
      );
    }
    if (schema < minSupportedDatabaseSchemaVersion) {
      return const BackupValidationOutcome(
        result: BackupValidationResult.unsupportedOldDatabaseVersion,
      );
    }

    // --- Database validation (read-only) ----------------------------------
    final dbBytes = handle.content(BackupManifest.databaseFileName);
    if (dbBytes == null) {
      return const BackupValidationOutcome(
        result: BackupValidationResult.missingDatabase,
      );
    }
    final int? profileCount =
        await _validateDatabase(dbBytes, expectedSchemaVersion: schema,
            tempDir: tempDir);
    if (profileCount == _invalidDatabaseMarker) {
      return const BackupValidationOutcome(
        result: BackupValidationResult.invalidBackupDatabase,
      );
    }

    // --- Preferences validation -------------------------------------------
    final prefsBytes = handle.content(BackupManifest.preferencesFileName);
    if (prefsBytes == null) {
      return const BackupValidationOutcome(
        result: BackupValidationResult.missingPreferences,
      );
    }
    if (prefsBytes.length > BackupLimits.maxPreferencesBytes) {
      return const BackupValidationOutcome(
        result: BackupValidationResult.backupTooLarge,
      );
    }
    if (!_validatePreferencesJson(prefsBytes)) {
      return const BackupValidationOutcome(
        result: BackupValidationResult.invalidBackupPreferences,
      );
    }

    // --- Preview ----------------------------------------------------------
    final migrationRequired = schema != currentDatabaseSchemaVersion;
    final compatibility = migrationRequired
        ? BackupCompatibility.compatibleMigrationRequired
        : BackupCompatibility.compatible;

    final warnings = <BackupWarning>[
      if (manifest.appVersion != currentAppVersion)
        BackupWarning.olderAppVersion,
      if (migrationRequired) BackupWarning.migrationRequired,
    ];

    return BackupValidationOutcome(
      result: BackupValidationResult.valid,
      warnings: warnings,
      preview: BackupPreview(
        backupCreatedAt: manifest.createdAt,
        appVersion: manifest.appVersion,
        backupFormatVersion: manifest.backupFormatVersion,
        databaseSchemaVersion: schema,
        currentDatabaseSchemaVersion: currentDatabaseSchemaVersion,
        compatibility: compatibility,
        migrationRequired: migrationRequired,
        profileCount: profileCount,
        managedFileCount: manifest.fileCount,
        backupFileSize: info.archiveSizeBytes,
        warnings: warnings,
      ),
    );
  }

  /// The set of entries the manifest must carry checksums for.
  static Set<String> requiredFilesOf(
    BackupManifest manifest,
    Set<String> managedNames,
  ) {
    return {
      BackupManifest.databaseFileName,
      BackupManifest.preferencesFileName,
      ...managedNames,
    };
  }

  /// Sentinel distinguishing "invalid database" from "count unavailable".
  static const int _invalidDatabaseMarker = -1;

  /// Returns the profile count, `null` when it could not be read safely, and
  /// [_invalidDatabaseMarker] when the database is invalid.
  Future<int?> _validateDatabase(
    Uint8List dbBytes, {
    required int expectedSchemaVersion,
    required Directory tempDir,
  }) async {
    // SQLite header magic: "SQLite format 3\0" (16 bytes). Checked before
    // opening so a non-database file is rejected cleanly.
    if (dbBytes.length < 16 ||
        utf8.decode(dbBytes.sublist(0, 16)) != 'SQLite format 3\u0000') {
      return _invalidDatabaseMarker;
    }

    final dbPath = p.join(tempDir.path, 'database_preview.sqlite');
    final file = File(dbPath);
    try {
      await file.writeAsBytes(dbBytes, flush: true);
    } catch (_) {
      return _invalidDatabaseMarker;
    }

    sqlite.Database? db;
    try {
      db = sqlite.sqlite3.open(dbPath, mode: sqlite.OpenMode.readOnly);
      // Cross-check the real schema version against the manifest declaration.
      if (db.userVersion != expectedSchemaVersion) {
        return _invalidDatabaseMarker;
      }
      final tableRows = db
          .select("SELECT name FROM sqlite_master WHERE type = 'table'")
          .rows;
      final tables = tableRows
          .where((r) => r.isNotEmpty && r.first is String)
          .map((r) => r.first as String)
          .toSet();
      for (final core in coreTables) {
        if (!tables.contains(core)) return _invalidDatabaseMarker;
      }

      int? count;
      try {
        final countRows = db.select('SELECT COUNT(*) FROM profiles').rows;
        if (countRows.isNotEmpty) {
          final raw = countRows.first.first;
          if (raw is int) {
            count = raw;
          }
        }
      } catch (_) {
        // Profile count is best-effort: omit rather than fail validation.
        count = null;
      }
      return count;
    } catch (_) {
      return _invalidDatabaseMarker;
    } finally {
      db?.close();
      try {
        await file.delete();
      } catch (_) {
        // Best-effort cleanup.
      }
    }
  }

  /// Structural problems in a parsed manifest, or null when well-formed.
  BackupValidationResult? _manifestProblem(BackupManifest manifest) {
    if (manifest.backupFormatVersion < 1) {
      return BackupValidationResult.invalidManifest;
    }
    if (manifest.appVersion.isEmpty) {
      return BackupValidationResult.invalidManifest;
    }
    if (manifest.databaseSchemaVersion <= 0) {
      return BackupValidationResult.invalidManifest;
    }
    if (manifest.createdAt.year <= 1970) {
      return BackupValidationResult.invalidManifest;
    }
    if (manifest.platform.isEmpty) {
      return BackupValidationResult.invalidManifest;
    }
    if (manifest.fileCount < 0) {
      return BackupValidationResult.invalidManifest;
    }
    if (manifest.totalUncompressedSize < 0) {
      return BackupValidationResult.invalidManifest;
    }

    final seen = <String>{};
    for (final key in manifest.checksums.keys) {
      if (key == BackupManifest.manifestFileName) {
        return BackupValidationResult.invalidManifest;
      }
      final normalized = p.posix.normalize(key);
      if (!seen.add(normalized)) {
        // Duplicate/conflicting checksum entries.
        return BackupValidationResult.invalidManifest;
      }
      if (!_isSafeChecksumKey(key) || !_isSha256Hex(manifest.checksums[key]!)) {
        return BackupValidationResult.invalidManifest;
      }
    }
    return null;
  }

  static bool _isSafeChecksumKey(String key) {
    if (key == BackupManifest.databaseFileName ||
        key == BackupManifest.preferencesFileName) {
      return true;
    }
    if (!key.startsWith(BackupManifest.filesDirectory)) return false;
    try {
      BackupArchivePath.validate(key);
      return true;
    } catch (_) {
      return false;
    }
  }

  static bool _isSha256Hex(String value) {
    if (value.length != 64) return false;
    final hex = RegExp(r'^[0-9a-fA-F]{64}$');
    return hex.hasMatch(value);
  }

  /// Validates the JSON document of user preferences.
  ///
  /// Unknown/undocumented future keys are tolerated (a documented policy: do
  /// not fail merely because a newer version added an optional key). Known
  /// keys must have stable value types.
  ///
  /// Both typed values and string-encoded values are accepted: the app persists
  /// every setting as a string (`'10'`, `'true'`) so archives the app itself
  /// creates carry all-string values, while other producers may write typed
  /// values. A string that cannot be parsed as the required type is rejected.
  bool _validatePreferencesJson(Uint8List bytes) {
    Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(bytes));
    } catch (_) {
      return false;
    }
    if (decoded is! Map) return false;
    final map = decoded.cast<String, Object?>();
    for (final MapEntry(key: key, value: value) in map.entries) {
      if (!_knownPreferenceKeys.contains(key)) continue;
      final bool valid;
      switch (key) {
        case _languageKey:
        case _alarmSoundUriKey:
        case _alarmSoundTitleKey:
          valid = value is String;
          break;
        case _snoozeKey:
        case _gracePeriodKey:
          valid = value is int ||
              (value is String && int.tryParse(value.trim()) != null);
          break;
        default:
          valid = value is bool ||
              (value is String && _toBool(value) != null);
      }
      if (!valid) return false;
    }
    return true;
  }

  /// Parses a stored boolean string (`'true'`/`'false'`, case-insensitive) or
  /// returns null when [value] is not a boolean string.
  static bool? _toBool(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
    return null;
  }
}

const String _languageKey = 'app_language';
const String _gracePeriodKey = 'next_item_grace_period_minutes';
const String _snoozeKey = 'default_snooze_duration';
const String _alarmSoundUriKey = 'alarm_sound_uri';
const String _alarmSoundTitleKey = 'alarm_sound_title';
const Set<String> _knownPreferenceKeys = {
  'app_language',
  'next_item_grace_period_minutes',
  'default_snooze_duration',
  'medication_reminders_enabled',
  'measurement_reminders_enabled',
  'reminder_sound_enabled',
  'reminder_vibration_enabled',
  'show_patient_name_in_notifications',
  'show_details_on_lock_screen',
  'alarm_sound_uri',
  'alarm_sound_title',
};