import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/core/constants/app_constants.dart';
import 'package:rehab_track/domain/entities/alarm_sound_selection.dart';
import 'package:rehab_track/domain/entities/reminder_style.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';

final medicationRemindersEnabledProvider =
    StateNotifierProvider<ReminderEnabledNotifier, bool>((ref) {
  return ReminderEnabledNotifier(
    ref.read(settingsRepositoryProvider),
    AppConstants.medicationRemindersEnabledKey,
    true,
  );
});

final measurementRemindersEnabledProvider =
    StateNotifierProvider<ReminderEnabledNotifier, bool>((ref) {
  return ReminderEnabledNotifier(
    ref.read(settingsRepositoryProvider),
    AppConstants.measurementRemindersEnabledKey,
    true,
  );
});

final reminderSoundEnabledProvider =
    StateNotifierProvider<ReminderEnabledNotifier, bool>((ref) {
  return ReminderEnabledNotifier(
    ref.read(settingsRepositoryProvider),
    AppConstants.reminderSoundEnabledKey,
    true,
  );
});

final reminderVibrationEnabledProvider =
    StateNotifierProvider<ReminderEnabledNotifier, bool>((ref) {
  return ReminderEnabledNotifier(
    ref.read(settingsRepositoryProvider),
    AppConstants.reminderVibrationEnabledKey,
    true,
  );
});

final defaultSnoozeDurationProvider =
    StateNotifierProvider<SnoozeDurationNotifier, int>((ref) {
  return SnoozeDurationNotifier(
    ref.read(settingsRepositoryProvider),
  );
});

final reminderStyleProvider =
    StateNotifierProvider<ReminderStyleNotifier, ReminderStyle>((ref) {
  return ReminderStyleNotifier(
    ref.read(settingsRepositoryProvider),
  );
});

/// The user-selected Alarm-style alarm sound (native alarm player), or null
/// when the system default alarm sound is used.
final alarmSoundProvider =
    StateNotifierProvider<AlarmSoundNotifier, AlarmSoundSelection?>((ref) {
  return AlarmSoundNotifier(
    ref.read(settingsRepositoryProvider),
  );
});

class ReminderEnabledNotifier extends StateNotifier<bool> {
  final SettingsRepository _settingsRepository;
  final String _key;
  Future<void>? _loadFuture;

  ReminderEnabledNotifier(
    this._settingsRepository,
    this._key,
    bool defaultValue,
  ) : super(defaultValue) {
    _loadFuture = _load();
  }

  Future<void> get ready => _loadFuture ?? Future.value();

  Future<void> _load() async {
    final raw = await _settingsRepository.getValue(_key);
    if (raw != null) {
      state = raw == 'true';
    }
  }

  Future<void> setEnabled(bool value) async {
    state = value;
    await _settingsRepository.setValue(_key, value.toString());
  }
}

class SnoozeDurationNotifier extends StateNotifier<int> {
  final SettingsRepository _settingsRepository;
  Future<void>? _loadFuture;

  SnoozeDurationNotifier(this._settingsRepository) : super(10) {
    _loadFuture = _load();
  }

  Future<void> get ready => _loadFuture ?? Future.value();

  Future<void> _load() async {
    final raw =
        await _settingsRepository.getValue(AppConstants.defaultSnoozeDurationKey);
    if (raw != null) {
      final parsed = int.tryParse(raw);
      if (parsed != null && parsed > 0) {
        state = parsed;
      }
    }
  }

  Future<void> setDuration(int minutes) async {
    if (minutes <= 0) return;
    state = minutes;
    await _settingsRepository.setValue(
      AppConstants.defaultSnoozeDurationKey,
      minutes.toString(),
    );
  }
}

class ReminderStyleNotifier extends StateNotifier<ReminderStyle> {
  final SettingsRepository _settingsRepository;
  Future<void>? _loadFuture;

  ReminderStyleNotifier(this._settingsRepository)
      : super(ReminderStyle.standard) {
    _loadFuture = _load();
  }

  Future<void> get ready => _loadFuture ?? Future.value();

  Future<void> _load() async {
    final raw = await _settingsRepository.getValue(AppConstants.reminderStyleKey);
    if (raw != null) {
      state = ReminderStyle.fromStorageValue(raw);
    }
  }

  Future<void> setStyle(ReminderStyle style) async {
    state = style;
    await _settingsRepository.setValue(
      AppConstants.reminderStyleKey,
      style.storageValue,
    );
  }
}

/// Persists the user's Alarm-style alarm sound selection. A null state means
/// the system default alarm sound is used.
class AlarmSoundNotifier extends StateNotifier<AlarmSoundSelection?> {
  final SettingsRepository _settingsRepository;
  Future<void>? _loadFuture;

  AlarmSoundNotifier(this._settingsRepository) : super(null) {
    _loadFuture = _load();
  }

  Future<void> get ready => _loadFuture ?? Future.value();

  Future<void> _load() async {
    final uri = await _settingsRepository.getValue(
      AppConstants.alarmSoundUriKey,
    );
    if (uri == null || uri.isEmpty) return;
    final title = await _settingsRepository.getValue(
      AppConstants.alarmSoundTitleKey,
    );
    state = AlarmSoundSelection(uri: uri, title: title);
  }

  Future<void> setAlarmSound(AlarmSoundSelection selection) async {
    state = selection;
    await _settingsRepository.setValue(
      AppConstants.alarmSoundUriKey,
      selection.uri,
    );
    if (selection.title == null || selection.title!.isEmpty) {
      await _settingsRepository.remove(AppConstants.alarmSoundTitleKey);
    } else {
      await _settingsRepository.setValue(
        AppConstants.alarmSoundTitleKey,
        selection.title!,
      );
    }
  }

  /// Clears the selection, falling back to the system default alarm sound.
  Future<void> clear() async {
    state = null;
    await _settingsRepository.remove(AppConstants.alarmSoundUriKey);
    await _settingsRepository.remove(AppConstants.alarmSoundTitleKey);
  }
}

final showPatientNameInNotificationsProvider =
    StateNotifierProvider<ReminderEnabledNotifier, bool>((ref) {
  return ReminderEnabledNotifier(
    ref.read(settingsRepositoryProvider),
    AppConstants.showPatientNameInNotificationsKey,
    true,
  );
});

final showDetailsOnLockScreenProvider =
    StateNotifierProvider<ReminderEnabledNotifier, bool>((ref) {
  return ReminderEnabledNotifier(
    ref.read(settingsRepositoryProvider),
    AppConstants.showDetailsOnLockScreenKey,
    true,
  );
});
