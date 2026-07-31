import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/data/services/notification/notification_scheduler.dart';
import 'package:rehab_track/data/services/notification/notification_service.dart';
import 'package:rehab_track/data/services/notification/reminder_content_formatter.dart';
import 'package:rehab_track/data/services/notification/reminder_payload.dart';
import 'package:rehab_track/domain/entities/dosage_form.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/domain/entities/medication_alternative.dart';
import 'package:rehab_track/domain/entities/medication_alternative_component.dart';
import 'package:rehab_track/domain/entities/medication_component.dart';
import 'package:rehab_track/domain/entities/schedule_config.dart';
import 'package:rehab_track/domain/repositories/medication_repository.dart';
import 'package:rehab_track/presentation/providers/notification_provider.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final db.AppDatabase _database;
  final Ref? _ref;

  MedicationRepositoryImpl(this._database, {this._ref});

  NotificationScheduler? get _scheduler {
    if (_ref == null) return null;
    try {
      return _ref.read(notificationSchedulerProvider);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<List<Medication>> watchMedications(int profileId) {
    return _database.medicationDao
        .watchMedications(profileId)
        .map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<List<Medication>> watchActiveMedications(int profileId) {
    return _database.medicationDao
        .watchActiveMedications(profileId)
        .map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<List<Medication>> getActiveMedications(int profileId) async {
    final rows = await _database.medicationDao.getActiveMedications(profileId);
    return rows.map(_toDomain).toList();
  }

  @override
  Future<List<Medication>> getMedications(int profileId) async {
    final rows = await _database.medicationDao.getMedications(profileId);
    return rows.map(_toDomain).toList();
  }

  @override
  Future<Medication?> getMedication(int id) async {
    final row = await _database.medicationDao.getMedication(id);
    return row != null ? _toDomain(row) : null;
  }

  @override
  Future<int> createMedication(Medication medication) async {
    return _database.medicationDao.insertMedication(
      db.MedicationsCompanion.insert(
        profileId: medication.profileId,
        name: medication.name,
        description: Value(medication.description),
        doseAmount: Value(medication.doseAmount),
        doseUnit: Value(medication.doseUnit),
        active: Value(medication.active),
        startDate: Value(medication.startDate),
        endDate: Value(medication.endDate),
        notes: Value(medication.notes),
        createdAt: medication.createdAt,
        updatedAt: medication.updatedAt,
      ),
    );
  }

  @override
  Future<void> updateMedication(Medication medication) async {
    await _database.medicationDao.updateMedication(
      db.MedicationsCompanion(
        id: Value(medication.id!),
        profileId: Value(medication.profileId),
        name: Value(medication.name),
        description: Value(medication.description),
        doseAmount: Value(medication.doseAmount),
        doseUnit: Value(medication.doseUnit),
        active: Value(medication.active),
        startDate: Value(medication.startDate),
        endDate: Value(medication.endDate),
        notes: Value(medication.notes),
        createdAt: Value(medication.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteMedication(int id) async {
    await _database.medicationDao.deleteMedication(id);
  }

  @override
  Stream<List<MedicationSchedule>> watchSchedules(int medicationId) {
    return _database.medicationDao
        .watchSchedules(medicationId)
        .map((rows) => rows.map(_scheduleToDomain).toList());
  }

  @override
  Future<List<MedicationSchedule>> getSchedulesForMedication(
    int medicationId,
  ) async {
    final rows = await _database.medicationDao.getSchedulesForMedication(
      medicationId,
    );
    return rows.map(_scheduleToDomain).toList();
  }

  @override
  Future<MedicationSchedule?> getSchedule(int id) async {
    final row = await _database.medicationDao.getSchedule(id);
    return row != null ? _scheduleToDomain(row) : null;
  }

  @override
  Future<int> createSchedule(MedicationSchedule schedule) async {
    final scheduleId = await _database.medicationDao.insertSchedule(
      db.MedicationSchedulesCompanion.insert(
        medicationId: schedule.medicationId,
        scheduleType: schedule.scheduleType,
        scheduleConfig: schedule.scheduleConfig.toJsonString(),
        intakeQuantity: Value(schedule.intakeQuantity),
        dosageForm: Value(schedule.dosageForm.toStorageString()),
        customDosageForm: Value(schedule.customDosageForm),
        startDate: Value(schedule.startDate),
        endDate: Value(schedule.endDate),
        instructions: Value(schedule.instructions),
        active: Value(schedule.active),
      ),
    );

    final savedSchedule = schedule.copyWith(id: scheduleId);
    await _scheduleNotifications(savedSchedule);

    return scheduleId;
  }

  @override
  Future<void> updateSchedule(MedicationSchedule schedule) async {
    await _cancelNotifications(schedule);

    await _database.medicationDao.updateSchedule(
      db.MedicationSchedulesCompanion(
        id: Value(schedule.id!),
        medicationId: Value(schedule.medicationId),
        scheduleType: Value(schedule.scheduleType),
        scheduleConfig: Value(schedule.scheduleConfig.toJsonString()),
        intakeQuantity: Value(schedule.intakeQuantity),
        dosageForm: Value(schedule.dosageForm.toStorageString()),
        customDosageForm: Value(schedule.customDosageForm),
        startDate: Value(schedule.startDate),
        endDate: Value(schedule.endDate),
        instructions: Value(schedule.instructions),
        active: Value(schedule.active),
      ),
    );

    await _scheduleNotifications(schedule);
  }

  @override
  Future<void> deleteSchedule(int id) async {
    final scheduleRow = await _database.medicationDao.getSchedule(id);
    if (scheduleRow != null) {
      final schedule = _scheduleToDomain(scheduleRow);
      await _cancelNotifications(schedule);
    }
    await _database.medicationDao.deleteSchedule(id);
  }

  @override
  Stream<List<MedicationLog>> watchLogs(
    int scheduleId, {
    DateTime? from,
    DateTime? to,
  }) {
    return _database.medicationDao
        .watchLogs(scheduleId, from: from, to: to)
        .map((rows) => rows.map(_logToDomain).toList());
  }

  @override
  Future<List<MedicationLog>> getLogs(
    int scheduleId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final rows = await _database.medicationDao.getLogs(
      scheduleId,
      from: from,
      to: to,
    );
    return rows.map(_logToDomain).toList();
  }

  @override
  Future<int> logDose(MedicationLog log) async {
    return _database.medicationDao.insertLog(
      db.MedicationLogsCompanion.insert(
        medicationScheduleId: log.medicationScheduleId,
        scheduledTime: log.scheduledTime,
        takenTime: Value(log.takenTime),
        status: log.status,
        notes: Value(log.notes),
        createdAt: log.createdAt,
        snapshotIntakeQuantity: Value(log.snapshotIntakeQuantity),
        snapshotDosageForm: Value(log.snapshotDosageForm?.toStorageString()),
        snapshotCustomDosageForm: Value(log.snapshotCustomDosageForm),
      ),
    );
  }

  @override
  Future<void> updateLog(MedicationLog log) async {
    await _database.medicationDao.updateLog(
      db.MedicationLogsCompanion(
        id: Value(log.id!),
        medicationScheduleId: Value(log.medicationScheduleId),
        scheduledTime: Value(log.scheduledTime),
        takenTime: Value(log.takenTime),
        status: Value(log.status),
        notes: Value(log.notes),
        createdAt: Value(log.createdAt),
        snapshotIntakeQuantity: Value(log.snapshotIntakeQuantity),
        snapshotDosageForm: Value(log.snapshotDosageForm?.toStorageString()),
        snapshotCustomDosageForm: Value(log.snapshotCustomDosageForm),
      ),
    );
  }

  @override
  Future<void> cancelReminderNotification(int scheduleId, DateTime scheduledTime) async {
    try {
      final schedule = await getSchedule(scheduleId);
      if (schedule == null) return;
      final scheduler = _scheduler;
      if (scheduler == null) return;
      await scheduler.cancelOccurrenceNotification(
        scheduleId: scheduleId,
        occurrenceDate: scheduledTime,
        scheduleStartDate: schedule.startDate ?? scheduledTime,
        isMeasurement: false,
      );
    } catch (_) {
      // Best-effort cancellation.
    }
  }

  @override
  Future<MedicationLog?> getLogForOccurrence(
    int scheduleId,
    DateTime scheduledTime,
  ) async {
    final row = await _database.medicationDao.getLogForOccurrence(
      scheduleId,
      scheduledTime,
    );
    return row != null ? _logToDomain(row) : null;
  }

  @override
  Future<void> deleteLogForOccurrence(
    int scheduleId,
    DateTime scheduledTime,
  ) async {
    await _database.medicationDao.deleteLogForOccurrence(
      scheduleId,
      scheduledTime,
    );
  }

  Medication _toDomain(db.Medication row) {
    return Medication(
      id: row.id,
      profileId: row.profileId,
      name: row.name,
      description: row.description,
      doseAmount: row.doseAmount,
      doseUnit: row.doseUnit,
      active: row.active,
      startDate: row.startDate,
      endDate: row.endDate,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  MedicationSchedule _scheduleToDomain(db.MedicationSchedule row) {
    return MedicationSchedule(
      id: row.id,
      medicationId: row.medicationId,
      scheduleType: row.scheduleType,
      scheduleConfig: ScheduleConfig.fromJsonString(row.scheduleConfig),
      intakeQuantity: row.intakeQuantity,
      dosageForm: DosageFormExtension.fromStorageString(row.dosageForm) ??
          DosageForm.tablet,
      customDosageForm: row.customDosageForm,
      startDate: row.startDate,
      endDate: row.endDate,
      instructions: row.instructions,
      active: row.active,
    );
  }

  MedicationLog _logToDomain(db.MedicationLog row) {
    return MedicationLog(
      id: row.id,
      medicationScheduleId: row.medicationScheduleId,
      scheduledTime: row.scheduledTime,
      takenTime: row.takenTime,
      status: row.status,
      notes: row.notes,
      createdAt: row.createdAt,
      snapshotIntakeQuantity: row.snapshotIntakeQuantity,
      snapshotDosageForm:
          DosageFormExtension.fromStorageString(row.snapshotDosageForm),
      snapshotCustomDosageForm: row.snapshotCustomDosageForm,
    );
  }

  Future<void> _scheduleNotifications(MedicationSchedule schedule) async {
    final scheduler = _scheduler;
    if (scheduler == null) return;
    if (!schedule.active) return;

    try {
      final medication = await getMedication(schedule.medicationId);
      if (medication == null) return;

      // Medication strength is stored in medicationComponents (not on the medication
      // itself). Fetch components to get the dose info for the notification title.
      String? doseAmount = medication.doseAmount;
      String? doseUnit = medication.doseUnit;
      if ((doseAmount == null || doseAmount.isEmpty) && medication.id != null) {
        final components = await getComponents(medication.id!);
        if (components.isNotEmpty) {
          final first = components.first;
          doseAmount = first.doseAmount;
          doseUnit = first.doseUnit;
        }
      }

      final title = ReminderContentFormatter.medicationTitle(
        medication: medication,
        profile: null,
        doseAmount: doseAmount,
        doseUnit: doseUnit,
      );
      log('[MedicationRepository] scheduling: medId=${medication.id} name="${medication.name}" '
          'doseAmount="$doseAmount" doseUnit="$doseUnit" '
          'title="$title"');
      final body = ReminderContentFormatter.medicationBody(
        medication: medication,
        profile: null,
        schedule: schedule,
        scheduledTime: DateTime.now(),
      );

      await scheduler.scheduleOccurrences(
        scheduleId: schedule.id!,
        title: title,
        body: body,
        config: schedule.scheduleConfig,
        channelId: NotificationService.medicationChannelId,
        includeActions: true,
        isMeasurement: false,
        startDate: schedule.startDate,
        endDate: schedule.endDate,
        perOccurrencePayload: (occDateTime) {
          return ReminderPayload(
            type: ReminderType.medication,
            profileId: medication.profileId,
            scheduleId: schedule.id!,
            occurrenceTime: occDateTime.toIso8601String(),
            medicationId: medication.id,
          ).toJsonString();
        },
      );
    } catch (e, stack) {
      log('[MedicationRepository] scheduleNotifications FAILED: $e');
      log('[MedicationRepository] scheduleNotifications stack: $stack');
    }
  }

  Future<void> _cancelNotifications(MedicationSchedule schedule) async {
    final scheduler = _scheduler;
    if (scheduler == null) return;
    if (schedule.id == null) return;

    try {
      await scheduler.cancelNotificationsInRange(
        scheduleId: schedule.id!,
        config: schedule.scheduleConfig,
        isMeasurement: false,
      );
    } catch (_) {
      // Best-effort cancellation.
    }
  }

  @override
  Stream<List<MedicationAlternative>> watchAlternatives(
    int medicationId,
  ) {
    return _database.medicationAlternativesDao
        .watchAlternatives(medicationId)
        .map((rows) => rows.map(_alternativeToDomain).toList());
  }

  @override
  Future<List<MedicationAlternative>> getAlternatives(
    int medicationId,
  ) async {
    final rows = await _database.medicationAlternativesDao
        .getAlternatives(medicationId);
    return rows.map(_alternativeToDomain).toList();
  }

  @override
  Future<MedicationAlternative?> getAlternative(int id) async {
    final row =
        await _database.medicationAlternativesDao.getAlternative(id);
    return row != null ? _alternativeToDomain(row) : null;
  }

  @override
  Future<int> createAlternative(
    MedicationAlternative alternative,
  ) async {
    return _database.medicationAlternativesDao.insertAlternative(
      db.MedicationAlternativesCompanion.insert(
        medicationId: alternative.medicationId,
        name: alternative.name,
        doseAmount: Value(alternative.doseAmount),
        doseUnit: Value(alternative.doseUnit),
        doctorApproved: Value(alternative.doctorApproved),
        notes: Value(alternative.notes),
        createdAt: alternative.createdAt,
      ),
    );
  }

  @override
  Future<void> updateAlternative(
    MedicationAlternative alternative,
  ) async {
    await _database.medicationAlternativesDao.updateAlternative(
      db.MedicationAlternativesCompanion(
        id: Value(alternative.id!),
        medicationId: Value(alternative.medicationId),
        name: Value(alternative.name),
        doseAmount: Value(alternative.doseAmount),
        doseUnit: Value(alternative.doseUnit),
        doctorApproved: Value(alternative.doctorApproved),
        notes: Value(alternative.notes),
        createdAt: Value(alternative.createdAt),
      ),
    );
  }

  @override
  Future<void> deleteAlternative(int id) async {
    await _database.medicationAlternativesDao.deleteAlternative(id);
  }

  @override
  Stream<List<MedicationComponent>> watchComponents(
    int medicationId,
  ) {
    return _database.medicationComponentsDao
        .watchComponents(medicationId)
        .map((rows) => rows.map(_componentToDomain).toList());
  }

  @override
  Future<List<MedicationComponent>> getComponents(
    int medicationId,
  ) async {
    final rows = await _database.medicationComponentsDao
        .getComponents(medicationId);
    return rows.map(_componentToDomain).toList();
  }

  @override
  Future<void> replaceMedicationComponents(
    int medicationId,
    List<MedicationComponent> components,
  ) async {
    final companions = components.map((c) {
      return db.MedicationComponentsCompanion(
        id: c.id != null ? Value(c.id!) : const Value.absent(),
        medicationId: Value(medicationId),
        componentName: Value(c.componentName),
        doseAmount: Value(c.doseAmount),
        doseUnit: Value(c.doseUnit),
        sortOrder: Value(c.sortOrder),
        createdAt: Value(c.createdAt),
        updatedAt: Value(c.updatedAt),
      );
    }).toList();
    await _database.medicationComponentsDao.replaceAllComponents(
      medicationId,
      companions,
    );
  }

  @override
  Stream<List<MedicationAlternativeComponent>>
      watchAlternativeComponents(int alternativeId) {
    return _database.medicationAlternativeComponentsDao
        .watchComponents(alternativeId)
        .map((rows) => rows.map(_altComponentToDomain).toList());
  }

  @override
  Future<List<MedicationAlternativeComponent>>
      getAlternativeComponents(int alternativeId) async {
    final rows = await _database.medicationAlternativeComponentsDao
        .getComponents(alternativeId);
    return rows.map(_altComponentToDomain).toList();
  }

  @override
  Future<void> replaceAlternativeComponents(
    int alternativeId,
    List<MedicationAlternativeComponent> components,
  ) async {
    final companions = components.map((c) {
      return db.MedicationAlternativeComponentsCompanion(
        id: c.id != null ? Value(c.id!) : const Value.absent(),
        medicationAlternativeId: Value(alternativeId),
        componentName: Value(c.componentName),
        doseAmount: Value(c.doseAmount),
        doseUnit: Value(c.doseUnit),
        sortOrder: Value(c.sortOrder),
        createdAt: Value(c.createdAt),
        updatedAt: Value(c.updatedAt),
      );
    }).toList();
    await _database.medicationAlternativeComponentsDao
        .replaceAllComponents(alternativeId, companions);
  }

  MedicationAlternative _alternativeToDomain(
    db.MedicationAlternative row,
  ) {
    return MedicationAlternative(
      id: row.id,
      medicationId: row.medicationId,
      name: row.name,
      doseAmount: row.doseAmount,
      doseUnit: row.doseUnit,
      doctorApproved: row.doctorApproved,
      notes: row.notes,
      createdAt: row.createdAt,
    );
  }

  MedicationComponent _componentToDomain(
    db.MedicationComponent row,
  ) {
    return MedicationComponent(
      id: row.id,
      medicationId: row.medicationId,
      componentName: row.componentName,
      doseAmount: row.doseAmount,
      doseUnit: row.doseUnit,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  MedicationAlternativeComponent _altComponentToDomain(
    db.MedicationAlternativeComponent row,
  ) {
    return MedicationAlternativeComponent(
      id: row.id,
      medicationAlternativeId: row.medicationAlternativeId,
      componentName: row.componentName,
      doseAmount: row.doseAmount,
      doseUnit: row.doseUnit,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
