// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_template_dao.dart';

// ignore_for_file: type=lint
mixin _$HealthTemplateDaoMixin on DatabaseAccessor<AppDatabase> {
  $HealthTemplatesTable get healthTemplates => attachedDatabase.healthTemplates;
  HealthTemplateDaoManager get managers => HealthTemplateDaoManager(this);
}

class HealthTemplateDaoManager {
  final _$HealthTemplateDaoMixin _db;
  HealthTemplateDaoManager(this._db);
  $$HealthTemplatesTableTableManager get healthTemplates =>
      $$HealthTemplatesTableTableManager(
        _db.attachedDatabase,
        _db.healthTemplates,
      );
}
