import 'package:rehab_track/domain/entities/document_attachment.dart';

abstract class DocumentRepository {
  Stream<List<DocumentAttachment>> watchDocuments(
    int profileId, {
    String? category,
  });
  Future<List<DocumentAttachment>> getDocuments(
    int profileId, {
    String? category,
  });
  Future<DocumentAttachment?> getDocument(int id);
  Future<int> createDocument(DocumentAttachment document);
  Future<void> updateDocument(DocumentAttachment document);
  Future<void> deleteDocument(int id);
}
