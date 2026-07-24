import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/tables/profile_table.dart';

class MeasurementTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id).nullable()();
  TextColumn get key => text().nullable()();
  TextColumn get name => text()();
  TextColumn get unit => text()();
  TextColumn get defaultUnit => text().nullable()();
  TextColumn get measurementCategory => text()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  IntColumn get displayOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class MeasurementTypeFields extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get measurementTypeId =>
      integer().references(MeasurementTypes, #id)();
  TextColumn get fieldKey => text()();
  TextColumn get label => text()();
  TextColumn get defaultUnit => text().nullable()();
  BoolColumn get required => boolean().withDefault(const Constant(true))();
  RealColumn get minimumValue => real().nullable()();
  RealColumn get maximumValue => real().nullable()();
  IntColumn get decimalPlaces => integer().withDefault(const Constant(1))();
  IntColumn get displayOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

class MeasurementRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id)();
  IntColumn get measurementTypeId =>
      integer().references(MeasurementTypes, #id)();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get valuePrimary => real()();
  RealColumn get valueSecondary => real().nullable()();
  RealColumn get valueTertiary => real().nullable()();
  TextColumn get unit => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

class MeasurementRecordValues extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get measurementRecordId =>
      integer().references(MeasurementRecords, #id)();
  TextColumn get fieldKey => text()();
  RealColumn get numericValue => real()();
  TextColumn get unit => text()();
  IntColumn get displayOrder => integer().withDefault(const Constant(0))();
}

class MeasurementSchedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id)();
  IntColumn get measurementTypeId =>
      integer().references(MeasurementTypes, #id)();
  TextColumn get scheduleConfig => text()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}
