import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/services/backup/backup_archive_reader.dart';
import 'package:rehab_track/data/services/backup/backup_document_gateway.dart';
import 'package:rehab_track/data/services/backup/backup_validator.dart';
import 'package:rehab_track/data/services/backup/restore_selection_service.dart';
import 'package:rehab_track/domain/backup/backup_validation_result.dart';
import 'package:rehab_track/presentation/providers/restore_provider.dart';

import 'helpers/backup_test_utils.dart';

class _CopyToFileGateway extends BackupDocumentGateway {
  final Uint8List bytes;

  _CopyToFileGateway(this.bytes);

  @override
  Future<void> copyDocument({
    required String contentUri,
    required String destinationPath,
  }) async {
    await File(destinationPath).writeAsBytes(bytes);
  }
}

void main() {
  late Directory tempBaseDir;

  setUp(() {
    tempBaseDir = Directory.systemTemp.createTempSync('restore_uri_');
  });

  tearDown(() {
    if (tempBaseDir.existsSync()) {
      tempBaseDir.deleteSync(recursive: true);
    }
  });

  test('restoreFromUri validates a backup at a known content URI', () async {
    final zip = buildValidBackupZip(
      schema: AppDatabase.currentSchemaVersion,
    );
    final controller = RestoreOperationController(
      selectionService: RestoreSelectionService(_CopyToFileGateway(zip)),
      archiveReader: const BackupArchiveReader(),
      validator: const BackupValidator(),
      tempBaseDir: tempBaseDir,
    );

    final result = await controller.restoreFromUri('content://doc/1');

    expect(result, BackupValidationResult.valid);
    expect(controller.state.preview, isNotNull);
    expect(controller.state.preview!.databaseSchemaVersion,
        AppDatabase.currentSchemaVersion);
    expect(controller.state.backupFilePath, isNotNull);
    expect(File(controller.state.backupFilePath!).existsSync(), isTrue);
  });

  test('restoreFromUri maps a missing/uncopyable document to failure',
      () async {
    final controller = RestoreOperationController(
      selectionService: RestoreSelectionService(
        _CopyToFileGateway(Uint8List(0)),
      ),
      archiveReader: const BackupArchiveReader(),
      validator: const BackupValidator(),
      tempBaseDir: tempBaseDir,
    );

    final result = await controller.restoreFromUri('content://gone');

    expect(result, isNot(BackupValidationResult.valid));
    expect(controller.state.preview, isNull);
  });

  test('restoreFromUri rejects while another restore is running', () async {
    final zip = buildValidBackupZip(
      schema: AppDatabase.currentSchemaVersion,
    );
    final controller = RestoreOperationController(
      selectionService: RestoreSelectionService(_CopyToFileGateway(zip)),
      archiveReader: const BackupArchiveReader(),
      validator: const BackupValidator(),
      tempBaseDir: tempBaseDir,
    );
    // Start the first restore and immediately attempt a second one.
    final first = controller.restoreFromUri('content://doc/1');
    final second = await controller.restoreFromUri('content://doc/1');

    expect(second, BackupValidationResult.operationAlreadyInProgress);
    await first;
    expect(controller.state.result, BackupValidationResult.valid);
  });
}