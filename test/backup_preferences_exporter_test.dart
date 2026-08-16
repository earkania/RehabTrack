import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/core/constants/app_constants.dart';
import 'package:rehab_track/data/services/backup/preferences_exporter.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';

class FakeSettingsRepository implements SettingsRepository {
  final Map<String, String> store;

  FakeSettingsRepository(this.store);

  @override
  Future<String?> getValue(String key) async => store[key];

  @override
  Future<void> setValue(String key, String value) async {
    store[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    store.remove(key);
  }

  @override
  Stream<Map<String, String>> watchAll() async* {
    yield Map.from(store);
  }

  @override
  Future<Map<String, String>> getAll() async => Map.from(store);
}

void main() {
  test('exports only allowlisted user settings', () async {
    final repo = FakeSettingsRepository({
      AppConstants.languageKey: 'ka',
      AppConstants.nextItemGracePeriodSettingsKey: '30',
      AppConstants.medicationRemindersEnabledKey: 'true',
      AppConstants.measurementRemindersEnabledKey: 'false',
      AppConstants.reminderSoundEnabledKey: 'true',
      AppConstants.reminderVibrationEnabledKey: 'true',
      AppConstants.defaultSnoozeDurationKey: '10',
      AppConstants.showPatientNameInNotificationsKey: 'false',
      AppConstants.showDetailsOnLockScreenKey: 'false',
      AppConstants.reminderStyleKey: 'alarmStyle',
    });

    final json = jsonDecode(await PreferencesExporter(repo).exportJson());
    expect(json, {
      AppConstants.languageKey: 'ka',
      AppConstants.nextItemGracePeriodSettingsKey: '30',
      AppConstants.medicationRemindersEnabledKey: 'true',
      AppConstants.measurementRemindersEnabledKey: 'false',
      AppConstants.reminderSoundEnabledKey: 'true',
      AppConstants.reminderVibrationEnabledKey: 'true',
      AppConstants.defaultSnoozeDurationKey: '10',
      AppConstants.showPatientNameInNotificationsKey: 'false',
      AppConstants.showDetailsOnLockScreenKey: 'false',
      AppConstants.reminderStyleKey: 'alarmStyle',
    });
  });

  test('excludes operational metadata and unknown keys', () async {
    final repo = FakeSettingsRepository({
      AppConstants.lastSuccessfulBackupKey: '2026-08-04T12:00:00.000',
      'some_internal_flag': 'x',
      AppConstants.languageKey: 'en',
    });

    final json = jsonDecode(await PreferencesExporter(repo).exportJson());
    expect(json, {AppConstants.languageKey: 'en'});
  });

  test('exports an empty object when nothing is set', () async {
    final repo = FakeSettingsRepository({});
    expect(await PreferencesExporter(repo).exportJson(), '{}');
  });
}
