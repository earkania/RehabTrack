import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/database/tables/document_table.dart';

part 'document_dao.g.dart';

@DriftAccessor(tables: [DocumentAttachments])
class DocumentDao extends DatabaseAccessor<AppDatabase>
    with _$DocumentDaoMixin {
  DocumentDao(super.db);

  Stream<List<DocumentAttachment>> watchDocuments(
    int profileId, {
    String? category,
  }) {
    final query = select(documentAttachments)
      ..where((t) => t.profileId.equals(profileId));
    if (category != null) {
      query.where((t) => t.category.equals(category));
    }
    query.orderBy([
      (t) => OrderingTerm.desc(t.createdAt),
    ]);
    return query.watch();
  }

  Future<List<DocumentAttachment>> getDocuments(
    int profileId, {
    String? category,
  }) {
    final query = select(documentAttachments)
      ..where((t) => t.profileId.equals(profileId));
    if (category != null) {
      query.where((t) => t.category.equals(category));
    }
    query.orderBy([
      (t) => OrderingTerm.desc(t.createdAt),
    ]);
    return query.get();
  }

  Future<DocumentAttachment?> getDocument(int id) {
    return (select(documentAttachments)
      ..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertDocument(DocumentAttachmentsCompanion entry) {
    return into(documentAttachments).insert(entry);
  }

  Future<bool> updateDocument(DocumentAttachmentsCompanion entry) {
    return update(documentAttachments).replace(entry);
  }

  Future<int> deleteDocument(int id) {
    return (delete(documentAttachments)
      ..where((t) => t.id.equals(id))).go();
  }
}
