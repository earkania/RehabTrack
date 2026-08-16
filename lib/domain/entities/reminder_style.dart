/// How reminder notifications are presented to the user.
///
/// This is a presentation concern: it selects which Android notification
/// channel (and therefore importance, sound, and vibration behavior) a
/// reminder is delivered on. It does not change what is scheduled, the
/// notification payload, or the notification identity.
enum ReminderStyle {
  standard,
  prominent,
  alarmStyle;

  /// Stable value persisted to settings. Localized labels are never stored.
  String get storageValue => switch (this) {
        ReminderStyle.standard => 'standard',
        ReminderStyle.prominent => 'prominent',
        ReminderStyle.alarmStyle => 'alarmStyle',
      };

  /// Parses a persisted value. Unknown or missing values fall back to
  /// [ReminderStyle.standard] so existing installs are unaffected.
  static ReminderStyle fromStorageValue(String? value) {
    return switch (value) {
      'standard' => ReminderStyle.standard,
      'prominent' => ReminderStyle.prominent,
      'alarmStyle' => ReminderStyle.alarmStyle,
      _ => ReminderStyle.standard,
    };
  }
}