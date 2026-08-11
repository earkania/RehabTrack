import 'package:flutter/material.dart';

import 'package:rehab_track/l10n/app_localizations.dart';

/// Stable food category values.
class DietFoodCategory {
  static const allowed = 'allowed';
  static const caution = 'caution';
  static const avoid = 'avoid';

  static const all = [allowed, caution, avoid];
}

/// Stable general guidance category values.
class DietGuidanceCategory {
  static const diet = 'diet';
  static const smoking = 'smoking';
  static const hydration = 'hydration';
  static const caffeine = 'caffeine';
  static const other = 'other';

  static const all = [diet, smoking, hydration, caffeine, other];
}

/// Localized label for a stable food category value.
String foodCategoryLabel(AppLocalizations l10n, String category) {
  switch (category) {
    case DietFoodCategory.allowed:
      return l10n.allowed;
    case DietFoodCategory.caution:
      return l10n.caution;
    case DietFoodCategory.avoid:
      return l10n.avoid;
    default:
      return category;
  }
}

/// Localized label for a stable general guidance category value.
String guidanceCategoryLabel(AppLocalizations l10n, String category) {
  switch (category) {
    case DietGuidanceCategory.diet:
      return l10n.dietGuidanceCategory;
    case DietGuidanceCategory.smoking:
      return l10n.smokingGuidanceCategory;
    case DietGuidanceCategory.hydration:
      return l10n.hydrationGuidanceCategory;
    case DietGuidanceCategory.caffeine:
      return l10n.caffeineGuidanceCategory;
    case DietGuidanceCategory.other:
      return l10n.otherGuidanceCategory;
    default:
      return category;
  }
}

/// Icon for a stable food category value.
IconData foodCategoryIcon(String category) {
  switch (category) {
    case DietFoodCategory.allowed:
      return Icons.check_circle_outline;
    case DietFoodCategory.caution:
      return Icons.warning_amber_rounded;
    case DietFoodCategory.avoid:
      return Icons.block;
    default:
      return Icons.restaurant_menu_outlined;
  }
}

/// Icon for a stable general guidance category value.
IconData guidanceCategoryIcon(String category) {
  switch (category) {
    case DietGuidanceCategory.diet:
      return Icons.restaurant_menu_outlined;
    case DietGuidanceCategory.smoking:
      return Icons.smoke_free_outlined;
    case DietGuidanceCategory.hydration:
      return Icons.water_drop_outlined;
    case DietGuidanceCategory.caffeine:
      return Icons.coffee_outlined;
    case DietGuidanceCategory.other:
      return Icons.info_outline;
    default:
      return Icons.info_outline;
  }
}

/// Theme-based tint color for a stable food category value.
///
/// Colors are derived from the theme's color scheme (never hardcoded) and are
/// always combined with an icon and a semantic label.
Color foodCategoryColor(ColorScheme colorScheme, String category) {
  switch (category) {
    case DietFoodCategory.allowed:
      return colorScheme.primary;
    case DietFoodCategory.caution:
      return colorScheme.tertiary;
    case DietFoodCategory.avoid:
      return colorScheme.error;
    default:
      return colorScheme.onSurfaceVariant;
  }
}

/// Theme-based tint color for a stable general guidance category value.
Color guidanceCategoryColor(ColorScheme colorScheme, String category) {
  switch (category) {
    case DietGuidanceCategory.diet:
      return colorScheme.primary;
    case DietGuidanceCategory.smoking:
      return colorScheme.tertiary;
    case DietGuidanceCategory.hydration:
      return colorScheme.primary;
    case DietGuidanceCategory.caffeine:
      return colorScheme.secondary;
    default:
      return colorScheme.onSurfaceVariant;
  }
}

/// Circular category icon avatar combining a theme tint and icon.
class CategoryIconAvatar extends StatelessWidget {
  const CategoryIconAvatar({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      image: true,
      child: ExcludeSemantics(
        child: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
