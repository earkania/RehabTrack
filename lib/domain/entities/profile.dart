enum Gender { male, female, other, unspecified }

enum Relationship {
  self,
  child,
  spouse,
  parent,
  sibling,
  grandparent,
  grandchild,
  other,
}

class Profile {
  final int? id;
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final String? bloodType;
  final String? allergies;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? phone;
  final String? email;
  final String? address;
  final String? relationshipToOwner;
  final bool isPrimary;
  final bool isActive;
  final String? photoPath;

  const Profile({
    this.id,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.bloodType,
    this.allergies,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.phone,
    this.email,
    this.address,
    this.relationshipToOwner,
    this.isPrimary = false,
    this.isActive = true,
    this.photoPath,
  });

  String get fullName => '$firstName $lastName';

  Relationship? get parsedRelationship {
    if (relationshipToOwner == null) return null;
    return Relationship.values.asNameMap()[relationshipToOwner];
  }

  Profile copyWith({
    int? id,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? bloodType,
    String? allergies,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? phone,
    String? email,
    String? address,
    String? relationshipToOwner,
    bool? isPrimary,
    bool? isActive,
    String? photoPath,
  }) {
    return Profile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      emergencyContactName:
          emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      relationshipToOwner:
          relationshipToOwner ?? this.relationshipToOwner,
      isPrimary: isPrimary ?? this.isPrimary,
      isActive: isActive ?? this.isActive,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}
