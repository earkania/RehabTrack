import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:rehab_track/data/services/report/saved_report_file.dart';

/// Saves generated report PDFs persistently in a user-accessible location and
/// opens/shares the saved file.
///
/// Android implementation (in `MainActivity`, channel
/// `com.earkania.rehabtrack/reports`):
/// - API 29+: `MediaStore.Downloads` with `RELATIVE_PATH=Download/RehabTrack`
///   — modern scoped storage, no storage permission required.
/// - API < 29: app-specific external Downloads dir (`Download/RehabTrack`
///   inside the app's external files folder) exposed through our own
///   [FileProvider] for open/share — still permission-free.
///
/// The service never receives raw filesystem paths from callers and never
/// hands any out; downstream actions work exclusively with content URIs.
class ReportStorageService {
  static const MethodChannel _channel =
      MethodChannel('com.earkania.rehabtrack/reports');

  final MethodChannel channel;

  /// Injected for tests; production instances use [_channel].
  ReportStorageService({MethodChannel? testChannel})
      : channel = testChannel ?? _channel;

  static const String pdfMimeType = 'application/pdf';

  /// Writes [bytes] to `Downloads/RehabTrack/<displayName>` (or the legacy
  /// equivalent), resolving filename collisions deterministically by appending
  /// `_2`, `_3`, … before the extension. Throws [ReportStorageException] on
  /// failure; incomplete entries are cleaned up natively before rethrowing.
  Future<SavedReportFile> savePdf({
    required Uint8List bytes,
    required String displayName,
  }) async {
    if (bytes.isEmpty) {
      throw const ReportStorageException(
        'INVALID_ARGUMENTS',
        message: 'PDF bytes are empty',
      );
    }
    try {
      final raw = await channel.invokeMethod<String>('savePdfToDownloads', {
        'displayName': displayName,
        'mimeType': pdfMimeType,
        'relativePath': 'Download/RehabTrack',
        'bytes': bytes,
      });
      if (raw == null) {
        throw const ReportStorageException('SAVE_ERROR');
      }
      return SavedReportFile.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } on PlatformException catch (e) {
      throw ReportStorageException(e.code, message: e.message);
    } on MissingPluginException {
      throw const ReportStorageException('MISSING_PLUGIN');
    } on FormatException catch (e) {
      throw ReportStorageException('SAVE_ERROR', message: e.message);
    }
  }

  /// Opens [file] with an installed PDF viewer via ACTION_VIEW. Throws
  /// [ReportStorageException] with code `NO_VIEWER` when no compatible
  /// viewer is installed.
  Future<void> open(SavedReportFile file) async {
    _requireUri(file);
    try {
      await channel.invokeMethod<void>('openSavedDocument', {
        'contentUri': file.contentUri,
        'mimeType': file.mimeType,
      });
    } on PlatformException catch (e) {
      throw ReportStorageException(e.code, message: e.message);
    } on MissingPluginException {
      throw const ReportStorageException('MISSING_PLUGIN');
    }
  }

  /// Shares [file] through the system share sheet (ACTION_SEND chooser).
  Future<void> share(SavedReportFile file) async {
    _requireUri(file);
    try {
      await channel.invokeMethod<void>('shareSavedDocument', {
        'contentUri': file.contentUri,
        'mimeType': file.mimeType,
        'displayName': file.displayName,
      });
    } on PlatformException catch (e) {
      throw ReportStorageException(e.code, message: e.message);
    } on MissingPluginException {
      throw const ReportStorageException('MISSING_PLUGIN');
    }
  }

  /// Opens an email composer with pre-filled recipient, subject, body,
  /// and the report PDF as an attachment.
  ///
  /// Uses Android ACTION_SEND with message/rfc822 to target email-capable
  /// applications. The user must explicitly press Send in their mail app.
  Future<void> composeEmail({
    required SavedReportFile file,
    required String recipient,
    required String subject,
    required String body,
  }) async {
    _requireUri(file);
    try {
      await channel.invokeMethod<void>('composeEmailWithAttachment', {
        'contentUri': file.contentUri,
        'mimeType': file.mimeType,
        'displayName': file.displayName,
        'recipient': recipient,
        'subject': subject,
        'body': body,
      });
    } on PlatformException catch (e) {
      throw ReportStorageException(e.code, message: e.message);
    } on MissingPluginException {
      throw const ReportStorageException('MISSING_PLUGIN');
    }
  }

  void _requireUri(SavedReportFile file) {
    if (file.contentUri == null || file.contentUri!.isEmpty) {
      throw const ReportStorageException(
        'INVALID_ARGUMENTS',
        message: 'saved file has no content URI',
      );
    }
  }
}
