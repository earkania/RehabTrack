import 'package:rehab_track/domain/entities/measurement_chart.dart';
import 'package:rehab_track/domain/entities/measurement_data_point.dart';
import 'package:rehab_track/domain/entities/measurement_statistics.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/domain/entities/reading_status_summary.dart';
import 'package:rehab_track/domain/services/reading_status_calculator.dart';

class MeasurementChartBuilder {
  MeasurementChartBuilder._();

  static List<MeasurementChartSeries> buildSeries({
    required String typeKey,
    required List<MeasurementDataPoint> dataPoints,
    required List<MeasurementTypeField> fields,
    MeasurementRanges? ranges,
  }) {
    if (dataPoints.isEmpty || fields.isEmpty) return [];

    final sorted = List<MeasurementDataPoint>.from(dataPoints)
      ..sort((a, b) => a.record.timestamp.compareTo(b.record.timestamp));

    final orderedFields = List<MeasurementTypeField>.from(fields)
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return switch (typeKey) {
      'blood_pressure' =>
        _buildBloodPressureSeries(sorted, orderedFields, ranges),
      _ => _buildGenericSeries(sorted, orderedFields, ranges),
    };
  }

  static List<MeasurementChartSeries> _buildBloodPressureSeries(
    List<MeasurementDataPoint> dataPoints,
    List<MeasurementTypeField> fields,
    MeasurementRanges? ranges,
  ) {
    final fieldKeys = ['systolic', 'diastolic', 'pulse'];
    final series = <MeasurementChartSeries>[];

    for (final fieldKey in fieldKeys) {
      final field = fields.where((f) => f.fieldKey == fieldKey).firstOrNull;
      final label = field?.label ?? fieldKey;
      final unit = dataPoints.isNotEmpty
          ? (dataPoints.first.unitForKey(fieldKey) ?? '')
          : '';

      final points = <MeasurementChartPoint>[];
      for (final dp in dataPoints) {
        final value = dp.valueForKey(fieldKey);
        if (value == null) continue;

        final pointFieldValues = <String, double>{
          'systolic': dp.valueForKey('systolic') ?? 0,
          'diastolic': dp.valueForKey('diastolic') ?? 0,
        };
        if (dp.valueForKey('pulse') != null) {
          pointFieldValues['pulse'] = dp.valueForKey('pulse')!;
        }

        final status = ReadingStatusCalculator.calculate(
          typeKey: 'blood_pressure',
          fieldValues: pointFieldValues,
          ranges: ranges,
        );

        points.add(MeasurementChartPoint(
          recordId: dp.record.id!,
          measuredAt: dp.record.timestamp,
          numericValue: value,
          unit: unit,
          readingStatus: status,
          irregularHeartbeatDetected:
              dp.record.irregularHeartbeatDetected ?? false,
        ));
      }

      if (points.isNotEmpty) {
        series.add(MeasurementChartSeries(
          fieldKey: fieldKey,
          label: label,
          unit: unit,
          points: points,
        ));
      }
    }

    return series;
  }

  static List<MeasurementChartSeries> _buildGenericSeries(
    List<MeasurementDataPoint> dataPoints,
    List<MeasurementTypeField> fields,
    MeasurementRanges? ranges,
  ) {
    final series = <MeasurementChartSeries>[];

    for (final field in fields) {
      final unit = dataPoints.isNotEmpty
          ? (dataPoints.first.unitForKey(field.fieldKey) ?? '')
          : '';

      final points = <MeasurementChartPoint>[];
      for (final dp in dataPoints) {
        final value = dp.valueForKey(field.fieldKey);
        if (value == null) continue;

        final status = ReadingStatusCalculator.calculate(
          typeKey: field.fieldKey,
          fieldValues: {field.fieldKey: value},
          ranges: ranges,
        );

        points.add(MeasurementChartPoint(
          recordId: dp.record.id!,
          measuredAt: dp.record.timestamp,
          numericValue: value,
          unit: unit,
          readingStatus: status,
        ));
      }

      if (points.isNotEmpty) {
        series.add(MeasurementChartSeries(
          fieldKey: field.fieldKey,
          label: field.label,
          unit: unit,
          points: points,
        ));
      }
    }

    return series;
  }

  static Map<String, MeasurementStatistics> computeFieldStatistics({
    required List<MeasurementChartSeries> series,
  }) {
    final stats = <String, MeasurementStatistics>{};
    for (final s in series) {
      stats[s.fieldKey] = MeasurementStatistics.compute(
        s.points.map((p) => p.numericValue).toList(),
      );
    }
    return stats;
  }

  static ReadingStatusSummary computeStatusSummary({
    required List<MeasurementChartSeries> series,
  }) {
    var below = 0;
    var within = 0;
    var above = 0;
    var unknown = 0;
    var irregular = 0;

    final seenRecords = <int>{};

    for (final s in series) {
      for (final p in s.points) {
        if (seenRecords.contains(p.recordId)) continue;
        seenRecords.add(p.recordId);

        switch (p.readingStatus) {
          case ReadingStatus.belowRange:
            below++;
          case ReadingStatus.inRange:
            within++;
          case ReadingStatus.aboveRange:
            above++;
          case ReadingStatus.unknown:
            unknown++;
        }
        if (p.irregularHeartbeatDetected) irregular++;
      }
    }

    return ReadingStatusSummary(
      belowCount: below,
      withinCount: within,
      aboveCount: above,
      unknownCount: unknown,
      irregularHeartbeatCount: irregular,
    );
  }
}
