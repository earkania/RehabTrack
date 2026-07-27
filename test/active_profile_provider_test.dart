import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/profile.dart';
import 'package:rehab_track/domain/repositories/profile_repository.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';

class FakeSettingsRepository implements SettingsRepository {
  final Map<String, String> _store = {};

  @override
  Future<String?> getValue(String key) async => _store[key];

  @override
  Future<void> setValue(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
  }

  @override
  Stream<Map<String, String>> watchAll() async* {
    yield _store;
  }

  @override
  Future<Map<String, String>> getAll() async => _store;
}

class FakeProfileRepository implements ProfileRepository {
  final List<Profile> _profiles = [];

  void addProfile(Profile profile) {
    _profiles.add(profile);
  }

  @override
  Stream<Profile?> watchActiveProfile(int profileId) {
    final match = _profiles.where((p) => p.id == profileId);
    return Stream.value(match.isNotEmpty ? match.first : null);
  }

  @override
  Future<Profile?> getActiveProfile(int profileId) async {
    final match = _profiles.where((p) => p.id == profileId);
    return match.isNotEmpty ? match.first : null;
  }

  @override
  Future<int> createProfile(Profile profile) async {
    _profiles.add(profile);
    return _profiles.length;
  }

  @override
  Future<void> updateProfile(Profile profile) async {}

  @override
  Future<void> deleteProfile(int id) async {}

  @override
  Stream<List<Profile>> watchAllProfiles() async* {
    yield _profiles;
  }

  @override
  Future<List<Profile>> getAllProfiles() async => _profiles;

  @override
  Future<void> setPrimaryProfile(int profileId) async {}

  @override
  Future<int> getProfileCount() async => _profiles.length;
}

void main() {
  late FakeSettingsRepository fakeSettings;
  late FakeProfileRepository fakeProfiles;
  late ProviderContainer container;

  setUp(() {
    fakeSettings = FakeSettingsRepository();
    fakeProfiles = FakeProfileRepository();
    container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(fakeSettings),
        profileRepositoryProvider.overrideWithValue(fakeProfiles),
      ],
    );
  });

  tearDown(() async {
    // Allow pending rebuilds to complete before disposing
    await Future<void>.delayed(Duration(milliseconds: 100));
    container.dispose();
  });

  Profile makeProfile(int id, {String name = 'John'}) {
    return Profile(
      id: id,
      firstName: name,
      lastName: 'Doe',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
  }

  group('ActiveProfileIdNotifier', () {
    test('creates default profile when no profiles and no setting', () async {
      final notifier = container.read(activeProfileIdProvider.notifier);
      await notifier.future;
      final value = container.read(activeProfileIdProvider);
      expect(value.valueOrNull, isNotNull);
      expect(fakeProfiles.getAllProfiles(), completion(isNotEmpty));
    });

    test('reads active profile id from settings', () async {
      fakeProfiles.addProfile(makeProfile(1));
      fakeProfiles.addProfile(makeProfile(2, name: 'Jane'));
      await fakeSettings.setValue('active_profile_id', '2');

      final notifier = container.read(activeProfileIdProvider.notifier);
      await notifier.future;
      final value = container.read(activeProfileIdProvider);
      expect(value.valueOrNull, 2);
    });

    test('defaults to first profile when no setting exists', () async {
      fakeProfiles.addProfile(makeProfile(5));

      final notifier = container.read(activeProfileIdProvider.notifier);
      await notifier.future;
      final value = container.read(activeProfileIdProvider);
      expect(value.valueOrNull, 5);
    });

    test('setActiveProfileId persists to settings and rebuilds', () async {
      fakeProfiles.addProfile(makeProfile(1));
      fakeProfiles.addProfile(makeProfile(2));

      final notifier = container.read(activeProfileIdProvider.notifier);
      await notifier.future;

      await notifier.setActiveProfileId(2);

      // Wait for the rebuild to complete
      await container.read(activeProfileIdProvider.notifier).future;

      final stored = await fakeSettings.getValue('active_profile_id');
      expect(stored, '2');

      final value = container.read(activeProfileIdProvider);
      expect(value.valueOrNull, 2);
    });
  });

  group('currentActiveProfileIdProvider', () {
    test('returns null when no active profile', () {
      final value = container.read(currentActiveProfileIdProvider);
      expect(value, null);
    });

    test('returns profile id when active profile is set', () async {
      fakeProfiles.addProfile(makeProfile(3));
      await fakeSettings.setValue('active_profile_id', '3');

      // Trigger the async notifier
      container.read(activeProfileIdProvider.notifier).future;

      // Wait for the provider to settle
      await Future<void>.delayed(Duration.zero);

      final value = container.read(currentActiveProfileIdProvider);
      expect(value, 3);
    });
  });
}
