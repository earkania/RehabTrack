/// Time-of-day dimensions used to narrow down which readings a trend chart
/// (or other measurement view) displays.
///
/// These are the canonical values: they are never derived from UI labels or
/// localized strings, so ranges could later become configurable without
/// rewriting chart display logic.
enum MeasurementTimeOfDayFilter {
  /// No time-of-day restriction: every reading qualifies.
  all,

  /// 06:00 inclusive .. 12:00 exclusive.
  morning,

  /// 12:00 inclusive .. 17:00 exclusive.
  midday,

  /// 17:00 inclusive .. 22:00 exclusive.
  evening,

  /// 22:00 inclusive .. 06:00 exclusive (wraps across midnight).
  night;
}