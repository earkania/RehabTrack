import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/tables/profile_table.dart';

class Medications extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id)();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get doseAmount => text().nullable()();
  TextColumn get doseUnit => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class MedicationSchedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicationId =>
      integer().references(Medications, #id)();
  TextColumn get scheduleType => text()();
  TextColumn get scheduleConfig => text()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get instructions => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

class MedicationLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicationScheduleId =>
      integer().references(MedicationSchedules, #id)();
  DateTimeColumn get scheduledTime => dateTime()();
  DateTimeColumn get takenTime => dateTime().nullable()();
  TextColumn get status => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class MedicationAlternatives extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicationId =>
      integer().references(Medications, #id)();
  TextColumn get name => text()();
  TextColumn get doseAmount => text().nullable()();
  TextColumn get doseUnit => text().nullable()();
  BoolColumn get doctorApproved =>
      boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
