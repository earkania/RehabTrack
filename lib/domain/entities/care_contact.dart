import 'package:rehab_track/domain/enums/enums.dart';

/// A Care Contact — an individual medical professional or a healthcare-related
/// organization. Belongs to exactly one Patient Profile (profileId).
///
/// Type-specific fields (specialty, organizationName, contactPerson,
/// workingHours, policyNumber, memberNumber) are nullable and only populated
/// for the matching contact type.
class CareContact {
  final int? id;
  final int profileId;
  final CareContactType contactType;
  final String displayName;
  final String? firstName;
  final String? lastName;
  final String? specialty;
  final String? organizationName;
  final String? department;
  final String? contactPerson;
  final String? primaryPhone;
  final String? secondaryPhone;
  final String? email;
  final String? website;
  final String? address;
  final String? workingHours;
  final String? policyNumber;
  final String? memberNumber;
  final String? notes;
  final String? photoPath;
  final bool isFavorite;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CareContact({
    this.id,
    required this.profileId,
    required this.contactType,
    required this.displayName,
    this.firstName,
    this.lastName,
    this.specialty,
    this.organizationName,
    this.department,
    this.contactPerson,
    this.primaryPhone,
    this.secondaryPhone,
    this.email,
    this.website,
    this.address,
    this.workingHours,
    this.policyNumber,
    this.memberNumber,
    this.notes,
    this.photoPath,
    this.isFavorite = false,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// The fallback name derived from type-specific name fields when no explicit
  /// display name is present. This is the single source of the fallback rules;
  /// it must never be persisted as a display name.
  static String fallbackName({
    required CareContactType contactType,
    String? firstName,
    String? lastName,
    String? organizationName,
  }) {
    if (contactType == CareContactType.doctor) {
      final given = firstName?.trim() ?? '';
      final family = lastName?.trim() ?? '';
      final combined = [given, family].where((s) => s.isNotEmpty).join(' ');
      if (combined.isNotEmpty) return combined;
    }
    final org = organizationName?.trim();
    if (org != null && org.isNotEmpty) return org;
    return '';
  }

  /// Whether the stored [displayName] is an explicit user-entered alias. A
  /// value is considered generated (non-explicit) when it exactly equals the
  /// fallback derivable from this contact's own name fields. Such values are
  /// cleared on save so the effective name always reflects current fields.
  bool get isExplicitDisplayName {
    final stored = displayName.trim();
    if (stored.isEmpty) return false;
    return stored != fallbackName(
      contactType: contactType,
      firstName: firstName,
      lastName: lastName,
      organizationName: organizationName,
    );
  }

  /// Initials derived from the effective display name (used by the avatar).
  String get initials {
    final name = effectiveDisplayName.trim();
    if (name.isEmpty) return '?';
    final parts =
        name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, 1).toUpperCase();
  }

  /// The canonical, single computed identity used for list rows, details,
  /// search, sorting, and initials. Explicit user-entered display name first,
  /// otherwise derived from type-specific name fields. Never persisted.
  String get effectiveDisplayName {
    if (displayName.trim().isNotEmpty) return displayName.trim();
    return fallbackName(
      contactType: contactType,
      firstName: firstName,
      lastName: lastName,
      organizationName: organizationName,
    );
  }

  CareContact copyWith({
    int? id,
    int? profileId,
    CareContactType? contactType,
    String? displayName,
    String? firstName,
    String? lastName,
    String? specialty,
    String? organizationName,
    String? department,
    String? contactPerson,
    String? primaryPhone,
    String? secondaryPhone,
    String? email,
    String? website,
    String? address,
    String? workingHours,
    String? policyNumber,
    String? memberNumber,
    String? notes,
    String? photoPath,
    bool? isFavorite,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CareContact(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      contactType: contactType ?? this.contactType,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      specialty: specialty ?? this.specialty,
      organizationName: organizationName ?? this.organizationName,
      department: department ?? this.department,
      contactPerson: contactPerson ?? this.contactPerson,
      primaryPhone: primaryPhone ?? this.primaryPhone,
      secondaryPhone: secondaryPhone ?? this.secondaryPhone,
      email: email ?? this.email,
      website: website ?? this.website,
      address: address ?? this.address,
      workingHours: workingHours ?? this.workingHours,
      policyNumber: policyNumber ?? this.policyNumber,
      memberNumber: memberNumber ?? this.memberNumber,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
