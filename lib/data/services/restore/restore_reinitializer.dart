import 'package:rehab_track/data/services/restore/restore_environment.dart';

/// Thrown when reopening/reinitializing the database-backed services fails.
class ReinitializationException implements Exception {
  const ReinitializationException();
}

/// Thrown when post-restore verification of the restored state fails.
class VerificationException implements Exception {
  const VerificationException();
}

/// Reopens the database and reinitializes database-backed services and
/// providers after the live state has been replaced.
class RestoreReinitializer {
  final RestoreEnvironment _environment;

  RestoreReinitializer(this._environment);

  Future<void> reopenAndReinitialize() async {
    try {
      await _environment.reopenDatabase();
      await _environment.reinitializeProviders();
    } catch (_) {
      throw const ReinitializationException();
    }
  }

  /// Verifies the restored state can be read. Returns whether verification
  /// passed. Throws [VerificationException] on unexpected errors.
  Future<bool> verifyRestoredState() async {
    try {
      return await _environment.verifyRestoredState();
    } catch (_) {
      throw const VerificationException();
    }
  }
}