import 'package:rehab_track/domain/entities/measurement_data_point.dart';
import 'package:rehab_track/domain/entities/measurement_time_of_day_filter.dart';

/// Canonical time-of-day definitions and the filtering helpers that use them.
///
/// All hour boundaries live here (and only here) so widgets, providers,
/// statistics and chart code never duplicate the boundary checks:
///
///  * [MeasurementTimeOfDayFilter.morning]: 06:00 inclusive .. 12:00 exclusive
///  * [MeasurementTimeOfDayFilter.midday]:  12:00 inclusive .. 17:00 exclusive
///  * [MeasurementTimeOfDayFilter.evening]: 17:00 inclusive .. 22:00 exclusive
///  * [MeasurementTimeOfDayFilter.night]:   22:00 inclusive .. 06:00 exclusive,
///    which wraps across midnight so it is expressed as `hour >= 22 || hour < 6`
///    rather than a simple `start <= hour < end` comparison.
class MeasurementTimeOfDayClassifier {
  MeasurementTimeOfDayClassifier._();

  /// Classifies [time] using its device-local wall clock.
  ///
  /// The app stores measurement timestamps as local wall-clock values, so for
  /// ordinary readings this is a no-op. Passing a UTC instant is also safe:
  /// `.toLocal()` is the same canonical conversion the app already uses, so a
  /// stored UTC timestamp that displays as 23:00 local is classified as Night
  /// even when its UTC hour belongs to another period.
  static MeasurementTimeOfDayFilter classify(DateTime time) {
    final hour = time.toLocal().hour;
    if (hour >= 6 && hour < 12) {
      return MeasurementTimeOfDayFilter.morning;
    }
    if (hour >= 12 && hour < 17) {
      return MeasurementTimeOfDayFilter.midday;
    }
    if (hour >= 17 && hour < 22) {
      return MeasurementTimeOfDayFilter.evening;
    }
    // 22:00..23:59 plus 00:00..05:59.
    return MeasurementTimeOfDayFilter.night;
  }

  /// Whether [time] (interpreted in device-local time) belongs to [filter].
  static bool matches(
    DateTime time,
    MeasurementTimeOfDayFilter filter,
  ) {
    if (filter == MeasurementTimeOfDayFilter.all) return true;
    return classify(time) == filter;
  }

  /// Applies the optional [from] cutoff and the [timeOfDay] filter to a set
  /// of data points, preserving their incoming (chronological) order.
  ///
  /// This is the single filtering pipeline shared by the Trends provider, so
  /// the final dataset used for the chart, the Y-axis scale, statistics and
  /// empty-state detection is always the same.
  static List<MeasurementDataPoint> filterDataPoints({
    required List<MeasurementDataPoint> dataPoints,
    required MeasurementTimeOfDayFilter timeOfDay,
    DateTime? from,
  }) {
    return dataPoints.where(
      (point) {
        final timestamp = point.record.timestamp;
        if (from != null && timestamp.isBefore(from)) return false;
        if (!matches(timestamp, timeOfDay)) return false;
        return true;
      },
    ).toList();
  }
}