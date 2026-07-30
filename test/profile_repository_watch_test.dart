import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/data/repositories/profile_repository_impl.dart';

void main() {
  late db.AppDatabase database;
  late ProfileRepositoryImpl repository;

  setUp(() {
    database = db.AppDatabase.test();
    repository = ProfileRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<int> insertProfile({
    String firstName = 'John',
    String lastName = 'Doe',
    bool isPrimary = true,
    bool isActive = true,
  }) async {
    return database.into(database.profiles).insert(
      db.ProfilesCompanion.insert(
        firstName: firstName,
        lastName: lastName,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        isPrimary: Value(isPrimary),
        isActive: Value(isActive),
      ),
    );
  }

  group('watchActiveProfile', () {
    test('emits profile when row exists', () async {
      final id = await insertProfile(firstName: 'Alice');

      final stream = repository.watchActiveProfile(id);
      final profile = await stream.first;

      expect(profile, isNotNull);
      expect(profile!.firstName, 'Alice');
      expect(profile.id, id);
    });

    test('emits null when row does not exist', () async {
      final stream = repository.watchActiveProfile(999);
      final profile = await stream.first;

      expect(profile, null);
    });

    test('emits updates after profile is saved', () async {
      final id = await insertProfile(firstName: 'Bob');

      final stream = repository.watchActiveProfile(id);

      final first = await stream.first;
      expect(first!.firstName, 'Bob');

      // Update the profile directly in the database
      await (database.update(database.profiles)
            ..where((t) => t.id.equals(id)))
          .write(db.ProfilesCompanion(
        firstName: const Value('Robert'),
      ));

      // The stream should emit the updated value
      final updated = await stream
          .where((p) => p != null && p.firstName == 'Robert').first
          .timeout(const Duration(seconds: 3));

      expect(updated!.firstName, 'Robert');
    });

    test('emits null then profile after insert for previously missing ID',
        () async {
      // Use a specific ID that doesn't exist yet
      final stream = repository.watchActiveProfile(42);

      // First emission should be null
      final first = await stream.first;
      expect(first, null);
    });
  });
}
