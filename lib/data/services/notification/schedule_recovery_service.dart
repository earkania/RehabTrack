import 'package:flutter/foundation.dart';

import '../notification/notification_scheduler.dart';
import '../notification/notification_service.dart';

class ScheduleRecoveryService {
  ScheduleRecoveryService({
    required NotificationService notificationService,
    required NotificationScheduler notificationScheduler,
  })  : _notificationService = notificationService,
        _notificationScheduler = notificationScheduler;

  final NotificationService _notificationService;
  final NotificationScheduler _notificationScheduler;

  Future<void> recoverAllSchedules({
    required List<ScheduleRecoveryEntry> activeSchedules,
  }) async {
    if (!_notificationService.isInitialized) {
      debugPrint('NotificationService not initialized, skipping recovery');
      return;
    }

    var restoredCount = 0;

    for (final entry in activeSchedules) {
      try {
        await _notificationScheduler.scheduleOccurrences(
          scheduleId: entry.scheduleId,
          title: entry.title,
          body: entry.body,
          config: entry.config,
          channelId: entry.channelId,
          payload: entry.payload,
          includeActions: entry.includeActions,
          isMeasurement: entry.isMeasurement,
          startDate: entry.startDate,
          endDate: entry.endDate,
        );
        restoredCount++;
      } catch (e) {
        debugPrint('Failed to restore schedule ${entry.scheduleId}: $e');
      }
    }

    debugPrint('Schedule recovery: restored $restoredCount schedule entries');
  }
}

class ScheduleRecoveryEntry {
  const ScheduleRecoveryEntry({
    required this.scheduleId,
    required this.title,
    required this.body,
    required this.config,
    required this.channelId,
    this.payload,
    this.includeActions = false,
    this.isMeasurement = false,
    required this.profileId,
    this.startDate,
    this.endDate,
  });

  final int scheduleId;
  final String title;
  final String body;
  final dynamic config;
  final String channelId;
  final String? payload;
  final bool includeActions;
  final bool isMeasurement;
  final int profileId;
  final DateTime? startDate;
  final DateTime? endDate;
}
