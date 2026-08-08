import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:rehab_track/data/services/restore/restore_database_manager.dart';

import 'helpers/restore_test_utils.dart';

void main() {
  late Directory dir;
  final manager = const RestoreDatabaseManager();

  setUp(() {
    dir = Directory.systemTemp.createTempSync('dbmanager_test_');
  });

  tearDown(() {
    dir.deleteSync(recursive: true);
  });

  test('prepare writes and validates a valid database', () async {
    final preparedDir = Directory(p.join(dir.path, 'prepared'));
    await preparedDir.create(recursive: true);
    final dbBytes = buildRestorableSqliteBytes(schema: 15, profiles: 2);
    final prepared = await manager.prepare(
      dbBytes: dbBytes,
      preparedDir: preparedDir,
      expectedSchemaVersion: 15,
    );
    expect(prepared.file.existsSync(), isTrue);
    expect(
      await manager.validatePrepared(
        file: prepared.file,
        expectedSchemaVersion: 15,
      ),
      isTrue,
    );
  });

  test('prepare rejects a database with a mismatched schema', () async {
    final preparedDir = Directory(p.join(dir.path, 'prepared'));
    await preparedDir.create(recursive: true);
    final dbBytes = buildRestorableSqliteBytes(schema: 13, profiles: 1);
    expect(
      manager.prepare(
        dbBytes: dbBytes,
        preparedDir: preparedDir,
        expectedSchemaVersion: 15,
      ),
      throwsA(isA<DatabasePreparationException>()),
    );
  });

  test('prepare rejects bytes that are not a database', () async {
    final preparedDir = Directory(p.join(dir.path, 'prepared'));
    await preparedDir.create(recursive: true);
    expect(
      manager.prepare(
        dbBytes: Uint8List.fromList('not a database at all'.codeUnits),
        preparedDir: preparedDir,
        expectedSchemaVersion: 15,
      ),
      throwsA(isA<DatabasePreparationException>()),
    );
  });

  test('validatePrepared is false for wrong schema/missing tables', () async {
    final good = buildRestorableSqliteBytes(schema: 15, profiles: 1);
    final file = File(p.join(dir.path, 'db.sqlite'));
    await file.writeAsBytes(good);
    expect(
      await manager.validatePrepared(file: file, expectedSchemaVersion: 13),
      isFalse,
    );
  });

  test('swap moves live plus sidecars so prepared can take its place, and '
      'restores it back', () async {
    final liveDir = Directory(p.join(dir.path, 'live'));
    await liveDir.create(recursive: true);
    final liveDb = File(p.join(liveDir.path, 'rehabtrack.sqlite'));
    await liveDb.writeAsBytes(buildRestorableSqliteBytes(schema: 15, profiles: 3));

    // Simulate a WAL sidecar that must move with the live database.
    final wal = File('${liveDb.path}-wal');
    await wal.writeAsBytes([1, 2, 3]);

    final prepared = File(p.join(dir.path, 'prepared.sqlite'));
    await prepared.writeAsBytes(buildRestorableSqliteBytes(schema: 15, profiles: 1));

    final rollbackDir = Directory(p.join(dir.path, 'rollback'));
    final swap = const RestoreDatabaseSwap();

    final handle = await swap.moveAside(liveFile: liveDb, rollbackDir: rollbackDir);
    expect(handle.movedFiles.length, 2);
    expect(liveDb.existsSync(), isFalse);

    await swap.placePrepared(preparedFile: prepared, liveFile: liveDb);
    expect(liveDb.existsSync(), isTrue);

    await swap.restoreLive(handle: handle);
    expect(liveDb.existsSync(), isTrue);
    // The restored live database is the original (3 profiles); the prepared one
    // was removed by restoreLive.
    expect(readProfileCount(liveDb.path), 3);
    expect(File('${liveDb.path}-wal').existsSync(), isTrue);
  });
}