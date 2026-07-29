class AppConstants {
  AppConstants._();

  static const String appName = 'RehabTrack';
  static const String defaultLanguage = 'en';

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
}
