import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/database/tables/care_contact_table.dart';

part 'care_contact_dao.g.dart';

@DriftAccessor(tables: [CareContacts])
class CareContactDao extends DatabaseAccessor<AppDatabase>
    with _$CareContactDaoMixin {
  CareContactDao(super.db);

  /// Watches contacts for a profile in one archive state. Rows are NOT ordered
  /// by the raw display_name column (it may be empty for generated names);
  /// sorting by effective display name happens in the repository layer.
  Stream<List<CareContact>> watchContactsForProfile(
    int profileId, {
    required bool archived,
  }) {
    return (select(careContacts)
      ..where((t) =>
          t.profileId.equals(profileId) &
          t.isArchived.equals(archived))).watch();
  }

  /// Watches every contact for a profile regardless of archive state.
  Stream<List<CareContact>> watchAllContactsForProfile(int profileId) {
    return (select(careContacts)
      ..where((t) => t.profileId.equals(profileId))).watch();
  }

  /// Watches a single contact scoped to a profile. Emits null when absent.
  Stream<CareContact?> watchContactById(int profileId, int contactId) {
    return (select(careContacts)
      ..where((t) =>
          t.id.equals(contactId) & t.profileId.equals(profileId))
      ..limit(1)).watchSingleOrNull();
  }

  Future<CareContact?> getContactById(int profileId, int contactId) {
    return (select(careContacts)
      ..where((t) =>
          t.id.equals(contactId) & t.profileId.equals(profileId))
      ..limit(1)).getSingleOrNull();
  }

  Future<int> insertContact(CareContactsCompanion entry) {
    return into(careContacts).insert(entry);
  }

  Future<bool> updateContact(CareContactsCompanion entry) {
    return update(careContacts).replace(entry);
  }

  Future<void> setArchived(
    int profileId,
    int contactId,
    bool archived,
  ) async {
    await (update(careContacts)
          ..where((t) =>
              t.id.equals(contactId) & t.profileId.equals(profileId)))
        .write(CareContactsCompanion(
      isArchived: Value(archived),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> setFavorite(
    int profileId,
    int contactId,
    bool favorite,
  ) async {
    await (update(careContacts)
          ..where((t) =>
              t.id.equals(contactId) & t.profileId.equals(profileId)))
        .write(CareContactsCompanion(
      isFavorite: Value(favorite),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> deleteContactPermanently(int profileId, int contactId) async {
    await (delete(careContacts)
          ..where((t) =>
              t.id.equals(contactId) & t.profileId.equals(profileId)))
        .go();
  }
}
