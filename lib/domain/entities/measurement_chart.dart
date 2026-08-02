import 'package:rehab_track/domain/entities/reading_status.dart';

class MeasurementChartPoint {
  final int recordId;
  final DateTime measuredAt;
  final double numericValue;
  final String unit;
  final ReadingStatus readingStatus;
  final ReadingStatus? componentStatus;
  final bool irregularHeartbeatDetected;

  const MeasurementChartPoint({
    required this.recordId,
    required this.measuredAt,
    required this.numericValue,
    required this.unit,
    required this.readingStatus,
    this.componentStatus,
    this.irregularHeartbeatDetected = false,
  });

  /// The status that governs how this individual point is rendered.
  ///
  /// [componentStatus] is the status of the specific component this point
  /// belongs to (for example systolic vs diastolic vs pulse), while
  /// [readingStatus] is the overall reading status. When no component status
  /// is provided, the overall reading status is used.
  ReadingStatus get effectiveStatus => componentStatus ?? readingStatus;
}

class MeasurementChartSeries {
  final String fieldKey;
  final String label;
  final String unit;
  final List<MeasurementChartPoint> points;

  const MeasurementChartSeries({
    required this.fieldKey,
    required this.label,
    required this.unit,
    required this.points,
  });

  bool get isEmpty => points.isEmpty;
  int get length => points.length;
}
