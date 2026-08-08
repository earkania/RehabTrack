import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/services/restore/restore_sqlite_migrator.dart';

void main() {
  late Directory dir;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('migrator_test_');
  });

  tearDown(() {
    dir.deleteSync(recursive: true);
  });

  /// Builds a faithful pre-v15 database: the real current Drift schema with the
  /// table added by the v15 migration removed and user_version set back to 14.
  Future<File> buildSchema14Fixture() async {
    final path = p.join(dir.path, 'schema14.sqlite');
    final db = AppDatabase.forTesting(
      NativeDatabase.createInBackground(File(path)),
    );
    await db.customSelect('SELECT 1').get(); // onCreate: createAll + seed
    await db.close();

    final raw = sqlite.sqlite3.open(path);
    raw.execute('DROP TABLE lab_analysis_attachments');
    raw.execute('DROP TABLE lab_analyses');
    raw.execute('PRAGMA user_version = 14');
    raw.close();
    return File(path);
  }

  test('migrates an older schema to the current schema in place', () async {
    final file = await buildSchema14Fixture();

    final result = await const RestoreSqliteMigrator().migrateToCurrent(
      file: file,
      fromSchemaVersion: 14,
    );

    expect(result.fromSchemaVersion, 14);
    expect(result.toSchemaVersion, 15);

    final db = sqlite.sqlite3.open(file.path, mode: sqlite.OpenMode.readOnly);
    expect(db.userVersion, 15);
    final labTableNames = db
        .select(
          "SELECT name FROM sqlite_master "
          "WHERE type='table' AND (name='lab_analyses' "
          "OR name='lab_analysis_attachments')",
        )
        .rows
        .map((r) => r.first.toString())
        .toSet();
    db.close();
    expect(labTableNames, containsAll({'lab_analyses', 'lab_analysis_attachments'}));
  });

  test('a database that is already current is a no-op', () async {
    final path = p.join(dir.path, 'current.sqlite');
    final db = AppDatabase.forTesting(
      NativeDatabase.createInBackground(File(path)),
    );
    await db.customSelect('SELECT 1').get();
    await db.close();

    final result = await const RestoreSqliteMigrator().migrateToCurrent(
      file: File(path),
      fromSchemaVersion: 15,
    );
    expect(result.toSchemaVersion, 15);
  });

  test('an unreadable database is rejected', () async {
    final bad = File(p.join(dir.path, 'bad.sqlite'));
    await bad.writeAsBytes([1, 2, 3, 4, 5]);

    await expectLater(
      const RestoreSqliteMigrator().migrateToCurrent(
        file: bad,
        fromSchemaVersion: 13,
      ),
      throwsA(isA<DatabaseMigrationException>()),
    );
  });
}
