import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/data/services/backup/backup_archive_reader.dart';
import 'package:rehab_track/data/services/backup/backup_validator.dart';
import 'package:rehab_track/domain/backup/backup_compatibility.dart';
import 'package:rehab_track/domain/backup/backup_preview.dart';
import 'package:rehab_track/domain/backup/backup_validation_result.dart';

import 'helpers/backup_test_utils.dart';

const _currentSchema = 14;

void main() {
  Future<BackupValidationOutcome> validate(Uint8List zipBytes) async {
    final tmp = writeTempFile('backup.rtb', zipBytes);
    addTearDown(() => tmp.dir.deleteSync(recursive: true));
    final read = await BackupArchiveReader().read(tmp.file);
    expect(read.succeeded, isTrue,
        reason: 'reader should open the test archive');
    return const BackupValidator().validate(
      handle: read.handle!,
      tempDir: tmp.dir,
      currentDatabaseSchemaVersion: _currentSchema,
      currentAppVersion: '1.2.0',
    );
  }

  group('BackupValidator.valid', () {
    test('accepts a current-schema archive and builds a preview', () async {
      final outcome = await validate(buildValidBackupZip(schema: _currentSchema));

      expect(outcome.result, BackupValidationResult.valid);
      final preview = outcome.preview!;
      expect(preview.compatibility, BackupCompatibility.compatible);
      expect(preview.migrationRequired, isFalse);
      expect(preview.databaseSchemaVersion, _currentSchema);
      expect(preview.currentDatabaseSchemaVersion, _currentSchema);
      expect(preview.profileCount, 2);
      expect(preview.managedFileCount, 0);
      expect(preview.warnings, isEmpty);
      expect(preview.appVersion, '1.2.0');
    });

    test('accepts an older supported schema as migration-required', () async {
      final outcome =
          await validate(buildValidBackupZip(schema: _currentSchema - 1));

      expect(outcome.result, BackupValidationResult.valid);
      final preview = outcome.preview!;
      expect(preview.compatibility,
          BackupCompatibility.compatibleMigrationRequired);
      expect(preview.migrationRequired, isTrue);
      expect(preview.warnings, contains(BackupWarning.migrationRequired));
    });

    test('warns when the backup comes from a different app version', () async {
      final outcome = await validate(
        buildValidBackupZip(schema: _currentSchema, appVersion: '0.9.0'),
      );

      expect(outcome.result, BackupValidationResult.valid);
      expect(
        outcome.preview!.warnings,
        contains(BackupWarning.olderAppVersion),
      );
    });
  });

  group('BackupValidator.rejections', () {
    test('rejects a newer backup-format version', () async {
      final outcome = await validate(
        buildValidBackupZip(schema: _currentSchema, formatVersion: 2),
      );
      expect(outcome.result, BackupValidationResult.unsupportedBackupFormat);
    });

    test('rejects a newer database schema', () async {
      final outcome = await validate(
        buildValidBackupZip(schema: _currentSchema + 1),
      );
      expect(outcome.result, BackupValidationResult.newerDatabaseVersion);
    });

    test('rejects a non-positive database schema as invalid manifest',
        () async {
      final outcome = await validate(buildValidBackupZip(schema: 0));
      expect(outcome.result, BackupValidationResult.invalidManifest);
    });

    test('rejects a missing manifest', () async {
      final db = buildSqliteBytes(schema: _currentSchema);
      final outcome = await validate(buildZip({
        'database.sqlite': db,
      }));
      expect(outcome.result, BackupValidationResult.missingManifest);
    });

    test('rejects an unparseable manifest', () async {
      final outcome = await validate(buildZip({
        'manifest.json': _utf8('not json'),
        'database.sqlite': buildSqliteBytes(schema: _currentSchema),
        'preferences.json': _utf8('{}'),
      }));
      expect(outcome.result, BackupValidationResult.invalidManifest);
    });

    test('rejects a missing database entry', () async {
      final outcome = await validate(buildZip({
        'manifest.json': _manifestBytes(_currentSchema, checksums: {
          'database.sqlite': 'a' * 64,
        }),
        'preferences.json': _utf8('{}'),
      }));
      expect(outcome.result, BackupValidationResult.missingDatabase);
    });

    test('rejects a missing preferences entry', () async {
      final db = buildSqliteBytes(schema: _currentSchema);
      final manifest = buildManifestJson(
        schema: _currentSchema,
        checksums: {'database.sqlite': sha256.convert(db).toString()},
      );
      final outcome = await validate(buildZip({
        'manifest.json': _utf8(jsonEncode(manifest)),
        'database.sqlite': db,
      }));
      expect(outcome.result, BackupValidationResult.missingPreferences);
    });

    test('rejects a checksum mismatch', () async {
      final db = buildSqliteBytes(schema: _currentSchema);
      final manifest = buildManifestJson(
        schema: _currentSchema,
        checksums: {
          'database.sqlite': sha256.convert(db).toString(),
          'preferences.json': '0' * 64,
        },
      );
      final outcome = await validate(buildZip({
        'manifest.json': _utf8(jsonEncode(manifest)),
        'database.sqlite': db,
        'preferences.json': _utf8('{"app_language":"en"}'),
      }));
      expect(outcome.result, BackupValidationResult.checksumMismatch);
    });

    test('rejects an unsafe archive entry path', () async {
      final db = buildSqliteBytes(schema: _currentSchema);
      final prefs = _utf8('{"app_language":"en"}');
      final manifest = buildManifestJson(
        schema: _currentSchema,
        checksums: {
          'database.sqlite': sha256.convert(db).toString(),
          'preferences.json': sha256.convert(prefs).toString(),
        },
      );
      final outcome = await validate(buildZip({
        'manifest.json': _utf8(jsonEncode(manifest)),
        'database.sqlite': db,
        'preferences.json': prefs,
        '../evil.txt': _utf8('bad'),
      }));
      expect(outcome.result, BackupValidationResult.unsafeArchivePath);
    });

    test('rejects duplicate archive entries', () async {
      final db = buildSqliteBytes(schema: _currentSchema);
      final prefs = _utf8('{"app_language":"en"}');
      final manifest = buildManifestJson(
        schema: _currentSchema,
        checksums: {
          'database.sqlite': sha256.convert(db).toString(),
          'preferences.json': sha256.convert(prefs).toString(),
        },
      );
      final manifestBytes =
          _utf8(jsonEncode(manifest));
      final outcome = await validate(buildZipWithDuplicates([
        ('manifest.json', manifestBytes),
        ('manifest.json', manifestBytes),
        ('database.sqlite', db),
        ('preferences.json', prefs),
      ]));
      expect(outcome.result, BackupValidationResult.unsafeArchivePath);
    });

    test('rejects a file-count mismatch in the manifest', () async {
      final db = buildSqliteBytes(schema: _currentSchema);
      final prefs = _utf8('{"app_language":"en"}');
      final manifest = buildManifestJson(
        schema: _currentSchema,
        fileCount: 1,
        checksums: {
          'database.sqlite': sha256.convert(db).toString(),
          'preferences.json': sha256.convert(prefs).toString(),
        },
      );
      final outcome = await validate(buildZip({
        'manifest.json': _utf8(jsonEncode(manifest)),
        'database.sqlite': db,
        'preferences.json': prefs,
      }));
      expect(outcome.result, BackupValidationResult.invalidManifest);
    });

    test('rejects a checksum key that is not a known archive entry',
        () async {
      final db = buildSqliteBytes(schema: _currentSchema);
      final prefs = _utf8('{"app_language":"en"}');
      final manifest = buildManifestJson(
        schema: _currentSchema,
        checksums: {
          'database.sqlite': sha256.convert(db).toString(),
          'preferences.json': sha256.convert(prefs).toString(),
          'unexpected.txt': 'a' * 64,
        },
      );
      final outcome = await validate(buildZip({
        'manifest.json': _utf8(jsonEncode(manifest)),
        'database.sqlite': db,
        'preferences.json': prefs,
      }));
      expect(outcome.result, BackupValidationResult.invalidManifest);
    });

    test('rejects a missing required checksum', () async {
      final db = buildSqliteBytes(schema: _currentSchema);
      final prefs = _utf8('{"app_language":"en"}');
      final manifest = buildManifestJson(
        schema: _currentSchema,
        checksums: {
          'database.sqlite': sha256.convert(db).toString(),
        },
      );
      final outcome = await validate(buildZip({
        'manifest.json': _utf8(jsonEncode(manifest)),
        'database.sqlite': db,
        'preferences.json': prefs,
      }));
      expect(outcome.result, BackupValidationResult.checksumMismatch);
    });

    test('rejects an invalid SQLite database', () async {
      final fakeDb = Uint8List.fromList(
        utf8.encode('SQLite format 3\u0000') +
            List.filled(64, 0x01),
      );
      final prefs = _utf8('{"app_language":"en"}');
      final manifest = buildManifestJson(
        schema: _currentSchema,
        checksums: {
          'database.sqlite': sha256.convert(fakeDb).toString(),
          'preferences.json': sha256.convert(prefs).toString(),
        },
      );
      final outcome = await validate(buildZip({
        'manifest.json': _utf8(jsonEncode(manifest)),
        'database.sqlite': fakeDb,
        'preferences.json': prefs,
      }));
      expect(outcome.result, BackupValidationResult.invalidBackupDatabase);
    });

    test('rejects preferences with an invalid known-key type', () async {
      final db = buildSqliteBytes(schema: _currentSchema);
      final prefs = _utf8('{"app_language": 5}');
      final manifest = buildManifestJson(
        schema: _currentSchema,
        checksums: {
          'database.sqlite': sha256.convert(db).toString(),
          'preferences.json': sha256.convert(prefs).toString(),
        },
      );
      final outcome = await validate(buildZip({
        'manifest.json': _utf8(jsonEncode(manifest)),
        'database.sqlite': db,
        'preferences.json': prefs,
      }));
      expect(outcome.result, BackupValidationResult.invalidBackupPreferences);
    });
  });

  group('BackupValidator.preferences encoding', () {
    test('accepts the app own export shape with all-string values', () async {
      final outcome = await validate(buildValidBackupZip(
        schema: _currentSchema,
        preferences: {
          'app_language': 'en',
          'next_item_grace_period_minutes': '30',
          'default_snooze_duration': '10',
          'medication_reminders_enabled': 'true',
          'measurement_reminders_enabled': 'false',
          'reminder_sound_enabled': 'true',
          'reminder_vibration_enabled': 'false',
          'show_patient_name_in_notifications': 'true',
          'show_details_on_lock_screen': 'false',
          'alarm_sound_uri':
              'content://media/internal/audio/media/42',
          'alarm_sound_title': 'Morning Alarm',
        },
      ));
      expect(outcome.result, BackupValidationResult.valid);
    });

    test('accepts typed integer and boolean values', () async {
      final outcome = await validate(buildValidBackupZip(
        schema: _currentSchema,
        preferences: {
          'next_item_grace_period_minutes': 30,
          'default_snooze_duration': 10,
          'medication_reminders_enabled': true,
          'reminder_sound_enabled': false,
        },
      ));
      expect(outcome.result, BackupValidationResult.valid);
    });

    test('rejects a non-numeric string for an integer preference', () async {
      final outcome = await validate(buildValidBackupZip(
        schema: _currentSchema,
        preferences: {'next_item_grace_period_minutes': 'thirty'},
      ));
      expect(outcome.result, BackupValidationResult.invalidBackupPreferences);
    });

    test('rejects a non-boolean string for a boolean preference', () async {
      final outcome = await validate(buildValidBackupZip(
        schema: _currentSchema,
        preferences: {'medication_reminders_enabled': 'maybe'},
      ));
      expect(outcome.result, BackupValidationResult.invalidBackupPreferences);
    });

    test('accepts boolean strings case-insensitively', () async {
      final outcome = await validate(buildValidBackupZip(
        schema: _currentSchema,
        preferences: {'reminder_sound_enabled': 'TRUE'},
      ));
      expect(outcome.result, BackupValidationResult.valid);
    });
  });
}

Uint8List _utf8(String text) => Uint8List.fromList(utf8.encode(text));

Uint8List _manifestBytes(
  int schema, {
  required Map<String, String> checksums,
}) {
  return _utf8(jsonEncode(buildManifestJson(schema: schema, checksums: checksums)));
}