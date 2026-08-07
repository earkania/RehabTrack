import 'package:rehab_track/data/services/backup/preferences_exporter.dart';
import 'package:rehab_track/data/services/restore/restore_environment.dart';

/// Thrown when restored preferences are invalid or cannot be applied.
class PreferencesRestoreException implements Exception {
  const PreferencesRestoreException();
}

/// Stages and applies restored user preferences.
///
/// Only allowlisted settings are restored (same policy as the backup exporter).
/// Unknown/undocumented future keys are tolerated; known keys must have stable
/// value types or the whole restore is rejected before any live change.
class RestorePreferencesManager {
  final RestoreEnvironment _environment;

  RestorePreferencesManager(this._environment);

  /// Normalizes raw decoded preference values into `{key: stringValue}`
  /// restricted to the allowlist. Throws [PreferencesRestoreException] on an
  /// invalid known value.
  Future<Map<String, String>> normalize(Map<String, Object?> raw) async {
    final result = <String, String>{};
    try {
      for (final MapEntry(key: key, value: value) in raw.entries) {
        if (!PreferencesExporter.allowlist.contains(key)) continue;
        if (value is String) {
          result[key] = value;
        } else if (value is bool) {
          result[key] = value.toString();
        } else if (value is int) {
          result[key] = value.toString();
        } else if (value is num) {
          result[key] = value.toString();
        } else {
          throw const PreferencesRestoreException();
        }
      }
    } catch (_) {
      throw const PreferencesRestoreException();
    }
    return result;
  }

  /// Applies the restored values, replacing the current supported set exactly.
  Future<void> apply(Map<String, String> values) async {
    try {
      await _environment.applyPreferences(values);
    } catch (_) {
      throw const PreferencesRestoreException();
    }
  }
}