import 'package:flutter/material.dart';

enum AppLocale { system, english, georgian }

extension AppLocaleX on AppLocale {
  Locale? get locale {
    switch (this) {
      case AppLocale.system:
        return null;
      case AppLocale.english:
        return const Locale('en');
      case AppLocale.georgian:
        return const Locale('ka');
    }
  }

  String get displayName {
    switch (this) {
      case AppLocale.system:
        return 'System';
      case AppLocale.english:
        return 'English';
      case AppLocale.georgian:
        return 'ქართული';
    }
  }

  /// Stable value persisted in the settings store.
  String get storageValue {
    switch (this) {
      case AppLocale.system:
        return 'system';
      case AppLocale.english:
        return 'en';
      case AppLocale.georgian:
        return 'ka';
    }
  }
}

/// Maps a persisted storage code back to an [AppLocale]. Unknown or null
/// values fall back to the system default.
AppLocale appLocaleFromStorage(String? value) {
  switch (value) {
    case 'ka':
      return AppLocale.georgian;
    case 'en':
      return AppLocale.english;
    default:
      return AppLocale.system;
  }
}
