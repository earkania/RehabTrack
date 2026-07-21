class MedicationAlternative {
  final int? id;
  final int medicationId;
  final String name;
  final String? doseAmount;
  final String? doseUnit;
  final bool doctorApproved;
  final String? notes;
  final DateTime createdAt;

  const MedicationAlternative({
    this.id,
    required this.medicationId,
    required this.name,
    this.doseAmount,
    this.doseUnit,
    this.doctorApproved = false,
    this.notes,
    required this.createdAt,
  });

  MedicationAlternative copyWith({
    int? id,
    int? medicationId,
    String? name,
    String? doseAmount,
    String? doseUnit,
    bool? doctorApproved,
    String? notes,
    DateTime? createdAt,
  }) {
    return MedicationAlternative(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      name: name ?? this.name,
      doseAmount: doseAmount ?? this.doseAmount,
      doseUnit: doseUnit ?? this.doseUnit,
      doctorApproved: doctorApproved ?? this.doctorApproved,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
