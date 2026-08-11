import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/data/services/backup/backup_management_service.dart';
import 'package:rehab_track/data/services/backup/backup_registry.dart';
import 'package:rehab_track/data/services/backup/backup_storage_gateway.dart';
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

class FakeStorageGateway extends BackupStorageGateway {
  final Map<String, BackupDocumentMetadata> queryResults;
  final Map<String, bool> deleteResults;
  final List<String> deleted = [];
  final List<String> shared = [];

  FakeStorageGateway({
    this.queryResults = const {},
    this.deleteResults = const {},
  });

  @override
  Future<BackupDocumentMetadata> queryDocument({
    required String contentUri,
  }) async {
    return queryResults[contentUri] ??
        const BackupDocumentMetadata(probed: true, accessible: true);
  }

  @override
  Future<bool> deleteDocument({required String contentUri}) async {
    deleted.add(contentUri);
    return deleteResults[contentUri] ?? true;
  }

  @override
  Future<void> shareDocument({
    required String contentUri,
    String? displayName,
  }) async {
    shared.add(contentUri);
  }
}

RegisteredBackup backup(String uri) => RegisteredBackup(contentUri: uri);

void main() {
  test('list returns registry entries in display order', () async {
    final registry = BackupRegistry(FakeSettingsRepository());
    await registry.add(backup('content://doc/2'));
    await registry.add(backup('content://doc/1'));

    final service = BackupManagementService(registry, FakeStorageGateway());
    final all = await service.list();
    expect(all.map((b) => b.contentUri).toList(), ['content://doc/2', 'content://doc/1']);
  });

  test('refresh marks a missing document as unavailable', () async {
    final registry = BackupRegistry(FakeSettingsRepository());
    await registry.add(backup('content://doc/1'));
    final gateway = FakeStorageGateway(
      queryResults: {
        'content://doc/1': const BackupDocumentMetadata(
          probed: true,
          accessible: false,
        ),
      },
    );
    final service = BackupManagementService(registry, gateway);

    final refreshed = await service.refresh(
      (await registry.all()).single,
    );

    expect(refreshed.available, isFalse);
    expect((await registry.all()).single.available, isFalse);
  });

  test('refresh keeps an accessible document available', () async {
    final registry = BackupRegistry(FakeSettingsRepository());
    await registry.add(backup('content://doc/1'));
    final gateway = FakeStorageGateway(
      queryResults: {
        'content://doc/1': const BackupDocumentMetadata(
          probed: true,
          accessible: true,
        ),
      },
    );
    final service = BackupManagementService(registry, gateway);

    final refreshed = await service.refresh(
      (await registry.all()).single,
    );

    expect(refreshed.available, isTrue);
  });

  test('refreshAll probes every entry', () async {
    final registry = BackupRegistry(FakeSettingsRepository());
    await registry.add(backup('content://doc/1'));
    await registry.add(backup('content://doc/2'));
    final gateway = FakeStorageGateway(
      queryResults: {
        'content://doc/1': const BackupDocumentMetadata(
          probed: true,
          accessible: false,
        ),
      },
    );
    final service = BackupManagementService(registry, gateway);

    final all = await service.refreshAll();

    expect(all, hasLength(2));
    expect(all.firstWhere((b) => b.contentUri == 'content://doc/1').available,
        isFalse);
    expect(all.firstWhere((b) => b.contentUri == 'content://doc/2').available,
        isTrue);
  });

  test('refresh handles a throwing gateway gracefully', () async {
    final registry = BackupRegistry(FakeSettingsRepository());
    await registry.add(backup('content://doc/1'));
    final gateway = _ThrowingGateway();
    final service = BackupManagementService(registry, gateway);

    final all = await service.refreshAll();

    expect(all.single.available, isFalse);
  });

  test('share forwards the content URI to the gateway', () async {
    final registry = BackupRegistry(FakeSettingsRepository());
    await registry.add(backup('content://doc/1'));
    final gateway = FakeStorageGateway();
    final service = BackupManagementService(registry, gateway);

    await service.share((await registry.all()).single);

    expect(gateway.shared, ['content://doc/1']);
  });

  test('delete removes the document and the registry entry', () async {
    final registry = BackupRegistry(FakeSettingsRepository());
    await registry.add(backup('content://doc/1'));
    final gateway = FakeStorageGateway(deleteResults: {'content://doc/1': true});
    final service = BackupManagementService(registry, gateway);

    final outcome = await service.delete((await registry.all()).single);

    expect(outcome, BackupDeleteOutcome.deleted);
    expect(gateway.deleted, ['content://doc/1']);
    expect(await registry.all(), isEmpty);
  });

  test('delete drops the registry entry even when the document is gone',
      () async {
    final registry = BackupRegistry(FakeSettingsRepository());
    await registry.add(backup('content://doc/1'));
    final gateway = FakeStorageGateway(
      deleteResults: {'content://doc/1': false},
    );
    final service = BackupManagementService(registry, gateway);

    final outcome = await service.delete((await registry.all()).single);

    expect(outcome, BackupDeleteOutcome.unresolved);
    expect(await registry.all(), isEmpty);
  });

  test('refresh updates the display name after an external rename while the '
      'URI stays valid', () async {
    final registry = BackupRegistry(FakeSettingsRepository());
    await registry.add(backup('content://doc/1'));
    final gateway = FakeStorageGateway(
      queryResults: {
        'content://doc/1': const BackupDocumentMetadata(
          probed: true,
          accessible: true,
          displayName: 'Renamed In Downloads.rtb',
        ),
      },
    );
    final service = BackupManagementService(registry, gateway);

    final refreshed = await service.refresh((await registry.all()).single);

    expect(refreshed.displayName, 'Renamed In Downloads.rtb');
    expect(refreshed.available, isTrue);
    expect((await registry.all()).single.displayName, 'Renamed In Downloads.rtb');
  });

  test('refresh persists the probe timestamp and availability state',
      () async {
    final registry = BackupRegistry(FakeSettingsRepository());
    await registry.add(backup('content://doc/1'));
    final service =
        BackupManagementService(registry, FakeStorageGateway());

    final refreshed = await service.refresh((await registry.all()).single);

    expect(refreshed.availability, BackupAvailability.available);
    expect(refreshed.lastCheckedAt, isNotNull);
    expect((await registry.all()).single.lastCheckedAt, isNotNull);
  });

  test('refreshAll leaves an unavailable entry visible (never auto-removed)',
      () async {
    final registry = BackupRegistry(FakeSettingsRepository());
    await registry.add(backup('content://doc/1'));
    final gateway = FakeStorageGateway(
      queryResults: {
        'content://doc/1': const BackupDocumentMetadata(
          probed: true,
          accessible: false,
        ),
      },
    );
    final service = BackupManagementService(registry, gateway);

    final all = await service.refreshAll();

    expect(all, hasLength(1));
    expect(all.single.availability, BackupAvailability.unavailable);
    expect((await registry.all()), hasLength(1));
  });

  test('removeFromList removes the registry entry only (no document delete)',
      () async {
    final registry = BackupRegistry(FakeSettingsRepository());
    await registry.add(backup('content://doc/1'));
    final gateway = FakeStorageGateway();
    final service = BackupManagementService(registry, gateway);

    await service.removeFromList('content://doc/1');

    expect(await registry.all(), isEmpty);
    expect(gateway.deleted, isEmpty);
  });

  test('delete marks the entry unavailable when registry cleanup fails '
      'instead of leaving it available', () async {
    final settings = _FailingSettings();
    final registry = BackupRegistry(settings);
    await registry.add(backup('content://doc/1'));
    final gateway = FakeStorageGateway(deleteResults: {'content://doc/1': true});
    final service = BackupManagementService(registry, gateway);

    final outcome = await service.delete((await registry.all()).single);

    expect(outcome, BackupDeleteOutcome.deleted);
    // The document was deleted; the failed registry removal was repaired by
    // persisting unavailable so the entry is never presented as available.
    final entries = await registry.all();
    expect(entries, hasLength(1));
    expect(entries.single.availability, BackupAvailability.unavailable);
  });
}

/// Persists normally, but the second write after construction throws so tests
/// can exercise registry-cleanup failures during delete.
class _FailingSettings extends FakeSettingsRepository {
  int _writes = 0;

  @override
  Future<void> setValue(String key, String value) async {
    _writes++;
    if (_writes == 2) {
      throw Exception('simulated persist failure');
    }
    store[key] = value;
  }
}

class _ThrowingGateway extends BackupStorageGateway {
  @override
  Future<BackupDocumentMetadata> queryDocument({
    required String contentUri,
  }) async {
    throw Exception('simulated native failure');
  }
}