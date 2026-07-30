import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/data/services/profile_image_service.dart';

void main() {
  late ProfileImageService service;

  setUp(() {
    service = ProfileImageService();
  });

  group('ProfileImageService', () {
    group('getProfilePhoto', () {
      test('returns null when photoPath is null', () async {
        final result = await service.getProfilePhoto(null);
        expect(result, null);
      });

      test('returns null when file does not exist', () async {
        final result = await service.getProfilePhoto('/nonexistent/path.jpg');
        expect(result, null);
      });
    });

    group('profilePhotoExists', () {
      test('returns false when photoPath is null', () async {
        final result = await service.profilePhotoExists(null);
        expect(result, false);
      });

      test('returns false when file does not exist', () async {
        final result = await service.profilePhotoExists('/nonexistent/path.jpg');
        expect(result, false);
      });
    });

    group('removeProfilePhoto', () {
      test('does not throw when photoPath is nonexistent', () async {
        expect(
          () => service.removeProfilePhoto('/nonexistent/path.jpg'),
          returnsNormally,
        );
      });
    });
  });
}
