class DocumentAttachment {
  final int? id;
  final int profileId;
  final String category;
  final String title;
  final String fileName;
  final String mimeType;
  final String storedPath;
  final int? fileSize;
  final DateTime createdAt;
  final String? notes;

  const DocumentAttachment({
    this.id,
    required this.profileId,
    required this.category,
    required this.title,
    required this.fileName,
    required this.mimeType,
    required this.storedPath,
    this.fileSize,
    required this.createdAt,
    this.notes,
  });

  DocumentAttachment copyWith({
    int? id,
    int? profileId,
    String? category,
    String? title,
    String? fileName,
    String? mimeType,
    String? storedPath,
    int? fileSize,
    DateTime? createdAt,
    String? notes,
  }) {
    return DocumentAttachment(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      category: category ?? this.category,
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      storedPath: storedPath ?? this.storedPath,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }
}
