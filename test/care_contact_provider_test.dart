import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/care_contact.dart';
import 'package:rehab_track/domain/enums/enums.dart';
import 'package:rehab_track/domain/repositories/care_contact_repository.dart';
import 'package:rehab_track/presentation/providers/care_contact_provider.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';

class FakeCareContactRepository implements CareContactRepository {
  final List<CareContact> _contacts = [];

  void add(CareContact contact) {
    _contacts.add(contact);
  }

  void clear() {
    _contacts.clear();
  }

  @override
  Stream<List<CareContact>> watchActiveContacts(int profileId) async* {
    yield _contacts
        .where((c) => c.profileId == profileId && !c.isArchived)
        .toList();
  }

  @override
  Stream<List<CareContact>> watchArchivedContacts(int profileId) async* {
    yield _contacts
        .where((c) => c.profileId == profileId && c.isArchived)
        .toList();
  }

  @override
  Stream<List<CareContact>> watchAllContacts(int profileId) async* {
    yield _contacts.where((c) => c.profileId == profileId).toList();
  }

  @override
  Stream<CareContact?> watchContactById(int profileId, int contactId) async* {
    final matches =
        _contacts.where((c) => c.profileId == profileId && c.id == contactId);
    yield matches.isEmpty ? null : matches.first;
  }

  @override
  Future<CareContact?> getContactById(int profileId, int contactId) async {
    final matches =
        _contacts.where((c) => c.profileId == profileId && c.id == contactId);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<int> createContact(CareContact contact) async {
    _contacts.add(contact);
    return _contacts.length;
  }

  @override
  Future<void> updateContact(CareContact contact) async {}

  @override
  Future<void> archiveContact(int profileId, int contactId) async {}

  @override
  Future<void> restoreContact(int profileId, int contactId) async {}

  @override
  Future<void> deleteContact(int profileId, int contactId) async {}

  @override
  Future<void> setFavorite(int profileId, int contactId, bool favorite) async {}
}

void main() {
  late FakeCareContactRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = FakeCareContactRepository();
    container = ProviderContainer(
      overrides: [
        careContactRepositoryProvider.overrideWithValue(repo),
        currentActiveProfileIdProvider.overrideWith((ref) => 7),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  CareContact makeContact({
    int id = 1,
    int profileId = 7,
    CareContactType type = CareContactType.doctor,
    String displayName = 'Dr. Smith',
    bool isFavorite = false,
    bool isArchived = false,
  }) {
    final now = DateTime(2026);
    return CareContact(
      id: id,
      profileId: profileId,
      contactType: type,
      displayName: displayName,
      createdAt: now,
      updatedAt: now,
      isFavorite: isFavorite,
      isArchived: isArchived,
    );
  }

  group('careContactsProvider', () {
    test('emits empty when no active profile id', () async {
      final local = ProviderContainer(
        overrides: [
          careContactRepositoryProvider.overrideWithValue(repo),
          currentActiveProfileIdProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(local.dispose);
      final value = await local.read(careContactsProvider.future);
      expect(value, isEmpty);
    });

    test('emits active contacts for the active profile', () async {
      repo.add(makeContact(id: 1, displayName: 'Dr. A'));
      repo.add(makeContact(id: 2, displayName: 'Dr. B', isArchived: true));

      final value = await container.read(careContactsProvider.future);
      expect(value.map((c) => c.id), [1]);
    });
  });

  group('archivedCareContactsProvider', () {
    test('emits archived contacts only', () async {
      repo.add(makeContact(id: 1, displayName: 'Dr. A'));
      repo.add(makeContact(id: 2, displayName: 'Dr. B', isArchived: true));

      final value = await container.read(archivedCareContactsProvider.future);
      expect(value.map((c) => c.id), [2]);
    });
  });

  group('careContactByIdProvider', () {
    test('emits the matching contact', () async {
      repo.add(makeContact(id: 5, displayName: 'Dr. Five'));

      final value = await container.read(careContactByIdProvider(5).future);
      expect(value, isNotNull);
      expect(value!.displayName, 'Dr. Five');
    });

    test('emits null for a contact of another profile', () async {
      repo.add(makeContact(id: 5, profileId: 99));

      final value = await container.read(careContactByIdProvider(5).future);
      expect(value, isNull);
    });

    test('emits null for unknown id', () async {
      final value = await container.read(careContactByIdProvider(123).future);
      expect(value, isNull);
    });
  });

  group('careContactSearchQueryProvider', () {
    test('defaults to empty and can be updated', () {
      expect(container.read(careContactSearchQueryProvider), '');
      container.read(careContactSearchQueryProvider.notifier).state = 'smith';
      expect(container.read(careContactSearchQueryProvider), 'smith');
    });
  });

  group('filteredCareContactsProvider', () {
    setUp(() {
      repo.add(makeContact(
        id: 1,
        type: CareContactType.doctor,
        displayName: 'Dr. Alice',
        isFavorite: true,
      ));
      repo.add(makeContact(
        id: 2,
        type: CareContactType.doctor,
        displayName: 'Dr. Bob',
      ));
      repo.add(makeContact(
        id: 3,
        type: CareContactType.clinic,
        displayName: 'City Clinic',
      ));
      repo.add(makeContact(
        id: 4,
        type: CareContactType.insurance,
        displayName: 'Geo Insurance',
      ));
      repo.add(makeContact(
        id: 5,
        type: CareContactType.pharmacy,
        displayName: 'Apotheka',
      ));
    });

    test('returns all contacts by default', () async {
      await container.read(careContactsProvider.future);
      final value = container.read(filteredCareContactsProvider);
      expect(value, hasLength(5));
    });

    test('filters by doctors', () async {
      await container.read(careContactsProvider.future);
      container.read(careContactFilterProvider.notifier).state =
          CareContactFilter.doctors;
      final value = container.read(filteredCareContactsProvider);
      expect(value.map((c) => c.id), [1, 2]);
    });

    test('filters by organizations', () async {
      await container.read(careContactsProvider.future);
      container.read(careContactFilterProvider.notifier).state =
          CareContactFilter.organizations;
      final value = container.read(filteredCareContactsProvider);
      expect(value.map((c) => c.id), [3, 4, 5]);
    });

    test('filters by insurance', () async {
      await container.read(careContactsProvider.future);
      container.read(careContactFilterProvider.notifier).state =
          CareContactFilter.insurance;
      final value = container.read(filteredCareContactsProvider);
      expect(value.map((c) => c.id), [4]);
    });

    test('filters by favorites', () async {
      await container.read(careContactsProvider.future);
      container.read(careContactFilterProvider.notifier).state =
          CareContactFilter.favorites;
      final value = container.read(filteredCareContactsProvider);
      expect(value.map((c) => c.id), [1]);
    });

    test('search matches display name case-insensitively', () async {
      await container.read(careContactsProvider.future);
      container.read(careContactSearchQueryProvider.notifier).state = 'alice';
      final value = container.read(filteredCareContactsProvider);
      expect(value.map((c) => c.id), [1]);
    });

    test('search matches effective name when display name is empty',
        () async {
      final now = DateTime(2026);
      repo.add(CareContact(
        id: 8,
        profileId: 7,
        contactType: CareContactType.doctor,
        displayName: '',
        firstName: 'Marie',
        lastName: 'Curie',
        createdAt: now,
        updatedAt: now,
      ));
      await container.read(careContactsProvider.future);

      container.read(careContactSearchQueryProvider.notifier).state = 'curie';
      final value = container.read(filteredCareContactsProvider);
      expect(value.map((c) => c.id), [8]);
    });

    test('search matches specialty and phone', () async {
      final now = DateTime(2026);
      repo.add(CareContact(
        id: 6,
        profileId: 7,
        contactType: CareContactType.doctor,
        displayName: 'Dr. X',
        specialty: 'Cardiology',
        primaryPhone: '555-0100',
        createdAt: now,
        updatedAt: now,
      ));
      await container.read(careContactsProvider.future);

      container.read(careContactSearchQueryProvider.notifier).state = 'cardio';
      expect(container.read(filteredCareContactsProvider).map((c) => c.id), [6]);

      container.read(careContactSearchQueryProvider.notifier).state = '0100';
      expect(container.read(filteredCareContactsProvider).map((c) => c.id), [6]);
    });

    test('combined filter and search', () async {
      await container.read(careContactsProvider.future);
      container.read(careContactFilterProvider.notifier).state =
          CareContactFilter.doctors;
      container.read(careContactSearchQueryProvider.notifier).state = 'bob';
      final value = container.read(filteredCareContactsProvider);
      expect(value.map((c) => c.id), [2]);
    });

    test('does not search sensitive insurance fields', () async {
      final now = DateTime(2026);
      repo.add(CareContact(
        id: 7,
        profileId: 7,
        contactType: CareContactType.insurance,
        displayName: 'Ins Co',
        policyNumber: 'POL-SECRET',
        memberNumber: 'MEM-SECRET',
        createdAt: now,
        updatedAt: now,
      ));
      await container.read(careContactsProvider.future);

      container.read(careContactSearchQueryProvider.notifier).state = 'secret';
      final value = container.read(filteredCareContactsProvider);
      expect(value, isEmpty);
    });
  });

  group('filteredArchivedCareContactsProvider', () {
    test('applies search but not type filters', () async {
      repo.add(makeContact(
        id: 1,
        displayName: 'Dr. Old',
        isArchived: true,
      ));
      repo.add(makeContact(
        id: 2,
        type: CareContactType.clinic,
        displayName: 'Old Clinic',
        isArchived: true,
      ));
      repo.add(makeContact(
        id: 3,
        displayName: 'Dr. Old',
      ));

      await container.read(archivedCareContactsProvider.future);
      final value = container.read(filteredArchivedCareContactsProvider);
      expect(value.map((c) => c.id), [1, 2]);
    });

    test('search narrows archived list', () async {
      repo.add(makeContact(id: 1, displayName: 'Dr. Old', isArchived: true));
      repo.add(makeContact(
        id: 2,
        displayName: 'Old Clinic',
        isArchived: true,
      ));

      await container.read(archivedCareContactsProvider.future);
      container.read(careContactSearchQueryProvider.notifier).state = 'clinic';
      final value = container.read(filteredArchivedCareContactsProvider);
      expect(value.map((c) => c.id), [2]);
    });
  });

  group('isCareContactFilterActive', () {
    test('is false when no query and all filter', () {
      expect(
        isCareContactFilterActive(
          query: '',
          filter: CareContactFilter.all,
        ),
        isFalse,
      );
    });

    test('is true when query present', () {
      expect(
        isCareContactFilterActive(
          query: '  ',
          filter: CareContactFilter.all,
        ),
        isFalse,
      );
      expect(
        isCareContactFilterActive(
          query: 'abc',
          filter: CareContactFilter.all,
        ),
        isTrue,
      );
    });

    test('is true when filter is not all', () {
      expect(
        isCareContactFilterActive(
          query: '',
          filter: CareContactFilter.doctors,
        ),
        isTrue,
      );
    });
  });
}
