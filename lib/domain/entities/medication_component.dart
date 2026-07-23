class MedicationComponent {
  final int? id;
  final int medicationId;
  final String? componentName;
  final String doseAmount;
  final String doseUnit;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MedicationComponent({
    this.id,
    required this.medicationId,
    this.componentName,
    required this.doseAmount,
    required this.doseUnit,
    this.sortOrder = 0,
    required this.createdAt,
    this.updatedAt,
  });

  MedicationComponent copyWith({
    int? id,
    int? medicationId,
    String? componentName,
    String? doseAmount,
    String? doseUnit,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicationComponent(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      componentName: componentName ?? this.componentName,
      doseAmount: doseAmount ?? this.doseAmount,
      doseUnit: doseUnit ?? this.doseUnit,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
