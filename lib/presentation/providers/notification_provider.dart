import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/notification/notification_action_bridge.dart';
import '../../data/services/notification/notification_scheduler.dart';
import '../../data/services/notification/notification_service.dart';
import '../../data/services/notification/schedule_recovery_service.dart';
import 'database_provider.dart';
import 'profile_provider.dart';
import 'reminder_settings_provider.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  ref.onDispose(() => debugPrint('[NotificationServiceProvider] disposed'));
  service.initialize().then((ok) {
    debugPrint('[NotificationServiceProvider] initialize result: $ok');
    if (!ok) {
      debugPrint('[NotificationServiceProvider] WARNING: initialization returned false');
    }
  }).catchError((e, stack) {
    debugPrint('[NotificationServiceProvider] initialize ERROR: $e');
    debugPrint('[NotificationServiceProvider] initialize stack: $stack');
  });
  return service;
});

final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  final service = ref.watch(notificationServiceProvider);
  final soundEnabled = ref.watch(reminderSoundEnabledProvider);
  final vibrationEnabled = ref.watch(reminderVibrationEnabledProvider);
  return NotificationScheduler(
    notificationService: service,
    playSound: soundEnabled,
    enableVibration: vibrationEnabled,
  );
});

final scheduleRecoveryServiceProvider =
    Provider<ScheduleRecoveryService>((ref) {
  return ScheduleRecoveryService(
    notificationService: ref.watch(notificationServiceProvider),
    notificationScheduler: ref.watch(notificationSchedulerProvider),
  );
});

final notificationActionBridgeProvider =
    Provider<NotificationActionBridge>((ref) {
  final bridge = NotificationActionBridge(
    notificationService: ref.watch(notificationServiceProvider),
    notificationScheduler: ref.watch(notificationSchedulerProvider),
    scheduleRecoveryService: ref.watch(scheduleRecoveryServiceProvider),
    medicationRepository: ref.watch(medicationRepositoryProvider),
    measurementRepository: ref.watch(measurementRepositoryProvider),
    profileRepository: ref.watch(profileRepositoryProvider),
    getSnoozeDuration: () {
      final minutes = ref.read(defaultSnoozeDurationProvider);
      return Duration(minutes: minutes);
    },
  );
  return bridge;
});

final notificationPermissionProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  return await service.hasNotificationPermission();
});

final exactAlarmPermissionProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  return await service.hasExactAlarmPermission();
});

final notificationInitializerProvider = FutureProvider<void>((ref) async {
  final bridge = ref.watch(notificationActionBridgeProvider);

  ref.onDispose(() {
    debugPrint('notificationInitializerProvider disposed');
  });

  await bridge.initialize();

  // Request notification permission on Android 13+.
  final service = ref.watch(notificationServiceProvider);
  final hasPermission = await service.hasNotificationPermission();
  if (!hasPermission) {
    debugPrint('[notificationInitializerProvider] requesting notification permission');
    final granted = await service.requestNotificationPermission();
    debugPrint('[notificationInitializerProvider] permission granted: $granted');
  }

  // Recovery runs after a short delay to let DB queries settle.
  await Future.delayed(const Duration(seconds: 2));
  final profileId = ref.read(currentActiveProfileIdProvider);
  if (profileId != null) {
    await bridge.recoverAll(profileId);
  }
});

final reminderToggleWatcherProvider = Provider<void>((ref) {
  final medicationEnabled = ref.watch(medicationRemindersEnabledProvider);
  final measurementEnabled = ref.watch(measurementRemindersEnabledProvider);
  final service = ref.watch(notificationServiceProvider);
  final bridge = ref.watch(notificationActionBridgeProvider);

  ref.listen(medicationRemindersEnabledProvider, (prev, next) async {
    if (prev == null || prev == next) return;
    final profileId = ref.read(currentActiveProfileIdProvider);
    if (profileId == null) return;
    if (next) {
      await bridge.recoverMedicationSchedules(profileId);
    } else {
      await service.cancelAllNotifications();
      if (measurementEnabled) {
        await bridge.recoverMeasurementSchedules(profileId);
      }
    }
  });

  ref.listen(measurementRemindersEnabledProvider, (prev, next) async {
    if (prev == null || prev == next) return;
    final profileId = ref.read(currentActiveProfileIdProvider);
    if (profileId == null) return;
    if (next) {
      await bridge.recoverMeasurementSchedules(profileId);
    } else {
      await service.cancelAllNotifications();
      if (medicationEnabled) {
        await bridge.recoverMedicationSchedules(profileId);
      }
    }
  });

  // Re-schedule all notifications when sound/vibration preferences change,
  // since existing scheduled notifications were created with old settings.
  ref.listen(reminderSoundEnabledProvider, (prev, next) async {
    if (prev == null || prev == next) return;
    final profileId = ref.read(currentActiveProfileIdProvider);
    if (profileId == null) return;
    await service.cancelAllNotifications();
    await bridge.recoverAll(profileId);
  });

  ref.listen(reminderVibrationEnabledProvider, (prev, next) async {
    if (prev == null || prev == next) return;
    final profileId = ref.read(currentActiveProfileIdProvider);
    if (profileId == null) return;
    await service.cancelAllNotifications();
    await bridge.recoverAll(profileId);
  });
});
