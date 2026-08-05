import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rehab_track/domain/backup/backup_compatibility.dart';
import 'package:rehab_track/domain/backup/backup_preview.dart';
import 'package:rehab_track/domain/restore/restore_apply_phase.dart';
import 'package:rehab_track/domain/restore/restore_failure.dart';
import 'package:rehab_track/domain/restore/restore_result.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/restore_apply_provider.dart';
import 'package:rehab_track/presentation/utils/localized_date_format.dart';

/// Shows the safe metadata of a validated backup and lets the user confirm or
/// cancel before restore.
///
/// Confirming starts the real restore engine: a progress dialog shows the
/// current phase (with cancellation allowed only in safe phases), followed by
/// a completion or failure dialog. The screen never exposes patient, clinical
/// or personal data.
class BackupPreviewScreen extends ConsumerStatefulWidget {
  final BackupPreview preview;

  /// Path of the validated app-owned backup copy; null when unavailable.
  final String? backupFilePath;

  const BackupPreviewScreen({
    super.key,
    required this.preview,
    this.backupFilePath,
  });

  @override
  ConsumerState<BackupPreviewScreen> createState() =>
      _BackupPreviewScreenState();
}

class _BackupPreviewScreenState extends ConsumerState<BackupPreviewScreen> {
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
            compatibility: widget.preview.compatibility,
            compatibilityLabel: _compatibilityLabel(l10n),
          ),
          if (widget.preview.migrationRequired) ...[
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
              LocalizedDateFormat.fullMonthDayYear(
                context,
                widget.preview.backupCreatedAt,
              ),
            ),
          ),
          const SizedBox(height: 4),
          _DetailRow(label: l10n.backupAppVersion(widget.preview.appVersion)),
          const SizedBox(height: 4),
          _DetailRow(
            label: l10n.backupFormatVersion(
              widget.preview.backupFormatVersion.toString(),
            ),
          ),
          const SizedBox(height: 4),
          _DetailRow(
            label: l10n.databaseVersion(
              widget.preview.databaseSchemaVersion.toString(),
            ),
          ),
          const SizedBox(height: 4),
          _DetailRow(
            label: l10n.currentDatabaseVersion(
              widget.preview.currentDatabaseSchemaVersion.toString(),
            ),
          ),
          const SizedBox(height: 4),
          if (widget.preview.profileCount != null)
            _DetailRow(
              label: l10n.profilesCount(widget.preview.profileCount!),
            ),
          const SizedBox(height: 4),
          _DetailRow(label: l10n.filesCount(widget.preview.managedFileCount)),
          const SizedBox(height: 4),
          _DetailRow(
            label: '${l10n.backupSize}: ${_formatBytes(widget.preview.backupFileSize)}',
          ),
          if (widget.preview.warnings.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (final warning in widget.preview.warnings)
              _WarningRow(label: _warningLabel(l10n, warning)),
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
    return switch (widget.preview.compatibility) {
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
    final l10n = AppLocalizations.of(context)!;

    if (widget.preview.migrationRequired) {
      await _showAlertDialog(
        title: l10n.restoreMigrationRequired,
        message: l10n.restoreMigrationNotAvailableYet,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dialogL10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(dialogL10n.backupPreview),
          content: Text(dialogL10n.restoreWillReplaceData),
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

    await _runRestore(context);
  }

  Future<void> _runRestore(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final filePath = widget.backupFilePath;
    if (filePath == null || filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalidBackupFile)),
      );
      return;
    }

    final controller = ref.read(restoreApplyProvider.notifier);
    if (ref.read(restoreApplyProvider).isRunning) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.restoreOperationAlreadyInProgress)),
      );
      return;
    }

    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const RestoreProgressDialog(),
    ));

    final failure = await controller.apply(
      backupFile: File(filePath),
      preview: widget.preview,
    );

    if (!context.mounted) return;
    // Close the progress dialog, then present the outcome.
    Navigator.of(context).pop();
    final outcome = failure ?? ref.read(restoreApplyProvider).failure;
    await _showOutcome(context, outcome);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _showOutcome(
    BuildContext context,
    RestoreFailure? failure,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    if (failure == null) {
      await _showAlertDialog(
        title: l10n.restoreFailedTitle,
        message: l10n.restoreFailedGeneric,
      );
      return;
    }

    if (failure.succeeded) {
      final date = LocalizedDateFormat.fullMonthDayYear(
        context,
        widget.preview.backupCreatedAt,
      );
      await _showAlertDialog(
        title: l10n.restoreCompletedTitle,
        message: l10n.restoreCompletedMessage(date),
        extra: l10n.remindersNeedRebuilding,
      );
      return;
    }

    if (failure.result == RestoreResult.cancelled) {
      await _showAlertDialog(
        title: l10n.restoreCancelledTitle,
        message: l10n.restoreCancelled,
      );
      return;
    }

    if (failure.result == RestoreResult.migrationNotSupported) {
      await _showAlertDialog(
        title: l10n.restoreMigrationRequired,
        message: l10n.restoreMigrationNotAvailableYet,
      );
      return;
    }

    if (failure.rollbackFailed) {
      await _showAlertDialog(
        title: l10n.restoreFailedTitle,
        message: l10n.criticalRestoreRecoveryRequired(failure.recoveryId),
      );
      return;
    }

    if (failure.originalDataRecovered) {
      await _showAlertDialog(
        title: l10n.restoreFailedTitle,
        message: l10n.originalDataRecovered,
        extra: _categoryMessage(l10n, failure),
      );
      return;
    }

    await _showAlertDialog(
      title: l10n.restoreFailedTitle,
      message: _categoryMessage(l10n, failure),
    );
  }

  String _categoryMessage(AppLocalizations l10n, RestoreFailure failure) {
    return switch (failure.result) {
      RestoreResult.validationFailure => l10n.invalidBackupFile,
      RestoreResult.safetySnapshotFailure => l10n.restoreSafetySnapshotFailed,
      RestoreResult.databasePreparationFailure ||
      RestoreResult.databaseReplacementFailure =>
        l10n.restoreDatabaseReplacementFailed,
      RestoreResult.managedFileRestoreFailure => l10n.restoreFilesFailed,
      RestoreResult.preferencesRestoreFailure => l10n.restorePreferencesFailed,
      RestoreResult.reinitializationFailure =>
        l10n.restoreReinitializationFailed,
      RestoreResult.verificationFailure => l10n.restoreVerificationFailed,
      _ => l10n.restoreFailedGeneric,
    };
  }

  Future<void> _showAlertDialog({
    required String title,
    required String message,
    String? extra,
  }) {
    return showDialog<void>(
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

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// A phase-label mapping shared by the progress dialog.
String restoreApplyPhaseLabel(
  AppLocalizations l10n,
  RestoreApplyPhase phase,
) {
  return switch (phase) {
    RestoreApplyPhase.preparingRestore => l10n.preparingRestore,
    RestoreApplyPhase.creatingSafetySnapshot => l10n.creatingSafetySnapshot,
    RestoreApplyPhase.preparingDatabase => l10n.preparingRestoredDatabase,
    RestoreApplyPhase.preparingFiles => l10n.preparingRestoredFiles,
    RestoreApplyPhase.preparingPreferences => l10n.preparingRestoredPreferences,
    RestoreApplyPhase.pausingServices => l10n.pausingApplicationServices,
    RestoreApplyPhase.replacingDatabase => l10n.replacingDatabase,
    RestoreApplyPhase.restoringFiles => l10n.restoringFiles,
    RestoreApplyPhase.restoringPreferences => l10n.restoringPreferences,
    RestoreApplyPhase.reinitializing => l10n.reinitializingApplication,
    RestoreApplyPhase.verifyingData => l10n.verifyingRestoredData,
    RestoreApplyPhase.rollingBack => l10n.rollingBackRestore,
    RestoreApplyPhase.finalizing => l10n.finalizingRestore,
  };
}

/// Non-dismissable progress dialog that reflects the running restore apply
/// phase and allows cancellation only while it is still safe.
class RestoreProgressDialog extends ConsumerStatefulWidget {
  const RestoreProgressDialog({super.key});

  @override
  ConsumerState<RestoreProgressDialog> createState() =>
      _RestoreProgressDialogState();
}

class _RestoreProgressDialogState extends ConsumerState<RestoreProgressDialog> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(restoreApplyProvider);
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(restoreApplyProvider.notifier);

    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(l10n.restoreInProgressTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              state.applyPhase == null
                  ? l10n.preparingRestore
                  : restoreApplyPhaseLabel(l10n, state.applyPhase!),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (controller.canCancel) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: controller.requestCancel,
                  child: Text(l10n.cancelRestore),
                ),
              ),
            ],
          ],
        ),
      ),
    );
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