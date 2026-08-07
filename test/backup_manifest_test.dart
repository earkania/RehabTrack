import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/backup/backup_manifest.dart';

void main() {
  BackupManifest buildManifest({
    int formatVersion = BackupManifest.currentFormatVersion,
    String appVersion = '1.0.0',
    int schemaVersion = 14,
    int fileCount = 2,
    Map<String, String>? checksums,
  }) {
    return BackupManifest(
      backupFormatVersion: formatVersion,
      appVersion: appVersion,
      databaseSchemaVersion: schemaVersion,
      createdAt: DateTime.utc(2026, 8, 4, 12, 30),
      platform: 'android',
      fileCount: fileCount,
      totalUncompressedSize: 1024,
      checksums: checksums ??
          {
            'database.sqlite': 'a' * 64,
            'preferences.json': 'b' * 64,
            'files/profile_images/profile_1.jpg': 'c' * 64,
            'files/care_contact_images/contact_1.jpg': 'd' * 64,
          },
    );
  }

  test('serializes to JSON with UTC timestamp', () {
    final json = buildManifest().toJson();
    expect(json['backupFormatVersion'], BackupManifest.currentFormatVersion);
    expect(json['appVersion'], '1.0.0');
    expect(json['databaseSchemaVersion'], 14);
    expect(json['createdAt'], '2026-08-04T12:30:00.000Z');
    expect(json['databaseFileName'], 'database.sqlite');
    expect(json['preferencesFileName'], 'preferences.json');
    expect(json['fileCount'], 2);
    expect(json['totalUncompressedSize'], 1024);
    expect(json['checksums'], isA<Map<String, Object?>>());
  });

  test('round-trips through JSON without losing data', () {
    final original = buildManifest();
    final parsed = BackupManifest.fromJsonString(original.toJsonString());

    expect(parsed.backupFormatVersion, original.backupFormatVersion);
    expect(parsed.appVersion, original.appVersion);
    expect(parsed.databaseSchemaVersion, original.databaseSchemaVersion);
    expect(parsed.createdAt, original.createdAt);
    expect(parsed.platform, original.platform);
    expect(parsed.fileCount, original.fileCount);
    expect(parsed.totalUncompressedSize, original.totalUncompressedSize);
    expect(parsed.checksums, original.checksums);
  });

  test('valid manifest has no problems', () {
    expect(buildManifest().validate(), isEmpty);
  });

  test('rejects unknown format version', () {
    final problems = buildManifest(formatVersion: 999).validate();
    expect(problems, isNotEmpty);
    expect(problems.single, contains('999'));
  });

  test('rejects empty app version', () {
    final problems = buildManifest(appVersion: '').validate();
    expect(problems, isNotEmpty);
  });

  test('rejects non-positive schema version', () {
    final problems = buildManifest(schemaVersion: 0).validate();
    expect(problems, isNotEmpty);
  });

  test('rejects unsafe checksum paths', () {
    final problems = buildManifest(
      checksums: {
        'database.sqlite': 'a' * 64,
        'preferences.json': 'b' * 64,
        '../outside.db': 'c' * 64,
      },
    ).validate();
    expect(problems, isNotEmpty);
  });

  test('rejects empty checksum digest', () {
    final problems = buildManifest(
      checksums: {
        'database.sqlite': 'a' * 64,
        'preferences.json': '',
      },
    ).validate();
    expect(problems, isNotEmpty);
  });

  group('manifestChecksumsComplete', () {
    test('true when checksums cover database, preferences and all files', () {
      final manifest = buildManifest();
      expect(manifestChecksumsComplete(manifest, 2), isTrue);
    });

    test('false when the database checksum is missing', () {
      final manifest = buildManifest(
        checksums: {
          'preferences.json': 'b' * 64,
          'files/profile_images/profile_1.jpg': 'c' * 64,
          'files/care_contact_images/contact_1.jpg': 'd' * 64,
        },
      );
      expect(manifestChecksumsComplete(manifest, 2), isFalse);
    });

    test('false when file count does not match', () {
      final manifest = buildManifest();
      expect(manifestChecksumsComplete(manifest, 3), isFalse);
    });
  });
}
