import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rehab_track/data/services/profile_image_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProfileImageService service;
  late Directory tempDir;
  late Directory mockAppDir;

  const methodChannel = MethodChannel(
    'plugins.flutter.io/path_provider',
  );

  setUp(() async {
    service = ProfileImageService();
    tempDir = Directory.systemTemp.createTempSync('profile_image_test_');
    mockAppDir = Directory(p.join(tempDir.path, 'app_docs'))
      ..createSync(recursive: true);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return mockAppDir.path;
      }
      return null;
    });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('ProfileImageService', () {
    test('importProfilePhoto copies file to private storage', () async {
      final bytes = await _createTestImageBytes();

      final result = await service.importProfilePhoto(
        profileId: 1,
        imageBytes: bytes,
      );

      expect(result, isNotEmpty);
      expect(result, contains('profile_images'));
      expect(result, contains('profile_1_'));
      expect(result, endsWith('.jpg'));

      final file = File(result);
      expect(await file.exists(), isTrue);

      // Verify the file is in the mock app docs directory
      expect(result, startsWith(mockAppDir.path));
    });

    test('importProfilePhoto does not delete external source file', () async {
      final sourceFile = File(p.join(tempDir.path, 'external_image.jpg'));
      final bytes = await _createTestImageBytes();
      await sourceFile.writeAsBytes(bytes);

      expect(await sourceFile.exists(), isTrue);

      await service.importProfilePhoto(
        profileId: 2,
        imageBytes: bytes,
      );

      // External source file should still exist
      expect(await sourceFile.exists(), isTrue);
    });

    test('removeProfilePhoto deletes managed file', () async {
      final bytes = await _createTestImageBytes();
      final path = await service.importProfilePhoto(
        profileId: 3,
        imageBytes: bytes,
      );

      final file = File(path);
      expect(await file.exists(), isTrue);

      await service.removeProfilePhoto(path);

      expect(await file.exists(), isFalse);
    });

    test('removeProfilePhoto handles missing file gracefully', () async {
      // Should not throw
      await service.removeProfilePhoto('/nonexistent/path/photo.jpg');
    });

    test('getProfilePhoto returns null for null path', () async {
      final result = await service.getProfilePhoto(null);
      expect(result, null);
    });

    test('getProfilePhoto returns null for nonexistent file', () async {
      final result = await service.getProfilePhoto('/nonexistent/file.jpg');
      expect(result, null);
    });

    test('profilePhotoExists returns false for null', () async {
      expect(await service.profilePhotoExists(null), false);
    });

    test('profilePhotoExists returns false for nonexistent file', () async {
      expect(
        await service.profilePhotoExists('/nonexistent/file.jpg'),
        false,
      );
    });

    test('profilePhotoExists returns true for existing file', () async {
      final bytes = await _createTestImageBytes();
      final path = await service.importProfilePhoto(
        profileId: 4,
        imageBytes: bytes,
      );

      expect(await service.profilePhotoExists(path), isTrue);
    });

    test('replacement photo removes old file after success', () async {
      final bytes = await _createTestImageBytes();

      final path1 = await service.importProfilePhoto(
        profileId: 5,
        imageBytes: bytes,
      );
      final file1 = File(path1);
      expect(await file1.exists(), isTrue);

      // Simulate replacement: import new, then remove old
      final path2 = await service.importProfilePhoto(
        profileId: 5,
        imageBytes: bytes,
      );
      expect(path2, isNot(equals(path1)));

      await service.removeProfilePhoto(path1);

      expect(await file1.exists(), isFalse);
      expect(await File(path2).exists(), isTrue);
    });
  });
}

Future<Uint8List> _createTestImageBytes() async {
  // Create a small valid 1x1 red pixel image using dart:ui
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawColor(const Color(0xFFFF0000), ui.BlendMode.src);
  final picture = recorder.endRecording();
  final image = await picture.toImage(1, 1);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return byteData!.buffer.asUint8List();
}
