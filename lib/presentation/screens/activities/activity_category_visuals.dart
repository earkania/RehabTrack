import 'package:flutter/material.dart';

import 'package:rehab_track/l10n/app_localizations.dart';

/// Stable activity category values.
class ActivityCategoryValue {
  static const exercise = 'exercise';
  static const rehabilitation = 'rehabilitation';
  static const physiotherapy = 'physiotherapy';
  static const generalWellness = 'general_wellness';
  static const other = 'other';

  static const all = [
    exercise,
    rehabilitation,
    physiotherapy,
    generalWellness,
    other,
  ];
}

/// Localized label for a stable activity category value.
String activityCategoryLabel(AppLocalizations l10n, String category) {
  switch (category) {
    case ActivityCategoryValue.exercise:
      return l10n.exercise;
    case ActivityCategoryValue.rehabilitation:
      return l10n.rehabilitation;
    case ActivityCategoryValue.physiotherapy:
      return l10n.physiotherapy;
    case ActivityCategoryValue.generalWellness:
      return l10n.generalWellness;
    default:
      return l10n.otherCategory;
  }
}

/// Icon for a stable activity category value.
IconData activityCategoryIcon(String category) {
  switch (category) {
    case ActivityCategoryValue.exercise:
      return Icons.fitness_center_outlined;
    case ActivityCategoryValue.rehabilitation:
      return Icons.healing_outlined;
    case ActivityCategoryValue.physiotherapy:
      return Icons.accessibility_new;
    case ActivityCategoryValue.generalWellness:
      return Icons.self_improvement_outlined;
    default:
      return Icons.extension_outlined;
  }
}

/// Theme-based tint color for a stable activity category value.
///
/// Colors are derived from the theme's color scheme (never hardcoded).
Color activityCategoryColor(ColorScheme colorScheme, String category) {
  switch (category) {
    case ActivityCategoryValue.exercise:
      return colorScheme.primary;
    case ActivityCategoryValue.rehabilitation:
      return colorScheme.tertiary;
    case ActivityCategoryValue.physiotherapy:
      return colorScheme.secondary;
    case ActivityCategoryValue.generalWellness:
      return colorScheme.primary;
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

/// Compact category chip combining a tinted icon and the localized label.
class ActivityCategoryChip extends StatelessWidget {
  const ActivityCategoryChip({
    super.key,
    required this.category,
    this.compact = false,
  });

  final String category;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final label = activityCategoryLabel(l10n, category);
    final color = activityCategoryColor(colorScheme, category);

    return Semantics(
      label: label,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              activityCategoryIcon(category),
              size: compact ? 12 : 14,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
