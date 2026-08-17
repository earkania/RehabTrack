import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/core/constants/app_constants.dart';
import 'package:rehab_track/domain/entities/alarm_sound_selection.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/reminder_settings_provider.dart';

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

ProviderContainer restartContainer(FakeSettingsRepository repo) {
  return ProviderContainer(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(repo),
    ],
  );
}

void main() {
  group('Alarm sound selection persistence', () {
    test('defaults to null (system default) when nothing is persisted', () async {
      final repo = FakeSettingsRepository();
      final container = restartContainer(repo);

      await container.read(alarmSoundProvider.notifier).ready;
      expect(container.read(alarmSoundProvider), isNull);
      container.dispose();
    });

    test('setAlarmSound persists uri and title and survives restart', () async {
      final repo = FakeSettingsRepository();
      final first = restartContainer(repo);
      await first.read(alarmSoundProvider.notifier).ready;

      await first.read(alarmSoundProvider.notifier).setAlarmSound(
        const AlarmSoundSelection(
          uri: 'content://media/internal/audio/media/42',
          title: 'Morning Bell',
        ),
      );

      expect(first.read(alarmSoundProvider), isNotNull);
      expect(first.read(alarmSoundProvider)!.uri,
          'content://media/internal/audio/media/42');
      expect(await repo.getValue(AppConstants.alarmSoundUriKey),
          'content://media/internal/audio/media/42');
      expect(await repo.getValue(AppConstants.alarmSoundTitleKey), 'Morning Bell');
      first.dispose();

      final restarted = restartContainer(repo);
      await restarted.read(alarmSoundProvider.notifier).ready;
      final reloaded = restarted.read(alarmSoundProvider);
      expect(reloaded, isNotNull);
      expect(reloaded!.uri, 'content://media/internal/audio/media/42');
      expect(reloaded.title, 'Morning Bell');
      restarted.dispose();
    });

    test('selection without a title persists the uri only', () async {
      final repo = FakeSettingsRepository();
      final container = restartContainer(repo);
      await container.read(alarmSoundProvider.notifier).ready;

      await container.read(alarmSoundProvider.notifier).setAlarmSound(
        const AlarmSoundSelection(uri: 'content://media/alarm/7'),
      );

      expect(await repo.getValue(AppConstants.alarmSoundUriKey),
          'content://media/alarm/7');
      expect(await repo.getValue(AppConstants.alarmSoundTitleKey), isNull);
      expect(container.read(alarmSoundProvider)!.title, isNull);
      container.dispose();
    });

    test('clear removes both keys and falls back to system default', () async {
      final repo = FakeSettingsRepository();
      final container = restartContainer(repo);
      await container.read(alarmSoundProvider.notifier).ready;
      await container.read(alarmSoundProvider.notifier).setAlarmSound(
        const AlarmSoundSelection(
          uri: 'content://media/alarm/9',
          title: 'Wake Up',
        ),
      );

      await container.read(alarmSoundProvider.notifier).clear();

      expect(container.read(alarmSoundProvider), isNull);
      expect(await repo.getValue(AppConstants.alarmSoundUriKey), isNull);
      expect(await repo.getValue(AppConstants.alarmSoundTitleKey), isNull);
      container.dispose();
    });

    test('persisted uri with no persisted title reloads as null-title selection',
        () async {
      final repo = FakeSettingsRepository();
      await repo.setValue(AppConstants.alarmSoundUriKey, 'content://media/a1');

      final container = restartContainer(repo);
      await container.read(alarmSoundProvider.notifier).ready;

      final selection = container.read(alarmSoundProvider);
      expect(selection, isNotNull);
      expect(selection!.uri, 'content://media/a1');
      expect(selection.title, isNull);
      container.dispose();
    });
  });
}