class Doctor {
  final int? id;
  final int profileId;
  final String firstName;
  final String lastName;
  final String? specialty;
  final String? phone;
  final String? email;
  final String? clinic;
  final String? notes;

  const Doctor({
    this.id,
    required this.profileId,
    required this.firstName,
    required this.lastName,
    this.specialty,
    this.phone,
    this.email,
    this.clinic,
    this.notes,
  });

  Doctor copyWith({
    int? id,
    int? profileId,
    String? firstName,
    String? lastName,
    String? specialty,
    String? phone,
    String? email,
    String? clinic,
    String? notes,
  }) {
    return Doctor(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      specialty: specialty ?? this.specialty,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      clinic: clinic ?? this.clinic,
      notes: notes ?? this.notes,
    );
  }

  String get fullName => '$firstName $lastName';
}

class DoctorVisit {
  final int? id;
  final int profileId;
  final int doctorId;
  final DateTime visitDate;
  final String status;
  final String? reason;
  final String? notes;
  final bool reminderEnabled;
  final int reminderMinutesBefore;

  const DoctorVisit({
    this.id,
    required this.profileId,
    required this.doctorId,
    required this.visitDate,
    required this.status,
    this.reason,
    this.notes,
    this.reminderEnabled = false,
    this.reminderMinutesBefore = 60,
  });

  DoctorVisit copyWith({
    int? id,
    int? profileId,
    int? doctorId,
    DateTime? visitDate,
    String? status,
    String? reason,
    String? notes,
    bool? reminderEnabled,
    int? reminderMinutesBefore,
  }) {
    return DoctorVisit(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      doctorId: doctorId ?? this.doctorId,
      visitDate: visitDate ?? this.visitDate,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
    );
  }
}
