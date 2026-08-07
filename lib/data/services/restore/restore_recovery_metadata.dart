import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Minimal, non-sensitive metadata persisted before the critical replacement
/// section of a restore so an interrupted operation can be detected on the
/// next app start.
///
/// Deliberately contains **no personal data and no filesystem paths that leak
/// user content**: only an operation id, an apply-phase name, and boolean flags
/// for what has already been swapped.
class RestoreRecoveryMetadata {
  final String operationId;

  /// Current [RestoreApplyPhase.name] when the metadata was last written.
  final String phase;

  /// Absolute path of the restore workspace (a private temp directory). Not
  /// personal data; used to locate the retained safety snapshot during
  /// interrupted-operation recovery.
  final String workspacePath;

  final bool databaseSwapStarted;

  final bool fileSwapStarted;

  final bool preferencesApplied;

  final bool finalized;

  /// Number of times automatic interrupted-recovery has been attempted for
  /// this operation. Bounded by [RestoreInterruptedRecoveryService] so a
  /// persistent failure reaches a terminal state instead of retrying forever.
  final int attemptCount;

  const RestoreRecoveryMetadata({
    required this.operationId,
    required this.phase,
    required this.workspacePath,
    this.databaseSwapStarted = false,
    this.fileSwapStarted = false,
    this.preferencesApplied = false,
    this.finalized = false,
    this.attemptCount = 0,
  });

  bool get needsRecovery =>
      (databaseSwapStarted || fileSwapStarted || preferencesApplied) &&
      !finalized;

  Map<String, Object?> toJson() => {
        'operationId': operationId,
        'phase': phase,
        'workspacePath': workspacePath,
        'databaseSwapStarted': databaseSwapStarted,
        'fileSwapStarted': fileSwapStarted,
        'preferencesApplied': preferencesApplied,
        'finalized': finalized,
        'attemptCount': attemptCount,
      };

  factory RestoreRecoveryMetadata.fromJson(Map<String, Object?> json) {
    return RestoreRecoveryMetadata(
      operationId: json['operationId'] as String? ?? '',
      phase: json['phase'] as String? ?? '',
      workspacePath: json['workspacePath'] as String? ?? '',
      databaseSwapStarted: json['databaseSwapStarted'] as bool? ?? false,
      fileSwapStarted: json['fileSwapStarted'] as bool? ?? false,
      preferencesApplied: json['preferencesApplied'] as bool? ?? false,
      finalized: json['finalized'] as bool? ?? false,
      attemptCount: json['attemptCount'] as int? ?? 0,
    );
  }

  factory RestoreRecoveryMetadata.fromJsonString(String source) {
    return RestoreRecoveryMetadata.fromJson(
      jsonDecode(source) as Map<String, Object?>,
    );
  }

  String toJsonString() => jsonEncode(toJson());
}

/// Persists [RestoreRecoveryMetadata] in app-private storage.
///
/// The base directory is resolved lazily (from an injectable resolver) so the
/// store can be constructed synchronously while production uses the
/// asynchronous application-support directory and tests inject a temp dir.
/// Files are named `<operationId>.json`.
class RestoreRecoveryStore {
  final Future<Directory> Function() _baseDir;
  Future<Directory>? _resolved;

  RestoreRecoveryStore(this._baseDir);

  /// A store rooted at a concrete [Directory] (used in tests).
  factory RestoreRecoveryStore.inDirectory(Directory dir) =>
      RestoreRecoveryStore(() async => dir);

  Future<Directory> _dir() => _resolved ??= _baseDir();

  Future<File> _file(String operationId) async {
    final dir = await _dir();
    return File(p.join(dir.path, '$operationId.json'));
  }

  Future<void> write(RestoreRecoveryMetadata metadata) async {
    final dir = await _dir();
    await dir.create(recursive: true);
    final file = File(p.join(dir.path, '${metadata.operationId}.json'));
    await file.writeAsString(metadata.toJsonString(), flush: true);
  }

  Future<RestoreRecoveryMetadata?> read(String operationId) async {
    final file = await _file(operationId);
    if (!await file.exists()) return null;
    try {
      return RestoreRecoveryMetadata.fromJsonString(await file.readAsString());
    } catch (_) {
      return null;
    }
  }

  /// Lists all recovery metadata files in the store.
  Future<List<RestoreRecoveryMetadata>> listAll() async {
    final dir = await _dir();
    if (!await dir.exists()) return const [];
    final result = <RestoreRecoveryMetadata>[];
    await for (final entity in dir.list()) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      try {
        final metadata =
            RestoreRecoveryMetadata.fromJsonString(await entity.readAsString());
        result.add(metadata);
      } catch (_) {
        // Ignore unreadable/incomplete metadata files.
      }
    }
    return result;
  }

  Future<void> clear(String operationId) async {
    final file = await _file(operationId);
    if (await file.exists()) {
      await file.delete();
    }
  }
}