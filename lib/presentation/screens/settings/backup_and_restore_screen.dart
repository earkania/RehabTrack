import 'package:flutter/material.dart';
import 'package:rehab_track/l10n/app_localizations.dart';

/// Placeholder for the future Backup & Restore module.
///
/// Backup/restore functionality (database export, ZIP archives, file pickers,
/// encryption, cloud sync, restore validation) is intentionally not implemented
/// yet. The screen only communicates the plan; none of the listed items are
/// interactive.
class BackupAndRestoreScreen extends StatelessWidget {
  const BackupAndRestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupAndRestore)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.settings_backup_restore,
                size: 64,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.backupRestoreComingSoon,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              _PlannedItem(
                icon: Icons.cloud_upload_outlined,
                label: l10n.createBackup,
              ),
              const SizedBox(height: 12),
              _PlannedItem(
                icon: Icons.settings_backup_restore,
                label: l10n.restoreBackup,
              ),
              const SizedBox(height: 12),
              _PlannedItem(
                icon: Icons.info_outline,
                label: l10n.backupInformation,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A non-interactive row summarizing a planned backup feature.
class _PlannedItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PlannedItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
