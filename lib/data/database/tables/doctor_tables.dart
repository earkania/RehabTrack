import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/tables/profile_table.dart';

class Doctors extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id)();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get specialty => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get clinic => text().nullable()();
  TextColumn get notes => text().nullable()();
}

class DoctorVisits extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id)();
  IntColumn get doctorId =>
      integer().references(Doctors, #id)();
  DateTimeColumn get visitDate => dateTime()();
  TextColumn get status => text()();
  TextColumn get reason => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(false))();
  IntColumn get reminderMinutesBefore =>
      integer().withDefault(const Constant(60))();
}
