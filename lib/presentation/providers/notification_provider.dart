import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/notification/notification_action_bridge.dart';
import '../../data/services/notification/notification_service.dart';
import '../../data/services/notification/notification_scheduler.dart';
import '../../data/services/notification/schedule_recovery_service.dart';
import '../../data/services/notification/battery_optimization_helper.dart';
import 'database_provider.dart';
import 'profile_provider.dart';

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

/// Eagerly initialized provider that wires up notification actions
/// and runs schedule recovery at application startup.
final notificationInitializerProvider = Provider<void>((ref) {
  final bridge = NotificationActionBridge(
    notificationService: ref.watch(notificationServiceProvider),
    scheduleRecoveryService: ref.watch(scheduleRecoveryServiceProvider),
    medicationRepository: ref.watch(medicationRepositoryProvider),
  );

  final profileId = ref.watch(activeProfileIdProvider) ?? 1;

  ref.onDispose(() {
    log('notificationInitializerProvider disposed');
  });

  // Initialize eagerly — this runs once at app startup.
  bridge.initialize(profileId: profileId);
});
