enum MeasurementPeriod {
  last7Days,
  last30Days,
  last90Days,
  allTime;

  DateTime? get from {
    switch (this) {
      case last7Days:
        return DateTime.now().subtract(const Duration(days: 7));
      case last30Days:
        return DateTime.now().subtract(const Duration(days: 30));
      case last90Days:
        return DateTime.now().subtract(const Duration(days: 90));
      case allTime:
        return null;
    }
  }
}
