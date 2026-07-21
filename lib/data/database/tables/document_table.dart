import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/tables/profile_table.dart';

class DocumentAttachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id)();
  TextColumn get category => text()();
  TextColumn get title => text()();
  TextColumn get fileName => text()();
  TextColumn get mimeType => text()();
  TextColumn get storedPath => text()();
  IntColumn get fileSize => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get notes => text().nullable()();
}
