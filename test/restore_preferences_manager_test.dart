import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:rehab_track/data/services/restore/restore_preferences_manager.dart';

import 'helpers/restore_test_utils.dart';

void main() {
  late Directory dir;
  late Directory docsDir;
  late FakeRestoreEnvironment env;
  late RestorePreferencesManager manager;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('prefsmanager_test_');
    docsDir = Directory(p.join(dir.path, 'documents'));
    env = FakeRestoreEnvironment(docsDir);
    manager = RestorePreferencesManager(env);
  });

  tearDown(() {
    dir.deleteSync(recursive: true);
  });

  test('normalize filters non-allowlist keys and coerces stable types', () async {
    final normalized = await manager.normalize({
      'app_language': 'ka',
      'medication_reminders_enabled': true,
      'default_snooze_duration': 10,
      'show_details_on_lock_screen': 1.5,
      'last_backup_at': '2026-08-05T00:00:00Z',
      'some_unknown_future_key': 'x',
    });
    expect(normalized, {
      'app_language': 'ka',
      'medication_reminders_enabled': 'true',
      'default_snooze_duration': '10',
      'show_details_on_lock_screen': '1.5',
    });
  });

  test('normalize rejects a known key with an unsupported value type', () async {
    expect(
      manager.normalize({
        'app_language': {'nested': 'map'},
      }),
      throwsA(isA<PreferencesRestoreException>()),
    );
  });

  test('apply persists the values via the environment', () async {
    final db = buildRestorableSqliteBytes(
      schema: 14,
      profiles: 0,
      settings: const {'app_language': 'ka'},
    );
    await writeLiveDatabase(docsDir, db);

    await manager.apply(const {'app_language': 'en'});
    expect(env.appliedPreferences, isNotEmpty);
    expect(await readAllowlistedSettings((await env.liveDb()).path), {
      'app_language': 'en',
    });
  });
}