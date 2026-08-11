import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/screens/health/diet_category_visuals.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('DietGuidanceCategory', () {
    test('contains the stable alcohol value', () {
      expect(DietGuidanceCategory.alcohol, 'alcohol');
    });

    test('keeps all existing stable values unchanged', () {
      expect(DietGuidanceCategory.all, [
        'diet',
        'smoking',
        'hydration',
        'caffeine',
        'alcohol',
        'other',
      ]);
    });
  });

  group('guidanceCategoryLabel', () {
    test('localizes alcohol', () {
      expect(guidanceCategoryLabel(l10n, DietGuidanceCategory.alcohol), 'Alcohol');
    });

    test('falls back to the raw value for unknown categories', () {
      expect(guidanceCategoryLabel(l10n, 'unknown'), 'unknown');
    });
  });

  group('guidanceCategoryIcon', () {
    test('alcohol uses a beverage icon', () {
      expect(
        guidanceCategoryIcon(DietGuidanceCategory.alcohol),
        Icons.local_bar_outlined,
      );
    });
  });

  group('guidanceCategoryColor', () {
    test('alcohol resolves to a theme color', () {
      const scheme = ColorScheme.light();
      expect(
        guidanceCategoryColor(scheme, DietGuidanceCategory.alcohol),
        scheme.tertiary,
      );
    });
  });
}
