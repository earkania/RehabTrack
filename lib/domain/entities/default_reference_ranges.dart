import 'package:rehab_track/domain/entities/reading_status.dart';

class DefaultReferenceRanges {
  DefaultReferenceRanges._();

  static final Map<String, MeasurementRanges> ranges = {
    'blood_pressure': const MeasurementRanges(fieldRanges: {
      'systolic': ReferenceRange(minValue: 90, maxValue: 120),
      'diastolic': ReferenceRange(minValue: 60, maxValue: 80),
      'pulse': ReferenceRange(minValue: 60, maxValue: 100),
    }),
    'pulse': const MeasurementRanges(fieldRanges: {
      'pulse': ReferenceRange(minValue: 60, maxValue: 100),
    }),
    'weight': const MeasurementRanges(fieldRanges: {}),
    'blood_glucose': const MeasurementRanges(fieldRanges: {
      'glucose': ReferenceRange(minValue: 3.9, maxValue: 7.8),
    }),
    'spo2': const MeasurementRanges(fieldRanges: {
      'spo2': ReferenceRange(minValue: 95, maxValue: 100),
      'pulse': ReferenceRange(minValue: 60, maxValue: 100),
    }),
    'temperature': const MeasurementRanges(fieldRanges: {
      'temperature': ReferenceRange(minValue: 36.1, maxValue: 37.2),
    }),
  };

  static MeasurementRanges? rangesForType(String typeKey) {
    return ranges[typeKey];
  }
}
