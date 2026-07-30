import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;

void main() {
  late db.AppDatabase database;

  setUp(() {
    database = db.AppDatabase.test();
  });

  tearDown(() async {
    await database.close();
  });

  Future<int> insertTestProfile({
    String firstName = 'John',
    String lastName = 'Doe',
    bool isPrimary = false,
    bool isActive = true,
    String? phone,
    String? email,
    String? address,
    String? relationshipToOwner,
    String? photoPath,
  }) async {
    return database.into(database.profiles).insert(
      db.ProfilesCompanion.insert(
        firstName: firstName,
        lastName: lastName,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        isPrimary: Value(isPrimary),
        isActive: Value(isActive),
        phone: Value(phone),
        email: Value(email),
        address: Value(address),
        relationshipToOwner: Value(relationshipToOwner),
        photoPath: Value(photoPath),
      ),
    );
  }

  group('ProfileDao - new columns', () {
    test('inserts profile with all new fields', () async {
      final id = await insertTestProfile(
        phone: '555-1234',
        email: 'john@example.com',
        address: '123 Main St',
        relationshipToOwner: 'self',
        isPrimary: true,
        isActive: true,
        photoPath: '/path/to/photo.jpg',
      );

      final profile = await (database.select(database.profiles)
            ..where((t) => t.id.equals(id)))
          .getSingle();

      expect(profile.id, id);
      expect(profile.firstName, 'John');
      expect(profile.lastName, 'Doe');
      expect(profile.phone, '555-1234');
      expect(profile.email, 'john@example.com');
      expect(profile.address, '123 Main St');
      expect(profile.relationshipToOwner, 'self');
      expect(profile.isPrimary, true);
      expect(profile.isActive, true);
      expect(profile.photoPath, '/path/to/photo.jpg');
    });

    test('new columns default to expected values', () async {
      final id = await insertTestProfile();

      final profile = await (database.select(database.profiles)
            ..where((t) => t.id.equals(id)))
          .getSingle();

      expect(profile.phone, null);
      expect(profile.email, null);
      expect(profile.address, null);
      expect(profile.relationshipToOwner, null);
      expect(profile.isPrimary, false);
      expect(profile.isActive, true);
      expect(profile.photoPath, null);
    });
  });

  group('ProfileDao - watchAllProfiles', () {
    test('returns only active profiles', () async {
      final defaultCount =
          (await database.profileDao.getAllProfiles()).length;
      await insertTestProfile(firstName: 'Active', isActive: true);
      await insertTestProfile(firstName: 'Inactive', isActive: false);

      final profiles = await database.profileDao.getAllProfiles();
      expect(profiles, hasLength(defaultCount + 1));
      expect(profiles.any((p) => p.firstName == 'Active'), isTrue);
      expect(profiles.any((p) => p.firstName == 'Inactive'), isFalse);
    });

    test('orders by isPrimary desc then firstName asc', () async {
      await insertTestProfile(firstName: 'Charlie', isPrimary: false);
      await insertTestProfile(firstName: 'Alice', isPrimary: true);
      await insertTestProfile(firstName: 'Bob', isPrimary: false);

      final profiles = await database.profileDao.getAllProfiles();
      // Default profile (isPrimary: true, firstName: '') sorts first
      final primaryProfiles =
          profiles.where((p) => p.isPrimary).toList();
      final nonPrimaryProfiles =
          profiles.where((p) => !p.isPrimary).toList();

      expect(primaryProfiles, isNotEmpty);
      expect(
        nonPrimaryProfiles.map((p) => p.firstName).toList(),
        ['Bob', 'Charlie'],
      );
    });
  });

  group('ProfileDao - setPrimaryProfile', () {
    test('sets one profile as primary and clears others', () async {
      final id1 = await insertTestProfile(firstName: 'Alice', isPrimary: true);
      final id2 = await insertTestProfile(firstName: 'Bob', isPrimary: false);

      await database.profileDao.setPrimaryProfile(id2);

      final p1 = await (database.select(database.profiles)
            ..where((t) => t.id.equals(id1)))
          .getSingle();
      final p2 = await (database.select(database.profiles)
            ..where((t) => t.id.equals(id2)))
          .getSingle();

      expect(p1.isPrimary, false);
      expect(p2.isPrimary, true);
    });
  });

  group('ProfileDao - getProfileCount', () {
    test('returns at least 1 due to default profile', () async {
      final count = await database.profileDao.getProfileCount();
      expect(count, greaterThanOrEqualTo(1));
    });

    test('returns correct count', () async {
      final before = await database.profileDao.getProfileCount();
      await insertTestProfile(firstName: 'Alice');
      await insertTestProfile(firstName: 'Bob');
      await insertTestProfile(firstName: 'Charlie');

      final count = await database.profileDao.getProfileCount();
      expect(count, before + 3);
    });
  });

  group('ProfileDao - watchActiveProfile with profileId', () {
    test('returns correct profile by id', () async {
      await insertTestProfile(firstName: 'Alice');
      final id2 = await insertTestProfile(firstName: 'Bob');

      final stream = database.profileDao.watchActiveProfile(id2);
      final profile = await stream.first;

      expect(profile, isNotNull);
      expect(profile!.firstName, 'Bob');
    });

    test('returns null for nonexistent id', () async {
      final stream = database.profileDao.watchActiveProfile(999);
      final profile = await stream.first;

      expect(profile, null);
    });
  });
}
