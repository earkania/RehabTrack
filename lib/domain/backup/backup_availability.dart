/// Persisted availability of a registered backup document.
///
/// Values are stored as their stable `storageKey` strings (never localized
/// labels) so the registry survives app/locale changes:
/// `available`, `unavailable`, `unknown`.
enum BackupAvailability {
  /// The underlying document was last probed and could be opened.
  available,

  /// The underlying document could not be opened (moved, renamed to a new URI,
  /// deleted, or the persisted URI grant was revoked).
  unavailable,

  /// Availability has never been probed (e.g. a legacy registry entry, or a
  /// probe that could not reach the provider).
  unknown;

  /// Stable persisted value. Must never be a localized label.
  String get storageKey => name;

  static BackupAvailability fromStorage(Object? raw) {
    if (raw is String) {
      return switch (raw) {
        'available' => BackupAvailability.available,
        'unavailable' => BackupAvailability.unavailable,
        'unknown' => BackupAvailability.unknown,
        _ => BackupAvailability.unknown,
      };
    }
    // Legacy payloads stored a plain boolean under the `available` key.
    if (raw is bool) {
      return raw ? BackupAvailability.available : BackupAvailability.unavailable;
    }
    return BackupAvailability.unknown;
  }
}