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
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier(ref.read(settingsRepositoryProvider));
});
