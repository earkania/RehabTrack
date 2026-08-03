import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/data/repositories/care_contact_repository_impl.dart';
import 'package:rehab_track/domain/entities/care_contact.dart';
import 'package:rehab_track/domain/enums/enums.dart';

void main() {
  late db.AppDatabase database;
  late CareContactRepositoryImpl repository;

  setUp(() {
    database = db.AppDatabase.test();
    repository = CareContactRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<int> insertProfile({String firstName = 'John', String lastName = 'Doe'}) {
    return database.into(database.profiles).insert(
      db.ProfilesCompanion.insert(
        firstName: firstName,
        lastName: lastName,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        isPrimary: const Value(true),
        isActive: const Value(true),
      ),
    );
  }

  CareContact makeContact({
    int profileId = 1,
    CareContactType type = CareContactType.doctor,
    String displayName = 'Dr. Smith',
    String? firstName = 'John',
    String? lastName = 'Smith',
    String? policyNumber,
    String? memberNumber,
  }) {
    final now = DateTime(2026);
    return CareContact(
      profileId: profileId,
      contactType: type,
      displayName: displayName,
      firstName: firstName,
      lastName: lastName,
      policyNumber: policyNumber,
      memberNumber: memberNumber,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('CareContactRepositoryImpl - createContact', () {
    test('persists contact and returns id', () async {
      final profileId = await insertProfile();
      final id = await repository.createContact(
        makeContact(profileId: profileId),
      );

      expect(id, greaterThan(0));

      final saved = await repository.getContactById(profileId, id);
      expect(saved, isNotNull);
      expect(saved!.displayName, 'Dr. Smith');
      expect(saved.contactType, CareContactType.doctor);
      expect(saved.firstName, 'John');
      expect(saved.lastName, 'Smith');
    });

    test('persists insurance sensitive fields', () async {
      final profileId = await insertProfile();
      final id = await repository.createContact(
        makeContact(
          profileId: profileId,
          type: CareContactType.insurance,
          displayName: 'Geo Insurance',
          policyNumber: 'POL-123',
          memberNumber: 'MEM-456',
        ),
      );

      final saved = await repository.getContactById(profileId, id);
      expect(saved!.policyNumber, 'POL-123');
      expect(saved.memberNumber, 'MEM-456');
    });

    test('defaults favorite and archived to false', () async {
      final profileId = await insertProfile();
      final id = await repository.createContact(
        makeContact(profileId: profileId),
      );

      final saved = await repository.getContactById(profileId, id);
      expect(saved!.isFavorite, isFalse);
      expect(saved.isArchived, isFalse);
    });
  });

  group('CareContactRepositoryImpl - watchActiveContacts', () {
    test('emits only active contacts ordered favorites-first', () async {
      final profileId = await insertProfile();

      final idA = await repository.createContact(
        makeContact(
          profileId: profileId,
          displayName: 'Dr. Beta',
        ).copyWith(isFavorite: true),
      );
      final idB = await repository.createContact(
        makeContact(
          profileId: profileId,
          displayName: 'Dr. Alpha',
        ),
      );
      final idC = await repository.createContact(
        makeContact(
          profileId: profileId,
          displayName: 'Archived One',
        ).copyWith(isArchived: true),
      );

      final stream = repository.watchActiveContacts(profileId);
      final contacts = await stream.first;

      expect(contacts.map((c) => c.id), [idA, idB]);
      expect(contacts.map((c) => c.id), isNot(contains(idC)));
      expect(contacts.first.isFavorite, isTrue);
    });

    test('does not emit contacts of another profile', () async {
      final profileA = await insertProfile(firstName: 'Alice');
      final profileB = await insertProfile(firstName: 'Bob');

      await repository.createContact(makeContact(profileId: profileA));

      final contactsB = await repository.watchActiveContacts(profileB).first;
      expect(contactsB, isEmpty);
    });

    test('sorts by effective display name when displayName is empty',
        () async {
      final profileId = await insertProfile();

      // Empty display_name: effective name derives from first/last name.
      final idGamma = await repository.createContact(
        makeContact(
          profileId: profileId,
          displayName: '',
          firstName: 'Gamma',
          lastName: 'Doc',
        ),
      );
      final idAlpha = await repository.createContact(
        makeContact(
          profileId: profileId,
          displayName: '',
          firstName: 'Alpha',
          lastName: 'Doc',
        ),
      );
      final idExplicit = await repository.createContact(
        makeContact(
          profileId: profileId,
          displayName: 'Beta Clinic',
          type: CareContactType.clinic,
        ).copyWith(organizationName: 'Beta Clinic'),
      );

      final stream = repository.watchActiveContacts(profileId);
      final contacts = await stream.first;

      expect(
        contacts.map((c) => c.effectiveDisplayName),
        ['Alpha Doc', 'Beta Clinic', 'Gamma Doc'],
      );
      expect(contacts.map((c) => c.id), [idAlpha, idExplicit, idGamma]);
    });
  });

  group('CareContactRepositoryImpl - watchArchivedContacts', () {
    test('emits only archived contacts', () async {
      final profileId = await insertProfile();
      final idA = await repository.createContact(
        makeContact(
          profileId: profileId,
          displayName: 'Archived',
        ).copyWith(isArchived: true),
      );
      await repository.createContact(
        makeContact(profileId: profileId, displayName: 'Active'),
      );

      final archived = await repository.watchArchivedContacts(profileId).first;
      expect(archived.map((c) => c.id), [idA]);
    });
  });

  group('CareContactRepositoryImpl - watchAllContacts', () {
    test('emits active and archived contacts', () async {
      final profileId = await insertProfile();
      await repository.createContact(makeContact(profileId: profileId));
      await repository.createContact(
        makeContact(profileId: profileId).copyWith(isArchived: true),
      );

      final all = await repository.watchAllContacts(profileId).first;
      expect(all, hasLength(2));
    });
  });

  group('CareContactRepositoryImpl - watchContactById', () {
    test('emits null for a contact of another profile', () async {
      final profileA = await insertProfile(firstName: 'Alice');
      final profileB = await insertProfile(firstName: 'Bob');
      final id = await repository.createContact(
        makeContact(profileId: profileA),
      );

      final forB = await repository.watchContactById(profileB, id).first;
      expect(forB, isNull);
    });

    test('emits null for nonexistent id', () async {
      final profileId = await insertProfile();
      final result = await repository.watchContactById(profileId, 999).first;
      expect(result, isNull);
    });

    test('emits updates after favorite toggle', () async {
      final profileId = await insertProfile();
      final id = await repository.createContact(
        makeContact(profileId: profileId),
      );

      final stream = repository.watchContactById(profileId, id);
      final first = await stream.first;
      expect(first!.isFavorite, isFalse);

      await repository.setFavorite(profileId, id, true);

      final updated = await stream
          .where((c) => c != null && c.isFavorite)
          .first
          .timeout(const Duration(seconds: 3));
      expect(updated!.isFavorite, isTrue);
    });
  });

  group('CareContactRepositoryImpl - updateContact', () {
    test('updates fields and preserves id', () async {
      final profileId = await insertProfile();
      final id = await repository.createContact(
        makeContact(profileId: profileId),
      );

      final saved = await repository.getContactById(profileId, id);
      await repository.updateContact(
        saved!.copyWith(specialty: 'Cardiology', displayName: 'Dr. John Smith'),
      );

      final updated = await repository.getContactById(profileId, id);
      expect(updated!.specialty, 'Cardiology');
      expect(updated.displayName, 'Dr. John Smith');
      expect(updated.id, id);
    });

    test('updates only scoped to profile', () async {
      final profileA = await insertProfile(firstName: 'Alice');
      final profileB = await insertProfile(firstName: 'Bob');
      final id = await repository.createContact(
        makeContact(profileId: profileA),
      );

      final saved = await repository.getContactById(profileA, id);
      await repository.updateContact(
        saved!.copyWith(profileId: profileB),
      );

      // Moved to profileB, no longer visible under profileA.
      final inA = await repository.getContactById(profileA, id);
      final inB = await repository.getContactById(profileB, id);
      expect(inA, isNull);
      expect(inB, isNotNull);
    });
  });

  group('CareContactRepositoryImpl - archive/restore', () {
    test('archive moves contact to archived watch', () async {
      final profileId = await insertProfile();
      final id = await repository.createContact(
        makeContact(profileId: profileId),
      );

      await repository.archiveContact(profileId, id);

      final active = await repository.watchActiveContacts(profileId).first;
      final archived = await repository.watchArchivedContacts(profileId).first;
      expect(active, isEmpty);
      expect(archived.map((c) => c.id), [id]);
    });

    test('restore moves contact back to active watch', () async {
      final profileId = await insertProfile();
      final id = await repository.createContact(
        makeContact(profileId: profileId).copyWith(isArchived: true),
      );

      await repository.restoreContact(profileId, id);

      final active = await repository.watchActiveContacts(profileId).first;
      final archived = await repository.watchArchivedContacts(profileId).first;
      expect(active.map((c) => c.id), [id]);
      expect(archived, isEmpty);
    });
  });

  group('CareContactRepositoryImpl - setFavorite', () {
    test('toggles favorite flag', () async {
      final profileId = await insertProfile();
      final id = await repository.createContact(
        makeContact(profileId: profileId),
      );

      await repository.setFavorite(profileId, id, true);
      var saved = await repository.getContactById(profileId, id);
      expect(saved!.isFavorite, isTrue);

      await repository.setFavorite(profileId, id, false);
      saved = await repository.getContactById(profileId, id);
      expect(saved!.isFavorite, isFalse);
    });
  });

  group('CareContactRepositoryImpl - deleteContact', () {
    test('permanently removes the contact', () async {
      final profileId = await insertProfile();
      final id = await repository.createContact(
        makeContact(profileId: profileId),
      );

      await repository.deleteContact(profileId, id);

      final all = await repository.watchAllContacts(profileId).first;
      expect(all, isEmpty);
      final saved = await repository.getContactById(profileId, id);
      expect(saved, isNull);
    });
  });
}
