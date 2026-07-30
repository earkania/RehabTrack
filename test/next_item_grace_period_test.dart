import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/core/constants/app_constants.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';

class FakeSettingsRepository implements SettingsRepository {
  final Map<String, String> _store = {};

  @override
  Future<String?> getValue(String key) async => _store[key];

  @override
  Future<void> setValue(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
  }

  @override
  Stream<Map<String, String>> watchAll() async* {
    yield Map.from(_store);
  }

  @override
  Future<Map<String, String>> getAll() async => Map.from(_store);
}

void main() {
  group('NextItemGracePeriod repository', () {
    test('default is 15 minutes', () async {
      final repo = FakeSettingsRepository();
      final raw = await repo.getValue(AppConstants.nextItemGracePeriodSettingsKey);
      final minutes = raw != null ? int.tryParse(raw) : null;
      expect(minutes ?? 15, 15);
    });

    test('save 5 minutes', () async {
      final repo = FakeSettingsRepository();
      await repo.setValue(AppConstants.nextItemGracePeriodSettingsKey, '5');
      final raw = await repo.getValue(AppConstants.nextItemGracePeriodSettingsKey);
      expect(int.parse(raw!), 5);
    });

    test('save 10 minutes', () async {
      final repo = FakeSettingsRepository();
      await repo.setValue(AppConstants.nextItemGracePeriodSettingsKey, '10');
      final raw = await repo.getValue(AppConstants.nextItemGracePeriodSettingsKey);
      expect(int.parse(raw!), 10);
    });

    test('save 15 minutes', () async {
      final repo = FakeSettingsRepository();
      await repo.setValue(AppConstants.nextItemGracePeriodSettingsKey, '15');
      final raw = await repo.getValue(AppConstants.nextItemGracePeriodSettingsKey);
      expect(int.parse(raw!), 15);
    });

    test('save 30 minutes', () async {
      final repo = FakeSettingsRepository();
      await repo.setValue(AppConstants.nextItemGracePeriodSettingsKey, '30');
      final raw = await repo.getValue(AppConstants.nextItemGracePeriodSettingsKey);
      expect(int.parse(raw!), 30);
    });

    test('save 60 minutes', () async {
      final repo = FakeSettingsRepository();
      await repo.setValue(AppConstants.nextItemGracePeriodSettingsKey, '60');
      final raw = await repo.getValue(AppConstants.nextItemGracePeriodSettingsKey);
      expect(int.parse(raw!), 60);
    });

    test('value persists across repository recreation', () async {
      final repo1 = FakeSettingsRepository();
      await repo1.setValue(AppConstants.nextItemGracePeriodSettingsKey, '30');

      final repo2 = FakeSettingsRepository();
      final raw = await repo2.getValue(AppConstants.nextItemGracePeriodSettingsKey);
      expect(raw, isNull);
    });

    test('invalid stored value falls back to 15 minutes', () {
      final raw = 'invalid';
      final parsed = int.tryParse(raw);
      final minutes = (parsed != null && parsed > 0) ? parsed : 15;
      expect(minutes, 15);
    });

    test('zero stored value falls back to 15 minutes', () {
      final raw = '0';
      final parsed = int.tryParse(raw);
      final minutes = (parsed != null && parsed > 0) ? parsed : 15;
      expect(minutes, 15);
    });

    test('negative stored value falls back to 15 minutes', () {
      final raw = '-5';
      final parsed = int.tryParse(raw);
      final minutes = (parsed != null && parsed > 0) ? parsed : 15;
      expect(minutes, 15);
    });
  });

  group('NextItemGracePeriod provider', () {
    late FakeSettingsRepository fakeSettings;
    late ProviderContainer container;

    setUp(() {
      fakeSettings = FakeSettingsRepository();
      container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(fakeSettings),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('defaults to 15 minutes', () async {
      await container.read(nextItemGracePeriodProvider.notifier).ready;

      final value = container.read(nextItemGracePeriodProvider);
      expect(value, 15);
    });

    test('reads persisted value', () async {
      await fakeSettings.setValue(
        AppConstants.nextItemGracePeriodSettingsKey,
        '30',
      );

      container.dispose();
      container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(fakeSettings),
        ],
      );
      await container.read(nextItemGracePeriodProvider.notifier).ready;

      final value = container.read(nextItemGracePeriodProvider);
      expect(value, 30);
    });

    test('save 5 minutes', () async {
      final notifier = container.read(nextItemGracePeriodProvider.notifier);
      await notifier.ready;
      await notifier.setGracePeriod(5);

      final value = container.read(nextItemGracePeriodProvider);
      expect(value, 5);

      final stored = await fakeSettings.getValue(
        AppConstants.nextItemGracePeriodSettingsKey,
      );
      expect(stored, '5');
    });

    test('save 60 minutes', () async {
      final notifier = container.read(nextItemGracePeriodProvider.notifier);
      await notifier.ready;
      await notifier.setGracePeriod(60);

      final value = container.read(nextItemGracePeriodProvider);
      expect(value, 60);

      final stored = await fakeSettings.getValue(
        AppConstants.nextItemGracePeriodSettingsKey,
      );
      expect(stored, '60');
    });

    test('ignores zero value', () async {
      final notifier = container.read(nextItemGracePeriodProvider.notifier);
      await notifier.ready;
      await notifier.setGracePeriod(0);

      final value = container.read(nextItemGracePeriodProvider);
      expect(value, 15);
    });

    test('ignores negative value', () async {
      final notifier = container.read(nextItemGracePeriodProvider.notifier);
      await notifier.ready;
      await notifier.setGracePeriod(-5);

      final value = container.read(nextItemGracePeriodProvider);
      expect(value, 15);
    });

    test('invalid stored value falls back to 15', () async {
      await fakeSettings.setValue(
        AppConstants.nextItemGracePeriodSettingsKey,
        'not_a_number',
      );

      container.dispose();
      container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(fakeSettings),
        ],
      );
      await container.read(nextItemGracePeriodProvider.notifier).ready;

      final value = container.read(nextItemGracePeriodProvider);
      expect(value, 15);
    });
  });

  group('Today Next Item receives configured grace period', () {
    late FakeSettingsRepository fakeSettings;
    late ProviderContainer container;

    setUp(() {
      fakeSettings = FakeSettingsRepository();
      container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(fakeSettings),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Next Item resolver receives configured value', () async {
      await fakeSettings.setValue(
        AppConstants.nextItemGracePeriodSettingsKey,
        '30',
      );

      container.dispose();
      container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(fakeSettings),
        ],
      );
      await container.read(nextItemGracePeriodProvider.notifier).ready;

      expect(container.read(nextItemGracePeriodProvider), 30);
    });

    test('changing setting refreshes Next Item immediately', () async {
      final notifier = container.read(nextItemGracePeriodProvider.notifier);
      await notifier.ready;
      expect(container.read(nextItemGracePeriodProvider), 15);

      await notifier.setGracePeriod(30);
      expect(container.read(nextItemGracePeriodProvider), 30);
    });
  });
}
