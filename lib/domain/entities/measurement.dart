import 'package:rehab_track/domain/entities/schedule_config.dart';

class MeasurementType {
  final int? id;
  final int? profileId;
  final String? key;
  final String name;
  final String unit;
  final String? defaultUnit;
  final String measurementCategory;
  final bool isSystem;
  final bool active;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MeasurementType({
    this.id,
    this.profileId,
    this.key,
    required this.name,
    required this.unit,
    this.defaultUnit,
    required this.measurementCategory,
    this.isSystem = false,
    this.active = true,
    this.displayOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  MeasurementType copyWith({
    int? id,
    int? profileId,
    String? key,
    String? name,
    String? unit,
    String? defaultUnit,
    String? measurementCategory,
    bool? isSystem,
    bool? active,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MeasurementType(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      key: key ?? this.key,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      defaultUnit: defaultUnit ?? this.defaultUnit,
      measurementCategory:
          measurementCategory ?? this.measurementCategory,
      isSystem: isSystem ?? this.isSystem,
      active: active ?? this.active,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MeasurementTypeField {
  final int? id;
  final int measurementTypeId;
  final String fieldKey;
  final String label;
  final String? defaultUnit;
  final bool required;
  final double? minimumValue;
  final double? maximumValue;
  final int decimalPlaces;
  final int displayOrder;
  final DateTime createdAt;

  const MeasurementTypeField({
    this.id,
    required this.measurementTypeId,
    required this.fieldKey,
    required this.label,
    this.defaultUnit,
    this.required = true,
    this.minimumValue,
    this.maximumValue,
    this.decimalPlaces = 1,
    this.displayOrder = 0,
    required this.createdAt,
  });

  MeasurementTypeField copyWith({
    int? id,
    int? measurementTypeId,
    String? fieldKey,
    String? label,
    String? defaultUnit,
    bool? required,
    double? minimumValue,
    double? maximumValue,
    int? decimalPlaces,
    int? displayOrder,
    DateTime? createdAt,
  }) {
    return MeasurementTypeField(
      id: id ?? this.id,
      measurementTypeId:
          measurementTypeId ?? this.measurementTypeId,
      fieldKey: fieldKey ?? this.fieldKey,
      label: label ?? this.label,
      defaultUnit: defaultUnit ?? this.defaultUnit,
      required: required ?? this.required,
      minimumValue: minimumValue ?? this.minimumValue,
      maximumValue: maximumValue ?? this.maximumValue,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
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
  final DateTime? updatedAt;

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
    this.updatedAt,
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
    DateTime? updatedAt,
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
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MeasurementRecordValue {
  final int? id;
  final int measurementRecordId;
  final String fieldKey;
  final double numericValue;
  final String unit;
  final int displayOrder;

  const MeasurementRecordValue({
    this.id,
    required this.measurementRecordId,
    required this.fieldKey,
    required this.numericValue,
    required this.unit,
    this.displayOrder = 0,
  });

  MeasurementRecordValue copyWith({
    int? id,
    int? measurementRecordId,
    String? fieldKey,
    double? numericValue,
    String? unit,
    int? displayOrder,
  }) {
    return MeasurementRecordValue(
      id: id ?? this.id,
      measurementRecordId:
          measurementRecordId ?? this.measurementRecordId,
      fieldKey: fieldKey ?? this.fieldKey,
      numericValue: numericValue ?? this.numericValue,
      unit: unit ?? this.unit,
      displayOrder: displayOrder ?? this.displayOrder,
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
