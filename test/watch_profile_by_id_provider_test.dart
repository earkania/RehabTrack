import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/profile.dart';
import 'package:rehab_track/domain/repositories/profile_repository.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';

class FakeProfileRepository implements ProfileRepository {
  final Map<int, Profile> _profiles = {};
  int _nextId = 1;

  void addProfile(Profile profile) {
    final id = profile.id ?? _nextId++;
    _profiles[id] = profile.copyWith(id: id);
  }

  @override
  Stream<Profile?> watchActiveProfile(int profileId) {
    return Stream.value(_profiles[profileId]);
  }

  @override
  Future<Profile?> getActiveProfile(int profileId) async =>
      _profiles[profileId];

  @override
  Future<int> createProfile(Profile profile) async {
    final id = _nextId++;
    _profiles[id] = profile.copyWith(id: id);
    return id;
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    if (profile.id != null) _profiles[profile.id!] = profile;
  }

  @override
  Future<void> deleteProfile(int id) async {
    _profiles.remove(id);
  }

  @override
  Stream<List<Profile>> watchAllProfiles() async* {
    yield _profiles.values.toList();
  }

  @override
  Future<List<Profile>> getAllProfiles() async =>
      _profiles.values.toList();

  @override
  Future<void> setPrimaryProfile(int profileId) async {}

  @override
  Future<int> getProfileCount() async => _profiles.length;
}

void main() {
  late FakeProfileRepository fakeRepo;
  late ProviderContainer container;

  setUp(() {
    fakeRepo = FakeProfileRepository();
    container = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
  });

  tearDown(() async {
    await Future<void>.delayed(Duration(milliseconds: 50));
    container.dispose();
  });

  Profile makeProfile(int id, {String firstName = 'John', String lastName = 'Doe'}) {
    return Profile(
      id: id,
      firstName: firstName,
      lastName: lastName,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      isPrimary: true,
      isActive: true,
    );
  }

  group('watchProfileByIdProvider', () {
    test('resolves to profile when it exists', () async {
      fakeRepo.addProfile(makeProfile(1, firstName: 'Alice'));

      final sub = container.listen(watchProfileByIdProvider(1), (_, _) {});
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final result = container.read(watchProfileByIdProvider(1));
      expect(result, isA<AsyncData<Profile?>>());
      expect(result.valueOrNull?.firstName, 'Alice');
      sub.close();
    });

    test('resolves to null when profile does not exist', () async {
      final sub = container.listen(watchProfileByIdProvider(999), (_, _) {});
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final result = container.read(watchProfileByIdProvider(999));
      expect(result, isA<AsyncData<Profile?>>());
      expect(result.valueOrNull, null);
      sub.close();
    });

    test('empty profile fields are still a valid data state', () async {
      fakeRepo.addProfile(makeProfile(1, firstName: '', lastName: ''));

      final sub = container.listen(watchProfileByIdProvider(1), (_, _) {});
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final result = container.read(watchProfileByIdProvider(1));
      expect(result, isA<AsyncData<Profile?>>());
      expect(result.valueOrNull, isNotNull);
      expect(result.valueOrNull!.firstName, '');
      expect(result.valueOrNull!.lastName, '');
      sub.close();
    });

    test('does not remain in loading state', () async {
      fakeRepo.addProfile(makeProfile(1));

      final sub = container.listen(watchProfileByIdProvider(1), (_, _) {});
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final result = container.read(watchProfileByIdProvider(1));
      expect(result.hasValue, true);
      expect(result.isLoading, false);
      sub.close();
    });

    test('multiple IDs resolve independently', () async {
      fakeRepo.addProfile(makeProfile(1, firstName: 'Alice'));
      fakeRepo.addProfile(makeProfile(2, firstName: 'Bob'));

      final sub1 = container.listen(watchProfileByIdProvider(1), (_, _) {});
      final sub2 = container.listen(watchProfileByIdProvider(2), (_, _) {});
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final result1 = container.read(watchProfileByIdProvider(1));
      final result2 = container.read(watchProfileByIdProvider(2));

      expect(result1.valueOrNull?.firstName, 'Alice');
      expect(result2.valueOrNull?.firstName, 'Bob');
      sub1.close();
      sub2.close();
    });
  });
}
