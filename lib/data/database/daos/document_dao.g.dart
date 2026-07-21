// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_dao.dart';

// ignore_for_file: type=lint
mixin _$DocumentDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $DocumentAttachmentsTable get documentAttachments =>
      attachedDatabase.documentAttachments;
  DocumentDaoManager get managers => DocumentDaoManager(this);
}

class DocumentDaoManager {
  final _$DocumentDaoMixin _db;
  DocumentDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$DocumentAttachmentsTableTableManager get documentAttachments =>
      $$DocumentAttachmentsTableTableManager(
        _db.attachedDatabase,
        _db.documentAttachments,
      );
}
