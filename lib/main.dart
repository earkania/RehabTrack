import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:rehab_track/app.dart';
import 'package:rehab_track/data/services/storage/lab_attachment_layout_migrator.dart';
import 'package:rehab_track/presentation/providers/locale_provider.dart';
import 'package:rehab_track/presentation/providers/notification_provider.dart';
import 'package:rehab_track/presentation/providers/reminder_settings_provider.dart';
import 'package:rehab_track/presentation/providers/restore_apply_provider.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final container = ProviderContainer();

  // Detect and recover an interrupted restore from a previous launch before
  // anything opens the database, so the app never reads a half-restored file.
  await runStartupRestoreRecovery(container);

  // Relocate legacy `files/lab_analyses` attachment files to the managed
  // `lab_analyses/` root so backups and restores stay consistent.
  await const LabAttachmentLayoutMigrator()
      .migrate(await getApplicationDocumentsDirectory());

  // Initialize notification actions and schedule recovery at startup.
  // This must happen before runApp so that the callback is registered
  // before any notification can be received.
  container.read(notificationInitializerProvider);
  // Activate the reminder-toggle watcher so it reacts to changes.
  container.read(reminderToggleWatcherProvider);

  // Block the first frame until persisted settings have been loaded. Without
  // this, providers start at their in-memory defaults and consumers such as
  // the notification action bridge or the settings screen can read a default
  // (e.g. 10-minute snooze) before the persisted value arrives, making saved
  // settings appear to reset after a restart.
  await _warmUpPersistedSettings(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const RehabTrackApp(),
    ),
  );
}

/// Loads every persisted app setting before the UI is shown.
Future<void> _warmUpPersistedSettings(ProviderContainer container) async {
  await container.read(localeProvider.notifier).ready;
  await container.read(nextItemGracePeriodProvider.notifier).ready;
  await container.read(defaultSnoozeDurationProvider.notifier).ready;
  await container.read(medicationRemindersEnabledProvider.notifier).ready;
  await container.read(measurementRemindersEnabledProvider.notifier).ready;
  await container.read(reminderSoundEnabledProvider.notifier).ready;
  await container.read(reminderVibrationEnabledProvider.notifier).ready;
  await container.read(showPatientNameInNotificationsProvider.notifier).ready;
  await container.read(showDetailsOnLockScreenProvider.notifier).ready;
}
