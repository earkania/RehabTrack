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

  /// Builds a faithful pre-v17 database: the real current Drift schema with the
  /// table added by the v17 migration removed and user_version set back to 16.
  Future<File> buildSchema16Fixture() async {
    final path = p.join(dir.path, 'schema16.sqlite');
    final db = AppDatabase.forTesting(
      NativeDatabase.createInBackground(File(path)),
    );
    await db.customSelect('SELECT 1').get(); // onCreate: createAll + seed
    await db.close();

    final raw = sqlite.sqlite3.open(path);
    raw.execute('DROP TABLE doctor_prescription_medications');
    raw.execute('PRAGMA user_version = 16');
    raw.close();
    return File(path);
  }

  test('migrates an older schema to the current schema in place', () async {
    final file = await buildSchema16Fixture();

    final result = await const RestoreSqliteMigrator().migrateToCurrent(
      file: file,
      fromSchemaVersion: 16,
    );

    expect(result.fromSchemaVersion, 16);
    expect(result.toSchemaVersion, AppDatabase.currentSchemaVersion);

    final db = sqlite.sqlite3.open(file.path, mode: sqlite.OpenMode.readOnly);
    expect(db.userVersion, AppDatabase.currentSchemaVersion);
    final prescriptionTableNames = db
        .select(
          "SELECT name FROM sqlite_master "
          "WHERE type='table' AND name='doctor_prescription_medications'",
        )
        .rows
        .map((r) => r.first.toString())
        .toSet();
    db.close();
    expect(prescriptionTableNames, contains('doctor_prescription_medications'));
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
      fromSchemaVersion: AppDatabase.currentSchemaVersion,
    );
    expect(result.toSchemaVersion, AppDatabase.currentSchemaVersion);
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
