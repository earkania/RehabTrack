import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

/// Builds a ZIP archive from [entries]. Duplicate names are added as extra
/// entries so readers that inspect raw headers can detect them.
Uint8List buildZip(
  Map<String, Uint8List> entries, {
  List<String> duplicates = const [],
}) {
  final archive = Archive();
  entries.forEach((name, bytes) {
    archive.addFile(ArchiveFile.typedData(name, bytes));
  });
  for (final name in duplicates) {
    archive.addFile(ArchiveFile.typedData(name, entries[name]!));
  }
  return ZipEncoder().encodeBytes(archive);
}

/// Builds a "stored" (uncompressed) ZIP that may contain the same entry name
/// more than once, which the high-level [Archive]/[ZipEncoder] API would
/// silently deduplicate. Used to exercise duplicate detection in readers.
Uint8List buildZipWithDuplicates(
  List<(String, Uint8List)> entries,
) {
  final localHeaders = BytesBuilder(copy: false);
  final centralHeaders = BytesBuilder(copy: false);
  final localOffsets = <int>[];

  for (final (name, data) in entries) {
    localOffsets.add(localHeaders.length);
    final nameBytes = Uint8List.fromList(utf8.encode(name));
    localHeaders.add(_u32(0x04034b50));
    localHeaders.add(_u16(20)); // version needed
    localHeaders.add(_u16(0)); // flags
    localHeaders.add(_u16(0)); // method: store
    localHeaders.add(_u16(0)); // mod time
    localHeaders.add(_u16(0)); // mod date
    localHeaders.add(_u32(crc32(data))); //
    localHeaders.add(_u32(data.length)); // compressed size
    localHeaders.add(_u32(data.length)); // uncompressed size
    localHeaders.add(_u16(nameBytes.length)); // name len
    localHeaders.add(_u16(0)); // extra len
    localHeaders.add(nameBytes);
    localHeaders.add(data);

    centralHeaders.add(_u32(0x02014b50));
    centralHeaders.add(_u16(20)); // version made by
    centralHeaders.add(_u16(20)); // version needed
    centralHeaders.add(_u16(0)); // flags
    centralHeaders.add(_u16(0)); // method
    centralHeaders.add(_u16(0)); // mod time
    centralHeaders.add(_u16(0)); // mod date
    centralHeaders.add(_u32(crc32(data)));
    centralHeaders.add(_u32(data.length)); // compressed size
    centralHeaders.add(_u32(data.length)); // uncompressed size
    centralHeaders.add(_u16(nameBytes.length)); // name len
    centralHeaders.add(_u16(0)); // extra len
    centralHeaders.add(_u16(0)); // comment len
    centralHeaders.add(_u16(0)); // disk number
    centralHeaders.add(_u16(0)); // internal attrs
    centralHeaders.add(_u32(0)); // external attrs
    centralHeaders.add(_u32(localOffsets.last)); // local header offset
    centralHeaders.add(nameBytes);
  }

  final cdSize = centralHeaders.length;
  final cdOffset = localHeaders.length;

  final end = BytesBuilder(copy: false);
  end.add(_u32(0x06054b50));
  end.add(_u16(0)); // disk number
  end.add(_u16(0)); // cd start disk
  end.add(_u16(entries.length)); // entries on this disk
  end.add(_u16(entries.length)); // total entries
  end.add(_u32(cdSize));
  end.add(_u32(cdOffset));
  end.add(_u16(0)); // comment len

  return Uint8List.fromList([...localHeaders.toBytes(), ...centralHeaders.toBytes(), ...end.toBytes()]);
}

Uint8List _u16(int value) {
  return Uint8List.fromList([value & 0xff, (value >> 8) & 0xff]);
}

Uint8List _u32(int value) {
  return Uint8List.fromList([
    value & 0xff,
    (value >> 8) & 0xff,
    (value >> 16) & 0xff,
    (value >> 24) & 0xff,
  ]);
}

int crc32(List<int> bytes) {
  int crc = 0xffffffff;
  for (final byte in bytes) {
    crc ^= byte;
    for (var i = 0; i < 8; i++) {
      crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xedb88320 : crc >> 1;
    }
  }
  return crc ^ 0xffffffff;
}

/// Creates a minimal SQLite database for [schema] with the core tables and
/// [profiles] profile rows, and returns its raw bytes.
Uint8List buildSqliteBytes({required int schema, int profiles = 2}) {
  final dir = Directory.systemTemp.createTempSync('rehabtest_db_');
  final path = p.join(dir.path, 'db.sqlite');
  try {
    final db = sqlite.sqlite3.open(path);
    try {
      db.execute('PRAGMA user_version = $schema');
      for (final table in [
        'profiles',
        'medications',
        'measurement_types',
        'app_settings',
      ]) {
        db.execute('CREATE TABLE $table (id INTEGER PRIMARY KEY)');
      }
      for (var i = 0; i < profiles; i++) {
        db.execute('INSERT INTO profiles (id) VALUES (${i + 1})');
      }
    } finally {
      db.close();
    }
    return File(path).readAsBytesSync();
  } finally {
    dir.deleteSync(recursive: true);
  }
}

/// A manifest JSON map with safe defaults.
Map<String, Object?> buildManifestJson({
  required int schema,
  required Map<String, String> checksums,
  int formatVersion = 1,
  int fileCount = 0,
  int totalUncompressedSize = 0,
  String appVersion = '1.2.0',
}) {
  return {
    'backupFormatVersion': formatVersion,
    'appVersion': appVersion,
    'databaseSchemaVersion': schema,
    'createdAt': '2026-08-05T00:00:00.000Z',
    'platform': 'android',
    'fileCount': fileCount,
    'totalUncompressedSize': totalUncompressedSize,
    'checksums': checksums,
  };
}

/// A valid `.rtb` archive: manifest + database + preferences with matching
/// checksums.
Uint8List buildValidBackupZip({
  int schema = 14,
  int formatVersion = 1,
  int fileCount = 0,
  int profiles = 2,
  String appVersion = '1.2.0',
}) {
  final db = buildSqliteBytes(schema: schema, profiles: profiles);
  final prefs =
      Uint8List.fromList(utf8.encode(jsonEncode({'app_language': 'en'})));
  final manifest = buildManifestJson(
    schema: schema,
    formatVersion: formatVersion,
    fileCount: fileCount,
    totalUncompressedSize: db.length + prefs.length,
    appVersion: appVersion,
    checksums: {
      'database.sqlite': sha256.convert(db).toString(),
      'preferences.json': sha256.convert(prefs).toString(),
    },
  );
  return buildZip({
    'manifest.json':
        Uint8List.fromList(utf8.encode(jsonEncode(manifest))),
    'database.sqlite': db,
    'preferences.json': prefs,
  });
}

/// Writes [bytes] to a fresh temp file inside a temp directory. The directory
/// is cleaned up by the returned [Directory.cleanup].
({File file, Directory dir}) writeTempFile(String name, List<int> bytes) {
  final dir = Directory.systemTemp.createTempSync('rehabtest_file_');
  final file = File(p.join(dir.path, name));
  file.writeAsBytesSync(bytes);
  return (file: file, dir: dir);
}
