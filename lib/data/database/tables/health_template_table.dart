import 'package:drift/drift.dart';

class HealthTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get configurationJson => text()();
}
