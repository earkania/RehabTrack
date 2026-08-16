import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/app_router.dart';
import '../../core/router/app_routes.dart';
import '../../data/services/notification/alarm_presentation.dart';
import '../../data/services/notification/alarm_style_capability_service.dart';
import '../../data/services/notification/notification_action_bridge.dart';
import '../../data/services/notification/notification_action_handler.dart';
import '../../data/services/notification/notification_scheduler.dart';
import '../../data/services/notification/notification_service.dart';
import '../../data/services/notification/schedule_recovery_service.dart';
import '../../domain/entities/reminder_style.dart';
import '../../domain/entities/scheduled_measurement.dart';
import 'database_provider.dart';
import 'profile_provider.dart';
import 'reminder_settings_provider.dart';
import 'today_provider.dart';

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

/// Synchronous, last-known full-screen allowance for alarm-style reminders.
/// Kept in sync by [alarmStyleCapabilityProvider]; the scheduler reads this so
/// it never blocks on a platform call when building notification details.
final alarmFullScreenAllowedProvider = StateProvider<bool>((ref) => false);

/// The currently active Alarm-style presentation to show on the Alarm screen.
/// Set when an alarm notification is opened; cleared when the presentation is
/// acknowledged (dismissed or completed).
final activeAlarmPresentationProvider =
    StateProvider<AlarmPresentation?>((ref) => null);

/// Probe alarm-style capability on the current device and mirrors the
/// full-screen allowance into [alarmFullScreenAllowedProvider].
final alarmStyleCapabilityProvider =
    FutureProvider<AlarmStyleCapability>((ref) async {
  final service = ref.watch(alarmStyleCapabilityServiceProvider);
  final capability = await service.check();
  ref.read(alarmFullScreenAllowedProvider.notifier).state =
      capability.fullScreenAllowed == true;
  return capability;
});

/// Service used to inspect alarm-style capability and to open the system
/// "Full screen content" settings for this app.
final alarmStyleCapabilityServiceProvider =
    Provider<AlarmStyleCapabilityService>((ref) {
  return AlarmStyleCapabilityService(
    notificationService: ref.watch(notificationServiceProvider),
  );
});

final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  final service = ref.watch(notificationServiceProvider);
  final soundEnabled = ref.watch(reminderSoundEnabledProvider);
  final vibrationEnabled = ref.watch(reminderVibrationEnabledProvider);
  final style = ref.watch(reminderStyleProvider);
  final fullScreenAllowed = ref.watch(alarmFullScreenAllowedProvider);
  return NotificationScheduler(
    notificationService: service,
    playSound: soundEnabled,
    enableVibration: vibrationEnabled,
    reminderStyle: style,
    fullScreenIntentForAlarm: fullScreenAllowed,
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
    doctorVisitRepository: ref.watch(doctorVisitRepositoryProvider),
    careContactRepository: ref.watch(careContactRepositoryProvider),
    getSnoozeDuration: () {
      final minutes = ref.read(defaultSnoozeDurationProvider);
      return Duration(minutes: minutes);
    },
    showProfileName: () {
      return ref.read(showPatientNameInNotificationsProvider);
    },
    showDetailsOnLockScreen: () {
      return ref.read(showDetailsOnLockScreenProvider);
    },
    isAlarmStyleActive: () {
      return ref.read(reminderStyleProvider) == ReminderStyle.alarmStyle;
    },
    onAlarmPresent: (notificationId, payload) {
      ref.read(activeAlarmPresentationProvider.notifier).state =
          AlarmPresentation(
        notificationId: notificationId ?? 0,
        payload: payload,
      );
      try {
        ref.read(routerProvider).push(AppRoutes.alarm);
      } catch (_) {
        // Navigation may fail during cold-start before the router is ready;
        // the initializer re-checks the active presentation after startup.
      }
    },
    onActionProcessed: (actionType, payload) {
      ref.invalidate(todayAgendaProvider);
      final now = DateTime.now();
      ref.read(selectedAgendaDateProvider.notifier).state =
          DateTime(now.year, now.month, now.day);
      // When an Alarm-style presentation is active the Alarm screen owns the
      // navigation (it decides success vs inline-error before leaving); the
      // generic notification routing below would yank the user away before the
      // Alarm screen could react to a failed action.
      if (ref.read(activeAlarmPresentationProvider) != null) {
        return;
      }
      try {
        if (actionType == NotificationActionType.measurementRecordNow &&
            payload.measurementTypeId != null) {
          final scheduledTime = payload.occurrenceDateTime != null
              ? MeasurementOccurrenceTime.normalize(payload.occurrenceDateTime!)
              : DateTime(now.year, now.month, now.day, now.hour, now.minute);
          final extra = RecordNowExtra(
            reminderScheduleId: payload.scheduleId,
            scheduledOccurrenceTime: scheduledTime,
          );
          // Navigate to Today first so the user can press back to return.
          ref.read(routerProvider).go(AppRoutes.home);
          ref.read(routerProvider).push(
            AppRoutes.measurementAdd(payload.measurementTypeId!),
            extra: extra,
          );
        } else if (actionType == NotificationActionType.doctorVisitOpen) {
          final visitId = payload.visitId ?? payload.scheduleId;
          if (visitId > 0) {
            ref.read(routerProvider).go(AppRoutes.home);
            ref.read(routerProvider).push(
              AppRoutes.doctorVisitDetails(visitId),
            );
          }
        } else {
          ref.read(routerProvider).go(AppRoutes.home);
        }
      } catch (_) {
        // Navigation may fail during initialization before router is ready.
      }
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

  // Probe alarm-style capability so the full-screen-intent allowance is known
  // before any reminder is scheduled in this process. The settings screen also
  // probes on open, but reminders can be scheduled from other flows (e.g. the
  // doctor-visit form) before Settings is ever shown. A probe failure must not
  // abort the rest of startup; the allowance simply stays at its default.
  try {
    await ref.read(alarmStyleCapabilityProvider.future);
  } catch (e, stack) {
    debugPrint('[notificationInitializerProvider] capability probe failed: $e');
    debugPrint('[notificationInitializerProvider] $stack');
  }

  // Process any pending actions that were stored by the background callback.
  await bridge.processPendingActions();

  // Check if app was launched by a notification action (terminated process case).
  await bridge.processAppLaunchAction();

  // Alarm-style cold-start presentation is intentionally NOT handled here.
  // It needs the persisted reminder style hydrated (reminderStyleProvider loads
  // from the database asynchronously) and a router that is attached, neither of
  // which is guaranteed while this initializer runs (it is read from main()
  // before runApp and can be disposed before the style loads). RehabTrackApp
  // runs the cold-start alarm presentation after the first frame instead, where
  // the router is ready, the style is loaded, and navigation is guaranteed.

  // Invalidate the agenda so it re-fetches after any actions processed above.
  // The onActionProcessed callback on the bridge also handles live taps, but
  // during initialization the agenda may not have been read yet, so invalidate
  // explicitly here.
  ref.invalidate(todayAgendaProvider);

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

  // Re-schedule all notifications when the reminder style changes, since
  // future pending notifications must move to the channel for the new style.
  // Occurrences already past or intentionally skipped/completed are not
  // re-scheduled because recovery only produces future occurrences.
  ref.listen(reminderStyleProvider, (prev, next) async {
    if (prev == null || prev == next) return;
    final profileId = ref.read(currentActiveProfileIdProvider);
    if (profileId == null) return;
    await service.cancelAllNotifications();
    await bridge.recoverAll(profileId);
  });
});
