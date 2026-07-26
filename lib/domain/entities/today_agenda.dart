import 'package:rehab_track/domain/entities/dosage_form.dart';
import 'package:rehab_track/domain/entities/measurement.dart';

enum TodayAgendaItemType {
  medication,
  measurement,
}

enum TodayAgendaItemStatus {
  upcoming,
  due,
  overdue,
  completed,
  skipped,
  snoozed,
}

class TodayAgendaItem {
  final String id;
  final TodayAgendaItemType type;
  final int sourceScheduleId;
  final DateTime scheduledDateTime;
  final String title;
  final String? subtitle;
  final String? instructions;
  final TodayAgendaItemStatus status;
  final DateTime? completedAt;
  final DateTime? snoozedUntil;

  final int? medicationId;
  final String? medicationName;
  final bool? irregularHeartbeatDetected;

  final int? measurementTypeId;
  final String? measurementTypeKey;
  final int? measurementRecordId;

  final String? strength;
  final double? intakeQuantity;
  final DosageForm? dosageForm;
  final String? customDosageForm;

  final List<MeasurementRecordValue> readingValues;

  const TodayAgendaItem({
    required this.id,
    required this.type,
    required this.sourceScheduleId,
    required this.scheduledDateTime,
    required this.title,
    this.subtitle,
    this.instructions,
    required this.status,
    this.completedAt,
    this.snoozedUntil,
    this.medicationId,
    this.medicationName,
    this.irregularHeartbeatDetected,
    this.measurementTypeId,
    this.measurementTypeKey,
    this.measurementRecordId,
    this.strength,
    this.intakeQuantity,
    this.dosageForm,
    this.customDosageForm,
    this.readingValues = const [],
  });

  TodayAgendaItem copyWith({
    String? id,
    TodayAgendaItemType? type,
    int? sourceScheduleId,
    DateTime? scheduledDateTime,
    String? title,
    String? subtitle,
    String? instructions,
    TodayAgendaItemStatus? status,
    DateTime? completedAt,
    DateTime? snoozedUntil,
    int? medicationId,
    String? medicationName,
    bool? irregularHeartbeatDetected,
    int? measurementTypeId,
    String? measurementTypeKey,
    int? measurementRecordId,
    String? strength,
    double? intakeQuantity,
    DosageForm? dosageForm,
    String? customDosageForm,
    List<MeasurementRecordValue>? readingValues,
    bool clearSubtitle = false,
    bool clearInstructions = false,
    bool clearCompletedAt = false,
    bool clearSnoozedUntil = false,
    bool clearMedicationId = false,
    bool clearMedicationName = false,
    bool clearIrregularHeartbeatDetected = false,
    bool clearMeasurementTypeId = false,
    bool clearMeasurementTypeKey = false,
    bool clearMeasurementRecordId = false,
    bool clearStrength = false,
    bool clearIntakeQuantity = false,
    bool clearDosageForm = false,
    bool clearCustomDosageForm = false,
  }) {
    return TodayAgendaItem(
      id: id ?? this.id,
      type: type ?? this.type,
      sourceScheduleId: sourceScheduleId ?? this.sourceScheduleId,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      title: title ?? this.title,
      subtitle: clearSubtitle ? null : (subtitle ?? this.subtitle),
      instructions: clearInstructions ? null : (instructions ?? this.instructions),
      status: status ?? this.status,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      snoozedUntil: clearSnoozedUntil ? null : (snoozedUntil ?? this.snoozedUntil),
      medicationId: clearMedicationId ? null : (medicationId ?? this.medicationId),
      medicationName: clearMedicationName ? null : (medicationName ?? this.medicationName),
      irregularHeartbeatDetected: clearIrregularHeartbeatDetected
          ? null
          : (irregularHeartbeatDetected ?? this.irregularHeartbeatDetected),
      measurementTypeId: clearMeasurementTypeId
          ? null
          : (measurementTypeId ?? this.measurementTypeId),
      measurementTypeKey: clearMeasurementTypeKey
          ? null
          : (measurementTypeKey ?? this.measurementTypeKey),
      measurementRecordId: clearMeasurementRecordId
          ? null
          : (measurementRecordId ?? this.measurementRecordId),
      strength: clearStrength ? null : (strength ?? this.strength),
      intakeQuantity: clearIntakeQuantity
          ? null
          : (intakeQuantity ?? this.intakeQuantity),
      dosageForm: clearDosageForm ? null : (dosageForm ?? this.dosageForm),
      customDosageForm: clearCustomDosageForm
          ? null
          : (customDosageForm ?? this.customDosageForm),
      readingValues: readingValues ?? this.readingValues,
    );
  }

  DateTime get effectiveTime => snoozedUntil ?? scheduledDateTime;

  bool get isActionable =>
      status == TodayAgendaItemStatus.upcoming ||
      status == TodayAgendaItemStatus.due ||
      status == TodayAgendaItemStatus.overdue ||
      status == TodayAgendaItemStatus.snoozed;

  bool get isCompleted =>
      status == TodayAgendaItemStatus.completed ||
      status == TodayAgendaItemStatus.skipped;

  bool isPast(DateTime now) => effectiveTime.isBefore(now);

  bool isFuture(DateTime now) => effectiveTime.isAfter(now);

  bool isDue(DateTime now, Duration graceWindow) {
    if (isPast(now)) return false;
    final diff = effectiveTime.difference(now);
    return diff <= graceWindow;
  }

  bool get isOverdue => status == TodayAgendaItemStatus.overdue;
}

class TodaySummary {
  final int medicationTotal;
  final int medicationCompleted;
  final int medicationSkipped;
  final int medicationOverdue;
  final int measurementTotal;
  final int measurementCompleted;
  final int measurementSkipped;
  final int measurementOverdue;

  const TodaySummary({
    required this.medicationTotal,
    required this.medicationCompleted,
    required this.medicationSkipped,
    required this.medicationOverdue,
    required this.measurementTotal,
    required this.measurementCompleted,
    required this.measurementSkipped,
    required this.measurementOverdue,
  });

  int get total => medicationTotal + measurementTotal;
  int get completed => medicationCompleted + measurementCompleted;
  int get skipped => medicationSkipped + measurementSkipped;
  int get overdue => medicationOverdue + measurementOverdue;
  int get handled => completed + skipped;

  double get completionPercentage =>
      total > 0 ? completed / total : 0.0;

  double get handledPercentage =>
      total > 0 ? handled / total : 0.0;

  const TodaySummary.empty()
      : medicationTotal = 0,
        medicationCompleted = 0,
        medicationSkipped = 0,
        medicationOverdue = 0,
        measurementTotal = 0,
        measurementCompleted = 0,
        measurementSkipped = 0,
        measurementOverdue = 0;
}

class TodayAgenda {
  final DateTime date;
  final List<TodayAgendaItem> items;
  final TodaySummary summary;

  const TodayAgenda({
    required this.date,
    required this.items,
    required this.summary,
  });

  bool get isEmpty => items.isEmpty;

  List<TodayAgendaItem> get allItems =>
      List.unmodifiable(items);

  TodayAgendaItem? nextItem({DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final graceWindow = const Duration(minutes: 30);
    return items
        .where((item) => !item.isCompleted && !item.isOverdue)
        .fold<TodayAgendaItem?>(null, (earliest, item) {
      final effective = item.effectiveTime;
      final isDueItem = !effective.isBefore(currentTime) &&
          effective.difference(currentTime) <= graceWindow;
      final isFutureItem = effective.isAfter(currentTime);
      if (!isDueItem && !isFutureItem) return earliest;
      if (earliest == null) return item;
      return effective.isBefore(earliest.effectiveTime) ? item : earliest;
    });
  }
}
