enum HistoryPeriod {
  last7Days,
  last30Days,
  allTime;

  DateTime? get from {
    switch (this) {
      case HistoryPeriod.last7Days:
        return DateTime.now().subtract(const Duration(days: 7));
      case HistoryPeriod.last30Days:
        return DateTime.now().subtract(const Duration(days: 30));
      case HistoryPeriod.allTime:
        return null;
    }
  }
}
