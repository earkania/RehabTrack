/// Canonical normalization for scheduled measurement occurrences.
///
/// Occurrence times reach the app from several sources with different
/// precision and timezone encodings:
///
///  * notification payloads serialize a `tz.TZDateTime` via
///    `toIso8601String()`, which includes a UTC offset (e.g.
///    `2026-08-12T10:30:00.000+0400`). `DateTime.parse` then returns a UTC
///    instant (06:30Z), and Drift reads that back as the local wall clock of
///    the stored instant — 06:30, not the 10:30 the user actually scheduled.
///  * the Today popup passes a plain local `DateTime` for the same slot.
///
/// [normalize] collapses any of these representations to a local
/// minute-precision wall clock so every write path stores the same canonical
/// value and the Today agenda (which matches on local year/month/day/hour/
/// minute) always finds the occurrence.
class MeasurementOccurrenceTime {
  const MeasurementOccurrenceTime._();

  /// Returns [value] converted to the device-local zone with seconds and
  /// sub-seconds truncated to minute precision.
  ///
  /// The result is UTC-free (always `isUtc == false`) and does not depend on
  /// how the original value was encoded, only on the instant it represents.
  static DateTime normalize(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day, local.hour, local.minute);
  }
}

/// Outcome of [MeasurementRepository.recordScheduledMeasurement].
class RecordScheduledMeasurementResult {
  final int recordId;
  final int? reminderLogId;

  /// Whether the occurrence notification was cancelled successfully. A false
  /// value means the reminder could not be withdrawn, but the medical data
  /// and the completed occurrence were already committed and must be kept.
  final bool notificationCancelled;

  /// True when a completed reminder log already existed for the occurrence
  /// before this call (e.g. a double-tap of the same notification).
  final bool alreadyCompleted;

  const RecordScheduledMeasurementResult({
    required this.recordId,
    this.reminderLogId,
    required this.notificationCancelled,
    required this.alreadyCompleted,
  });
}
