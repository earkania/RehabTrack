import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/tables/profile_table.dart';

class DietPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id)();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();
}

class DietItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get dietPlanId =>
      integer().references(DietPlans, #id)();
  TextColumn get category => text()();
  TextColumn get itemText => text()();
  TextColumn get notes => text().nullable()();
}
