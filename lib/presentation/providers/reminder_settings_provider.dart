import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/core/constants/app_constants.dart';
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
