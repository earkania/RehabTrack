import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/data/services/backup/backup_document_gateway.dart';
import 'package:rehab_track/data/services/backup/restore_selection_service.dart';
import 'package:rehab_track/domain/backup/backup_validation_result.dart';

class FakeBackupDocumentGateway extends BackupDocumentGateway {
  String? uriToReturn;
  Object? openError;
  bool copyCalled = false;
  String? copiedUri;
  String? copiedDestination;
  Object? copyError;

  @override
  Future<String?> openDocument() async {
    if (openError != null) throw openError!;
    return uriToReturn;
  }

  @override
  Future<void> copyDocument({
    required String contentUri,
    required String destinationPath,
  }) async {
    if (copyError != null) throw copyError!;
    copyCalled = true;
    copiedUri = contentUri;
    copiedDestination = destinationPath;
    File(destinationPath).writeAsBytesSync([1, 2, 3]);
  }
}

void main() {
  late Directory tempDir;
  late String tempPath;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('rehabtest_select_');
    tempPath = '${tempDir.path}/selected.rtb';
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  test('copies the selected document and reports the local file', () async {
    final gateway = FakeBackupDocumentGateway()
      ..uriToReturn = 'content://provider/backup.rtb';
    final service = RestoreSelectionService(gateway);

    final outcome = await service.select(tempFilePath: tempPath);

    expect(outcome.succeeded, isTrue);
    expect(outcome.cancelled, isFalse);
    expect(outcome.file, isNotNull);
    expect(outcome.result, BackupValidationResult.valid);
    expect(gateway.copyCalled, isTrue);
    expect(gateway.copiedUri, 'content://provider/backup.rtb');
    expect(gateway.copiedDestination, tempPath);
    expect(await outcome.file!.readAsBytes(), [1, 2, 3]);
  });

  test('reports cancelled when the picker returns no URI', () async {
    final gateway = FakeBackupDocumentGateway()..uriToReturn = null;
    final service = RestoreSelectionService(gateway);

    final outcome = await service.select(tempFilePath: tempPath);

    expect(outcome.succeeded, isFalse);
    expect(outcome.cancelled, isTrue);
    expect(outcome.result, BackupValidationResult.cancelled);
    expect(gateway.copyCalled, isFalse);
  });

  test('reports storage failure when opening the picker throws', () async {
    final gateway = FakeBackupDocumentGateway()
      ..openError = PlatformException(code: 'channel_error');
    final service = RestoreSelectionService(gateway);

    final outcome = await service.select(tempFilePath: tempPath);

    expect(outcome.result, BackupValidationResult.storageFailure);
    expect(outcome.succeeded, isFalse);
  });

  test('reports storage failure when copying throws', () async {
    final gateway = FakeBackupDocumentGateway()
      ..uriToReturn = 'content://provider/backup.rtb'
      ..copyError = PlatformException(code: 'copy_error');
    final service = RestoreSelectionService(gateway);

    final outcome = await service.select(tempFilePath: tempPath);

    expect(outcome.result, BackupValidationResult.storageFailure);
    expect(outcome.succeeded, isFalse);
  });
}
