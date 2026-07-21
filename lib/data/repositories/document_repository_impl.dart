import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/domain/entities/document_attachment.dart';
import 'package:rehab_track/domain/repositories/document_repository.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final db.AppDatabase _database;

  DocumentRepositoryImpl(this._database);

  @override
  Stream<List<DocumentAttachment>> watchDocuments(
    int profileId, {
    String? category,
  }) {
    return _database.documentDao
        .watchDocuments(profileId, category: category)
        .map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<List<DocumentAttachment>> getDocuments(
    int profileId, {
    String? category,
  }) async {
    final rows = await _database.documentDao.getDocuments(
      profileId,
      category: category,
    );
    return rows.map(_toDomain).toList();
  }

  @override
  Future<DocumentAttachment?> getDocument(int id) async {
    final row = await _database.documentDao.getDocument(id);
    return row != null ? _toDomain(row) : null;
  }

  @override
  Future<int> createDocument(
    DocumentAttachment document,
  ) async {
    return _database.documentDao.insertDocument(
      db.DocumentAttachmentsCompanion.insert(
        profileId: document.profileId,
        category: document.category,
        title: document.title,
        fileName: document.fileName,
        mimeType: document.mimeType,
        storedPath: document.storedPath,
        fileSize: Value(document.fileSize),
        createdAt: document.createdAt,
        notes: Value(document.notes),
      ),
    );
  }

  @override
  Future<void> updateDocument(
    DocumentAttachment document,
  ) async {
    await _database.documentDao.updateDocument(
      db.DocumentAttachmentsCompanion(
        id: Value(document.id!),
        profileId: Value(document.profileId),
        category: Value(document.category),
        title: Value(document.title),
        fileName: Value(document.fileName),
        mimeType: Value(document.mimeType),
        storedPath: Value(document.storedPath),
        fileSize: Value(document.fileSize),
        createdAt: Value(document.createdAt),
        notes: Value(document.notes),
      ),
    );
  }

  @override
  Future<void> deleteDocument(int id) async {
    await _database.documentDao.deleteDocument(id);
  }

  DocumentAttachment _toDomain(db.DocumentAttachment row) {
    return DocumentAttachment(
      id: row.id,
      profileId: row.profileId,
      category: row.category,
      title: row.title,
      fileName: row.fileName,
      mimeType: row.mimeType,
      storedPath: row.storedPath,
      fileSize: row.fileSize,
      createdAt: row.createdAt,
      notes: row.notes,
    );
  }
}
