import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/tables/profile_table.dart';

/// Care Contacts — a single shared table for medical professionals and
/// healthcare-related organizations. Contact-type-specific fields are nullable
/// columns on the same row.
@TableIndex(name: 'care_contacts_profile_idx', columns: {#profileId})
@TableIndex(name: 'care_contacts_type_idx', columns: {#contactType})
@TableIndex(name: 'care_contacts_archived_idx', columns: {#isArchived})
@TableIndex(name: 'care_contacts_favorite_idx', columns: {#isFavorite})
@TableIndex(name: 'care_contacts_display_name_idx', columns: {#displayName})
class CareContacts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id)();
  TextColumn get contactType => text()();
  TextColumn get displayName => text()();
  TextColumn get firstName => text().nullable()();
  TextColumn get lastName => text().nullable()();
  TextColumn get specialty => text().nullable()();
  TextColumn get organizationName => text().nullable()();
  TextColumn get department => text().nullable()();
  TextColumn get contactPerson => text().nullable()();
  TextColumn get primaryPhone => text().nullable()();
  TextColumn get secondaryPhone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get website => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get workingHours => text().nullable()();
  TextColumn get policyNumber => text().nullable()();
  TextColumn get memberNumber => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
