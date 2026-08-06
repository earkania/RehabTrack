import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rehab_track/data/services/restore/restore_operation.dart';
import 'package:rehab_track/domain/backup/backup_compatibility.dart';
import 'package:rehab_track/domain/backup/backup_preview.dart';
import 'package:rehab_track/domain/restore/restore_apply_phase.dart';
import 'package:rehab_track/domain/restore/restore_failure.dart';
import 'package:rehab_track/domain/restore/restore_result.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/restore_apply_provider.dart';
import 'package:rehab_track/presentation/providers/locale_provider.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
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

    // Check if a restore is already running in the main provider.
    if (ref.read(restoreApplyProvider).isRunning) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.restoreOperationAlreadyInProgress)),
      );
      return;
    }

    // Capture navigator before any async operations to avoid stale context.
    final navigator = Navigator.of(context);

    // Create a completely independent RestoreOperation that doesn't
    // depend on Riverpod providers. This isolates it from the main
    // container's provider invalidation during database reinitialization.
    final operation = await createRestoreOperation(ProviderScope.containerOf(context));

    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RestoreProgressDialog(
        stateStream: operation.stateStream,
        onCancel: operation.requestCancel,
      ),
    ));

    // Listen to state changes and handle completion.
    final subscription = operation.stateStream.listen((state) {
      if (state.isFinished && navigator.canPop()) {
        // Don't auto-dismiss progress dialog on success - let _showOutcome handle it
        // The progress dialog will be handled by _showOutcome
      }
    });

    try {
      final failure = await operation.apply(
        backupFile: File(filePath),
        preview: widget.preview,
      );

      if (!context.mounted) return;
      // Present outcome (handles progress dialog dismissal and success dialog)
      final outcome = failure ?? const RestoreFailure(
        result: RestoreResult.unexpectedFailure,
        recoveryId: 'unknown',
      );
      await _showOutcome(context, outcome);
      if (!context.mounted) return;
      // The restore operation swapped the database in its own container.
      // Invalidate main app's database to pick up the restored data (including locale).
      ref.invalidate(databaseProvider);
      // Small delay to allow database to reopen and locale to load.
      await Future.delayed(const Duration(milliseconds: 500));
      navigator.pop(); // preview screen
    } finally {
      await subscription.cancel();
      operation.dispose();
    }
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

    // Close progress dialog first
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (failure.succeeded) {
      final date = LocalizedDateFormat.fullMonthDayYear(
        context,
        widget.preview.backupCreatedAt,
      );
      await _showAlertDialog(
        title: l10n.restoreCompletedTitle,
        message: switch (failure.result) {
          RestoreResult.successWithReminderWarning =>
            l10n.restoreCompletedRemindersPending,
          RestoreResult.successWithMissingOptionalFiles =>
            '${l10n.restoreCompletedMessage(date)}\n${l10n.someOptionalFilesMissing}',
          _ => l10n.restoreCompletedMessage(date),
        },
        actions: [
          FilledButton(
            onPressed: () {
              if (context.mounted) {
                Navigator.of(context).pop(); // outcome dialog
                Navigator.of(context).pop(); // preview screen -> back to Backup & Restore
              }
            },
            child: Text(l10n.ok),
          ),
        ],
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
      RestoreResult.databasePreparationFailure => l10n.restoreDatabaseReplacementFailed,
      RestoreResult.migrationFailure => l10n.restoreMigrationFailed,
      RestoreResult.pathRepairFailure => l10n.restorePathRepairFailed,
      RestoreResult.databaseVerificationFailure => l10n.restoreDatabaseVerificationFailed,
      RestoreResult.databaseReplacementFailure => l10n.restoreDatabaseReplacementFailed,
      RestoreResult.managedFileRestoreFailure => l10n.restoreFilesFailed,
      RestoreResult.preferencesRestoreFailure => l10n.restorePreferencesFailed,
      RestoreResult.reinitializationFailure =>
        l10n.restoreReinitializationFailed,
      RestoreResult.verificationFailure => l10n.restoreVerificationFailed,
      RestoreResult.reminderRebuildFailure => l10n.restoreReminderRebuildFailed,
      RestoreResult.insufficientStorage => l10n.restoreNotEnoughStorage,
      _ => l10n.restoreFailedGeneric,
    };
  }

  Future<void> _showReminderWarningDialog(
    BuildContext context,
    String date,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final dialogL10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(dialogL10n.restoreCompletedTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dialogL10n.restoreCompletedMessage(date)),
              const SizedBox(height: 12),
              Text(dialogL10n.restoreCompletedRemindersPending),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(dialogL10n.ok),
            ),
            FilledButton(
              onPressed: () async {
                final ok = await ref
                    .read(restoreApplyProvider.notifier)
                    .retryReminderRebuild();
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                await _showRetryResult(context, ok);
              },
              child: Text(dialogL10n.retryReminderRebuild),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRetryResult(BuildContext context, bool succeeded) async {
    final l10n = AppLocalizations.of(context)!;
    await _showAlertDialog(
      title: succeeded
          ? l10n.restoreCompletedTitle
          : l10n.restoreFailedTitle,
      message: succeeded
          ? l10n.restoreCompletedRemindersPending
          : l10n.restoreReminderRebuildFailed,
    );
  }

  Future<void> _showAlertDialog({
    required String title,
    required String message,
    String? extra,
    List<Widget>? actions,
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
          actions: actions ??
              [
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
    RestoreApplyPhase.migratingDatabase => l10n.migratingDatabase,
    RestoreApplyPhase.validatingMigratedDatabase => l10n.validatingMigratedDatabase,
    RestoreApplyPhase.repairingFilePaths => l10n.repairingFilePaths,
    RestoreApplyPhase.preparingFiles => l10n.preparingRestoredFiles,
    RestoreApplyPhase.preparingPreferences => l10n.preparingRestoredPreferences,
    RestoreApplyPhase.pausingServices => l10n.pausingApplicationServices,
    RestoreApplyPhase.replacingDatabase => l10n.replacingDatabase,
    RestoreApplyPhase.restoringFiles => l10n.restoringFiles,
    RestoreApplyPhase.restoringPreferences => l10n.restoringPreferences,
    RestoreApplyPhase.reinitializing => l10n.reinitializingApplication,
    RestoreApplyPhase.verifyingData => l10n.verifyingRestoredData,
    RestoreApplyPhase.rebuildingReminders => l10n.rebuildingReminders,
    RestoreApplyPhase.rollingBack => l10n.rollingBackRestore,
    RestoreApplyPhase.finalizing => l10n.finalizingRestore,
  };
}

/// Non-dismissable progress dialog that reflects the running restore apply
/// phase and allows cancellation only while it is still safe.
class RestoreProgressDialog extends StatefulWidget {
  final Stream<RestoreOperationState> stateStream;
  final VoidCallback? onCancel;

  const RestoreProgressDialog({
    super.key,
    required this.stateStream,
    this.onCancel,
  });

  @override
  State<RestoreProgressDialog> createState() => _RestoreProgressDialogState();
}

class _RestoreProgressDialogState extends State<RestoreProgressDialog> {
  RestoreOperationState? _latestState;

  @override
  void initState() {
    super.initState();
    widget.stateStream.listen((state) {
      if (mounted) {
        setState(() => _latestState = state);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = _latestState ?? const RestoreOperationState();
    final l10n = AppLocalizations.of(context)!;

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
            Semantics(
              liveRegion: true,
              label: state.applyPhase == null
                  ? l10n.preparingRestore
                  : restoreApplyPhaseLabel(l10n, state.applyPhase!),
              child: Text(
                state.applyPhase == null
                    ? l10n.preparingRestore
                    : restoreApplyPhaseLabel(l10n, state.applyPhase!),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (state.isRunning && state.applyPhase != null) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: widget.onCancel,
                  child: Text(l10n.cancelRestore),
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              Text(
                l10n.restoreCancellationUnavailable,
                style: Theme.of(context).textTheme.bodySmall,
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