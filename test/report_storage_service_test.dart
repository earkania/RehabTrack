import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/data/services/report/report_storage_service.dart';
import 'package:rehab_track/data/services/report/saved_report_file.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ReportStorageService service;
  late MethodChannel channel;
  final calls = <MethodCall>[];

  Future<Object?> handler(MethodCall call) async {
    calls.add(call);
    switch (call.method) {
      case 'savePdfToDownloads':
        final args = call.arguments as Map<Object?, Object?>;
        if ((args['bytes'] as Uint8List).isEmpty) {
          throw PlatformException(code: 'INVALID_ARGUMENTS');
        }
        return jsonEncode({
          'displayName': 'RehabTrack_Health_Summary_2026-08-26.pdf',
          'contentUri': 'content://media/external/downloads/42',
          'mimeType': 'application/pdf',
          'size': 2048,
          'createdAt': 1756160400000,
          'logicalLocation': 'Downloads/RehabTrack',
        });
      case 'openSavedDocument':
        return true;
      case 'shareSavedDocument':
        return true;
      default:
        return null;
    }
  }

  setUp(() {
    channel = const MethodChannel('com.earkania.rehabtrack/reports.test');
    service = ReportStorageService(testChannel: channel);
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handler);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('savePdf', () {
    test('sends bytes, name, mime type and relative path to the platform',
        () async {
      await service.savePdf(
        bytes: Uint8List.fromList([0x25, 0x50, 0x44, 0x46]),
        displayName: 'RehabTrack_Health_Summary_2026-08-26.pdf',
      );

      expect(calls.single.method, 'savePdfToDownloads');
      final args = calls.single.arguments as Map<Object?, Object?>;
      expect(args['displayName'], contains('Health_Summary'));
      expect(args['mimeType'], 'application/pdf');
      expect(args['relativePath'], 'Download/RehabTrack');
      expect((args['bytes'] as Uint8List).sublist(0, 4), [0x25, 0x50, 0x44, 0x46]);
    });

    test('parses the platform result into a SavedReportFile', () async {
      final saved = await service.savePdf(
        bytes: Uint8List.fromList([1]),
        displayName: 'x.pdf',
      );
      expect(saved.displayName, 'RehabTrack_Health_Summary_2026-08-26.pdf');
      expect(saved.contentUri, 'content://media/external/downloads/42');
      expect(saved.mimeType, 'application/pdf');
      expect(saved.size, 2048);
      expect(saved.createdAt, DateTime.fromMillisecondsSinceEpoch(1756160400000));
      expect(saved.logicalLocation, 'Downloads/RehabTrack');
    });

    test('rejects empty PDF bytes before touching the platform', () async {
      await expectLater(
        service.savePdf(bytes: Uint8List(0), displayName: 'x.pdf'),
        throwsA(isA<ReportStorageException>()
            .having((e) => e.code, 'code', 'INVALID_ARGUMENTS')),
      );
      expect(calls, isEmpty);
    });

    test('maps native SAVE_ERROR to ReportStorageException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) {
        throw PlatformException(code: 'SAVE_ERROR', message: 'disk full');
      });
      await expectLater(
        service.savePdf(bytes: Uint8List.fromList([1]), displayName: 'x.pdf'),
        throwsA(isA<ReportStorageException>().having(
            (e) => e.code, 'code', 'SAVE_ERROR')),
      );
    });
  });

  group('open', () {
    test('passes the content URI and mime type', () async {
      final file = _savedFile();
      await service.open(file);
      final args = calls.single.arguments as Map<Object?, Object?>;
      expect(calls.single.method, 'openSavedDocument');
      expect(args['contentUri'], 'content://media/external/downloads/42');
      expect(args['mimeType'], 'application/pdf');
    });

    test('maps NO_VIEWER to ReportStorageException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) {
        throw PlatformException(code: 'NO_VIEWER');
      });
      await expectLater(
        service.open(_savedFile()),
        throwsA(isA<ReportStorageException>()
            .having((e) => e.code, 'code', 'NO_VIEWER')),
      );
    });

    test('rejects files without a content URI', () async {
      final file = SavedReportFile(
        displayName: 'a.pdf',
        logicalLocation: 'Downloads/RehabTrack',
        mimeType: 'application/pdf',
        size: 1,
        createdAt: DateTime.now(),
        contentUri: null,
      );
      await expectLater(
        service.open(file),
        throwsA(isA<ReportStorageException>()
            .having((e) => e.code, 'code', 'INVALID_ARGUMENTS')),
      );
      expect(calls, isEmpty);
    });
  });

  group('share', () {
    test('passes content URI, mime type and display name', () async {
      await service.share(_savedFile());
      expect(calls.single.method, 'shareSavedDocument');
      final args = calls.single.arguments as Map<Object?, Object?>;
      expect(args['contentUri'], 'content://media/external/downloads/42');
      expect(args['mimeType'], 'application/pdf');
      expect(args['displayName'], 'report.pdf');
    });

    test('maps SHARE_ERROR to ReportStorageException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) {
        throw PlatformException(code: 'SHARE_ERROR');
      });
      await expectLater(
        service.share(_savedFile()),
        throwsA(isA<ReportStorageException>()
            .having((e) => e.code, 'code', 'SHARE_ERROR')),
      );
    });
  });
}

SavedReportFile _savedFile() => SavedReportFile(
      displayName: 'report.pdf',
      logicalLocation: 'Downloads/RehabTrack',
      mimeType: 'application/pdf',
      size: 10,
      createdAt: DateTime(2026, 8, 26),
      contentUri: 'content://media/external/downloads/42',
    );
