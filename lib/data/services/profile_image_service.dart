import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ProfileImageService {
  static const _profileImagesDir = 'profile_images';
  static const _maxWidth = 512;
  static const _maxHeight = 512;

  Future<String> importProfilePhoto({
    required int profileId,
    required Uint8List imageBytes,
  }) async {
    final dir = await _getProfileImagesDirectory();
    final fileName = 'profile_${profileId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(p.join(dir.path, fileName));

    final resized = await _resizeImageBytes(
      imageBytes,
      maxWidth: _maxWidth,
      maxHeight: _maxHeight,
    );

    await file.writeAsBytes(resized);
    return file.path;
  }

  Future<void> removeProfilePhoto(String photoPath) async {
    final file = File(photoPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File?> getProfilePhoto(String? photoPath) async {
    if (photoPath == null) return null;
    final file = File(photoPath);
    if (await file.exists()) return file;
    return null;
  }

  Future<bool> profilePhotoExists(String? photoPath) async {
    if (photoPath == null) return false;
    return File(photoPath).exists();
  }

  Future<Directory> _getProfileImagesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(appDir.path, _profileImagesDir));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  static Future<Uint8List> _resizeImageBytes(
    Uint8List bytes, {
    required int maxWidth,
    required int maxHeight,
  }) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    var width = image.width;
    var height = image.height;

    if (width > maxWidth || height > maxHeight) {
      final ratio = (width / maxWidth).clamp(0.0, 1.0);
      final heightRatio = (height / maxHeight).clamp(0.0, 1.0);
      final scale = ratio > heightRatio ? ratio : heightRatio;
      width = (width / scale).round();
      height = (height / scale).round();
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint()..filterQuality = FilterQuality.high,
    );

    final picture = recorder.endRecording();
    final resizedImage = await picture.toImage(width, height);
    final byteData = await resizedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    image.dispose();
    resizedImage.dispose();

    return byteData!.buffer.asUint8List();
  }
}
