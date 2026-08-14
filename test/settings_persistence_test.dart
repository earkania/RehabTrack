import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/core/constants/app_constants.dart';
import 'package:rehab_track/core/localization/app_locale.dart';
import 'package:rehab_track/domain/entities/reminder_style.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/locale_provider.dart';
import 'package:rehab_track/presentation/providers/reminder_settings_provider.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';

class FakeSettingsRepository implements SettingsRepository {
  final Map<String, String> store = {};

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
    yield Map.of(store);
  }

  @override
  Future<Map<String, String>> getAll() async => Map.of(store);
}

/// Creates a fresh provider container over a shared [repo] store, mimicking a
/// cold app restart while keeping the same persisted storage.
ProviderContainer restartContainer(FakeSettingsRepository repo) {
  return ProviderContainer(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(repo),
    ],
  );
}

void main() {
  group('Language persistence', () {
    test('setLocale persists and reloads across restart', () async {
      final repo = FakeSettingsRepository();

      final first = restartContainer(repo);
      await first.read(localeProvider.notifier).ready;
      await first.read(localeProvider.notifier).setLocale(AppLocale.georgian);

      expect(first.read(localeProvider), const Locale('ka'));
      expect(await repo.getValue(AppConstants.languageKey), 'ka');
      first.dispose();

      final restarted = restartContainer(repo);
      await restarted.read(localeProvider.notifier).ready;
      expect(restarted.read(localeProvider), const Locale('ka'));
      restarted.dispose();
    });

    test('defaults to system when nothing is persisted', () async {
      final repo = FakeSettingsRepository();
      final container = restartContainer(repo);

      await container.read(localeProvider.notifier).ready;
      expect(container.read(localeProvider), isNull);
      container.dispose();
    });

    test('persisted english locale reloads across restart', () async {
      final repo = FakeSettingsRepository();
      await repo.setValue(AppConstants.languageKey, 'en');

      final container = restartContainer(repo);
      await container.read(localeProvider.notifier).ready;
      expect(container.read(localeProvider), const Locale('en'));
      container.dispose();
    });

    test('unknown persisted value falls back to system', () async {
      final repo = FakeSettingsRepository();
      await repo.setValue(AppConstants.languageKey, 'fr');

      final container = restartContainer(repo);
      await container.read(localeProvider.notifier).ready;
      expect(container.read(localeProvider), isNull);
      container.dispose();
    });

    test('resetToSystem persists system and reloads as null', () async {
      final repo = FakeSettingsRepository();

      final first = restartContainer(repo);
      await first.read(localeProvider.notifier).ready;
      await first.read(localeProvider.notifier).setLocale(AppLocale.georgian);
      await first.read(localeProvider.notifier).resetToSystem();

      expect(first.read(localeProvider), isNull);
      expect(await repo.getValue(AppConstants.languageKey), 'system');
      first.dispose();

      final restarted = restartContainer(repo);
      await restarted.read(localeProvider.notifier).ready;
      expect(restarted.read(localeProvider), isNull);
      restarted.dispose();
    });
  });

  group('Default snooze duration persistence', () {
    test('persisted value is loaded before consumers read it', () async {
      final repo = FakeSettingsRepository();
      await repo.setValue(AppConstants.defaultSnoozeDurationKey, '30');

      final container = restartContainer(repo);
      await container.read(defaultSnoozeDurationProvider.notifier).ready;

      expect(container.read(defaultSnoozeDurationProvider), 30);
      container.dispose();
    });

    test('save is awaited and visible across restart', () async {
      final repo = FakeSettingsRepository();

      final first = restartContainer(repo);
      final notifier = first.read(defaultSnoozeDurationProvider.notifier);
      await notifier.ready;
      await notifier.setDuration(60);
      first.dispose();

      final restarted = restartContainer(repo);
      await restarted.read(defaultSnoozeDurationProvider.notifier).ready;
      expect(restarted.read(defaultSnoozeDurationProvider), 60);
      restarted.dispose();
    });
  });

  group('Reminder toggle persistence', () {
    test('disabled reminder reloads across restart', () async {
      final repo = FakeSettingsRepository();

      final first = restartContainer(repo);
      final notifier = first.read(medicationRemindersEnabledProvider.notifier);
      await notifier.ready;
      await notifier.setEnabled(false);
      first.dispose();

      final restarted = restartContainer(repo);
      await restarted.read(medicationRemindersEnabledProvider.notifier).ready;
      expect(restarted.read(medicationRemindersEnabledProvider), isFalse);
      restarted.dispose();
    });

    test('enabled reminder persists and reloads as true', () async {
      final repo = FakeSettingsRepository();

      final first = restartContainer(repo);
      final notifier = first.read(reminderSoundEnabledProvider.notifier);
      await notifier.ready;
      await notifier.setEnabled(true);
      first.dispose();

      final restarted = restartContainer(repo);
      await restarted.read(reminderSoundEnabledProvider.notifier).ready;
      expect(restarted.read(reminderSoundEnabledProvider), isTrue);
      restarted.dispose();
    });
  });

  group('Next item grace period persistence', () {
    test('persisted grace period reloads across restart', () async {
      final repo = FakeSettingsRepository();

      final first = restartContainer(repo);
      final notifier = first.read(nextItemGracePeriodProvider.notifier);
      await notifier.ready;
      await notifier.setGracePeriod(30);
      first.dispose();

      final restarted = restartContainer(repo);
      await restarted.read(nextItemGracePeriodProvider.notifier).ready;
      expect(restarted.read(nextItemGracePeriodProvider), 30);
      restarted.dispose();
    });
  });

  group('Reminder style persistence', () {
    test('defaults to standard when nothing is persisted', () async {
      final repo = FakeSettingsRepository();

      final container = restartContainer(repo);
      await container.read(reminderStyleProvider.notifier).ready;
      expect(container.read(reminderStyleProvider), ReminderStyle.standard);
      container.dispose();
    });

    test('prominent style persists with a stable value across restart', () async {
      final repo = FakeSettingsRepository();

      final first = restartContainer(repo);
      final notifier = first.read(reminderStyleProvider.notifier);
      await notifier.ready;
      await notifier.setStyle(ReminderStyle.prominent);
      expect(await repo.getValue(AppConstants.reminderStyleKey), 'prominent');
      first.dispose();

      final restarted = restartContainer(repo);
      await restarted.read(reminderStyleProvider.notifier).ready;
      expect(restarted.read(reminderStyleProvider), ReminderStyle.prominent);
      restarted.dispose();
    });

    test('standard style persists and reloads as standard', () async {
      final repo = FakeSettingsRepository();

      final first = restartContainer(repo);
      final notifier = first.read(reminderStyleProvider.notifier);
      await notifier.ready;
      await notifier.setStyle(ReminderStyle.standard);
      expect(await repo.getValue(AppConstants.reminderStyleKey), 'standard');
      first.dispose();

      final restarted = restartContainer(repo);
      await restarted.read(reminderStyleProvider.notifier).ready;
      expect(restarted.read(reminderStyleProvider), ReminderStyle.standard);
      restarted.dispose();
    });

    test('unknown persisted value falls back to standard', () async {
      final repo = FakeSettingsRepository();
      await repo.setValue(AppConstants.reminderStyleKey, 'alarm');

      final container = restartContainer(repo);
      await container.read(reminderStyleProvider.notifier).ready;
      expect(container.read(reminderStyleProvider), ReminderStyle.standard);
      container.dispose();
    });
  });
}
