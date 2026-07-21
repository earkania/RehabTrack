import 'package:rehab_track/domain/entities/schedule_config.dart';

class MeasurementType {
  final int? id;
  final int? profileId;
  final String name;
  final String unit;
  final String measurementCategory;
  final bool isSystem;
  final bool active;

  const MeasurementType({
    this.id,
    this.profileId,
    required this.name,
    required this.unit,
    required this.measurementCategory,
    this.isSystem = false,
    this.active = true,
  });

  MeasurementType copyWith({
    int? id,
    int? profileId,
    String? name,
    String? unit,
    String? measurementCategory,
    bool? isSystem,
    bool? active,
  }) {
    return MeasurementType(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      measurementCategory:
          measurementCategory ?? this.measurementCategory,
      isSystem: isSystem ?? this.isSystem,
      active: active ?? this.active,
    );
  }
}

class MeasurementRecord {
  final int? id;
  final int profileId;
  final int measurementTypeId;
  final DateTime timestamp;
  final double valuePrimary;
  final double? valueSecondary;
  final double? valueTertiary;
  final String unit;
  final String? notes;
  final DateTime createdAt;

  const MeasurementRecord({
    this.id,
    required this.profileId,
    required this.measurementTypeId,
    required this.timestamp,
    required this.valuePrimary,
    this.valueSecondary,
    this.valueTertiary,
    required this.unit,
    this.notes,
    required this.createdAt,
  });

  MeasurementRecord copyWith({
    int? id,
    int? profileId,
    int? measurementTypeId,
    DateTime? timestamp,
    double? valuePrimary,
    double? valueSecondary,
    double? valueTertiary,
    String? unit,
    String? notes,
    DateTime? createdAt,
  }) {
    return MeasurementRecord(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      measurementTypeId:
          measurementTypeId ?? this.measurementTypeId,
      timestamp: timestamp ?? this.timestamp,
      valuePrimary: valuePrimary ?? this.valuePrimary,
      valueSecondary: valueSecondary ?? this.valueSecondary,
      valueTertiary: valueTertiary ?? this.valueTertiary,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MeasurementSchedule {
  final int? id;
  final int profileId;
  final int measurementTypeId;
  final ScheduleConfig scheduleConfig;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool active;

  const MeasurementSchedule({
    this.id,
    required this.profileId,
    required this.measurementTypeId,
    required this.scheduleConfig,
    this.startDate,
    this.endDate,
    this.active = true,
  });

  MeasurementSchedule copyWith({
    int? id,
    int? profileId,
    int? measurementTypeId,
    ScheduleConfig? scheduleConfig,
    DateTime? startDate,
    DateTime? endDate,
    bool? active,
  }) {
    return MeasurementSchedule(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      measurementTypeId:
          measurementTypeId ?? this.measurementTypeId,
      scheduleConfig: scheduleConfig ?? this.scheduleConfig,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      active: active ?? this.active,
    );
  }
}
