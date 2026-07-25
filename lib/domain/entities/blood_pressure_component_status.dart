import 'package:rehab_track/domain/entities/reading_status.dart';

class BloodPressureComponentStatus {
  final ReadingStatus overallStatus;
  final ReadingStatus systolicStatus;
  final ReadingStatus diastolicStatus;
  final ReadingStatus? pulseStatus;

  const BloodPressureComponentStatus({
    required this.overallStatus,
    required this.systolicStatus,
    required this.diastolicStatus,
    this.pulseStatus,
  });
}
