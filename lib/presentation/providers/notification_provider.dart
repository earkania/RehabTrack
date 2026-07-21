import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/notification/notification_service.dart';
import '../../data/services/notification/notification_scheduler.dart';
import '../../data/services/notification/schedule_recovery_service.dart';
import '../../data/services/notification/battery_optimization_helper.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  service.initialize();
  return service;
});

final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  return NotificationScheduler(
    notificationService: ref.watch(notificationServiceProvider),
  );
});

final scheduleRecoveryServiceProvider =
    Provider<ScheduleRecoveryService>((ref) {
  return ScheduleRecoveryService(
    notificationService: ref.watch(notificationServiceProvider),
    notificationScheduler: ref.watch(notificationSchedulerProvider),
  );
});

final batteryOptimizationHelperProvider =
    Provider<BatteryOptimizationHelper>((ref) {
  return BatteryOptimizationHelper();
});
