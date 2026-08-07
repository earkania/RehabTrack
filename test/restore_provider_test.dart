import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:rehab_track/data/services/backup/backup_archive_reader.dart';
import 'package:rehab_track/data/services/backup/backup_document_gateway.dart';
import 'package:rehab_track/data/services/backup/backup_validator.dart';
import 'package:rehab_track/data/services/backup/restore_selection_service.dart';
import 'package:rehab_track/domain/backup/backup_compatibility.dart';
import 'package:rehab_track/domain/backup/backup_preview.dart';
import 'package:rehab_track/domain/backup/backup_validation_result.dart';
import 'package:rehab_track/domain/backup/restore_phase.dart';
import 'package:rehab_track/presentation/providers/restore_provider.dart';

import 'helpers/backup_test_utils.dart';

class FakeSelectionService extends RestoreSelectionService {
  BackupSelectionOutcome? next;
  Completer<BackupSelectionOutcome>? gate;

  FakeSelectionService() : super(const BackupDocumentGateway());

  @override
  Future<BackupSelectionOutcome> select({
    required String tempFilePath,
  }) {
    if (gate != null) return gate!.future;
    final outcome = next!;
    if (outcome.succeeded) {
      // A structurally valid archive is enough for the real reader. Return a
      // success outcome pointing at the actually-written temp file.
      File(tempFilePath).writeAsBytesSync(buildZip({
        'manifest.json': Uint8List.fromList(utf8.encode('{}')),
      }));
      return Future.value(BackupSelectionOutcome.success(File(tempFilePath)));
    }
    return Future.value(outcome);
  }
}

class FakeArchiveReader extends BackupArchiveReader {
  @override
  Future<BackupArchiveReadResult> read(File archiveFile) {
    return const BackupArchiveReader().read(archiveFile);
  }
}

class FakeValidator extends BackupValidator {
  BackupValidationOutcome? next;

  @override
  Future<BackupValidationOutcome> validate({
    required BackupArchiveHandle handle,
    required Directory tempDir,
    required int currentDatabaseSchemaVersion,
    required String currentAppVersion,
    void Function(RestorePhase phase)? onPhase,
  }) async {
    return next!;
  }
}

BackupPreview _preview() {
  return BackupPreview(
    backupCreatedAt: DateTime.utc(2026, 8, 5),
    appVersion: '1.2.0',
    backupFormatVersion: 1,
    databaseSchemaVersion: 14,
    currentDatabaseSchemaVersion: 14,
    compatibility: BackupCompatibility.compatible,
    migrationRequired: false,
    profileCount: 2,
    managedFileCount: 0,
    backupFileSize: 128,
  );
}

void main() {
  late Directory baseDir;

  setUp(() {
    baseDir = Directory.systemTemp.createTempSync('rehabtest_restore_');
  });

  tearDown(() {
    baseDir.deleteSync(recursive: true);
  });

  RestoreOperationController buildController({
    required FakeSelectionService selection,
    BackupValidationOutcome? validatorOutcome,
  }) {
    return RestoreOperationController(
      selectionService: selection,
      archiveReader: FakeArchiveReader(),
      validator: (FakeValidator()..next = validatorOutcome),
      tempBaseDir: baseDir,
    );
  }

  test('ends ready for preview on a valid archive', () async {
    final selection = FakeSelectionService()
      ..next = BackupSelectionOutcome.success(
        File('${baseDir.path}/unused.rtb'),
      );
    final controller = buildController(
      selection: selection,
      validatorOutcome: BackupValidationOutcome(
        result: BackupValidationResult.valid,
        preview: _preview(),
      ),
    );
    final result = await controller.restoreBackup();

    expect(result, BackupValidationResult.valid);
    expect(controller.state.isReadyForPreview, isTrue);
    expect(controller.state.preview, isNotNull);
    expect(controller.state.preview!.profileCount, 2);
    expect(controller.state.phase, RestorePhase.readyForPreview);
  });

  test('ends cancelled when the user dismisses the picker', () async {
    final selection = FakeSelectionService()
      ..next = BackupSelectionOutcome.cancelled();
    final controller = buildController(selection: selection);
    final result = await controller.restoreBackup();

    expect(result, BackupValidationResult.cancelled);
    expect(controller.state.phase, RestorePhase.cancelled);
  });

  test('ends in failure when selection cannot copy the file', () async {
    final selection = FakeSelectionService()
      ..next = BackupSelectionOutcome.failure(
        BackupValidationResult.storageFailure,
      );
    final controller = buildController(selection: selection);
    final result = await controller.restoreBackup();

    expect(result, BackupValidationResult.storageFailure);
    expect(controller.state.phase, RestorePhase.failure);
  });

  test('ends in failure with warnings when validation rejects', () async {
    final selection = FakeSelectionService()
      ..next = BackupSelectionOutcome.success(
        File('${baseDir.path}/unused.rtb'),
      );
    final controller = buildController(
      selection: selection,
      validatorOutcome: const BackupValidationOutcome(
        result: BackupValidationResult.newerDatabaseVersion,
        warnings: [BackupWarning.olderAppVersion],
      ),
    );
    final result = await controller.restoreBackup();

    expect(result, BackupValidationResult.newerDatabaseVersion);
    expect(controller.state.phase, RestorePhase.failure);
    expect(controller.state.warnings, contains(BackupWarning.olderAppVersion));
  });

  test('returns operationAlreadyInProgress while a restore runs', () async {
    final selection = FakeSelectionService();
    final gate = Completer<BackupSelectionOutcome>();
    selection.gate = gate;
    final controller = buildController(selection: selection);

    final first = controller.restoreBackup();
    final second = await controller.restoreBackup();

    expect(second, BackupValidationResult.operationAlreadyInProgress);
    gate.complete(BackupSelectionOutcome.cancelled());
    await first;
  });

  test('persists a validated backup copy and cleans up the temp work dir',
      () async {
    final selection = FakeSelectionService()
      ..next = BackupSelectionOutcome.success(
        File('${baseDir.path}/unused.rtb'),
      );
    final controller = buildController(
      selection: selection,
      validatorOutcome: const BackupValidationOutcome(
        result: BackupValidationResult.valid,
      ),
    );
    await controller.restoreBackup();

    // The validated archive is persisted so the restore-apply flow can reuse it.
    expect(controller.state.backupFilePath, isNotNull);
    expect(
      File(p.join(baseDir.path, 'pending-restore', 'selected.rtb')).existsSync(),
      isTrue,
    );
    // Only the pending-restore copy remains; ephemeral work dirs are removed.
    expect(
      baseDir.listSync().map((e) => p.basename(e.path)).toList(),
      ['pending-restore'],
    );
  });
}
