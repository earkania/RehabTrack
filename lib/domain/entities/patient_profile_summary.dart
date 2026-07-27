import 'package:rehab_track/domain/entities/profile.dart';

class PatientProfileSummary {
  final Profile profile;
  final int activeMedicationCount;
  final int activeMeasurementScheduleCount;
  final int totalMeasurementsLast30Days;
  final int completedMedicationsLast7Days;
  final int missedMedicationsLast7Days;
  final DateTime? lastActivityDate;

  const PatientProfileSummary({
    required this.profile,
    this.activeMedicationCount = 0,
    this.activeMeasurementScheduleCount = 0,
    this.totalMeasurementsLast30Days = 0,
    this.completedMedicationsLast7Days = 0,
    this.missedMedicationsLast7Days = 0,
    this.lastActivityDate,
  });

  int? get age {
    if (profile.birthDate == null) return null;
    final now = DateTime.now();
    var age = now.year - profile.birthDate!.year;
    if (now.month < profile.birthDate!.month ||
        (now.month == profile.birthDate!.month &&
            now.day < profile.birthDate!.day)) {
      age--;
    }
    return age;
  }

  double get medicationAdherenceRate {
    final total =
        completedMedicationsLast7Days + missedMedicationsLast7Days;
    if (total == 0) return 0;
    return completedMedicationsLast7Days / total;
  }

  PatientProfileSummary copyWith({
    Profile? profile,
    int? activeMedicationCount,
    int? activeMeasurementScheduleCount,
    int? totalMeasurementsLast30Days,
    int? completedMedicationsLast7Days,
    int? missedMedicationsLast7Days,
    DateTime? lastActivityDate,
  }) {
    return PatientProfileSummary(
      profile: profile ?? this.profile,
      activeMedicationCount:
          activeMedicationCount ?? this.activeMedicationCount,
      activeMeasurementScheduleCount:
          activeMeasurementScheduleCount ?? this.activeMeasurementScheduleCount,
      totalMeasurementsLast30Days:
          totalMeasurementsLast30Days ?? this.totalMeasurementsLast30Days,
      completedMedicationsLast7Days:
          completedMedicationsLast7Days ?? this.completedMedicationsLast7Days,
      missedMedicationsLast7Days:
          missedMedicationsLast7Days ?? this.missedMedicationsLast7Days,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }
}
