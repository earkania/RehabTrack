import 'package:rehab_track/domain/entities/reading_status.dart';

class MeasurementChartPoint {
  final int recordId;
  final DateTime measuredAt;
  final double numericValue;
  final String unit;
  final ReadingStatus readingStatus;
  final bool irregularHeartbeatDetected;

  const MeasurementChartPoint({
    required this.recordId,
    required this.measuredAt,
    required this.numericValue,
    required this.unit,
    required this.readingStatus,
    this.irregularHeartbeatDetected = false,
  });
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
