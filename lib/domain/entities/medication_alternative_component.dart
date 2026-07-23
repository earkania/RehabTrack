class MedicationAlternativeComponent {
  final int? id;
  final int medicationAlternativeId;
  final String? componentName;
  final String doseAmount;
  final String doseUnit;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MedicationAlternativeComponent({
    this.id,
    required this.medicationAlternativeId,
    this.componentName,
    required this.doseAmount,
    required this.doseUnit,
    this.sortOrder = 0,
    required this.createdAt,
    this.updatedAt,
  });

  MedicationAlternativeComponent copyWith({
    int? id,
    int? medicationAlternativeId,
    String? componentName,
    String? doseAmount,
    String? doseUnit,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicationAlternativeComponent(
      id: id ?? this.id,
      medicationAlternativeId:
          medicationAlternativeId ?? this.medicationAlternativeId,
      componentName: componentName ?? this.componentName,
      doseAmount: doseAmount ?? this.doseAmount,
      doseUnit: doseUnit ?? this.doseUnit,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
