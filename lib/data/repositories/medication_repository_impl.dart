import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/data/services/notification/notification_scheduler.dart';
import 'package:rehab_track/data/services/notification/notification_service.dart';
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
  Future<List<Medication>> getMedications(int profileId) async {
    final rows =
        await _database.medicationDao.getMedications(profileId);
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
  Stream<List<MedicationSchedule>> watchSchedules(
    int medicationId,
  ) {
    return _database.medicationDao
        .watchSchedules(medicationId)
        .map((rows) => rows.map(_scheduleToDomain).toList());
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
    await _database.medicationDao.updateSchedule(
      db.MedicationSchedulesCompanion(
        id: Value(schedule.id!),
        medicationId: Value(schedule.medicationId),
        scheduleType: Value(schedule.scheduleType),
        scheduleConfig:
            Value(schedule.scheduleConfig.toJsonString()),
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
      ),
    );
  }

  @override
  Future<void> updateLog(MedicationLog log) async {
    await _database.medicationDao.updateLog(
      db.MedicationLogsCompanion(
        id: Value(log.id!),
        medicationScheduleId:
            Value(log.medicationScheduleId),
        scheduledTime: Value(log.scheduledTime),
        takenTime: Value(log.takenTime),
        status: Value(log.status),
        notes: Value(log.notes),
        createdAt: Value(log.createdAt),
      ),
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

  MedicationSchedule _scheduleToDomain(
    db.MedicationSchedule row,
  ) {
    return MedicationSchedule(
      id: row.id,
      medicationId: row.medicationId,
      scheduleType: row.scheduleType,
      scheduleConfig:
          ScheduleConfig.fromJsonString(row.scheduleConfig),
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
    );
  }

  Future<void> _scheduleNotifications(MedicationSchedule schedule) async {
    final scheduler = _scheduler;
    if (scheduler == null) return;
    if (!schedule.active) return;

    try {
      final medication = await getMedication(schedule.medicationId);
      if (medication == null) return;

      final components = await getComponents(medication.id!);

      final title = 'Time to take ${medication.name}';
      final body = _buildNotificationBody(medication, schedule, components);
      final payload = jsonEncode({
        'medicationId': medication.id,
        'scheduleId': schedule.id,
      });

      await scheduler.scheduleFromConfig(
        notificationId: schedule.id!,
        title: title,
        body: body,
        config: schedule.scheduleConfig,
        channelType: NotificationChannelType.medication,
        payload: payload,
        includeActions: true,
      );
    } catch (_) {
      // Notification scheduling is best-effort; database is already saved.
    }
  }

  Future<void> _cancelNotifications(MedicationSchedule schedule) async {
    final scheduler = _scheduler;
    if (scheduler == null) return;
    if (schedule.id == null) return;

    try {
      await scheduler.cancelNotificationsForSchedule(
        baseNotificationId: schedule.id!,
        config: schedule.scheduleConfig,
      );
    } catch (_) {
      // Best-effort cancellation.
    }
  }

  String _buildNotificationBody(
    Medication medication,
    MedicationSchedule schedule,
    List<MedicationComponent> components,
  ) {
    final parts = <String>[];
    final dose = components.isNotEmpty
        ? _formatDoseFromComponents(components)
        : _formatDoseShort(medication);
    if (dose.isNotEmpty) parts.add(dose);
    if (schedule.instructions != null && schedule.instructions!.isNotEmpty) {
      parts.add(schedule.instructions!);
    }
    return parts.isEmpty ? '' : parts.join(' — ');
  }

  String _formatDoseFromComponents(List<MedicationComponent> components) {
    if (components.isEmpty) return '';
    if (components.length == 1) {
      return _formatSingleComponent(components.first.doseAmount, components.first.doseUnit);
    }
    final buffer = StringBuffer();
    for (var i = 0; i < components.length; i++) {
      if (i > 0) buffer.write('/');
      buffer.write(components[i].doseAmount);
      if (components[i].doseUnit.isNotEmpty) {
        buffer.write(' ${components[i].doseUnit}');
      }
    }
    return buffer.toString();
  }

  String _formatSingleComponent(String amount, String unit) {
    if (amount.isEmpty) return '';
    if (unit.isEmpty) return amount;
    return '$amount $unit';
  }

  String _formatDoseShort(Medication medication) {
    final parts = <String>[];
    if (medication.doseAmount != null && medication.doseAmount!.isNotEmpty) {
      parts.add(medication.doseAmount!);
    }
    if (medication.doseUnit != null && medication.doseUnit!.isNotEmpty) {
      parts.add(medication.doseUnit!);
    }
    return parts.join(' ');
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
