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
}
