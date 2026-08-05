class AppConstants {
  AppConstants._();

  static const String appName = 'RehabTrack';
  static const String defaultLanguage = 'en';

  /// Application version recorded in backup manifests. Keep in sync with
  /// `pubspec.yaml`.
  static const String appVersion = '1.0.0';

  /// Settings key for the user-selected app language.
  ///
  /// Persisted values are the storage codes defined in [AppLocale]'s
  /// `storageValue` mapping (`en`, `ka`, or `system`). Absence of the key is
  /// equivalent to `system`.
  static const String languageKey = 'app_language';

  /// Default grace period for the "Next" card and time-state classification.
  static const Duration nextItemGraceWindow = Duration(minutes: 15);

  /// Settings key for the user-configurable Next Item grace period in minutes.
  static const String nextItemGracePeriodSettingsKey = 'next_item_grace_period_minutes';

  // Reminder notification settings
  static const String medicationRemindersEnabledKey = 'medication_reminders_enabled';
  static const String measurementRemindersEnabledKey = 'measurement_reminders_enabled';
  static const String reminderSoundEnabledKey = 'reminder_sound_enabled';
  static const String reminderVibrationEnabledKey = 'reminder_vibration_enabled';
  static const String defaultSnoozeDurationKey = 'default_snooze_duration';
  static const String showPatientNameInNotificationsKey = 'show_patient_name_in_notifications';
  static const String showDetailsOnLockScreenKey = 'show_details_on_lock_screen';

  /// Settings key holding the ISO 8601 timestamp of the last successful backup.
  /// Written only after the archive has been stored at its destination.
  static const String lastSuccessfulBackupKey = 'last_backup_at';
}
