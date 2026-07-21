import 'package:drift/drift.dart';

class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get gender => text().nullable()();
  RealColumn get heightCm => real().nullable()();
  RealColumn get weightKg => real().nullable()();
  TextColumn get bloodType => text().nullable()();
  TextColumn get allergies => text().nullable()();
  TextColumn get emergencyContactName => text().nullable()();
  TextColumn get emergencyContactPhone => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
