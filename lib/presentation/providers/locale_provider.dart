import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rehab_track/core/constants/app_constants.dart';
import 'package:rehab_track/core/localization/app_locale.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';

class LocaleNotifier extends StateNotifier<Locale?> {
  final SettingsRepository _settingsRepository;
  Future<void>? _loadFuture;

  LocaleNotifier(this._settingsRepository) : super(null) {
    _loadFuture = _load();
  }

  /// Completes once the persisted locale has been loaded from storage.
  Future<void> get ready => _loadFuture ?? Future.value();

  Future<void> _load() async {
    final raw = await _settingsRepository.getValue(AppConstants.languageKey);
    state = appLocaleFromStorage(raw).locale;
  }

  Future<void> setLocale(AppLocale appLocale) async {
    state = appLocale.locale;
    await _settingsRepository.setValue(
      AppConstants.languageKey,
      appLocale.storageValue,
    );
  }

  Future<void> resetToSystem() async {
    state = null;
    await _settingsRepository.setValue(
      AppConstants.languageKey,
      AppLocale.system.storageValue,
    );
  }

/// Reloads the locale from settings (e.g. after a restore).
  Future<void> reload() async {
    try {
      await _load();
    } catch (_) {
      // Database might be temporarily unavailable during restore;
      // schedule retries with increasing delays (total ~15s max).
      for (int i = 0; i < 5; i++) {
        await Future.delayed(Duration(seconds: i + 2));
        if (!mounted) return;
        try {
          await _load();
          return;
        } catch (_) {
          // Continue retrying
        }
      }
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier(ref.read(settingsRepositoryProvider));
});
