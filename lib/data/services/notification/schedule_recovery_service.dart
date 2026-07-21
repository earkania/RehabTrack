import 'dart:developer';

import '../notification/notification_service.dart';
import '../notification/notification_scheduler.dart';

class ScheduleRecoveryService {
  ScheduleRecoveryService({
    required this._notificationService,
    required this._notificationScheduler,
  });

  final NotificationService _notificationService;
  final NotificationScheduler _notificationScheduler;

  Future<void> recoverAllSchedules({
    required List<ScheduleRecoveryEntry> activeSchedules,
  }) async {
    if (!_notificationService.isInitialized) {
      log('NotificationService not initialized, skipping recovery');
      return;
    }

    final pendingNotifications =
        await _notificationService.getPendingNotifications();
    final pendingIds = pendingNotifications.map((n) => n.id).toSet();

    var restoredCount = 0;

    for (final entry in activeSchedules) {
      final notificationIds = entry.notificationIds;

      final missingIds =
          notificationIds.where((id) => !pendingIds.contains(id)).toList();

      if (missingIds.isEmpty) continue;

      for (final id in missingIds) {
        try {
          await _notificationScheduler.scheduleFromConfig(
            notificationId: id,
            title: entry.title,
            body: entry.body,
            config: entry.config,
            channelType: entry.channelType,
            payload: entry.payload,
            includeActions: entry.includeActions,
          );
          restoredCount++;
        } catch (e) {
          log('Failed to restore notification $id: $e');
        }
      }
    }

    log('Schedule recovery: restored $restoredCount notifications');
  }

  Future<void> cancelAllAndReschedule({
    required List<ScheduleRecoveryEntry> activeSchedules,
  }) async {
    await _notificationService.cancelAllNotifications();

    for (final entry in activeSchedules) {
      for (final id in entry.notificationIds) {
        try {
          await _notificationScheduler.scheduleFromConfig(
            notificationId: id,
            title: entry.title,
            body: entry.body,
            config: entry.config,
            channelType: entry.channelType,
            payload: entry.payload,
            includeActions: entry.includeActions,
          );
        } catch (e) {
          log('Failed to reschedule notification $id: $e');
        }
      }
    }
  }
}

class ScheduleRecoveryEntry {
  const ScheduleRecoveryEntry({
    required this.notificationIds,
    required this.title,
    required this.body,
    required this.config,
    required this.channelType,
    this.payload,
    this.includeActions = false,
  });

  final List<int> notificationIds;
  final String title;
  final String body;
  final dynamic config;
  final NotificationChannelType channelType;
  final String? payload;
  final bool includeActions;
}
