enum Gender {
  male,
  female,
  other;

  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }

  static Gender fromString(String value) {
    return Gender.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Gender.other,
    );
  }
}

enum MedicationDoseStatus {
  pending,
  taken,
  missed,
  skipped;

  static MedicationDoseStatus fromString(String value) {
    return MedicationDoseStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MedicationDoseStatus.pending,
    );
  }
}

enum VisitStatus {
  scheduled,
  completed,
  cancelled;

  static VisitStatus fromString(String value) {
    return VisitStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => VisitStatus.scheduled,
    );
  }
}

enum DocumentCategory {
  labResult,
  prescription,
  dietPlan,
  other;

  String get displayName {
    switch (this) {
      case DocumentCategory.labResult:
        return 'Lab Result';
      case DocumentCategory.prescription:
        return 'Prescription';
      case DocumentCategory.dietPlan:
        return 'Diet Plan';
      case DocumentCategory.other:
        return 'Other';
    }
  }

  static DocumentCategory fromString(String value) {
    return DocumentCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DocumentCategory.other,
    );
  }
}

enum DietCategory {
  recommended,
  avoid,
  limit;

  String get displayName {
    switch (this) {
      case DietCategory.recommended:
        return 'Recommended';
      case DietCategory.avoid:
        return 'Avoid';
      case DietCategory.limit:
        return 'Limit';
    }
  }

  static DietCategory fromString(String value) {
    return DietCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DietCategory.recommended,
    );
  }
}

enum MeasurementCategory {
  vital,
  metabolic,
  body,
  custom;

  String get displayName {
    switch (this) {
      case MeasurementCategory.vital:
        return 'Vital Signs';
      case MeasurementCategory.metabolic:
        return 'Metabolic';
      case MeasurementCategory.body:
        return 'Body';
      case MeasurementCategory.custom:
        return 'Custom';
    }
  }

  static MeasurementCategory fromString(String value) {
    return MeasurementCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MeasurementCategory.custom,
    );
  }
}
