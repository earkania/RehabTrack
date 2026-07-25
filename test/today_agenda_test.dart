import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/dosage_form.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';

void main() {
  group('TodayAgendaItem', () {
    TodayAgendaItem makeItem({
      required String id,
      required DateTime scheduledDateTime,
      required TodayAgendaItemStatus status,
      DateTime? snoozedUntil,
      TodayAgendaItemType type = TodayAgendaItemType.medication,
    }) {
      return TodayAgendaItem(
        id: id,
        type: type,
        sourceScheduleId: 1,
        scheduledDateTime: scheduledDateTime,
        title: 'Test',
        status: status,
        snoozedUntil: snoozedUntil,
      );
    }

    test('effectiveTime returns scheduledDateTime when not snoozed', () {
      final dt = DateTime(2025, 7, 25, 8, 0);
      final item = makeItem(id: '1', scheduledDateTime: dt, status: TodayAgendaItemStatus.upcoming);
      expect(item.effectiveTime, dt);
    });

    test('effectiveTime returns snoozedUntil when snoozed', () {
      final scheduled = DateTime(2025, 7, 25, 8, 0);
      final snoozed = DateTime(2025, 7, 25, 8, 10);
      final item = makeItem(
        id: '1',
        scheduledDateTime: scheduled,
        status: TodayAgendaItemStatus.snoozed,
        snoozedUntil: snoozed,
      );
      expect(item.effectiveTime, snoozed);
    });

    test('isPast returns true when effectiveTime is before now', () {
      final now = DateTime(2025, 7, 25, 12, 0);
      final item = makeItem(
        id: '1',
        scheduledDateTime: DateTime(2025, 7, 25, 8, 0),
        status: TodayAgendaItemStatus.overdue,
      );
      expect(item.isPast(now), isTrue);
    });

    test('isFuture returns true when effectiveTime is after now', () {
      final now = DateTime(2025, 7, 25, 12, 0);
      final item = makeItem(
        id: '1',
        scheduledDateTime: DateTime(2025, 7, 25, 14, 0),
        status: TodayAgendaItemStatus.upcoming,
      );
      expect(item.isFuture(now), isTrue);
    });

    test('isDue returns true when within grace window', () {
      final now = DateTime(2025, 7, 25, 12, 0);
      final item = makeItem(
        id: '1',
        scheduledDateTime: DateTime(2025, 7, 25, 12, 15),
        status: TodayAgendaItemStatus.due,
      );
      expect(item.isDue(now, const Duration(minutes: 30)), isTrue);
    });

    test('isDue returns false when past', () {
      final now = DateTime(2025, 7, 25, 12, 0);
      final item = makeItem(
        id: '1',
        scheduledDateTime: DateTime(2025, 7, 25, 11, 0),
        status: TodayAgendaItemStatus.overdue,
      );
      expect(item.isDue(now, const Duration(minutes: 30)), isFalse);
    });

    test('isActionable is true for upcoming, due, overdue, snoozed', () {
      for (final status in [
        TodayAgendaItemStatus.upcoming,
        TodayAgendaItemStatus.due,
        TodayAgendaItemStatus.overdue,
        TodayAgendaItemStatus.snoozed,
      ]) {
        final item = makeItem(
          id: '1',
          scheduledDateTime: DateTime(2025),
          status: status,
        );
        expect(item.isActionable, isTrue, reason: 'status=$status');
      }
    });

    test('isActionable is false for completed and skipped', () {
      for (final status in [
        TodayAgendaItemStatus.completed,
        TodayAgendaItemStatus.skipped,
      ]) {
        final item = makeItem(
          id: '1',
          scheduledDateTime: DateTime(2025),
          status: status,
        );
        expect(item.isActionable, isFalse, reason: 'status=$status');
      }
    });

    test('isCompleted is true for completed and skipped', () {
      for (final status in [
        TodayAgendaItemStatus.completed,
        TodayAgendaItemStatus.skipped,
      ]) {
        final item = makeItem(
          id: '1',
          scheduledDateTime: DateTime(2025),
          status: status,
        );
        expect(item.isCompleted, isTrue, reason: 'status=$status');
      }
    });

    test('strength is null by default', () {
      final item = makeItem(
        id: '1',
        scheduledDateTime: DateTime(2025),
        status: TodayAgendaItemStatus.upcoming,
      );
      expect(item.strength, isNull);
    });

    test('strength is stored when provided', () {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(2025),
        title: 'Concor',
        status: TodayAgendaItemStatus.upcoming,
        strength: '5 mg',
      );
      expect(item.strength, '5 mg');
    });

    test('intake fields default to null', () {
      final item = makeItem(
        id: '1',
        scheduledDateTime: DateTime(2025),
        status: TodayAgendaItemStatus.upcoming,
      );
      expect(item.intakeQuantity, isNull);
      expect(item.dosageForm, isNull);
      expect(item.customDosageForm, isNull);
    });

    test('intake fields are stored when provided', () {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(2025),
        title: 'Concor',
        status: TodayAgendaItemStatus.upcoming,
        intakeQuantity: 0.5,
        dosageForm: DosageForm.tablet,
        customDosageForm: null,
      );
      expect(item.intakeQuantity, 0.5);
      expect(item.dosageForm, DosageForm.tablet);
      expect(item.customDosageForm, isNull);
    });

    test('medication with all dosage fields has complete info', () {
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(2025),
        title: 'Concor',
        status: TodayAgendaItemStatus.upcoming,
        strength: '5 mg',
        intakeQuantity: 0.5,
        dosageForm: DosageForm.tablet,
        instructions: 'Take in the morning',
      );
      expect(item.strength, '5 mg');
      expect(item.intakeQuantity, 0.5);
      expect(item.dosageForm, DosageForm.tablet);
      expect(item.instructions, 'Take in the morning');
    });
  });

  group('TodayAgenda', () {
    TodayAgendaItem makeItem({
      required String id,
      required DateTime scheduledDateTime,
      required TodayAgendaItemStatus status,
      DateTime? snoozedUntil,
      TodayAgendaItemType type = TodayAgendaItemType.medication,
    }) {
      return TodayAgendaItem(
        id: id,
        type: type,
        sourceScheduleId: 1,
        scheduledDateTime: scheduledDateTime,
        title: 'Test',
        status: status,
        snoozedUntil: snoozedUntil,
      );
    }

    test('items appear exactly once in allItems', () {
      final items = [
        makeItem(id: '1', scheduledDateTime: DateTime(2025, 7, 25, 8, 0), status: TodayAgendaItemStatus.upcoming),
        makeItem(id: '2', scheduledDateTime: DateTime(2025, 7, 25, 9, 0), status: TodayAgendaItemStatus.completed),
      ];
      final agenda = TodayAgenda(
        date: DateTime(2025, 7, 25),
        items: items,
        summary: const TodaySummary.empty(),
      );
      expect(agenda.allItems.length, 2);
      expect(agenda.allItems.map((i) => i.id).toSet().length, 2);
    });

    test('chronological sorting by effectiveTime, then by id', () {
      final items = [
        makeItem(id: 'b', scheduledDateTime: DateTime(2025, 7, 25, 9, 0), status: TodayAgendaItemStatus.upcoming),
        makeItem(id: 'a', scheduledDateTime: DateTime(2025, 7, 25, 8, 0), status: TodayAgendaItemStatus.upcoming),
      ];
      items.sort((a, b) {
        final cmp = a.effectiveTime.compareTo(b.effectiveTime);
        if (cmp != 0) return cmp;
        return a.id.compareTo(b.id);
      });
      final agenda = TodayAgenda(
        date: DateTime(2025, 7, 25),
        items: items,
        summary: const TodaySummary.empty(),
      );
      expect(agenda.items[0].id, 'a');
      expect(agenda.items[1].id, 'b');
    });

    test('snoozed item sorts by effectiveTime (snoozedUntil)', () {
      final items = [
        makeItem(
          id: 'a',
          scheduledDateTime: DateTime(2025, 7, 25, 8, 0),
          status: TodayAgendaItemStatus.upcoming,
        ),
        makeItem(
          id: 'b',
          scheduledDateTime: DateTime(2025, 7, 25, 7, 0),
          status: TodayAgendaItemStatus.snoozed,
          snoozedUntil: DateTime(2025, 7, 25, 9, 0),
        ),
      ];
      items.sort((a, b) {
        final cmp = a.effectiveTime.compareTo(b.effectiveTime);
        if (cmp != 0) return cmp;
        return a.id.compareTo(b.id);
      });
      final agenda = TodayAgenda(
        date: DateTime(2025, 7, 25),
        items: items,
        summary: const TodaySummary.empty(),
      );
      expect(agenda.items[0].id, 'a');
      expect(agenda.items[1].id, 'b');
    });

    test('nextItem excludes overdue items', () {
      final now = DateTime(2025, 7, 25, 21, 32);
      final items = [
        makeItem(
          id: 'overdue',
          scheduledDateTime: DateTime(2025, 7, 25, 10, 0),
          status: TodayAgendaItemStatus.overdue,
        ),
        makeItem(
          id: 'upcoming',
          scheduledDateTime: DateTime(2025, 7, 25, 23, 0),
          status: TodayAgendaItemStatus.upcoming,
        ),
      ];
      final agenda = TodayAgenda(
        date: DateTime(2025, 7, 25),
        items: items,
        summary: const TodaySummary.empty(),
      );
      final next = agenda.nextItem(now: now);
      expect(next, isNotNull);
      expect(next!.id, 'upcoming');
    });

    test('nextItem excludes completed and skipped', () {
      final now = DateTime(2025, 7, 25, 12, 0);
      final items = [
        makeItem(
          id: 'completed',
          scheduledDateTime: DateTime(2025, 7, 25, 10, 0),
          status: TodayAgendaItemStatus.completed,
        ),
        makeItem(
          id: 'skipped',
          scheduledDateTime: DateTime(2025, 7, 25, 10, 30),
          status: TodayAgendaItemStatus.skipped,
        ),
      ];
      final agenda = TodayAgenda(
        date: DateTime(2025, 7, 25),
        items: items,
        summary: const TodaySummary.empty(),
      );
      expect(agenda.nextItem(now: now), isNull);
    });

    test('nextItem selects earliest future item', () {
      final now = DateTime(2025, 7, 25, 12, 0);
      final items = [
        makeItem(
          id: 'later',
          scheduledDateTime: DateTime(2025, 7, 25, 15, 0),
          status: TodayAgendaItemStatus.upcoming,
        ),
        makeItem(
          id: 'earlier',
          scheduledDateTime: DateTime(2025, 7, 25, 13, 0),
          status: TodayAgendaItemStatus.upcoming,
        ),
      ];
      final agenda = TodayAgenda(
        date: DateTime(2025, 7, 25),
        items: items,
        summary: const TodaySummary.empty(),
      );
      final next = agenda.nextItem(now: now);
      expect(next!.id, 'earlier');
    });

    test('nextItem selects due item before later future item', () {
      final now = DateTime(2025, 7, 25, 12, 0);
      final items = [
        makeItem(
          id: 'later',
          scheduledDateTime: DateTime(2025, 7, 25, 15, 0),
          status: TodayAgendaItemStatus.upcoming,
        ),
        makeItem(
          id: 'due',
          scheduledDateTime: DateTime(2025, 7, 25, 12, 10),
          status: TodayAgendaItemStatus.due,
        ),
      ];
      final agenda = TodayAgenda(
        date: DateTime(2025, 7, 25),
        items: items,
        summary: const TodaySummary.empty(),
      );
      final next = agenda.nextItem(now: now);
      expect(next!.id, 'due');
    });

    test('nextItem uses snoozedUntil for snoozed items', () {
      final now = DateTime(2025, 7, 25, 12, 0);
      final items = [
        makeItem(
          id: 'future',
          scheduledDateTime: DateTime(2025, 7, 25, 15, 0),
          status: TodayAgendaItemStatus.upcoming,
        ),
        makeItem(
          id: 'snoozed',
          scheduledDateTime: DateTime(2025, 7, 25, 11, 0),
          status: TodayAgendaItemStatus.snoozed,
          snoozedUntil: DateTime(2025, 7, 25, 12, 10),
        ),
      ];
      final agenda = TodayAgenda(
        date: DateTime(2025, 7, 25),
        items: items,
        summary: const TodaySummary.empty(),
      );
      final next = agenda.nextItem(now: now);
      expect(next!.id, 'snoozed');
    });

    test('nextItem returns null when no future/due items', () {
      final now = DateTime(2025, 7, 25, 23, 59);
      final items = [
        makeItem(
          id: 'past',
          scheduledDateTime: DateTime(2025, 7, 25, 8, 0),
          status: TodayAgendaItemStatus.completed,
        ),
      ];
      final agenda = TodayAgenda(
        date: DateTime(2025, 7, 25),
        items: items,
        summary: const TodaySummary.empty(),
      );
      expect(agenda.nextItem(now: now), isNull);
    });

    test('isEmpty is true when items is empty', () {
      final agenda = TodayAgenda(
        date: DateTime(2025, 7, 25),
        items: const [],
        summary: const TodaySummary.empty(),
      );
      expect(agenda.isEmpty, isTrue);
    });

    test('isEmpty is false when items exist', () {
      final items = [
        makeItem(
          id: '1',
          scheduledDateTime: DateTime(2025, 7, 25, 8, 0),
          status: TodayAgendaItemStatus.upcoming,
        ),
      ];
      final agenda = TodayAgenda(
        date: DateTime(2025, 7, 25),
        items: items,
        summary: const TodaySummary.empty(),
      );
      expect(agenda.isEmpty, isFalse);
    });
  });

  group('TodaySummary', () {
    test('total sums medication and measurement', () {
      const summary = TodaySummary(
        medicationTotal: 3,
        medicationCompleted: 1,
        medicationSkipped: 0,
        medicationOverdue: 1,
        measurementTotal: 2,
        measurementCompleted: 1,
        measurementSkipped: 1,
        measurementOverdue: 0,
      );
      expect(summary.total, 5);
      expect(summary.completed, 2);
      expect(summary.skipped, 1);
      expect(summary.overdue, 1);
      expect(summary.handled, 3);
    });

    test('percentages compute correctly', () {
      const summary = TodaySummary(
        medicationTotal: 2,
        medicationCompleted: 1,
        medicationSkipped: 0,
        medicationOverdue: 1,
        measurementTotal: 0,
        measurementCompleted: 0,
        measurementSkipped: 0,
        measurementOverdue: 0,
      );
      expect(summary.completionPercentage, 0.5);
      expect(summary.handledPercentage, 0.5);
    });

    test('percentages are 0 when total is 0', () {
      const summary = TodaySummary.empty();
      expect(summary.completionPercentage, 0.0);
      expect(summary.handledPercentage, 0.0);
    });
  });

  group('TodayBackground', () {
    test('past item classification', () {
      final now = DateTime(2025, 7, 25, 12, 0);
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(2025, 7, 25, 8, 0),
        title: 'Test',
        status: TodayAgendaItemStatus.overdue,
      );
      // Overdue is past regardless of effectiveTime
      expect(item.isOverdue, isTrue);
      expect(item.isPast(now), isTrue);
    });

    test('future item classification', () {
      final now = DateTime(2025, 7, 25, 12, 0);
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(2025, 7, 25, 14, 0),
        title: 'Test',
        status: TodayAgendaItemStatus.upcoming,
      );
      expect(item.isFuture(now), isTrue);
      expect(item.isPast(now), isFalse);
    });

    test('due item classification within grace window', () {
      final now = DateTime(2025, 7, 25, 12, 0);
      final item = TodayAgendaItem(
        id: '1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: DateTime(2025, 7, 25, 12, 15),
        title: 'Test',
        status: TodayAgendaItemStatus.due,
      );
      expect(item.isDue(now, const Duration(minutes: 30)), isTrue);
    });
  });
}
