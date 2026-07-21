// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_setting_dao.dart';

// ignore_for_file: type=lint
mixin _$AppSettingDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppSettingsTable get appSettings => attachedDatabase.appSettings;
  AppSettingDaoManager get managers => AppSettingDaoManager(this);
}

class AppSettingDaoManager {
  final _$AppSettingDaoMixin _db;
  AppSettingDaoManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db.attachedDatabase, _db.appSettings);
}
