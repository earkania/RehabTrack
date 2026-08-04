import 'package:rehab_track/domain/enums/enums.dart';

/// A single doctor visit tracked in the Records → Doctor Visits module.
///
/// Distinct from the legacy `DoctorVisit` entity (which belongs to the old
/// placeholder Doctor module and requires a `doctorId`); this module stores
/// only the visit record and references optional Care Contact rows for the
/// doctor (type `doctor`) and the clinic/hospital (organization type).
class DoctorVisitRecord {
  final int? id;
  final int profileId;

  /// Care Contact of type `doctor` (optional — a visit may reference only a
  /// clinic, neither, or both).
  final int? doctorContactId;

  /// Care Contact of an organization type such as clinic/hospital (optional).
  final int? organizationContactId;

  final DoctorVisitType visitType;
  final DoctorVisitStatus status;
  final DateTime scheduledDateTime;
  final String? reason;
  final String? notes;
  final bool reminderEnabled;
  final int reminderMinutesBefore;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DoctorVisitRecord({
    this.id,
    required this.profileId,
    this.doctorContactId,
    this.organizationContactId,
    required this.visitType,
    required this.status,
    required this.scheduledDateTime,
    this.reason,
    this.notes,
    this.reminderEnabled = false,
    this.reminderMinutesBefore = 1440,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  DoctorVisitRecord copyWith({
    int? id,
    int? profileId,
    int? doctorContactId,
    int? organizationContactId,
    DoctorVisitType? visitType,
    DoctorVisitStatus? status,
    DateTime? scheduledDateTime,
    String? reason,
    String? notes,
    bool? reminderEnabled,
    int? reminderMinutesBefore,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDoctorContactId = false,
    bool clearOrganizationContactId = false,
    bool clearReason = false,
    bool clearNotes = false,
  }) {
    return DoctorVisitRecord(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      doctorContactId: clearDoctorContactId
          ? null
          : (doctorContactId ?? this.doctorContactId),
      organizationContactId: clearOrganizationContactId
          ? null
          : (organizationContactId ?? this.organizationContactId),
      visitType: visitType ?? this.visitType,
      status: status ?? this.status,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      reason: clearReason ? null : (reason ?? this.reason),
      notes: clearNotes ? null : (notes ?? this.notes),
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Whether the visit is still open (needs an action) versus terminal.
  bool get isOpen => status == DoctorVisitStatus.scheduled;

  /// Whether the visit is a scheduled-for-the-future planned visit.
  bool get isFutureScheduled {
    if (!isOpen) return false;
    final now = DateTime.now();
    return scheduledDateTime.isAfter(now);
  }
}
