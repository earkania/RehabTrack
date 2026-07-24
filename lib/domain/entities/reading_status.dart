enum ReadingStatus {
  unknown,
  belowRange,
  inRange,
  aboveRange,
}

class ReferenceRange {
  final double? minValue;
  final double? maxValue;

  const ReferenceRange({this.minValue, this.maxValue});

  bool get hasRange => minValue != null || maxValue != null;

  bool contains(double value) {
    if (minValue != null && value < minValue!) return false;
    if (maxValue != null && value > maxValue!) return false;
    return true;
  }

  bool isBelow(double value) {
    if (minValue != null && value < minValue!) return true;
    return false;
  }

  bool isAbove(double value) {
    if (maxValue != null && value > maxValue!) return true;
    return false;
  }
}

class MeasurementRanges {
  final Map<String, ReferenceRange> fieldRanges;

  const MeasurementRanges({required this.fieldRanges});

  ReferenceRange? rangeForField(String fieldKey) {
    return fieldRanges[fieldKey];
  }
}
