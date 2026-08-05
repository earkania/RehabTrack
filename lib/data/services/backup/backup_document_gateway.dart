import 'package:flutter/services.dart';

/// Result of asking the user to pick a backup document.
class BackupDocumentResult {
  /// `content://` URI of the chosen document, set only on success.
  final String? contentUri;

  final bool cancelled;

  final bool failed;

  const BackupDocumentResult._({
    this.contentUri,
    this.cancelled = false,
    this.failed = false,
  });

  factory BackupDocumentResult.success(String contentUri) =>
      BackupDocumentResult._(contentUri: contentUri);

  factory BackupDocumentResult.cancelled() =>
      const BackupDocumentResult._(cancelled: true);

  factory BackupDocumentResult.failed() =>
      const BackupDocumentResult._(failed: true);

  bool get succeeded => contentUri != null && !cancelled && !failed;
}

/// Opens a backup document through the Android Storage Access Framework and
/// copies its bytes to an app-owned temporary file.
///
/// The native side (in `MainActivity`) drives `ACTION_OPEN_DOCUMENT` and copies
/// the selected document via the content resolver, so the app never converts
/// `content://` URIs into unreliable raw filesystem paths and never requests
/// broad storage permission.
class BackupDocumentGateway {
  static const MethodChannel _channel =
      MethodChannel('com.earkania.rehabtrack/backup');

  const BackupDocumentGateway();

  /// Presents the document picker. Returns the `content://` URI or null when
  /// the user cancels. Throws [PlatformException] / [MissingPluginException]
  /// on failure.
  Future<String?> openDocument() {
    return _channel.invokeMethod<String>('openDocument');
  }

  /// Copies the document at [contentUri] into [destinationPath].
  ///
  /// The copy happens inside the app's own temporary directory; the content
  /// URI is never treated as a filesystem path.
  Future<void> copyDocument({
    required String contentUri,
    required String destinationPath,
  }) {
    return _channel.invokeMethod<void>('copyDocument', {
      'contentUri': contentUri,
      'destinationPath': destinationPath,
    });
  }
}
