import 'package:flutter/material.dart';
import 'package:rehab_track/l10n/app_localizations.dart';

/// Placeholder shown for modules that are not implemented yet
/// (Activities, Diet, Lab Analyses, Doctor Visits, Reports, Doctors,
/// Emergency Contacts, Medical Notes).
///
/// Provides the module title, an icon, localized "not available yet" text, and
/// standard back navigation via the AppBar.
class ModulePlaceholderScreen extends StatelessWidget {
  final IconData icon;
  final String title;

  const ModulePlaceholderScreen({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.moduleNotAvailableYet,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.comingSoon,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
