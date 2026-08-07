import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'package:rehab_track/data/services/restore/app_settings_writer.dart';

import 'helpers/restore_test_utils.dart';

Future<File> _dbWith(
  Directory dir,
  Map<String, String> settings,
) async {
  final bytes = buildRestorableSqliteBytes(
    schema: 15,
    profiles: 0,
    settings: settings,
    withCareContacts: false,
  );
  final file = File(p.join(dir.path, 'settings.sqlite'));
  await file.writeAsBytes(bytes);
  return file;
}

Map<String, String> _readAll(String path) {
  final db = sqlite.sqlite3.open(path, mode: sqlite.OpenMode.readOnly);
  try {
    return {
      for (final row in db.select('SELECT key, value FROM app_settings').rows)
        row[0] as String: row[1] as String,
    };
  } finally {
    db.close();
  }
}

void main() {
  late Directory dir;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('writer_test_');
  });

  tearDown(() {
    dir.deleteSync(recursive: true);
  });

  test('upserts allowlisted values and removes absent allowlisted keys', () async {
    final file = await _dbWith(dir, {
      'app_language': 'ka',
    });
    AppSettingsWriter.write(file.path, {'app_language': 'en'});
    final all = _readAll(file.path);
    expect(all['app_language'], 'en');
    // Allowlisted key absent from the input must be deleted.
    expect(all.containsKey('medication_reminders_enabled'), isFalse);
  });

  test('preserves non-allowlist operational keys', () async {
    final file = await _dbWith(dir, {
      'app_language': 'ka',
      'last_backup_at': '2026-08-01T00:00:00Z',
    });
    AppSettingsWriter.write(file.path, {'app_language': 'en'});
    final all = _readAll(file.path);
    expect(all['app_language'], 'en');
    expect(all['last_backup_at'], '2026-08-01T00:00:00Z');
  });

  test('replaces existing allowlisted values on conflict', () async {
    final file = await _dbWith(dir, {'default_snooze_duration': '10'});
    AppSettingsWriter.write(file.path, {'default_snooze_duration': '20'});
    final all = _readAll(file.path);
    expect(all['default_snooze_duration'], '20');
  });
}