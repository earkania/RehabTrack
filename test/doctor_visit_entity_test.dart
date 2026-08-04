import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/doctor_visit_record.dart';
import 'package:rehab_track/domain/enums/enums.dart';

void main() {
  final now = DateTime(2026, 8, 1, 10, 0);

  DoctorVisitRecord makeVisit({
    int? id = 1,
    int? doctorContactId,
    int? organizationContactId,
    DoctorVisitType visitType = DoctorVisitType.planned,
    DoctorVisitStatus status = DoctorVisitStatus.scheduled,
    DateTime? scheduledDateTime,
    String? reason,
    String? notes,
    bool reminderEnabled = false,
    int reminderMinutesBefore = 1440,
    bool isArchived = false,
  }) {
    return DoctorVisitRecord(
      id: id,
      profileId: 1,
      doctorContactId: doctorContactId,
      organizationContactId: organizationContactId,
      visitType: visitType,
      status: status,
      scheduledDateTime: scheduledDateTime ?? now,
      reason: reason,
      notes: notes,
      reminderEnabled: reminderEnabled,
      reminderMinutesBefore: reminderMinutesBefore,
      isArchived: isArchived,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('DoctorVisitRecord', () {
    test('defaults reminder and archive flags', () {
      final visit = makeVisit();
      expect(visit.reminderEnabled, isFalse);
      expect(visit.reminderMinutesBefore, 1440);
      expect(visit.isArchived, isFalse);
    });

    test('isOpen only for scheduled visits', () {
      expect(makeVisit(status: DoctorVisitStatus.scheduled).isOpen, isTrue);
      expect(makeVisit(status: DoctorVisitStatus.completed).isOpen, isFalse);
      expect(makeVisit(status: DoctorVisitStatus.cancelled).isOpen, isFalse);
      expect(makeVisit(status: DoctorVisitStatus.missed).isOpen, isFalse);
    });

    test('isFutureScheduled true for a future scheduled visit', () {
      final visit = makeVisit(
        scheduledDateTime: DateTime.now().add(const Duration(days: 1)),
      );
      expect(visit.isFutureScheduled, isTrue);
    });

    test('isFutureScheduled false for a terminal visit', () {
      final visit = makeVisit(
        status: DoctorVisitStatus.completed,
        scheduledDateTime: DateTime.now().add(const Duration(days: 1)),
      );
      expect(visit.isFutureScheduled, isFalse);
    });

    test('isFutureScheduled false for a past open visit', () {
      final visit = makeVisit(
        scheduledDateTime: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(visit.isFutureScheduled, isFalse);
    });

    test('copyWith updates fields', () {
      final visit = makeVisit(reason: 'Original');
      final updated = visit.copyWith(
        status: DoctorVisitStatus.completed,
        reason: 'Done',
        reminderEnabled: true,
      );
      expect(updated.status, DoctorVisitStatus.completed);
      expect(updated.reason, 'Done');
      expect(updated.reminderEnabled, isTrue);
      expect(updated.doctorContactId, isNull);
    });

    test('copyWith clearDoctorContactId clears the reference', () {
      final visit = makeVisit(doctorContactId: 5);
      final updated = visit.copyWith(clearDoctorContactId: true);
      expect(updated.doctorContactId, isNull);
      expect(updated.organizationContactId, isNull);
    });

    test('copyWith preserves existing contacts unless cleared', () {
      final visit = makeVisit(doctorContactId: 5, organizationContactId: 7);
      final updated = visit.copyWith(reminderEnabled: true);
      expect(updated.doctorContactId, 5);
      expect(updated.organizationContactId, 7);
    });
  });

  group('DoctorVisitStatus.isTerminal', () {
    test('only completed, cancelled, and missed are terminal', () {
      expect(DoctorVisitStatus.scheduled.isTerminal, isFalse);
      expect(DoctorVisitStatus.completed.isTerminal, isTrue);
      expect(DoctorVisitStatus.cancelled.isTerminal, isTrue);
      expect(DoctorVisitStatus.missed.isTerminal, isTrue);
    });
  });

  group('Enum fromString fallbacks', () {
    test('DoctorVisitType.fromString falls back to planned', () {
      expect(DoctorVisitType.fromString('planned'), DoctorVisitType.planned);
      expect(DoctorVisitType.fromString('onDemand'), DoctorVisitType.onDemand);
      expect(DoctorVisitType.fromString('bogus'), DoctorVisitType.planned);
    });

    test('DoctorVisitStatus.fromString falls back to scheduled', () {
      expect(DoctorVisitStatus.fromString('scheduled'),
          DoctorVisitStatus.scheduled);
      expect(
          DoctorVisitStatus.fromString('completed'), DoctorVisitStatus.completed);
      expect(DoctorVisitStatus.fromString('cancelled'),
          DoctorVisitStatus.cancelled);
      expect(DoctorVisitStatus.fromString('missed'), DoctorVisitStatus.missed);
      expect(DoctorVisitStatus.fromString('bogus'),
          DoctorVisitStatus.scheduled);
    });
  });
}
