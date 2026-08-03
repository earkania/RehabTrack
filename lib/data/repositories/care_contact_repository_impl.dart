import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/domain/entities/care_contact.dart';
import 'package:rehab_track/domain/enums/enums.dart';
import 'package:rehab_track/domain/repositories/care_contact_repository.dart';

class CareContactRepositoryImpl implements CareContactRepository {
  final db.AppDatabase _database;

  CareContactRepositoryImpl(this._database);

  @override
  Stream<List<CareContact>> watchActiveContacts(int profileId) {
    return _database.careContactDao
        .watchContactsForProfile(profileId, archived: false)
        .map((rows) => _order(rows.map(_toDomain).toList()));
  }

  @override
  Stream<List<CareContact>> watchArchivedContacts(int profileId) {
    return _database.careContactDao
        .watchContactsForProfile(profileId, archived: true)
        .map((rows) => _order(rows.map(_toDomain).toList()));
  }

  @override
  Stream<List<CareContact>> watchAllContacts(int profileId) {
    return _database.careContactDao
        .watchAllContactsForProfile(profileId)
        .map((rows) => _order(rows.map(_toDomain).toList()));
  }

  @override
  Stream<CareContact?> watchContactById(int profileId, int contactId) {
    return _database.careContactDao
        .watchContactById(profileId, contactId)
        .map((row) => row != null ? _toDomain(row) : null);
  }

  @override
  Future<CareContact?> getContactById(int profileId, int contactId) async {
    final row =
        await _database.careContactDao.getContactById(profileId, contactId);
    return row != null ? _toDomain(row) : null;
  }

  @override
  Future<int> createContact(CareContact contact) async {
    final now = contact.createdAt;
    return _database.careContactDao.insertContact(
      db.CareContactsCompanion.insert(
        profileId: contact.profileId,
        contactType: contact.contactType.name,
        displayName: contact.displayName,
        firstName: Value(contact.firstName),
        lastName: Value(contact.lastName),
        specialty: Value(contact.specialty),
        organizationName: Value(contact.organizationName),
        department: Value(contact.department),
        contactPerson: Value(contact.contactPerson),
        primaryPhone: Value(contact.primaryPhone),
        secondaryPhone: Value(contact.secondaryPhone),
        email: Value(contact.email),
        website: Value(contact.website),
        address: Value(contact.address),
        workingHours: Value(contact.workingHours),
        policyNumber: Value(contact.policyNumber),
        memberNumber: Value(contact.memberNumber),
        notes: Value(contact.notes),
        photoPath: Value(contact.photoPath),
        isFavorite: Value(contact.isFavorite),
        isArchived: Value(contact.isArchived),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  Future<void> updateContact(CareContact contact) async {
    await _database.careContactDao.updateContact(
      db.CareContactsCompanion(
        id: Value(contact.id!),
        profileId: Value(contact.profileId),
        contactType: Value(contact.contactType.name),
        displayName: Value(contact.displayName),
        firstName: Value(contact.firstName),
        lastName: Value(contact.lastName),
        specialty: Value(contact.specialty),
        organizationName: Value(contact.organizationName),
        department: Value(contact.department),
        contactPerson: Value(contact.contactPerson),
        primaryPhone: Value(contact.primaryPhone),
        secondaryPhone: Value(contact.secondaryPhone),
        email: Value(contact.email),
        website: Value(contact.website),
        address: Value(contact.address),
        workingHours: Value(contact.workingHours),
        policyNumber: Value(contact.policyNumber),
        memberNumber: Value(contact.memberNumber),
        notes: Value(contact.notes),
        photoPath: Value(contact.photoPath),
        isFavorite: Value(contact.isFavorite),
        isArchived: Value(contact.isArchived),
        createdAt: Value(contact.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> archiveContact(int profileId, int contactId) {
    return _database.careContactDao.setArchived(profileId, contactId, true);
  }

  @override
  Future<void> restoreContact(int profileId, int contactId) {
    return _database.careContactDao.setArchived(profileId, contactId, false);
  }

  @override
  Future<void> deleteContact(int profileId, int contactId) {
    return _database.careContactDao.deleteContactPermanently(
      profileId,
      contactId,
    );
  }

  @override
  Future<void> setFavorite(int profileId, int contactId, bool favorite) {
    return _database.careContactDao.setFavorite(profileId, contactId, favorite);
  }

  /// Sorts by favorite first, then effective display name (case-insensitive).
  List<CareContact> _order(List<CareContact> contacts) {
    final sorted = [...contacts];
    sorted.sort((a, b) {
      if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;
      return a.effectiveDisplayName.toLowerCase().compareTo(
            b.effectiveDisplayName.toLowerCase(),
          );
    });
    return sorted;
  }

  CareContact _toDomain(db.CareContact row) {
    return CareContact(
      id: row.id,
      profileId: row.profileId,
      contactType: CareContactType.fromString(row.contactType),
      displayName: row.displayName,
      firstName: row.firstName,
      lastName: row.lastName,
      specialty: row.specialty,
      organizationName: row.organizationName,
      department: row.department,
      contactPerson: row.contactPerson,
      primaryPhone: row.primaryPhone,
      secondaryPhone: row.secondaryPhone,
      email: row.email,
      website: row.website,
      address: row.address,
      workingHours: row.workingHours,
      policyNumber: row.policyNumber,
      memberNumber: row.memberNumber,
      notes: row.notes,
      photoPath: row.photoPath,
      isFavorite: row.isFavorite,
      isArchived: row.isArchived,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
