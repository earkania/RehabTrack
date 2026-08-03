import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/care_contact.dart';
import 'package:rehab_track/domain/enums/enums.dart';

void main() {
  CareContact makeContact({
    CareContactType type = CareContactType.doctor,
    String displayName = '',
    String? firstName,
    String? lastName,
    String? organizationName,
  }) {
    final now = DateTime(2026);
    return CareContact(
      profileId: 1,
      contactType: type,
      displayName: displayName,
      firstName: firstName,
      lastName: lastName,
      organizationName: organizationName,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('CareContactType enum', () {
    test('has all six stable values', () {
      expect(CareContactType.values, hasLength(6));
      expect(CareContactType.values, containsAll([
        CareContactType.doctor,
        CareContactType.clinic,
        CareContactType.laboratory,
        CareContactType.pharmacy,
        CareContactType.insurance,
        CareContactType.other,
      ]));
    });

    test('fromString round-trips every value', () {
      for (final type in CareContactType.values) {
        expect(CareContactType.fromString(type.name), type);
      }
    });

    test('fromString falls back to other for unknown values', () {
      expect(CareContactType.fromString('unknown'), CareContactType.other);
      expect(CareContactType.fromString(''), CareContactType.other);
    });

    test('isOrganization marks non-doctor types as organizations', () {
      expect(CareContactType.doctor.isOrganization, isFalse);
      expect(CareContactType.clinic.isOrganization, isTrue);
      expect(CareContactType.laboratory.isOrganization, isTrue);
      expect(CareContactType.pharmacy.isOrganization, isTrue);
      expect(CareContactType.insurance.isOrganization, isTrue);
      expect(CareContactType.other.isOrganization, isTrue);
    });
  });

  group('CareContact.fallbackName', () {
    test('doctor combines first and last name', () {
      final name = CareContact.fallbackName(
        contactType: CareContactType.doctor,
        firstName: 'John',
        lastName: 'Smith',
      );
      expect(name, 'John Smith');
    });

    test('doctor uses firstName alone when lastName missing', () {
      final name = CareContact.fallbackName(
        contactType: CareContactType.doctor,
        firstName: 'John',
      );
      expect(name, 'John');
    });

    test('doctor uses lastName alone when firstName missing', () {
      final name = CareContact.fallbackName(
        contactType: CareContactType.doctor,
        lastName: 'Smith',
      );
      expect(name, 'Smith');
    });

    test('organization uses organization name', () {
      final name = CareContact.fallbackName(
        contactType: CareContactType.clinic,
        organizationName: 'City Hospital',
      );
      expect(name, 'City Hospital');
    });

    test('returns empty when nothing provided', () {
      expect(
        CareContact.fallbackName(contactType: CareContactType.other),
        '',
      );
    });
  });

  group('CareContact.isExplicitDisplayName', () {
    test('true when display name differs from fallback', () {
      final contact = makeContact(
        type: CareContactType.doctor,
        displayName: 'Dr. Smith',
        firstName: 'John',
        lastName: 'Smith',
      );
      expect(contact.isExplicitDisplayName, isTrue);
    });

    test('false when display name equals the derivable fallback', () {
      final contact = makeContact(
        type: CareContactType.doctor,
        displayName: 'John Smith',
        firstName: 'John',
        lastName: 'Smith',
      );
      expect(contact.isExplicitDisplayName, isFalse);
    });

    test('false when display name is blank', () {
      final contact = makeContact(
        type: CareContactType.doctor,
        displayName: '   ',
        firstName: 'John',
      );
      expect(contact.isExplicitDisplayName, isFalse);
    });

    test('false for generated organization name', () {
      final contact = makeContact(
        type: CareContactType.clinic,
        displayName: 'City Hospital',
        organizationName: 'City Hospital',
      );
      expect(contact.isExplicitDisplayName, isFalse);
    });
  });

  group('CareContact.initials', () {
    test('doctor uses first and last name initials', () {
      final contact = makeContact(
        type: CareContactType.doctor,
        firstName: 'John',
        lastName: 'Smith',
      );
      expect(contact.initials, 'JS');
    });

    test('doctor with only first name uses single initial', () {
      final contact = makeContact(
        type: CareContactType.doctor,
        firstName: 'John',
      );
      expect(contact.initials, 'J');
    });

    test('organization uses two words', () {
      final contact = makeContact(
        type: CareContactType.clinic,
        organizationName: 'City Central Hospital',
      );
      expect(contact.initials, 'CC');
    });

    test('organization with single word uses first letter', () {
      final contact = makeContact(
        type: CareContactType.pharmacy,
        organizationName: 'Apotheka',
      );
      expect(contact.initials, 'A');
    });

    test('returns ? when no name available', () {
      final contact = makeContact(type: CareContactType.other);
      expect(contact.initials, '?');
    });
  });

  group('CareContact.effectiveDisplayName', () {
    test('returns display name when set', () {
      final contact = makeContact(
        type: CareContactType.doctor,
        displayName: 'Dr. Smith',
        firstName: 'John',
        lastName: 'Smith',
      );
      expect(contact.effectiveDisplayName, 'Dr. Smith');
    });

    test('doctor falls back to combined name', () {
      final contact = makeContact(
        type: CareContactType.doctor,
        firstName: 'John',
        lastName: 'Smith',
      );
      expect(contact.effectiveDisplayName, 'John Smith');
    });

    test('organization falls back to organization name', () {
      final contact = makeContact(
        type: CareContactType.laboratory,
        organizationName: 'MedLab',
      );
      expect(contact.effectiveDisplayName, 'MedLab');
    });

    test('returns empty when nothing available', () {
      final contact = makeContact(type: CareContactType.other);
      expect(contact.effectiveDisplayName, '');
    });
  });

  group('CareContact.copyWith', () {
    test('preserves all fields when no arguments provided', () {
      final now = DateTime(2026);
      final contact = CareContact(
        id: 1,
        profileId: 2,
        contactType: CareContactType.insurance,
        displayName: 'Geo Ins',
        firstName: null,
        lastName: null,
        specialty: null,
        organizationName: 'Geo Ins',
        department: 'Claims',
        contactPerson: 'Jane',
        primaryPhone: '555-0100',
        secondaryPhone: null,
        email: 'claims@example.com',
        website: 'example.com',
        address: 'Tbilisi',
        workingHours: '9-18',
        policyNumber: 'P-123',
        memberNumber: 'M-456',
        notes: 'notes',
        photoPath: '/photos/a.jpg',
        isFavorite: true,
        isArchived: true,
        createdAt: now,
        updatedAt: now,
      );

      final copy = contact.copyWith();
      expect(copy.id, 1);
      expect(copy.profileId, 2);
      expect(copy.contactType, CareContactType.insurance);
      expect(copy.displayName, 'Geo Ins');
      expect(copy.organizationName, 'Geo Ins');
      expect(copy.department, 'Claims');
      expect(copy.contactPerson, 'Jane');
      expect(copy.primaryPhone, '555-0100');
      expect(copy.email, 'claims@example.com');
      expect(copy.website, 'example.com');
      expect(copy.address, 'Tbilisi');
      expect(copy.workingHours, '9-18');
      expect(copy.policyNumber, 'P-123');
      expect(copy.memberNumber, 'M-456');
      expect(copy.notes, 'notes');
      expect(copy.photoPath, '/photos/a.jpg');
      expect(copy.isFavorite, true);
      expect(copy.isArchived, true);
    });

    test('overrides specified fields', () {
      final contact = makeContact(displayName: 'A');
      final copy = contact.copyWith(
        displayName: 'B',
        isFavorite: true,
        specialty: 'Cardiology',
      );
      expect(copy.displayName, 'B');
      expect(copy.isFavorite, true);
      expect(copy.specialty, 'Cardiology');
    });

    test('preserves nullable fields when not provided', () {
      final now = DateTime(2026);
      final contact = CareContact(
        profileId: 1,
        contactType: CareContactType.doctor,
        displayName: 'Dr. Smith',
        firstName: 'John',
        createdAt: now,
        updatedAt: now,
      );
      final copy = contact.copyWith();
      expect(copy.firstName, 'John');
    });
  });
}
