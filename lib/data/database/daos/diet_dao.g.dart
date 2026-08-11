// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_dao.dart';

// ignore_for_file: type=lint
mixin _$DietDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $DietItemsTable get dietItems => attachedDatabase.dietItems;
  $DietGuidanceRulesTable get dietGuidanceRules =>
      attachedDatabase.dietGuidanceRules;
  DietDaoManager get managers => DietDaoManager(this);
}

class DietDaoManager {
  final _$DietDaoMixin _db;
  DietDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$DietItemsTableTableManager get dietItems =>
      $$DietItemsTableTableManager(_db.attachedDatabase, _db.dietItems);
  $$DietGuidanceRulesTableTableManager get dietGuidanceRules =>
      $$DietGuidanceRulesTableTableManager(
        _db.attachedDatabase,
        _db.dietGuidanceRules,
      );
}
