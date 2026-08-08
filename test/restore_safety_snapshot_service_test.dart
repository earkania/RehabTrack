import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:rehab_track/data/services/restore/restore_safety_snapshot_service.dart';

import 'helpers/restore_test_utils.dart';

void main() {
  late Directory dir;
  late Directory docsDir;
  late FakeRestoreEnvironment env;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('snapshot_test_');
    docsDir = Directory(p.join(dir.path, 'documents'));
    env = FakeRestoreEnvironment(docsDir);
  });

  tearDown(() {
    dir.deleteSync(recursive: true);
  });

  test('snapshots the database, allowlisted preferences and managed files',
      () async {
    final db = buildRestorableSqliteBytes(
      schema: 15,
      profiles: 2,
      settings: const {'app_language': 'ka', 'last_backup_at': 'ignored'},
    );
    await writeLiveDatabase(docsDir, db);
    await writeManagedFile(docsDir, 'profile_images', 'a.jpg', [1, 2, 3]);

    final snapshotDir = Directory(p.join(dir.path, 'safety-snapshot'));
    await RestoreSafetySnapshotService(env).create(snapshotDir: snapshotDir);

    expect(File(p.join(snapshotDir.path, 'database.sqlite')).existsSync(), isTrue);
    final content = SafetySnapshotContent(snapshotDir);
    final prefs = await content.readPreferences();
    // Operational key `last_backup_at` is excluded by the allowlist filter.
    expect(prefs, {'app_language': 'ka'});
    expect(
      File(p.join(snapshotDir.path, 'files', 'profile_images', 'a.jpg'))
          .existsSync(),
      isTrue,
    );
  });

  test('throws SafetySnapshotException when the database cannot be snapshotted',
      () async {
    final db = buildRestorableSqliteBytes(schema: 15, profiles: 1);
    await writeLiveDatabase(docsDir, db);
    env.failSnapshot = true;

    expect(
      RestoreSafetySnapshotService(env).create(
        snapshotDir: Directory(p.join(dir.path, 'safety-snapshot')),
      ),
      throwsA(isA<SafetySnapshotException>()),
    );
  });
}