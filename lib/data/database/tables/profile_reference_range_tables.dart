import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/tables/profile_table.dart';

class ProfileReferenceRanges extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(Profiles, #id)();
  TextColumn get typeKey => text()();
  TextColumn get fieldKey => text()();
  RealColumn get minValue => real().nullable()();
  RealColumn get maxValue => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
