class AppConstants {
  AppConstants._();

  static const String appName = 'RehabTrack';
  static const String defaultLanguage = 'en';

  /// Default grace period for the "Next" card and time-state classification.
  static const Duration nextItemGraceWindow = Duration(minutes: 15);

  /// Settings key for the user-configurable Next Item grace period in minutes.
  static const String nextItemGracePeriodSettingsKey = 'next_item_grace_period_minutes';
}
