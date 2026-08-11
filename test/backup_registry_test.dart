import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/data/services/backup/backup_registry.dart';
import 'package:rehab_track/domain/backup/backup_availability.dart';
import 'package:rehab_track/domain/backup/registered_backup.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';

class FakeSettingsRepository implements SettingsRepository {
  final Map<String, String> store = {};

  @override
  Future<String?> getValue(String key) async => store[key];

  @override
  Future<void> setValue(String key, String value) async {
    store[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    store.remove(key);
  }

  @override
  Stream<Map<String, String>> watchAll() async* {
    yield Map.from(store);
  }

  @override
  Future<Map<String, String>> getAll() async => Map.from(store);
}

RegisteredBackup backup({
  required String uri,
  String? name,
  DateTime? createdAt,
  int? size,
  BackupAvailability availability = BackupAvailability.available,
}) {
  return RegisteredBackup(
    contentUri: uri,
    displayName: name,
    createdAt: createdAt,
    fileSize: size,
    availability: availability,
  );
}

void main() {
  test('persists and reloads registered backups', () async {
    final settings = FakeSettingsRepository();
    final registry = BackupRegistry(settings);

    await registry.add(
      backup(
        uri: 'content://doc/1',
        name: 'Morning.rtb',
        createdAt: DateTime(2026, 8, 1, 9),
        size: 100,
      ),
    );

    final all = await registry.all();
    expect(all, hasLength(1));
    expect(all.first.contentUri, 'content://doc/1');
    expect(all.first.displayName, 'Morning.rtb');
    expect(all.first.fileSize, 100);
    expect(all.first.available, isTrue);
  });

  test('upserts on duplicate URI instead of duplicating', () async {
    final settings = FakeSettingsRepository();
    final registry = BackupRegistry(settings);

    await registry.add(backup(uri: 'content://doc/1', name: 'First.rtb'));
    await registry.add(backup(uri: 'content://doc/1', name: 'Second.rtb'));

    final all = await registry.all();
    expect(all, hasLength(1));
    expect(all.first.displayName, 'Second.rtb');
  });

  test('sorts newest-first by creation time', () async {
    final settings = FakeSettingsRepository();
    final registry = BackupRegistry(settings);

    await registry.add(
      backup(uri: 'content://doc/old', createdAt: DateTime(2026, 1, 1)),
    );
    await registry.add(
      backup(uri: 'content://doc/new', createdAt: DateTime(2026, 6, 1)),
    );
    await registry.add(backup(uri: 'content://doc/unknown'));

    final all = await registry.all();
    expect(all.map((b) => b.contentUri).toList(), [
      'content://doc/new',
      'content://doc/old',
      'content://doc/unknown',
    ]);
  });

  test('ignores corrupt payloads and returns an empty list', () async {
    final settings = FakeSettingsRepository();
    settings.store[backupRegistryStorageKey] = '{not json';

    expect(await BackupRegistry(settings).all(), isEmpty);
  });

  test('updates metadata, availability state and last-checked time', () async {
    final settings = FakeSettingsRepository();
    final registry = BackupRegistry(settings);

    await registry.add(backup(uri: 'content://doc/1'));
    await registry.applyProbe(
      'content://doc/1',
      availability: BackupAvailability.unavailable,
      checkedAt: DateTime(2026, 8, 1, 12),
    );

    final entry = (await registry.all()).single;
    expect(entry.availability, BackupAvailability.unavailable);
    expect(entry.available, isFalse);
    expect(entry.lastCheckedAt, DateTime(2026, 8, 1, 12));

    await registry.update(
      entry.copyWith(displayName: 'Renamed.rtb'),
    );
    expect((await registry.all()).single.displayName, 'Renamed.rtb');
  });

  test('persists availability as a stable non-localized value', () async {
    final settings = FakeSettingsRepository();
    final registry = BackupRegistry(settings);
    final checkedAt = DateTime(2026, 8, 1, 12);

    await registry.add(
      backup(uri: 'content://doc/1', availability: BackupAvailability.unavailable),
    );
    await registry.applyProbe(
      'content://doc/1',
      availability: BackupAvailability.unknown,
      checkedAt: checkedAt,
    );

    final raw = settings.store[backupRegistryStorageKey]!;
    expect(raw, contains('"availabilityState":"unknown"'));
    expect(raw, isNot(contains('"Unavailable"')));
    expect(raw, contains('"lastCheckedAt"'));
  });

  test('reads legacy boolean availability payloads', () async {
    final settings = FakeSettingsRepository();
    settings.store[backupRegistryStorageKey] =
        '[{"contentUri":"content://old","displayName":"Old.rtb","available":false}]';

    final entry = (await BackupRegistry(settings).all()).single;
    expect(entry.availability, BackupAvailability.unavailable);
    expect(entry.available, isFalse);
    expect(entry.lastCheckedAt, isNull);
  });

  test('new entries default to unknown availability until probed', () async {
    final settings = FakeSettingsRepository();
    final registry = BackupRegistry(settings);

    await registry.add(
      RegisteredBackup(contentUri: 'content://doc/1'),
    );

    expect((await registry.all()).single.availability,
        BackupAvailability.unknown);
    expect((await registry.all()).single.available, isFalse);
  });

  test('applyProbe is a no-op for unknown URIs', () async {
    final settings = FakeSettingsRepository();
    final registry = BackupRegistry(settings);

    await registry.applyProbe(
      'content://never',
      availability: BackupAvailability.unavailable,
    );

    expect(await registry.all(), isEmpty);
  });

  test('removes an entry by URI', () async {
    final settings = FakeSettingsRepository();
    final registry = BackupRegistry(settings);

    await registry.add(backup(uri: 'content://doc/1'));
    await registry.add(backup(uri: 'content://doc/2'));
    await registry.remove('content://doc/1');

    final all = await registry.all();
    expect(all.map((b) => b.contentUri).toList(), ['content://doc/2']);
  });

  test('rejects entries without a usable content URI when decoding',
      () async {
    final settings = FakeSettingsRepository();
    settings.store[backupRegistryStorageKey] = '[{"contentUri":""}]';

    expect(await BackupRegistry(settings).all(), isEmpty);
  });
}