import 'package:rehab_track/domain/entities/care_contact.dart';

abstract class CareContactRepository {
  /// Watches active (non-archived) contacts for a profile.
  Stream<List<CareContact>> watchActiveContacts(int profileId);

  /// Watches archived contacts for a profile.
  Stream<List<CareContact>> watchArchivedContacts(int profileId);

  /// Watches all contacts for a profile (active and archived).
  Stream<List<CareContact>> watchAllContacts(int profileId);

  /// Watches a single contact scoped to a profile; null when absent.
  Stream<CareContact?> watchContactById(int profileId, int contactId);

  Future<CareContact?> getContactById(int profileId, int contactId);

  Future<int> createContact(CareContact contact);

  Future<void> updateContact(CareContact contact);

  Future<void> archiveContact(int profileId, int contactId);

  Future<void> restoreContact(int profileId, int contactId);

  Future<void> deleteContact(int profileId, int contactId);

  Future<void> setFavorite(int profileId, int contactId, bool favorite);
}
