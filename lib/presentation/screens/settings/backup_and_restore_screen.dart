import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/backup/backup_availability.dart';
import 'package:rehab_track/domain/backup/backup_result.dart';
import 'package:rehab_track/domain/backup/backup_validation_result.dart';
import 'package:rehab_track/domain/backup/restore_phase.dart';
import 'package:rehab_track/domain/services/app_date_formatter.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/backup_provider.dart';
import 'package:rehab_track/presentation/providers/restore_apply_provider.dart';
import 'package:rehab_track/presentation/providers/restore_provider.dart';
import 'package:rehab_track/presentation/screens/settings/backup_preview_screen.dart';

/// Backup & Restore screen.
///
/// Phase 1 implements manual backup creation. Phase 2 (Restore Foundation)
/// adds backup selection, validation, compatibility checking and a preview.
/// Phase 3 implements the restore engine driven from the preview screen.
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
    final restoreOperation = ref.watch(restoreOperationProvider);
    final restoreApply = ref.watch(restoreApplyProvider);
    final lastBackup = ref.watch(lastBackupAtProvider);
    final lastBackupDisplayName = ref.watch(lastBackupDisplayNameProvider);
    final lastBackupAvailability =
        ref.watch(lastBackupAvailabilityProvider).value;
    final lastRestore = ref.watch(lastRestoreAtProvider);

    final anyRunning =
        operation.isRunning || restoreOperation.isRunning || restoreApply.isRunning;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupAndRestore)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Header(description: l10n.backupScreenDescription),
          const SizedBox(height: 16),
          _LastOperationTile(
            icon: Icons.history,
            primary: lastBackup.value == null
                ? l10n.backupLastNever
                : l10n.backupLastCreated(
                    _formatDateTime(context, lastBackup.value!),
                  ),
            secondary: lastBackupAvailability == BackupAvailability.unavailable
                ? l10n.fileUnavailable
                : switch (lastBackupDisplayName.value) {
                    final name? => l10n.backupStoredAs(name),
                    null => null,
                  },
          ),
          if (lastRestore.value != null) ...[
            const SizedBox(height: 8),
            _LastOperationTile(
              icon: Icons.restore,
              primary: l10n.restoreLastCompleted(
                _formatDateTime(context, lastRestore.value!),
              ),
            ),
          ],
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
            Semantics(
              liveRegion: true,
              label: l10n.backupInProgress,
              child: Text(
                l10n.backupInProgress,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 12),
          ],
          FilledButton.icon(
            onPressed: anyRunning ? null : () => _createBackup(l10n),
            icon: const Icon(Icons.save_alt),
            label: Text(l10n.createBackup),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          Text(l10n.backupInformation, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          if (restoreOperation.isRunning) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              label: _restoreProgressLabel(l10n, restoreOperation.phase),
              child: Text(
                _restoreProgressLabel(l10n, restoreOperation.phase),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 12),
          ],
          OutlinedButton.icon(
            onPressed:
                anyRunning ? null : () => _restoreBackup(l10n),
            icon: const Icon(Icons.restore),
            label: Text(l10n.restoreBackup),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed:
                anyRunning ? null : _openManageBackups,
            icon: const Icon(Icons.folder_open_outlined),
            label: Text(l10n.manageBackups),
          ),
        ],
      ),
    );
  }

  String _restoreProgressLabel(AppLocalizations l10n, RestorePhase phase) {
    return switch (phase) {
      RestorePhase.selectingFile => l10n.selectingBackup,
      RestorePhase.readingArchive => l10n.readingBackup,
      RestorePhase.validatingManifest => l10n.validatingBackup,
      RestorePhase.verifyingChecksums => l10n.verifyingChecksums,
      RestorePhase.checkingCompatibility => l10n.checkingCompatibility,
      _ => l10n.validatingBackup,
    };
  }

  Future<void> _createBackup(AppLocalizations l10n) async {
    final result = await ref.read(backupOperationProvider.notifier).createBackup();
    if (!mounted) return;
    ref.invalidate(lastBackupAtProvider);
    ref.invalidate(lastBackupDisplayNameProvider);
    ref.invalidate(lastBackupAvailabilityProvider);

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

  Future<void> _openManageBackups() async {
    // push preserves the back stack so the AppBar shows a back button.
    ref.invalidate(lastBackupAvailabilityProvider);
    await context.push(AppRoutes.manageBackups);
    if (!mounted) return;
    // Manage Backups re-probes availability; refresh the tile on return.
    ref.invalidate(lastBackupAvailabilityProvider);
  }

  Future<void> _restoreBackup(AppLocalizations l10n) async {
    final result = await ref
        .read(restoreOperationProvider.notifier)
        .restoreBackup();
    if (!mounted) return;

    switch (result) {
      case BackupValidationResult.valid:
        final preview = ref.read(restoreOperationProvider).preview;
        final backupFilePath =
            ref.read(restoreOperationProvider).backupFilePath;
        if (preview == null) {
          _showSnackBar(l10n.backupValidationFailed);
          return;
        }
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BackupPreviewScreen(
              preview: preview,
              backupFilePath: backupFilePath,
            ),
          ),
        );
        if (!mounted) return;
        ref.invalidate(lastRestoreAtProvider);
      case BackupValidationResult.cancelled:
        // User dismissed the picker: normal outcome, not an error.
        break;
      case BackupValidationResult.operationAlreadyInProgress:
        _showSnackBar(l10n.operationAlreadyInProgress);
      default:
        await _showResultDialog(
          title: l10n.backupValidationFailed,
          message: _restoreFailureMessage(l10n, result),
        );
    }
  }

  String _restoreFailureMessage(
    AppLocalizations l10n,
    BackupValidationResult result,
  ) {
    return switch (result) {
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

  String _formatDateTime(BuildContext context, DateTime time) {
    return AppDateFormatter.of(context).formatMediumDateTime(time);
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

class _LastOperationTile extends StatelessWidget {
  final IconData icon;
  final String primary;

  /// Optional secondary line (e.g. the stored file name).
  final String? secondary;

  const _LastOperationTile({
    required this.icon,
    required this.primary,
    this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      label: [primary, ?secondary].join(', '),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(primary, style: theme.textTheme.bodySmall),
                if (secondary != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    secondary!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
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
