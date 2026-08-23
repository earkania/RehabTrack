import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rehab_track/domain/entities/activity.dart';
import 'package:rehab_track/domain/services/activity_formatters.dart';
import 'package:rehab_track/domain/services/app_date_formatter.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/activity_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/screens/activities/activity_mode_visuals.dart';

/// Details of a single completed/cancelled session record.
class ActivityHistoryDetailsScreen extends ConsumerWidget {
  const ActivityHistoryDetailsScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileId = ref.watch(currentActiveProfileIdProvider);
    if (profileId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.sessionDetails)),
        body: Center(child: Text(l10n.noActiveProfile)),
      );
    }

    final session = ref.watch(
      sessionByIdProvider((id: sessionId, profileId: profileId)),
    );
    final activity = ref.watch(
      activityForSessionProvider((sessionId: sessionId, profileId: profileId)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sessionDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.deleteSession,
            onPressed: session.valueOrNull == null
                ? null
                : () => _deleteSession(context, ref, profileId),
          ),
        ],
      ),
      body: session.when(
        data: (value) {
          if (value == null) {
            return _buildMissing(context);
          }
          return _buildDetails(context, value, activity.valueOrNull, profileId);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
      ),
    );
  }

  Widget _buildMissing(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.sessionNotFound,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () => context.pop(),
            child: Text(l10n.back),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(
    BuildContext context,
    ActivitySession session,
    Activity? activity,
    int profileId,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final formatter = AppDateFormatter.of(context);
    final duration = Duration(seconds: session.accumulatedSeconds);
    final statusLabel = sessionStatusLabel(l10n, session.status, session.mode);
    final statusColor = session.statusEnum == SessionStatus.cancelled
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity?.name ?? l10n.activeSession,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  SessionModeBadge(mode: session.mode),
                ],
              ),
            ),
            Text(
              statusLabel,
              style: theme.textTheme.labelLarge?.copyWith(color: statusColor),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _DetailRow(
          icon: Icons.access_time,
          label: l10n.actualDuration,
          value: '${formatHm(duration)} (${formatClockDuration(duration)})',
        ),
        _DetailRow(
          icon: Icons.login_outlined,
          label: l10n.recordedAt,
          value: formatter.formatMediumDateTime(session.startedAt),
        ),
        if (session.endedAt != null)
          _DetailRow(
            icon: Icons.logout_outlined,
            label: l10n.endedAt,
            value: formatter.formatMediumDateTime(session.endedAt!),
          ),
        if (session.completedAt != null)
          _DetailRow(
            icon: Icons.check_circle_outline,
            label: l10n.completedOn,
            value: formatter.formatMediumDateTime(session.completedAt!),
          ),
        if (session.modeEnum == SessionMode.timedInterval &&
            session.plannedDurationSeconds != null)
          _DetailRow(
            icon: Icons.repeat_outlined,
            label: l10n.activityDuration,
            value: l10n.xMinutes(session.plannedDurationSeconds! ~/ 60),
          ),
        if (session.modeEnum == SessionMode.timedInterval &&
            session.restDurationSeconds != null)
          _DetailRow(
            icon: Icons.hourglass_bottom_outlined,
            label: l10n.restDuration,
            value: l10n.xMinutes(session.restDurationSeconds! ~/ 60),
          ),
        if (session.modeEnum == SessionMode.timedInterval)
          _DetailRow(
            icon: Icons.done_all_outlined,
            label: l10n.intervalsCompleted,
            value: '${session.completedIntervals}',
          ),
        if (session.notes != null && session.notes!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.sessionLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(session.notes!, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _deleteSession(
    BuildContext context,
    WidgetRef ref,
    int profileId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteSession),
        content: Text(l10n.confirmDeleteSession),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref
        .read(activityRepositoryProvider)
        .deleteSession(sessionId, profileId);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.sessionDeleted)));
      context.pop();
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
