import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rehab_track/data/services/backup/backup_import_service.dart';
import 'package:rehab_track/data/services/backup/backup_management_service.dart';
import 'package:rehab_track/domain/backup/backup_validation_result.dart';
import 'package:rehab_track/domain/backup/registered_backup.dart';
import 'package:rehab_track/domain/services/app_date_formatter.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/manage_backups_provider.dart';
import 'package:rehab_track/presentation/providers/restore_provider.dart';
import 'package:rehab_track/presentation/screens/settings/backup_preview_screen.dart';

/// Lists the backups this app created or imported, with details, restore,
/// share, delete and "Remove from List" actions, plus a "Import Existing
/// Backups" entry.
///
/// The list is backed by the backup registry (non-sensitive metadata only); no
/// loose storage permissions are requested. Files that are no longer reachable
/// are marked unavailable (distinct visual treatment + announced to screen
/// readers) and never silently presented as present; they can be removed from
/// the list without touching storage.
class ManageBackupsScreen extends ConsumerStatefulWidget {
  const ManageBackupsScreen({super.key});

  @override
  ConsumerState<ManageBackupsScreen> createState() =>
      _ManageBackupsScreenState();
}

class _ManageBackupsScreenState extends ConsumerState<ManageBackupsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(manageBackupsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(manageBackupsProvider);
    final restoreOperation = ref.watch(restoreOperationProvider);
    final anyRunning = state.isImporting || restoreOperation.isRunning;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageBackups)),
      body: switch (state) {
        _ when state.isLoading => Center(
            child: Semantics(
              label: l10n.refreshingBackupAvailability,
              child: const CircularProgressIndicator(),
            ),
          ),
        _ when state.loadFailed => _LoadFailed(
            onRetry: () => ref.read(manageBackupsProvider.notifier).load(),
          ),
        _ => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: anyRunning ? null : _import,
                    icon: const Icon(Icons.file_download_outlined),
                    label: Text(l10n.importExistingBackups),
                  ),
                ),
              ),
              Expanded(
                child: state.backups.isEmpty
                    ? _EmptyState(l10n: l10n)
                    : RefreshIndicator(
                        onRefresh: () =>
                            ref.read(manageBackupsProvider.notifier).load(),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: state.backups.length,
                          separatorBuilder: (_, _) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) => _BackupListTile(
                            backup: state.backups[index],
                            onTap: () =>
                                _showDetails(context, state.backups[index]),
                          ),
                        ),
                      ),
              ),
            ],
          ),
      },
      bottomNavigationBar: anyRunning
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            )
          : null,
    );
  }

  Future<void> _import() async {
    final outcome =
        await ref.read(manageBackupsProvider.notifier).importBackups();
    if (!mounted) return;
    _showImportResult(outcome);
  }

  void _showImportResult(BackupImportOutcome outcome) {
    final l10n = AppLocalizations.of(context)!;
    if (outcome.cancelled) return;
    final String message;
    if (outcome.status == BackupImportStatus.success) {
      final parts = <String>[
        if (outcome.imported > 0) l10n.backupsImported(outcome.imported),
        if (outcome.refreshed > 0)
          l10n.backupsAlreadyPresent(outcome.refreshed),
        if (outcome.invalidSkipped > 0)
          l10n.invalidBackupSkipped(outcome.invalidSkipped),
      ];
      message = parts.isEmpty
          ? l10n.backupImportFailed
          : parts.join('\n');
    } else {
      message = l10n.backupImportFailed;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showDetails(BuildContext context, RegisteredBackup backup) async {
    // Re-probe availability/metadata right before showing details so actions
    // reflect the document's current state (a just-deleted file opens as
    // unavailable, keeping Restore/Share disabled rather than failing later).
    final fresh =
        await ref.read(manageBackupsProvider.notifier).refreshOne(backup);
    if (!context.mounted) return;
    return showDialog<void>(
      context: context,
      builder: (ctx) => _BackupDetailsDialog(backup: fresh, parentRef: ref),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;

  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_off_outlined,
              size: 56,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.manageBackupsEmpty,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.manageBackupsEmptyHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadFailed extends ConsumerWidget {
  final VoidCallback onRetry;

  const _LoadFailed({required this.onRetry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 56,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(l10n.manageBackupsLoadFailed),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: onRetry,
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}

class _BackupListTile extends StatelessWidget {
  final RegisteredBackup backup;
  final VoidCallback onTap;

  const _BackupListTile({required this.backup, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final unavailable = !backup.available;

    final subtitle = <String>[
      if (backup.createdAt != null)
        AppDateFormatter.of(context).formatShortDate(backup.createdAt!),
      if (backup.fileSize != null) _formatBytes(backup.fileSize!),
    ].join(' · ');

    final foreground =
        unavailable ? theme.colorScheme.onErrorContainer : null;

    final tile = ListTile(
      leading: Icon(
        unavailable ? Icons.cloud_off : Icons.settings_backup_restore,
        color: unavailable
            ? theme.colorScheme.onErrorContainer
            : theme.colorScheme.primary,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              backup.displayLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: foreground ?? theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (unavailable) ...[
            const SizedBox(width: 8),
            Text(
              l10n.backupUnavailable,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      subtitle: unavailable
          ? Text(
              l10n.backupFileNotFound,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            )
          : (subtitle.isEmpty ? null : Text(subtitle)),
      trailing: Icon(
        Icons.chevron_right,
        color: unavailable
            ? theme.colorScheme.onErrorContainer
            : theme.colorScheme.onSurfaceVariant,
      ),
    );

    if (!unavailable) {
      return ListTile(
        onTap: onTap,
        leading: Icon(
          Icons.settings_backup_restore,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          backup.displayLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyLarge,
        ),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    // Subtle error-container treatment for unavailable rows. Color is not the
    // only indicator: the row also carries text ("Backup file not found") and a
    // "Unavailable" badge. The semantics tree exposes a single confirmable
    // node labelled "<name>, Unavailable" (the visual text is excluded from the
    // tree to avoid double-announcing the same row).
    return Semantics(
      container: true,
      button: true,
      label: '${backup.displayLabel}, ${l10n.backupUnavailable}',
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: theme.colorScheme.errorContainer,
          child: InkWell(
            onTap: onTap,
            child: tile,
          ),
        ),
      ),
    );
  }
}

class _BackupDetailsDialog extends ConsumerStatefulWidget {
  final RegisteredBackup backup;

  /// The managing screen's [WidgetRef]. The dialog's own `context` and `ref`
  /// are disposed when the dialog is popped, while the screen stays alive, so
  /// post-pop work must read providers through this ref.
  final WidgetRef parentRef;

  const _BackupDetailsDialog({required this.backup, required this.parentRef});

  @override
  ConsumerState<_BackupDetailsDialog> createState() =>
      _BackupDetailsDialogState();
}

class _BackupDetailsDialogState
    extends ConsumerState<_BackupDetailsDialog> {
  bool _deleting = false;
  bool _removing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final backup = widget.backup;
    final unavailable = !backup.available;

    return AlertDialog(
      title: Text(backup.displayLabel),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (unavailable) ...[
              _DetailLine(
                icon: Icons.cloud_off,
                label: l10n.manageBackupsUnavailableDetail,
                emphasized: true,
              ),
              const SizedBox(height: 8),
            ],
            if (backup.createdAt != null)
              _DetailLine(
                icon: Icons.schedule,
                label: l10n.backupDate(
                  AppDateFormatter.of(context).formatMediumDate(
                    backup.createdAt!,
                  ),
                ),
              ),
            if (backup.fileSize != null)
              _DetailLine(
                icon: Icons.data_usage,
                label: '${l10n.backupSize}: ${_formatBytes(backup.fileSize!)}',
              ),
            if (backup.backupFormatVersion != null)
              _DetailLine(
                icon: Icons.category_outlined,
                label: l10n.backupFormatVersion(
                  backup.backupFormatVersion!.toString(),
                ),
              ),
            if (backup.databaseSchemaVersion != null)
              _DetailLine(
                icon: Icons.storage_outlined,
                label: l10n.databaseVersion(
                  backup.databaseSchemaVersion!.toString(),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _deleting || _removing || !backup.available
              ? null
              : () => _share(context),
          child: Text(l10n.manageBackupsShare),
        ),
        if (unavailable)
          TextButton(
            onPressed: _removing ? null : () => _confirmRemoveFromList(context),
            child: Text(l10n.removeFromList),
          )
        else
          TextButton(
            onPressed: _deleting ? null : () => _confirmDelete(context),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: Text(l10n.manageBackupsDelete),
          ),
        TextButton(
          onPressed:
              _deleting || _removing ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
        FilledButton(
          onPressed: _deleting || _removing || !backup.available
              ? null
              : () => _confirmRestore(context),
          child: Text(l10n.manageBackupsRestore),
        ),
      ],
      actionsOverflowAlignment: OverflowBarAlignment.end,
      actionsOverflowDirection: VerticalDirection.up,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      icon: Icon(
        unavailable ? Icons.cloud_off : Icons.settings_backup_restore,
        color: unavailable
            ? theme.colorScheme.error
            : theme.colorScheme.primary,
      ),
    );
  }

  Future<void> _share(BuildContext context) async {
    try {
      await ref.read(manageBackupsProvider.notifier).share(widget.backup);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.manageBackupsShareFailed),
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dialogL10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(dialogL10n.manageBackupsDeleteTitle),
          content: Text(dialogL10n.manageBackupsDeleteConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(dialogL10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(dialogL10n.manageBackupsDelete),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;

    setState(() => _deleting = true);
    final outcome = await ref
        .read(manageBackupsProvider.notifier)
        .delete(widget.backup);
    if (!context.mounted) return;
    final message = outcome == BackupDeleteOutcome.deleted
        ? l10n.manageBackupsDeleted
        : l10n.manageBackupsDeleteUnresolved;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Navigator.of(context).pop(); // close the details dialog
  }

  Future<void> _confirmRemoveFromList(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dialogL10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(dialogL10n.removeFromList),
          content: Text(dialogL10n.confirmRemoveBackupFromList),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(dialogL10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(dialogL10n.removeFromList),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;

    setState(() => _removing = true);
    await ref
        .read(manageBackupsProvider.notifier)
        .removeFromList(widget.backup.contentUri);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.backupRemovedFromList)));
    Navigator.of(context).pop(); // close the details dialog
  }

  Future<void> _confirmRestore(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dialogL10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(dialogL10n.manageBackupsRestoreTitle),
          content: Text(dialogL10n.manageBackupsRestoreConfirm),
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
    if (confirmed != true || !context.mounted) return;

    // Capture stable references before popping the details dialog: its
    // context and the widget's `ref` are disposed during the pop, so neither
    // can be used after the await below.
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop(); // close details dialog

    final result = await widget.parentRef
        .read(restoreOperationProvider.notifier)
        .restoreFromUri(widget.backup.contentUri);

    final state = widget.parentRef.read(restoreOperationProvider);
    if (result == BackupValidationResult.valid && state.preview != null) {
      await navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => BackupPreviewScreen(
            preview: state.preview!,
            backupFilePath: state.backupFilePath,
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(_restoreFailureMessage(l10n, result))),
      );
    }
  }

  String _restoreFailureMessage(
    AppLocalizations l10n,
    BackupValidationResult result,
  ) {
    return switch (result) {
      BackupValidationResult.cancelled => l10n.manageBackupsRestoreCancelled,
      BackupValidationResult.invalidArchive ||
      BackupValidationResult.corruptedArchive =>
        l10n.corruptedBackup,
      BackupValidationResult.missingManifest => l10n.missingBackupManifest,
      BackupValidationResult.invalidManifest => l10n.invalidBackupManifest,
      BackupValidationResult.missingDatabase => l10n.missingBackupDatabase,
      BackupValidationResult.missingPreferences => l10n.missingBackupPreferences,
      BackupValidationResult.checksumMismatch => l10n.checksumMismatch,
      BackupValidationResult.unsafeArchivePath => l10n.unsafeBackupArchive,
      BackupValidationResult.backupTooLarge => l10n.backupTooLarge,
      BackupValidationResult.unsupportedBackupFormat => l10n.newerBackupVersion,
      BackupValidationResult.newerDatabaseVersion => l10n.newerDatabaseVersion,
      BackupValidationResult.unsupportedOldDatabaseVersion =>
        l10n.unsupportedOldDatabaseVersion,
      BackupValidationResult.invalidBackupDatabase => l10n.invalidBackupDatabase,
      BackupValidationResult.invalidBackupPreferences =>
        l10n.invalidBackupPreferences,
      BackupValidationResult.storageFailure => l10n.backupStorageFailure,
      _ => l10n.invalidBackupFile,
    };
  }
}

class _DetailLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool emphasized;

  const _DetailLine({
    required this.icon,
    required this.label,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = emphasized
        ? theme.colorScheme.error
        : theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: emphasized
                  ? theme.textTheme.bodySmall?.copyWith(color: color)
                  : theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}