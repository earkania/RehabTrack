import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/core/localization/app_locale.dart';
import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/data/services/notification/notification_service.dart';
import 'package:rehab_track/presentation/providers/locale_provider.dart';
import 'package:rehab_track/presentation/providers/notification_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/providers/reminder_settings_provider.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';
import 'package:rehab_track/presentation/widgets/profile/profile_avatar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    final profileId = ref.watch(currentActiveProfileIdProvider);
    final profileAsync = profileId != null
        ? ref.watch(watchProfileByIdProvider(profileId))
        : null;
    final profile = profileAsync?.valueOrNull;

    final gracePeriodMinutes = ref.watch(nextItemGracePeriodProvider);

    final medicationReminders = ref.watch(medicationRemindersEnabledProvider);
    final measurementReminders = ref.watch(measurementRemindersEnabledProvider);
    final reminderSound = ref.watch(reminderSoundEnabledProvider);
    final reminderVibration = ref.watch(reminderVibrationEnabledProvider);
    final snoozeDuration = ref.watch(defaultSnoozeDurationProvider);
    final showPatientName = ref.watch(showPatientNameInNotificationsProvider);
    final showLockScreenDetails = ref.watch(showDetailsOnLockScreenProvider);

    final hasName =
        profile != null &&
        (profile.firstName.isNotEmpty || profile.lastName.isNotEmpty);
    final displayName = hasName
        ? '${profile.firstName} ${profile.lastName}'.trim()
        : l10n.patientProfile;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildSectionHeader(context, l10n.patientProfile),
          ListTile(
            leading: ProfileAvatar(
              photoPath: profile?.photoPath,
              firstName: profile?.firstName,
              lastName: profile?.lastName,
              radius: 20,
              isPrimary: profile?.isPrimary ?? false,
            ),
            title: Text(displayName),
            subtitle: Text(l10n.activeProfile),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.patientProfile),
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.language),
          _buildLanguageTile(
            context, ref,
            title: 'System',
            locale: AppLocale.system,
            currentLocale: currentLocale,
          ),
          _buildLanguageTile(
            context, ref,
            title: 'English',
            locale: AppLocale.english,
            currentLocale: currentLocale,
          ),
          _buildLanguageTile(
            context, ref,
            title: 'ქართული',
            locale: AppLocale.georgian,
            currentLocale: currentLocale,
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.theme),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: Text(l10n.theme),
            subtitle: Text(l10n.systemDefault),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.today),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: Text(l10n.nextItemGracePeriod),
            subtitle: Text(l10n.minutesValue(gracePeriodMinutes)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showGracePeriodDialog(context, ref, l10n, gracePeriodMinutes),
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.reminders),
          SwitchListTile(
            secondary: const Icon(Icons.medication_outlined),
            title: Text(l10n.medicationReminders),
            value: medicationReminders,
            onChanged: (value) {
              ref.read(medicationRemindersEnabledProvider.notifier).setEnabled(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.monitor_heart_outlined),
            title: Text(l10n.measurementReminders),
            value: measurementReminders,
            onChanged: (value) {
              ref.read(measurementRemindersEnabledProvider.notifier).setEnabled(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up_outlined),
            title: Text(l10n.reminderSound),
            value: reminderSound,
            onChanged: (value) {
              ref.read(reminderSoundEnabledProvider.notifier).setEnabled(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration_outlined),
            title: Text(l10n.reminderVibration),
            value: reminderVibration,
            onChanged: (value) {
              ref.read(reminderVibrationEnabledProvider.notifier).setEnabled(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: Text(l10n.defaultSnoozeDuration),
            subtitle: Text(l10n.minutesValue(snoozeDuration)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSnoozeDurationDialog(context, ref, l10n, snoozeDuration),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.person_outlined),
            title: Text('Show patient name'),
            subtitle: const Text('Display patient name in notifications'),
            value: showPatientName,
            onChanged: (value) {
              ref.read(showPatientNameInNotificationsProvider.notifier).setEnabled(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.lock_outline),
            title: Text('Show details on lock screen'),
            subtitle: const Text('Show medication details on the lock screen'),
            value: showLockScreenDetails,
            onChanged: (value) {
              ref.read(showDetailsOnLockScreenProvider.notifier).setEnabled(value);
            },
          ),
          const Divider(),
          _buildPermissionTile(
            context, ref, l10n,
            title: l10n.notificationPermission,
            provider: notificationPermissionProvider,
            grantedLabel: l10n.permissionGranted,
            deniedLabel: l10n.permissionDenied,
            onRequest: () async {
              final service = ref.read(notificationServiceProvider);
              await service.requestNotificationPermission();
              ref.invalidate(notificationPermissionProvider);
            },
          ),
          _buildPermissionTile(
            context, ref, l10n,
            title: l10n.exactAlarmAccess,
            provider: exactAlarmPermissionProvider,
            grantedLabel: l10n.permissionGranted,
            deniedLabel: l10n.permissionDenied,
            onRequest: () async {
              final service = ref.read(notificationServiceProvider);
              await service.requestExactAlarmPermission();
              ref.invalidate(exactAlarmPermissionProvider);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.medication_outlined),
            title: Text(l10n.testMedicationReminder),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _sendTestReminder(context, ref, l10n, isMeasurement: false),
          ),
          ListTile(
            leading: const Icon(Icons.monitor_heart_outlined),
            title: Text(l10n.testMeasurementReminder),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _sendTestReminder(context, ref, l10n, isMeasurement: true),
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.systemControls),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(l10n.androidNotificationSettings),
            subtitle: Text(l10n.androidNotificationSettingsDescription),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ref.read(notificationServiceProvider).openAppNotificationSettings();
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(72, 0, 16, 8),
            child: Text(
              l10n.androidMayHideUnusedCategories,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.security),
          SwitchListTile(
            secondary: const Icon(Icons.lock_outline),
            title: Text(l10n.appLock),
            subtitle: Text(l10n.disabled),
            value: false,
            onChanged: (value) {},
          ),
          if (kDebugMode) ...[
            const Divider(),
            _buildSectionHeader(context, 'Debug'),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Notification Diagnostics'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.push('/settings/notification-diagnostics');
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildPermissionTile(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n, {
    required String title,
    required FutureProvider<bool> provider,
    required String grantedLabel,
    required String deniedLabel,
    required VoidCallback onRequest,
  }) {
    final permissionState = ref.watch(provider);
    return ListTile(
      leading: const Icon(Icons.security_outlined),
      title: Text(title),
      subtitle: Text(
        permissionState.when(
          data: (granted) => granted ? grantedLabel : deniedLabel,
          loading: () => l10n.loading,
          error: (_, _) => deniedLabel,
        ),
      ),
      trailing: TextButton(
        onPressed: onRequest,
        child: Text(l10n.request),
      ),
    );
  }

  void _showGracePeriodDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    int current,
  ) {
    final options = [5, 10, 15, 30, 60];
    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Text(l10n.nextItemGracePeriod),
          children: options.map((minutes) {
            return ListTile(
              leading: Icon(
                minutes == current
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: minutes == current
                    ? Theme.of(ctx).colorScheme.primary
                    : null,
              ),
              title: Text(_gracePeriodLabel(l10n, minutes)),
              onTap: () {
                ref.read(nextItemGracePeriodProvider.notifier).setGracePeriod(minutes);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showSnoozeDurationDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    int current,
  ) {
    final options = [5, 10, 15, 30, 60];
    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Text(l10n.defaultSnoozeDuration),
          children: options.map((minutes) {
            return ListTile(
              leading: Icon(
                minutes == current
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: minutes == current
                    ? Theme.of(ctx).colorScheme.primary
                    : null,
              ),
              title: Text(l10n.minutesValue(minutes)),
              onTap: () {
                ref.read(defaultSnoozeDurationProvider.notifier).setDuration(minutes);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        );
      },
    );
  }

  String _gracePeriodLabel(AppLocalizations l10n, int minutes) {
    return switch (minutes) {
      5 => l10n.fiveMinutes,
      10 => l10n.tenMinutes,
      15 => l10n.fifteenMinutes,
      30 => l10n.thirtyMinutes,
      60 => l10n.sixtyMinutes,
      _ => '$minutes ${l10n.minutesValue(minutes)}',
    };
  }

  Future<void> _sendTestReminder(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n, {
    required bool isMeasurement,
  }) async {
    final service = ref.read(notificationServiceProvider);
    final hasPermission = await service.hasNotificationPermission();
    if (!hasPermission) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noPermission)),
        );
      }
      return;
    }

    final playSound = ref.read(reminderSoundEnabledProvider);
    final enableVibration = ref.read(reminderVibrationEnabledProvider);

    final now = DateTime.now();
    final testTime = now.add(const Duration(seconds: 5));
    final tzDate = tz.TZDateTime(
      tz.local,
      testTime.year,
      testTime.month,
      testTime.day,
      testTime.hour,
      testTime.minute,
      testTime.second,
    );

    if (isMeasurement) {
      const channelId = NotificationService.measurementChannelId;
      const id = 999998;
      await service.scheduleNotification(
        id: id,
        title: 'Test measurement reminder',
        body: 'This is a test of measurement reminder alerts.',
        scheduledDate: tzDate,
        channelId: channelId,
        playSound: playSound,
        enableVibration: enableVibration,
      );
    } else {
      const channelId = NotificationService.medicationChannelId;
      const id = 999999;
      await service.scheduleNotification(
        id: id,
        title: 'Test medication reminder',
        body: 'This is a test of medication reminder alerts.',
        scheduledDate: tzDate,
        channelId: channelId,
        playSound: playSound,
        enableVibration: enableVibration,
      );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.testReminderSent)),
      );
    }
  }

  Widget _buildLanguageTile(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required AppLocale locale,
    required Locale? currentLocale,
  }) {
    final isSelected = currentLocale == locale.locale;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(title),
      onTap: () => ref.read(localeProvider.notifier).setLocale(locale),
    );
  }
}
