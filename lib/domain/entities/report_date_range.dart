/// Date-range presets offered by the Health Report configuration.
enum ReportDateRangeType {
  last7Days,
  last30Days,
  last90Days,
  custom,
  allTime,
}

/// A fully resolved, half-open local date range:
///
/// - [startInclusive] is the beginning of the first local day.
/// - [endExclusive] is the beginning of the day AFTER the last included day,
///   so late-night records on the final selected day are always covered by
///   `timestamp >= startInclusive && timestamp < endExclusive`.
///
/// For [ReportDateRangeType.allTime] both bounds are null (unbounded).
class ResolvedReportDateRange {
  const ResolvedReportDateRange({
    required this.type,
    this.startInclusive,
    this.endExclusive,
  });

  final ReportDateRangeType type;
  final DateTime? startInclusive;
  final DateTime? endExclusive;

  bool get unbounded => startInclusive == null && endExclusive == null;

  /// Inclusive upper bound for repositories that query with
  /// `timestamp <= to` and store second-precision timestamps: the last whole
  /// second before [endExclusive].
  DateTime? get inclusiveQueryEnd {
    final end = endExclusive;
    if (end == null) return null;
    return end.subtract(const Duration(seconds: 1));
  }
}

class ReportDateRangeResolver {
  const ReportDateRangeResolver._();

  /// Resolves a range preset against [now].
  ///
  /// For [ReportDateRangeType.custom] both bounds must be dates (any time of
  /// day); they are normalized to local day boundaries. Throws
  /// [ArgumentError] when only one bound is set or when the start day is
  /// after the end day.
  static ResolvedReportDateRange resolve(
    ReportDateRangeType type,
    DateTime now, {
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    switch (type) {
      case ReportDateRangeType.last7Days:
        return _lastNDays(now, 7);
      case ReportDateRangeType.last30Days:
        return _lastNDays(now, 30);
      case ReportDateRangeType.last90Days:
        return _lastNDays(now, 90);
      case ReportDateRangeType.custom:
        if (customStart == null || customEnd == null) {
          throw ArgumentError('Custom range requires both bounds');
        }
        final start = _startOfDay(customStart);
        final end = _startOfDay(customEnd);
        if (start.isAfter(end)) {
          throw ArgumentError('Custom range start is after end');
        }
        return ResolvedReportDateRange(
          type: type,
          startInclusive: start,
          endExclusive: end.add(const Duration(days: 1)),
        );
      case ReportDateRangeType.allTime:
        return const ResolvedReportDateRange(type: ReportDateRangeType.allTime);
    }
  }

  static ResolvedReportDateRange _lastNDays(DateTime now, int days) {
    final todayStart = _startOfDay(now);
    return ResolvedReportDateRange(
      type: days == 7
          ? ReportDateRangeType.last7Days
          : days == 30
              ? ReportDateRangeType.last30Days
              : ReportDateRangeType.last90Days,
      // Today plus the previous (days - 1) calendar days.
      startInclusive: todayStart.subtract(Duration(days: days - 1)),
      endExclusive: todayStart.add(const Duration(days: 1)),
    );
  }

  static DateTime _startOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
}
