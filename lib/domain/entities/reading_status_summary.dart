class ReadingStatusSummary {
  final int belowCount;
  final int withinCount;
  final int aboveCount;
  final int unknownCount;
  final int irregularHeartbeatCount;

  const ReadingStatusSummary({
    required this.belowCount,
    required this.withinCount,
    required this.aboveCount,
    required this.unknownCount,
    this.irregularHeartbeatCount = 0,
  });

  int get total => belowCount + withinCount + aboveCount + unknownCount;

  bool get hasIrregularHeartbeat => irregularHeartbeatCount > 0;

  static const empty = ReadingStatusSummary(
    belowCount: 0,
    withinCount: 0,
    aboveCount: 0,
    unknownCount: 0,
    irregularHeartbeatCount: 0,
  );
}
