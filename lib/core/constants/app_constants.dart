class AppConstants {
  AppConstants._();

  static const String appName = 'RehabTrack';
  static const String defaultLanguage = 'en';

  /// How long after a scheduled time an item remains "due" (not "overdue")
  /// in the status classification.
  static const Duration statusGraceWindow = Duration(minutes: 30);

  /// How long after a scheduled time an item remains eligible for
  /// the "Next" card. Must be <= [statusGraceWindow].
  static const Duration nextItemGraceWindow = Duration(minutes: 15);

  /// Settings key for the user-configurable Next Item grace period in minutes.
  static const String nextItemGracePeriodSettingsKey = 'next_item_grace_period_minutes';
}
