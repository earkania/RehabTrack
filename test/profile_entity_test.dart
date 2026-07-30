import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/profile.dart';

void main() {
  group('Profile', () {
    group('constructor defaults', () {
      test('isPrimary defaults to false', () {
        final profile = Profile(
          firstName: 'John',
          lastName: 'Doe',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );
        expect(profile.isPrimary, false);
      });

      test('isActive defaults to true', () {
        final profile = Profile(
          firstName: 'John',
          lastName: 'Doe',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );
        expect(profile.isActive, true);
      });

      test('nullable fields default to null', () {
        final profile = Profile(
          firstName: 'John',
          lastName: 'Doe',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );
        expect(profile.phone, null);
        expect(profile.email, null);
        expect(profile.address, null);
        expect(profile.relationshipToOwner, null);
        expect(profile.photoPath, null);
        expect(profile.birthDate, null);
        expect(profile.gender, null);
        expect(profile.heightCm, null);
        expect(profile.weightKg, null);
        expect(profile.bloodType, null);
        expect(profile.allergies, null);
        expect(profile.emergencyContactName, null);
        expect(profile.emergencyContactPhone, null);
        expect(profile.notes, null);
      });
    });

    group('fullName', () {
      test('combines first and last name', () {
        final profile = Profile(
          firstName: 'John',
          lastName: 'Doe',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );
        expect(profile.fullName, 'John Doe');
      });

      test('handles single character names', () {
        final profile = Profile(
          firstName: 'A',
          lastName: 'B',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );
        expect(profile.fullName, 'A B');
      });
    });

    group('parsedRelationship', () {
      test('returns null when relationshipToOwner is null', () {
        final profile = Profile(
          firstName: 'John',
          lastName: 'Doe',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );
        expect(profile.parsedRelationship, null);
      });

      test('returns Relationship.self for "self"', () {
        final profile = Profile(
          firstName: 'John',
          lastName: 'Doe',
          relationshipToOwner: 'self',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );
        expect(profile.parsedRelationship, Relationship.self);
      });

      test('returns Relationship.child for "child"', () {
        final profile = Profile(
          firstName: 'John',
          lastName: 'Doe',
          relationshipToOwner: 'child',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );
        expect(profile.parsedRelationship, Relationship.child);
      });

      test('returns Relationship.spouse for "spouse"', () {
        final profile = Profile(
          firstName: 'John',
          lastName: 'Doe',
          relationshipToOwner: 'spouse',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );
        expect(profile.parsedRelationship, Relationship.spouse);
      });

      test('returns null for unrecognized string', () {
        final profile = Profile(
          firstName: 'John',
          lastName: 'Doe',
          relationshipToOwner: 'unknown',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );
        expect(profile.parsedRelationship, null);
      });
    });

    group('copyWith', () {
      test('preserves all fields when no arguments provided', () {
        final now = DateTime(2026);
        final profile = Profile(
          id: 1,
          firstName: 'John',
          lastName: 'Doe',
          birthDate: DateTime(1990, 6, 15),
          gender: 'male',
          heightCm: 180.0,
          weightKg: 75.0,
          bloodType: 'O+',
          allergies: 'Peanuts',
          emergencyContactName: 'Jane',
          emergencyContactPhone: '555-1234',
          notes: 'Test notes',
          createdAt: now,
          updatedAt: now,
          phone: '555-5678',
          email: 'john@example.com',
          address: '123 Main St',
          relationshipToOwner: 'self',
          isPrimary: true,
          isActive: false,
          photoPath: '/path/to/photo.jpg',
        );

        final copy = profile.copyWith();
        expect(copy.id, 1);
        expect(copy.firstName, 'John');
        expect(copy.lastName, 'Doe');
        expect(copy.birthDate, DateTime(1990, 6, 15));
        expect(copy.gender, 'male');
        expect(copy.heightCm, 180.0);
        expect(copy.weightKg, 75.0);
        expect(copy.bloodType, 'O+');
        expect(copy.allergies, 'Peanuts');
        expect(copy.emergencyContactName, 'Jane');
        expect(copy.emergencyContactPhone, '555-1234');
        expect(copy.notes, 'Test notes');
        expect(copy.createdAt, now);
        expect(copy.updatedAt, now);
        expect(copy.phone, '555-5678');
        expect(copy.email, 'john@example.com');
        expect(copy.address, '123 Main St');
        expect(copy.relationshipToOwner, 'self');
        expect(copy.isPrimary, true);
        expect(copy.isActive, false);
        expect(copy.photoPath, '/path/to/photo.jpg');
      });

      test('overrides specified fields', () {
        final profile = Profile(
          firstName: 'John',
          lastName: 'Doe',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );

        final copy = profile.copyWith(
          firstName: 'Jane',
          isPrimary: true,
          phone: '555-0000',
        );
        expect(copy.firstName, 'Jane');
        expect(copy.lastName, 'Doe');
        expect(copy.isPrimary, true);
        expect(copy.phone, '555-0000');
      });

      test('creates independent copy', () {
        final profile = Profile(
          firstName: 'John',
          lastName: 'Doe',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );

        final copy1 = profile.copyWith(firstName: 'Jane');
        final copy2 = profile.copyWith(firstName: 'Bob');

        expect(profile.firstName, 'John');
        expect(copy1.firstName, 'Jane');
        expect(copy2.firstName, 'Bob');
      });
    });
  });

  group('Gender enum', () {
    test('has all expected values', () {
      expect(Gender.values, hasLength(4));
      expect(Gender.values, contains(Gender.male));
      expect(Gender.values, contains(Gender.female));
      expect(Gender.values, contains(Gender.other));
      expect(Gender.values, contains(Gender.unspecified));
    });
  });

  group('Relationship enum', () {
    test('has all expected values', () {
      expect(Relationship.values, hasLength(8));
      expect(Relationship.values, contains(Relationship.self));
      expect(Relationship.values, contains(Relationship.child));
      expect(Relationship.values, contains(Relationship.spouse));
      expect(Relationship.values, contains(Relationship.parent));
      expect(Relationship.values, contains(Relationship.sibling));
      expect(Relationship.values, contains(Relationship.grandparent));
      expect(Relationship.values, contains(Relationship.grandchild));
      expect(Relationship.values, contains(Relationship.other));
    });
  });
}
