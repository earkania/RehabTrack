import 'package:flutter/material.dart';

import 'package:rehab_track/domain/backup/backup_compatibility.dart';
import 'package:rehab_track/domain/backup/backup_preview.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/utils/localized_date_format.dart';

/// Shows the safe metadata of a validated backup and lets the user confirm or
/// cancel before restore.
///
/// In this phase, confirming does **not** modify any data — it only shows an
/// informational message that the restore engine is not implemented yet.
/// The screen never exposes patient, clinical, or personal data.
class BackupPreviewScreen extends StatelessWidget {
  final BackupPreview preview;

  const BackupPreviewScreen({super.key, required this.preview});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupPreview)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CompatibilityBanner(
            compatibility: preview.compatibility,
            compatibilityLabel: _compatibilityLabel(l10n),
          ),
          if (preview.migrationRequired) ...[
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.upgrade,
              label: l10n.migrationRequired,
              emphasized: true,
            ),
          ],
          const SizedBox(height: 24),
          Text(l10n.backupDetails, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _DetailRow(
            label: l10n.backupDate(
              LocalizedDateFormat.fullMonthDayYear(context, preview.backupCreatedAt),
            ),
          ),
          const SizedBox(height: 4),
          _DetailRow(label: l10n.backupAppVersion(preview.appVersion)),
          const SizedBox(height: 4),
          _DetailRow(
            label: l10n.backupFormatVersion(preview.backupFormatVersion.toString()),
          ),
          const SizedBox(height: 4),
          _DetailRow(
            label: l10n.databaseVersion(preview.databaseSchemaVersion.toString()),
          ),
          const SizedBox(height: 4),
          _DetailRow(
            label: l10n.currentDatabaseVersion(
              preview.currentDatabaseSchemaVersion.toString(),
            ),
          ),
          const SizedBox(height: 4),
          if (preview.profileCount != null)
            _DetailRow(
              label: l10n.profilesCount(preview.profileCount!),
            ),
          const SizedBox(height: 4),
          _DetailRow(label: l10n.filesCount(preview.managedFileCount)),
          const SizedBox(height: 4),
          _DetailRow(label: '${l10n.backupSize}: ${_formatBytes(preview.backupFileSize)}'),
          if (preview.warnings.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (final warning in preview.warnings) _WarningRow(label: _warningLabel(l10n, warning)),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancelRestore),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => _continueRestore(context),
                  child: Text(l10n.continueRestore),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _compatibilityLabel(AppLocalizations l10n) {
    return switch (preview.compatibility) {
      BackupCompatibility.compatible => l10n.compatibleBackup,
      BackupCompatibility.compatibleMigrationRequired =>
        l10n.compatibleMigrationRequired,
      BackupCompatibility.incompatible => l10n.incompatibleBackup,
    };
  }

  String _warningLabel(AppLocalizations l10n, BackupWarning warning) {
    return switch (warning) {
      BackupWarning.olderAppVersion => l10n.backupWarningOlderAppVersion,
      BackupWarning.migrationRequired => l10n.backupWarningMigrationRequired,
    };
  }

  Future<void> _continueRestore(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dialogL10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(dialogL10n.restoreWillReplaceData),
          content: Text(dialogL10n.backupPreview),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(dialogL10n.cancelRestore),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(dialogL10n.continueRestore),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final dialogL10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(dialogL10n.continueRestore),
          content: Text(dialogL10n.restoreNotImplementedYet),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(dialogL10n.ok),
            ),
          ],
        );
      },
    );
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class _CompatibilityBanner extends StatelessWidget {
  final BackupCompatibility compatibility;
  final String compatibilityLabel;

  const _CompatibilityBanner({
    required this.compatibility,
    required this.compatibilityLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (compatibility) {
      BackupCompatibility.compatible => theme.colorScheme.primary,
      BackupCompatibility.compatibleMigrationRequired =>
        theme.colorScheme.tertiary,
      BackupCompatibility.incompatible => theme.colorScheme.error,
    };
    final icon = switch (compatibility) {
      BackupCompatibility.compatible => Icons.check_circle_outline,
      BackupCompatibility.compatibleMigrationRequired => Icons.sync,
      BackupCompatibility.incompatible => Icons.cancel_outlined,
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              compatibilityLabel,
              style: theme.textTheme.titleMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;

  const _DetailRow({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(label, style: theme.textTheme.bodyMedium);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool emphasized;

  const _InfoRow({
    required this.icon,
    required this.label,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = emphasized
        ? theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.tertiary,
            fontWeight: FontWeight.w600,
          )
        : theme.textTheme.bodyMedium;
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: style)),
      ],
    );
  }
}

class _WarningRow extends StatelessWidget {
  final String label;

  const _WarningRow({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_outlined,
            size: 20,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}