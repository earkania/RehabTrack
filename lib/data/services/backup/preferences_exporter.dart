import 'dart:convert';

import 'package:rehab_track/core/constants/app_constants.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';

/// Exports the user-configurable application settings as a JSON document.
///
/// Only settings that are safe to restore are included (language, grace
/// period, reminders, snooze, notification content). Operational metadata such
/// as the last-backup timestamp is intentionally excluded.
class PreferencesExporter {
  /// Keys the app considers user settings that belong in a backup.
  static const allowlist = <String>{
    AppConstants.languageKey,
    AppConstants.nextItemGracePeriodSettingsKey,
    AppConstants.medicationRemindersEnabledKey,
    AppConstants.measurementRemindersEnabledKey,
    AppConstants.reminderSoundEnabledKey,
    AppConstants.reminderVibrationEnabledKey,
    AppConstants.defaultSnoozeDurationKey,
    AppConstants.showPatientNameInNotificationsKey,
    AppConstants.showDetailsOnLockScreenKey,
    AppConstants.reminderStyleKey,
    AppConstants.alarmSoundUriKey,
    AppConstants.alarmSoundTitleKey,
  };

  final SettingsRepository _settingsRepository;

  PreferencesExporter(this._settingsRepository);

  /// Returns a JSON object of `{settingsKey: storedValue}` for allowlisted
  /// keys currently present in the settings store.
  Future<String> exportJson() async {
    final all = await _settingsRepository.getAll();
    final filtered = <String, String>{
      for (final key in allowlist)
        if (all.containsKey(key)) key: all[key]!,
    };
    return jsonEncode(filtered);
  }
}
