import 'package:rehab_track/domain/entities/reading_status.dart';

class ReadingStatusCalculator {
  ReadingStatusCalculator._();

  static ReadingStatus calculate({
    required String typeKey,
    required Map<String, double> fieldValues,
    MeasurementRanges? ranges,
  }) {
    if (ranges == null) return ReadingStatus.unknown;
    if (ranges.fieldRanges.isEmpty) return ReadingStatus.unknown;

    return switch (typeKey) {
      'blood_pressure' => _calculateBloodPressure(fieldValues, ranges),
      _ => _calculateSingleField(fieldValues, ranges),
    };
  }

  static ReadingStatus calculateFieldValue({
    required String fieldKey,
    required double? value,
    required MeasurementRanges? ranges,
  }) {
    if (ranges == null) return ReadingStatus.unknown;
    final range = ranges.rangeForField(fieldKey);
    if (value == null || range == null || !range.hasRange) {
      return ReadingStatus.unknown;
    }

    if (range.isAbove(value)) return ReadingStatus.aboveRange;
    if (range.isBelow(value)) return ReadingStatus.belowRange;
    return ReadingStatus.inRange;
  }

  static ReadingStatus _calculateBloodPressure(
    Map<String, double> values,
    MeasurementRanges ranges,
  ) {
    final sysRange = ranges.rangeForField('systolic');
    final diaRange = ranges.rangeForField('diastolic');
    final sys = values['systolic'];
    final dia = values['diastolic'];

    if (sys == null || dia == null) return ReadingStatus.unknown;
    if (sysRange == null && diaRange == null) return ReadingStatus.unknown;

    final sysAbove = sysRange?.isAbove(sys) ?? false;
    final diaAbove = diaRange?.isAbove(dia) ?? false;
    final sysBelow = sysRange?.isBelow(sys) ?? false;
    final diaBelow = diaRange?.isBelow(dia) ?? false;

    if (sysAbove || diaAbove) return ReadingStatus.aboveRange;
    if (sysBelow || diaBelow) return ReadingStatus.belowRange;
    return ReadingStatus.inRange;
  }

  static ReadingStatus _calculateSingleField(
    Map<String, double> values,
    MeasurementRanges ranges,
  ) {
    for (final entry in ranges.fieldRanges.entries) {
      final value = values[entry.key];
      if (value == null) continue;

      final range = entry.value;
      if (!range.hasRange) continue;

      if (range.isAbove(value)) return ReadingStatus.aboveRange;
      if (range.isBelow(value)) return ReadingStatus.belowRange;
      return ReadingStatus.inRange;
    }

    return ReadingStatus.unknown;
  }
}
