import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/data/services/backup/backup_storage_gateway.dart';
import 'package:rehab_track/domain/backup/backup_result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.earkania.rehabtrack/backup');
  const gateway = BackupStorageGateway();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  group('save', () {
    test('decodes uri, displayName, size and persisted from payload',
        () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'createDocument');
        expect(call.arguments['fileName'], 'Suggested.rtb');
        return jsonEncode({
          'uri': 'content://backups/1',
          'displayName': 'Renamed.rtb',
          'size': 4096,
          'persisted': true,
        });
      });

      final result = await gateway.save(
        bytes: Uint8List(0),
        fileName: 'Suggested.rtb',
      );

      expect(result.succeeded, isTrue);
      expect(result.path, 'content://backups/1');
      expect(result.displayName, 'Renamed.rtb');
      expect(result.fileSize, 4096);
      expect(result.persisted, isTrue);
    });

    test('falls back to raw URI when native returns a plain path', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        return '/legacy/path.rtb';
      });

      final result = await gateway.save(
        bytes: Uint8List(0),
        fileName: 'a.rtb',
      );

      expect(result.path, '/legacy/path.rtb');
      expect(result.displayName, isNull);
      expect(result.fileSize, isNull);
      expect(result.persisted, isFalse);
    });

    test('maps cancel (null payload) to cancelled', () async {
      messenger.setMockMethodCallHandler(channel, (call) async => null);

      final result = await gateway.save(
        bytes: Uint8List(0),
        fileName: 'a.rtb',
      );

      expect(result.result, BackupResult.cancelled);
    });

    test('maps ENOSPC/space errors to notEnoughStorage', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(
          code: 'WRITE_ERROR',
          message: 'No space left on device',
        );
      });

      final result = await gateway.save(
        bytes: Uint8List(0),
        fileName: 'a.rtb',
      );

      expect(result.result, BackupResult.notEnoughStorage);
    });
  });

  group('queryDocument', () {
    test('decodes accessible metadata', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'queryDocument');
        expect(call.arguments['contentUri'], 'content://backups/9');
        return jsonEncode({
          'displayName': 'MyBackup.rtb',
          'size': 2048,
          'lastModified': 1750000000000,
          'accessible': true,
        });
      });

      final metadata =
          await gateway.queryDocument(contentUri: 'content://backups/9');

      expect(metadata.probed, isTrue);
      expect(metadata.accessible, isTrue);
      expect(metadata.displayName, 'MyBackup.rtb');
      expect(metadata.fileSize, 2048);
      expect(metadata.lastModified, 1750000000000);
    });

    test('reports an inaccessible document as accessible=false', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        return jsonEncode({
          'displayName': null,
          'size': null,
          'lastModified': null,
          'accessible': false,
        });
      });

      final metadata =
          await gateway.queryDocument(contentUri: 'content://gone');

      expect(metadata.probed, isTrue);
      expect(metadata.accessible, isFalse);
    });

    test('treats platform errors as an unprobed result', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: 'QUERY_ERROR', message: 'no such doc');
      });

      final metadata =
          await gateway.queryDocument(contentUri: 'content://gone');

      expect(metadata.probed, isFalse);
      expect(metadata.accessible, isFalse);
    });
  });

  group('deleteDocument', () {
    test('forwards the content URI and returns provider confirmation',
        () async {
      String? capturedUri;
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'deleteDocument');
        capturedUri = call.arguments['contentUri'] as String?;
        return true;
      });

      final deleted =
          await gateway.deleteDocument(contentUri: 'content://backups/5');

      expect(deleted, isTrue);
      expect(capturedUri, 'content://backups/5');
    });
  });

  group('shareDocument', () {
    test('forwards content URI and display name', () async {
      Map<String, Object?>? captured;
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'shareDocument');
        captured = (call.arguments as Map).cast<String, Object?>();
        return null;
      });

      await gateway.shareDocument(
        contentUri: 'content://backups/5',
        displayName: 'MyBackup.rtb',
      );

      expect(captured, {
        'contentUri': 'content://backups/5',
        'displayName': 'MyBackup.rtb',
      });
    });
  });

  group('hasPersistedPermission', () {
    test('returns the native granted flag', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'persistableUriPermission');
        return true;
      });

      expect(
        await gateway.hasPersistedPermission('content://backups/5'),
        isTrue,
      );
    });
  });
}