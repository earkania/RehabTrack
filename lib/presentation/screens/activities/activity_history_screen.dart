import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/entities/activity.dart';
import 'package:rehab_track/domain/services/activity_formatters.dart';
import 'package:rehab_track/domain/services/app_date_formatter.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/activity_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/screens/activities/activity_category_visuals.dart';
import 'package:rehab_track/presentation/screens/activities/activity_mode_visuals.dart';
import 'package:rehab_track/presentation/widgets/empty_state.dart';

/// History of completed and cancelled sessions, grouped by day. An active
/// session is pinned on top for continuation.
class ActivityHistoryScreen extends ConsumerWidget {
  const ActivityHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileId = ref.watch(currentActiveProfileIdProvider);
    final activeSession = ref
        .watch(activeSessionProvider(profileId ?? -1))
        .valueOrNull;

    if (profileId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.sessionHistory)),
        body: Center(child: Text(l10n.noActiveProfile)),
      );
    }

    final history = ref.watch(sessionHistoryProvider(profileId));
    final activities = ref.watch(allActivitiesProvider(profileId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sessionHistory)),
      body: history.when(
        data: (sessions) => activities.when(
          data: (allActivities) {
            final activityById = {
              for (final activity in allActivities) activity.id!: activity,
            };
            return _buildData(
              context,
              ref,
              sessions,
              activityById,
              activeSession,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('$error')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
      ),
    );
  }

  Widget _buildData(
    BuildContext context,
    WidgetRef ref,
    List<ActivitySession> sessions,
    Map<int, Activity> activityById,
    ActivitySession? activeSession,
  ) {
    final l10n = AppLocalizations.of(context)!;

    final groups = _groupByDay(sessions);

    if (groups.isEmpty && activeSession == null) {
      return EmptyState(
        icon: Icons.history,
        title: l10n.noHistoryYet,
        subtitle: l10n.activitiesEmptySubtitle,
      );
    }

    final children = <Widget>[];
    if (activeSession != null) {
      children.add(_ActiveSessionCard(session: activeSession));
    }

    for (final group in groups) {
      children.add(_DayHeader(day: group.day));
      for (final session in group.sessions) {
        final activity = activityById[session.activityId];
        children.add(
          _SessionTile(
            session: session,
            activityName: activity?.name ?? l10n.activeSession,
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: children,
    );
  }

  List<_SessionGroup> _groupByDay(List<ActivitySession> sessions) {
    final grouped = <DateTime, List<ActivitySession>>{};
    for (final session in sessions) {
      final day = DateTime(
        session.startedAt.year,
        session.startedAt.month,
        session.startedAt.day,
      );
      grouped.putIfAbsent(day, () => []).add(session);
    }
    final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final day in days) _SessionGroup(day: day, sessions: grouped[day]!),
    ];
  }
}

class _SessionGroup {
  final DateTime day;
  final List<ActivitySession> sessions;

  const _SessionGroup({required this.day, required this.sessions});
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final label = day.isAtSameMomentAs(today)
        ? l10n.today
        : day.isAtSameMomentAs(yesterday)
        ? l10n.yesterday
        : AppDateFormatter.of(context).formatMediumDate(day);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session, required this.activityName});

  final ActivitySession session;
  final String activityName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final duration = Duration(seconds: session.accumulatedSeconds);
    final statusLabel = sessionStatusLabel(l10n, session.status, session.mode);
    final statusColor = session.statusEnum == SessionStatus.cancelled
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;

    final formatter = AppDateFormatter.of(context);
    final endTime = session.endedAt ?? session.startedAt;

    return Card(
      child: ListTile(
        leading: CategoryIconAvatar(
          icon: sessionModeIcon(session.mode),
          color: sessionModeColor(colorScheme, session.mode),
          label: sessionModeLabel(l10n, session.mode),
        ),
        title: Text(
          activityName,
          style: theme.textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${formatter.formatTime(session.startedAt)} – '
              '${formatter.formatTime(endTime)} · '
              '${formatHm(duration)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                SessionModeBadge(mode: session.mode, compact: true),
                const SizedBox(width: 8),
                Text(
                  statusLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () =>
            context.push(AppRoutes.activitySessionDetails(session.id!)),
      ),
    );
  }
}

class _ActiveSessionCard extends ConsumerWidget {
  const _ActiveSessionCard({required this.session});

  final ActivitySession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final now = ref.watch(currentTimeProvider).value ?? DateTime.now();
    final activity = ref
        .watch(
          activityByIdProvider((
            id: session.activityId,
            profileId: session.profileId,
          )),
        )
        .valueOrNull;

    return Card(
      color: colorScheme.primaryContainer,
      child: ListTile(
        leading: Icon(
          Icons.directions_run,
          color: colorScheme.onPrimaryContainer,
        ),
        title: Text(
          activity?.name ?? l10n.activeSession,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        subtitle: Text(
          '${session.statusEnum == SessionStatus.paused ? l10n.sessionPaused : l10n.sessionRunning} · '
          '${formatClockDuration(Duration(seconds: session.elapsedSecondsAt(now)))}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        trailing: FilledButton(
          onPressed: () => context.push(AppRoutes.activitySessionActive),
          child: Text(l10n.continueSession),
        ),
      ),
    );
  }
}
