import 'package:rehab_track/domain/entities/schedule_config.dart';

class Medication {
  final int? id;
  final int profileId;
  final String name;
  final String? description;
  /// @deprecated Use MedicationComponents table instead. Kept temporarily for migration compatibility.
  final String? doseAmount;
  /// @deprecated Use MedicationComponents table instead. Kept temporarily for migration compatibility.
  final String? doseUnit;
  final bool active;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Medication({
    this.id,
    required this.profileId,
    required this.name,
    this.description,
    this.doseAmount,
    this.doseUnit,
    this.active = true,
    this.startDate,
    this.endDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Medication copyWith({
    int? id,
    int? profileId,
    String? name,
    String? description,
    String? doseAmount,
    String? doseUnit,
    bool? active,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medication(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      description: description ?? this.description,
      doseAmount: doseAmount ?? this.doseAmount,
      doseUnit: doseUnit ?? this.doseUnit,
      active: active ?? this.active,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MedicationSchedule {
  final int? id;
  final int medicationId;
  final String scheduleType;
  final ScheduleConfig scheduleConfig;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? instructions;
  final bool active;

  const MedicationSchedule({
    this.id,
    required this.medicationId,
    required this.scheduleType,
    required this.scheduleConfig,
    this.startDate,
    this.endDate,
    this.instructions,
    this.active = true,
  });

  MedicationSchedule copyWith({
    int? id,
    int? medicationId,
    String? scheduleType,
    ScheduleConfig? scheduleConfig,
    DateTime? startDate,
    DateTime? endDate,
    String? instructions,
    bool? active,
  }) {
    return MedicationSchedule(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      scheduleType: scheduleType ?? this.scheduleType,
      scheduleConfig: scheduleConfig ?? this.scheduleConfig,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      instructions: instructions ?? this.instructions,
      active: active ?? this.active,
    );
  }
}

class MedicationLog {
  final int? id;
  final int medicationScheduleId;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final String status;
  final String? notes;
  final DateTime createdAt;

  const MedicationLog({
    this.id,
    required this.medicationScheduleId,
    required this.scheduledTime,
    this.takenTime,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  MedicationLog copyWith({
    int? id,
    int? medicationScheduleId,
    DateTime? scheduledTime,
    DateTime? takenTime,
    String? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return MedicationLog(
      id: id ?? this.id,
      medicationScheduleId:
          medicationScheduleId ?? this.medicationScheduleId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenTime: takenTime ?? this.takenTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
