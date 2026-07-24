class ProfileReferenceRange {
  final int? id;
  final int profileId;
  final String typeKey;
  final String fieldKey;
  final double? minValue;
  final double? maxValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileReferenceRange({
    this.id,
    required this.profileId,
    required this.typeKey,
    required this.fieldKey,
    this.minValue,
    this.maxValue,
    required this.createdAt,
    required this.updatedAt,
  });

  ProfileReferenceRange copyWith({
    int? id,
    int? profileId,
    String? typeKey,
    String? fieldKey,
    double? minValue,
    double? maxValue,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearMinValue = false,
    bool clearMaxValue = false,
  }) {
    return ProfileReferenceRange(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      typeKey: typeKey ?? this.typeKey,
      fieldKey: fieldKey ?? this.fieldKey,
      minValue: clearMinValue ? null : (minValue ?? this.minValue),
      maxValue: clearMaxValue ? null : (maxValue ?? this.maxValue),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
