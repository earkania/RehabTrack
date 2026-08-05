import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/data/services/restore/restore_recovery_metadata.dart';

void main() {
  late Directory dir;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('recovery_store_test_');
  });

  tearDown(() {
    dir.deleteSync(recursive: true);
  });

  test('needsRecovery is true once a swap begins and false once finalized',
      () {
    const fresh = RestoreRecoveryMetadata(
      operationId: 'op1',
      phase: 'preparingRestore',
      workspacePath: '/tmp/ws',
    );
    expect(fresh.needsRecovery, isFalse);

    const started = RestoreRecoveryMetadata(
      operationId: 'op1',
      phase: 'replacingDatabase',
      workspacePath: '/tmp/ws',
      databaseSwapStarted: true,
    );
    expect(started.needsRecovery, isTrue);

    const finalized = RestoreRecoveryMetadata(
      operationId: 'op1',
      phase: 'finalizingRestore',
      workspacePath: '/tmp/ws',
      databaseSwapStarted: true,
      finalized: true,
    );
    expect(finalized.needsRecovery, isFalse);
  });

  test('round-trips through JSON', () {
    const metadata = RestoreRecoveryMetadata(
      operationId: 'op1',
      phase: 'replacingDatabase',
      workspacePath: '/private/tmp/ws',
      databaseSwapStarted: true,
      fileSwapStarted: true,
      preferencesApplied: true,
    );
    final restored = RestoreRecoveryMetadata.fromJsonString(
      metadata.toJsonString(),
    );
    expect(restored.operationId, 'op1');
    expect(restored.phase, 'replacingDatabase');
    expect(restored.workspacePath, '/private/tmp/ws');
    expect(restored.databaseSwapStarted, isTrue);
    expect(restored.fileSwapStarted, isTrue);
    expect(restored.preferencesApplied, isTrue);
    expect(restored.finalized, isFalse);
  });

  test('store writes, reads, lists and clears metadata files', () async {
    final store = RestoreRecoveryStore.inDirectory(dir);
    await store.write(const RestoreRecoveryMetadata(
      operationId: 'op1',
      phase: 'replacingDatabase',
      workspacePath: '/tmp/ws',
      databaseSwapStarted: true,
    ));
    await store.write(const RestoreRecoveryMetadata(
      operationId: 'op2',
      phase: 'preparingRestore',
      workspacePath: '/tmp/ws',
    ));

    expect((await store.read('op1'))?.operationId, 'op1');
    expect(await store.read('missing'), isNull);

    final all = await store.listAll();
    expect(all.map((m) => m.operationId).toSet(), {'op1', 'op2'});

    await store.clear('op1');
    expect(await store.read('op1'), isNull);
    expect((await store.listAll()).length, 1);
  });
}