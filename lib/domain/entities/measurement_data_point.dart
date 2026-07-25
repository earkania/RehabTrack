import 'package:rehab_track/domain/entities/measurement.dart';

class MeasurementDataPoint {
  final MeasurementRecord record;
  final List<MeasurementRecordValue> values;

  const MeasurementDataPoint({
    required this.record,
    required this.values,
  });

  double? valueForKey(String fieldKey) {
    for (final v in values) {
      if (v.fieldKey == fieldKey) return v.numericValue;
    }
    return null;
  }

  String? unitForKey(String fieldKey) {
    for (final v in values) {
      if (v.fieldKey == fieldKey) return v.unit;
    }
    return null;
  }
}
