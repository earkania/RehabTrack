class ExerciseType {
  final int? id;
  final int profileId;
  final String name;
  final String unit;
  final String? notes;
  final bool active;

  const ExerciseType({
    this.id,
    required this.profileId,
    required this.name,
    required this.unit,
    this.notes,
    this.active = true,
  });

  ExerciseType copyWith({
    int? id,
    int? profileId,
    String? name,
    String? unit,
    String? notes,
    bool? active,
  }) {
    return ExerciseType(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      active: active ?? this.active,
    );
  }
}

class ExerciseGoal {
  final int? id;
  final int profileId;
  final int exerciseTypeId;
  final double targetValue;
  final String targetUnit;
  final String? frequency;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool active;

  const ExerciseGoal({
    this.id,
    required this.profileId,
    required this.exerciseTypeId,
    required this.targetValue,
    required this.targetUnit,
    this.frequency,
    this.startDate,
    this.endDate,
    this.active = true,
  });

  ExerciseGoal copyWith({
    int? id,
    int? profileId,
    int? exerciseTypeId,
    double? targetValue,
    String? targetUnit,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    bool? active,
  }) {
    return ExerciseGoal(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      exerciseTypeId: exerciseTypeId ?? this.exerciseTypeId,
      targetValue: targetValue ?? this.targetValue,
      targetUnit: targetUnit ?? this.targetUnit,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      active: active ?? this.active,
    );
  }
}

class ExerciseLog {
  final int? id;
  final int profileId;
  final int exerciseTypeId;
  final DateTime logDate;
  final int? durationMinutes;
  final double? distance;
  final int? calories;
  final String? notes;

  const ExerciseLog({
    this.id,
    required this.profileId,
    required this.exerciseTypeId,
    required this.logDate,
    this.durationMinutes,
    this.distance,
    this.calories,
    this.notes,
  });

  ExerciseLog copyWith({
    int? id,
    int? profileId,
    int? exerciseTypeId,
    DateTime? logDate,
    int? durationMinutes,
    double? distance,
    int? calories,
    String? notes,
  }) {
    return ExerciseLog(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      exerciseTypeId: exerciseTypeId ?? this.exerciseTypeId,
      logDate: logDate ?? this.logDate,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      distance: distance ?? this.distance,
      calories: calories ?? this.calories,
      notes: notes ?? this.notes,
    );
  }
}
