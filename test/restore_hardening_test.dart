import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'package:rehab_track/data/services/restore/restore_recovery_metadata.dart';
import 'package:rehab_track/data/services/restore/restore_stale_workspace_cleaner.dart';
import 'package:rehab_track/data/services/restore/restore_state_verifier.dart';

import 'helpers/restore_test_utils.dart';

void main() {
  group('RestoreStateVerifier', () {
    const verifier = RestoreStateVerifier();

    test('accepts a valid restorable database at the expected schema', () async {
      final dir = Directory.systemTemp.createTempSync('verifier_');
      await writeLiveDatabase(
        dir,
        buildRestorableSqliteBytes(schema: 14, profiles: 1),
      );
      expect(
        await verifier.verify(
          databasePath: p.join(dir.path, 'rehabtrack.sqlite'),
          expectedSchemaVersion: 14,
        ),
        isTrue,
      );
      dir.deleteSync(recursive: true);
    });

    test('rejects a missing database file', () async {
      expect(
        await verifier.verify(
          databasePath: p.join('no/such/dir', 'db.sqlite'),
          expectedSchemaVersion: 14,
        ),
        isFalse,
      );
    });

    test('rejects a mismatched schema version', () async {
      final dir = Directory.systemTemp.createTempSync('verifier_');
      await writeLiveDatabase(
        dir,
        buildRestorableSqliteBytes(schema: 14, profiles: 1),
      );
      expect(
        await verifier.verify(
          databasePath: p.join(dir.path, 'rehabtrack.sqlite'),
          expectedSchemaVersion: 13,
        ),
        isFalse,
      );
      dir.deleteSync(recursive: true);
    });

    test('rejects a file that is not a SQLite database', () async {
      final dir = Directory.systemTemp.createTempSync('verifier_');
      final bogus = File(p.join(dir.path, 'not_db.sqlite'));
      await bogus.writeAsString('this is not sqlite at all');
      expect(
        await verifier.verify(
          databasePath: bogus.path,
          expectedSchemaVersion: 14,
        ),
        isFalse,
      );
      dir.deleteSync(recursive: true);
    });

    test('rejects a schema missing a core table', () async {
      final dir = Directory.systemTemp.createTempSync('verifier_');
      await writeLiveDatabase(
        dir,
        buildRestorableSqliteBytes(schema: 14, profiles: 1),
      );
      final out = p.join(dir.path, 'rehabtrack.sqlite');
      await stripTable(out, 'measurement_records');
      expect(
        await verifier.verify(
          databasePath: out,
          expectedSchemaVersion: 14,
        ),
        isFalse,
      );
      dir.deleteSync(recursive: true);
    });

    test('checks the managed-files root exists when required', () async {
      final dir = Directory.systemTemp.createTempSync('verifier_');
      await writeLiveDatabase(
        dir,
        buildRestorableSqliteBytes(schema: 14, profiles: 1),
      );
      final root = Directory(p.join(dir.path, 'profile_images'));
      await root.create(recursive: true);
      expect(await root.exists(), isTrue);
      expect(
        await verifier.verify(
          databasePath: p.join(dir.path, 'rehabtrack.sqlite'),
          expectedSchemaVersion: 14,
          managedFilesRoot: root.path,
        ),
        isTrue,
      );
      expect(
        await verifier.verify(
          databasePath: p.join(dir.path, 'rehabtrack.sqlite'),
          expectedSchemaVersion: 14,
          managedFilesRoot: p.join(dir.path, 'missing_root'),
        ),
        isFalse,
      );
      dir.deleteSync(recursive: true);
    });
  });

  group('RestoreStaleWorkspaceCleaner', () {
    const cleaner = RestoreStaleWorkspaceCleaner();
    late Directory tempBaseDir;
    late RestoreRecoveryStore recoveryStore;

    setUp(() {
      tempBaseDir = Directory.systemTemp.createTempSync('stale_');
      recoveryStore = RestoreRecoveryStore.inDirectory(
        Directory(p.join(tempBaseDir.path, 'recovery')),
      );
    });

    tearDown(() {
      tempBaseDir.deleteSync(recursive: true);
    });

    Future<void> makeWorkspace(String opId) async {
      await Directory(
        p.join(tempBaseDir.path, 'restore-workspace', opId, 'safety-snapshot'),
      ).create(recursive: true);
    }

    test('removes abandoned workspaces but keeps ones tied to active metadata',
        () async {
      await makeWorkspace('active_op');
      await makeWorkspace('abandoned_op');
      await recoveryStore.write(RestoreRecoveryMetadata(
        operationId: 'active_op',
        phase: 'replacingDatabase',
        workspacePath: p.join(
          tempBaseDir.path,
          'restore-workspace',
          'active_op',
        ),
        databaseSwapStarted: true,
      ));

      await cleaner.clean(tempBaseDir: tempBaseDir, recoveryStore: recoveryStore);

      expect(
        await Directory(
          p.join(tempBaseDir.path, 'restore-workspace', 'active_op'),
        ).exists(),
        isTrue,
      );
      expect(
        await Directory(
          p.join(tempBaseDir.path, 'restore-workspace', 'abandoned_op'),
        ).exists(),
        isFalse,
      );
    });

    test('cleans abandoned backup temps and stale pending-restore', () async {
      await Directory(
        p.join(tempBaseDir.path, 'rehabtrack_backup_abc'),
      ).create(recursive: true);
      await Directory(
        p.join(tempBaseDir.path, 'unrelated_cache'),
      ).create(recursive: true);
      final pending = File(
        p.join(tempBaseDir.path, 'pending-restore', 'selected.rtb'),
      );
      await pending.parent.create(recursive: true);
      await pending.writeAsBytes([1, 2, 3]);

      await cleaner.clean(tempBaseDir: tempBaseDir, recoveryStore: recoveryStore);

      expect(
        await Directory(
          p.join(tempBaseDir.path, 'rehabtrack_backup_abc'),
        ).exists(),
        isFalse,
      );
      expect(await pending.exists(), isFalse);
      expect(
        await Directory(
          p.join(tempBaseDir.path, 'unrelated_cache'),
        ).exists(),
        isTrue,
      );
    });
  });
}

Future<void> stripTable(String path, String table) async {
  final db = sqlite.sqlite3.open(path);
  try {
    db.execute('DROP TABLE "$table"');
  } finally {
    db.close();
  }
}