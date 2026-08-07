import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:rehab_track/data/services/restore/restore_interrupted_recovery_service.dart';
import 'package:rehab_track/data/services/restore/restore_recovery_metadata.dart';

import 'helpers/restore_test_utils.dart';

void main() {
  late Directory tempBaseDir;
  late Directory docsDir;
  late FakeRestoreEnvironment env;
  late RestoreRecoveryStore recoveryStore;
  late RestoreInterruptedRecoveryService service;

  final aDb = buildRestorableSqliteBytes(
    schema: 15,
    profiles: 2,
    settings: const {'app_language': 'ka'},
  );
  final bDb = buildRestorableSqliteBytes(
    schema: 15,
    profiles: 1,
    settings: const {'app_language': 'en'},
  );

  setUp(() {
    tempBaseDir = Directory.systemTemp.createTempSync('recovery_svc_');
    docsDir = Directory(p.join(tempBaseDir.path, 'documents'));
    env = FakeRestoreEnvironment(docsDir);
    recoveryStore = RestoreRecoveryStore.inDirectory(
      Directory(p.join(tempBaseDir.path, 'recovery')),
    );
    service = RestoreInterruptedRecoveryService(
      environment: env,
      recoveryStore: recoveryStore,
    );
  });

  tearDown(() {
    tempBaseDir.deleteSync(recursive: true);
  });

  Future<Directory> buildWorkspaceWithSnapshot(String opId) async {
    final ws = await Directory(
      p.join(tempBaseDir.path, 'restore-workspace', opId),
    ).create(recursive: true);
    await Directory(p.join(ws.path, 'safety-snapshot')).create(recursive: true);
    await File(p.join(ws.path, 'safety-snapshot', 'database.sqlite'))
        .writeAsBytes(aDb);
    await File(p.join(ws.path, 'safety-snapshot', 'preferences.json'))
        .writeAsString(jsonEncode({'app_language': 'ka'}));
    await Directory(
      p.join(ws.path, 'safety-snapshot', 'files'),
    ).create(recursive: true);
    await writeManagedFile(
      Directory(p.join(ws.path, 'safety-snapshot', 'files')),
      'profile_images',
      'photoA.jpg',
      [1],
    );
    return ws;
  }

  test('no metadata means nothing to recover', () async {
    expect(await service.recover(), RestoreInterruptedRecoveryResult.none);
  });

  test('recovers a half-restored device to the pre-restore state', () async {
    final opId = 'op_interrupted';
    final ws = await buildWorkspaceWithSnapshot(opId);
    await recoveryStore.write(RestoreRecoveryMetadata(
      operationId: opId,
      phase: 'replacingDatabase',
      workspacePath: ws.path,
      databaseSwapStarted: true,
      fileSwapStarted: true,
    ));

    // The live device currently holds the partially-restored backup B.
    await writeLiveDatabase(docsDir, bDb);
    await writeManagedFile(docsDir, 'profile_images', 'photoB.jpg', [2]);

    expect(await service.recover(), RestoreInterruptedRecoveryResult.recovered);

    // Live state matches the snapshot (A), not the half-applied backup (B).
    expect(readProfileCount((await env.liveDb()).path), 2);
    expect(
      await readAllowlistedSettings((await env.liveDb()).path),
      {'app_language': 'ka'},
    );
    expect(await managedFileExists(docsDir, 'profile_images', 'photoA.jpg'),
        isTrue);
    expect(await managedFileExists(docsDir, 'profile_images', 'photoB.jpg'),
        isFalse);
    expect(await recoveryStore.listAll(), isEmpty);
  });

  test('discards non-recovery metadata and leaves the state untouched',
      () async {
    final opId = 'op_never_started';
    final ws = await buildWorkspaceWithSnapshot(opId);
    await recoveryStore.write(RestoreRecoveryMetadata(
      operationId: opId,
      phase: 'preparingRestore',
      workspacePath: ws.path,
    ));

    expect(await service.recover(), RestoreInterruptedRecoveryResult.none);
    expect(await recoveryStore.listAll(), isEmpty);
  });

  test('a missing workspace fails recovery and retains the metadata', () async {
    final opId = 'op_missing_ws';
    await recoveryStore.write(RestoreRecoveryMetadata(
      operationId: opId,
      phase: 'replacingDatabase',
      workspacePath: p.join(tempBaseDir.path, 'restore-workspace', opId),
      databaseSwapStarted: true,
    ));

    expect(await service.recover(), RestoreInterruptedRecoveryResult.failed);
    expect(await recoveryStore.listAll(), isNotEmpty);
  });

  test('recovery failure due to verification retains metadata', () async {
    final opId = 'op_bad_verify';
    final ws = await buildWorkspaceWithSnapshot(opId);
    await recoveryStore.write(RestoreRecoveryMetadata(
      operationId: opId,
      phase: 'replacingDatabase',
      workspacePath: ws.path,
      databaseSwapStarted: true,
    ));
    env.verifyResult = false;

    expect(await service.recover(), RestoreInterruptedRecoveryResult.failed);
    expect(await recoveryStore.listAll(), isNotEmpty);
  });

  test('exhausted attempts enter the terminal recoveryLimitReached state',
      () async {
    final opId = 'op_limited';
    final ws = await buildWorkspaceWithSnapshot(opId);
    await recoveryStore.write(RestoreRecoveryMetadata(
      operationId: opId,
      phase: 'replacingDatabase',
      workspacePath: ws.path,
      databaseSwapStarted: true,
      attemptCount: RestoreInterruptedRecoveryService.maxRecoveryAttempts,
    ));

    expect(
      await service.recover(),
      RestoreInterruptedRecoveryResult.recoveryLimitReached,
    );
    // Metadata is retained for manual action and never retried.
    expect(await recoveryStore.listAll(), isNotEmpty);
    expect(env.reopenDatabaseCalls, 0);
  });

  test('failed recovery increments the attempt counter across launches',
      () async {
    final opId = 'op_attempts';
    final ws = await buildWorkspaceWithSnapshot(opId);
    await recoveryStore.write(RestoreRecoveryMetadata(
      operationId: opId,
      phase: 'replacingDatabase',
      workspacePath: ws.path,
      databaseSwapStarted: true,
    ));
    env.verifyResult = false;

    for (var i = 1; i <= RestoreInterruptedRecoveryService.maxRecoveryAttempts;
        i++) {
      expect(await service.recover(), RestoreInterruptedRecoveryResult.failed);
      final stored = (await recoveryStore.listAll()).single;
      expect(stored.attemptCount, i);
    }

    expect(
      await service.recover(),
      RestoreInterruptedRecoveryResult.recoveryLimitReached,
    );
  });
}