import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rehab_track/domain/backup/backup_result.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/backup_provider.dart';

/// Backup & Restore screen.
///
/// Phase 1 implements manual backup only: the user creates a `.rtb` archive
/// (database + photos + settings) and saves it to a location they choose via
/// the system file picker. Restore is shown as coming soon.
class BackupAndRestoreScreen extends ConsumerStatefulWidget {
  const BackupAndRestoreScreen({super.key});

  @override
  ConsumerState<BackupAndRestoreScreen> createState() =>
      _BackupAndRestoreScreenState();
}

class _BackupAndRestoreScreenState
    extends ConsumerState<BackupAndRestoreScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final operation = ref.watch(backupOperationProvider);
    final lastBackup = ref.watch(lastBackupAtProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupAndRestore)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Header(description: l10n.backupScreenDescription),
          const SizedBox(height: 16),
          _LastBackupTile(
            lastBackup: lastBackup.value,
            neverLabel: l10n.backupLastNever,
            lastLabel: l10n.backupLastSuccessful,
          ),
          const Divider(height: 32),
          Text(l10n.backupIncludes, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _IncludesRow(
            icon: Icons.medical_information_outlined,
            label: l10n.backupIncludesDatabase,
          ),
          _IncludesRow(
            icon: Icons.photo_outlined,
            label: l10n.backupIncludesPhotos,
          ),
          _IncludesRow(
            icon: Icons.tune,
            label: l10n.backupIncludesSettings,
          ),
          const SizedBox(height: 24),
          if (operation.isRunning) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              l10n.backupInProgress,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
          ],
          FilledButton.icon(
            onPressed: operation.isRunning ? null : () => _createBackup(l10n),
            icon: const Icon(Icons.save_alt),
            label: Text(l10n.createBackup),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          Text(l10n.backupInformation, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(
            l10n.backupRestoreNotAvailable,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createBackup(AppLocalizations l10n) async {
    final result = await ref.read(backupOperationProvider.notifier).createBackup();
    if (!mounted) return;
    ref.invalidate(lastBackupAtProvider);

    switch (result) {
      case BackupResult.success:
        final warnings = ref.read(backupOperationProvider).warnings;
        await _showResultDialog(
          title: l10n.backupSuccessTitle,
          message: l10n.backupSuccessMessage,
          extra: warnings.isNotEmpty ? l10n.backupMissingFilesMessage : null,
        );
      case BackupResult.cancelled:
        await _showResultDialog(
          title: l10n.backupCancelledTitle,
          message: l10n.backupCancelledMessage,
        );
      case BackupResult.operationAlreadyInProgress:
        _showSnackBar(l10n.backupOperationInProgress);
      default:
        await _showResultDialog(
          title: l10n.backupFailedTitle,
          message: _failureMessage(l10n, result),
        );
    }
  }

  String _failureMessage(AppLocalizations l10n, BackupResult result) {
    return switch (result) {
      BackupResult.storageFailure => l10n.backupStorageFailure,
      BackupResult.databaseFailure => l10n.backupDatabaseFailure,
      BackupResult.archiveFailure => l10n.backupArchiveFailure,
      BackupResult.permissionDenied => l10n.backupPermissionDenied,
      BackupResult.notEnoughStorage => l10n.backupNotEnoughStorage,
      _ => l10n.backupUnexpectedFailure,
    };
  }

  Future<void> _showResultDialog({
    required String title,
    required String message,
    String? extra,
  }) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              if (extra != null) ...[
                const SizedBox(height: 12),
                Text(extra),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _Header extends StatelessWidget {
  final String description;

  const _Header({required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          Icons.settings_backup_restore,
          size: 56,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Text(
          description,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LastBackupTile extends StatelessWidget {
  final DateTime? lastBackup;
  final String neverLabel;
  final String Function(String time) lastLabel;

  const _LastBackupTile({
    required this.lastBackup,
    required this.neverLabel,
    required this.lastLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = lastBackup == null
        ? neverLabel
        : lastLabel(_formatDateTime(lastBackup!));
    return Row(
      children: [
        Icon(Icons.history, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: theme.textTheme.bodySmall),
        ),
      ],
    );
  }

  static String _formatDateTime(DateTime time) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(time.day)}.${two(time.month)}.${time.year} '
        '${two(time.hour)}:${two(time.minute)}';
  }
}

class _IncludesRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _IncludesRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
