import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rehab_track/domain/entities/activity.dart';
import 'package:rehab_track/domain/services/activity_formatters.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/activity_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/screens/activities/activity_category_visuals.dart';
import 'package:rehab_track/presentation/screens/activities/activity_completion_sheet.dart';
import 'package:rehab_track/presentation/screens/activities/activity_mode_visuals.dart';

const _countdownPresets = [5, 10, 15, 20, 30, 45, 60];
const _restPresets = [1, 2, 5];

/// Session screen: setup (choose mode + durations), running/paused state for
/// the active session, and the conflict screen when another session is
/// already active.
class ActivitySessionScreen extends ConsumerStatefulWidget {
  const ActivitySessionScreen({super.key, this.activityId});

  /// When set, the screen starts a new session for this activity. When null,
  /// the screen resumes the currently active session.
  final int? activityId;

  @override
  ConsumerState<ActivitySessionScreen> createState() =>
      _ActivitySessionScreenState();
}

class _ActivitySessionScreenState extends ConsumerState<ActivitySessionScreen> {
  SessionMode _mode = SessionMode.timedSession;
  int _workMinutes = 10;
  int _restMinutes = 1;
  bool _resumeExisting = false;
  bool _countdownHandled = false;
  bool _defaultsApplied = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileId = ref.watch(currentActiveProfileIdProvider);
    final session = ref
        .watch(activeSessionProvider(profileId ?? -1))
        .valueOrNull;
    final setupActivity = widget.activityId == null
        ? null
        : ref
              .watch(
                activityByIdProvider((
                  id: widget.activityId!,
                  profileId: profileId ?? -1,
                )),
              )
              .valueOrNull;
    final sessionActivity = ref
        .watch(activeSessionActivityProvider(profileId ?? -1))
        .valueOrNull;

    if (profileId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.activeSession)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (session == null) {
      _countdownHandled = false;
      if (widget.activityId == null) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.activeSession)),
          body: Center(child: Text(l10n.noHistoryYet)),
        );
      }
      return _buildSetup(context, profileId, setupActivity);
    }

    if (!_resumeExisting &&
        widget.activityId != null &&
        session.activityId != widget.activityId) {
      return _buildConflict(context, profileId, session, sessionActivity);
    }

    return _buildRunning(
      context,
      profileId,
      session,
      sessionActivity ?? setupActivity,
    );
  }

  // ---- Setup ---------------------------------------------------------------

  Widget _buildSetup(BuildContext context, int profileId, Activity? activity) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    if (activity != null && !_defaultsApplied) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_defaultsApplied) {
          setState(() {
            _workMinutes = activity.recommendedTimeMinutes ?? 10;
            _defaultsApplied = true;
          });
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newSession)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (activity != null) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(activity.name, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      ActivityCategoryChip(category: activity.category),
                    ],
                  ),
                ),
                if (activity.recommendedTimeMinutes != null)
                  Text(
                    l10n.xMinutes(activity.recommendedTimeMinutes!),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          Text(l10n.sessionMode, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<SessionMode>(
            segments: [
              ButtonSegment(
                value: SessionMode.timedSession,
                icon: const Icon(Icons.timer_outlined),
                label: Text(l10n.countdownMode),
              ),
              ButtonSegment(
                value: SessionMode.timedInterval,
                icon: const Icon(Icons.repeat_outlined),
                label: Text(l10n.intervalMode),
              ),
              ButtonSegment(
                value: SessionMode.untimed,
                icon: const Icon(Icons.timer_off_outlined),
                label: Text(l10n.manualMode),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) {
              setState(() => _mode = selection.first);
            },
          ),
          const SizedBox(height: 24),
          if (_mode == SessionMode.timedSession) ...[
            Text(l10n.activityDuration, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in _countdownPresets)
                  ChoiceChip(
                    label: Text(l10n.xMinutes(value)),
                    selected: _workMinutes == value,
                    onSelected: (_) => setState(() => _workMinutes = value),
                  ),
              ],
            ),
          ] else if (_mode == SessionMode.timedInterval) ...[
            Text(l10n.activityDuration, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in _countdownPresets)
                  ChoiceChip(
                    label: Text(l10n.xMinutes(value)),
                    selected: _workMinutes == value,
                    onSelected: (_) => setState(() => _workMinutes = value),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.restDuration, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in _restPresets)
                  ChoiceChip(
                    label: Text(l10n.xMinutes(value)),
                    selected: _restMinutes == value,
                    onSelected: (_) => setState(() => _restMinutes = value),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => _startSession(profileId, activity),
            icon: const Icon(Icons.play_arrow),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(l10n.startSession),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Conflict ------------------------------------------------------------

  Widget _buildConflict(
    BuildContext context,
    int profileId,
    ActivitySession session,
    Activity? activity,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.activeSession)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.info_outline, size: 64, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              l10n.activeSession,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              activity?.name ?? l10n.activeSession,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => setState(() => _resumeExisting = true),
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.continueSession),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _cancelAndStartNew(context, profileId, session),
              child: Text(l10n.cancelSession),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelAndStartNew(
    BuildContext context,
    int profileId,
    ActivitySession session,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelSession),
        content: Text(l10n.cancelSessionConfirmation),
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
            child: Text(l10n.cancelSession),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref
        .read(activityRepositoryProvider)
        .cancelSession(session.id!, profileId, now: DateTime.now());
  }

  // ---- Running -------------------------------------------------------------

  Widget _buildRunning(
    BuildContext context,
    int profileId,
    ActivitySession session,
    Activity? activity,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final now = ref.watch(currentTimeProvider).value ?? DateTime.now();
    final elapsed = session.elapsedSecondsAt(now);
    final isPaused = session.statusEnum == SessionStatus.paused;
    final mode = session.modeEnum;

    final isCountdown = mode == SessionMode.timedSession;
    final remaining = isCountdown && session.plannedDurationSeconds != null
        ? session.plannedDurationSeconds! - elapsed
        : null;

    if (isCountdown &&
        !isPaused &&
        remaining != null &&
        remaining <= 0 &&
        !_countdownHandled) {
      _countdownHandled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _openCompletionSheet(
            profileId,
            session,
            activity,
            countdownExpired: true,
          );
        }
      });
    }

    // Interval segment bookkeeping.
    var inWorkSegment = true;
    var segmentRemaining = elapsed;
    var completedIntervals = 0;
    double? progress;
    if (mode == SessionMode.timedSession) {
      final total = session.plannedDurationSeconds ?? 1;
      progress = total <= 0 ? 0 : (elapsed / total).clamp(0, 1);
    } else if (mode == SessionMode.timedInterval) {
      final work = session.plannedDurationSeconds ?? 0;
      final rest = session.restDurationSeconds ?? 0;
      final cycle = work + rest;
      completedIntervals = cycle > 0 ? elapsed ~/ cycle : 0;
      final inCycle = cycle > 0 ? elapsed % cycle : 0;
      inWorkSegment = inCycle < work;
      segmentRemaining = inWorkSegment
          ? work - inCycle
          : rest - (inCycle - work);
      final segment = inWorkSegment ? work : rest;
      progress = segment <= 0 ? 0 : (segmentRemaining / segment).clamp(0, 1);
    }

    final String primaryLabel;
    if (mode == SessionMode.timedSession) {
      primaryLabel = formatClockDuration(
        Duration(seconds: remaining == null || remaining < 0 ? 0 : remaining),
      );
    } else if (mode == SessionMode.timedInterval) {
      primaryLabel = formatClockDuration(
        Duration(seconds: segmentRemaining < 0 ? 0 : segmentRemaining),
      );
    } else {
      primaryLabel = formatClockDuration(Duration(seconds: elapsed));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(activity?.name ?? l10n.activeSession),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: l10n.cancelSession,
            onPressed: () => _cancelSession(profileId, session),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (activity != null)
              ActivityCategoryChip(category: activity.category),
            const Spacer(),
            Text(
              isPaused ? l10n.sessionPaused : l10n.sessionRunning,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isPaused ? colorScheme.tertiary : colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              primaryLabel,
              style: theme.textTheme.displayLarge?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (mode == SessionMode.timedInterval) ...[
              const SizedBox(height: 8),
              Text(
                inWorkSegment ? l10n.workInterval : l10n.restInterval,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${l10n.intervalsCompleted}: $completedIntervals',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (progress != null) ...[
              const SizedBox(height: 24),
              LinearProgressIndicator(
                value: progress > 1 ? 1 : progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
            const Spacer(),
            if (isCountdown && (remaining ?? 0) > 0) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isPaused
                      ? () => _resumeSession(profileId, session)
                      : () => _pauseSession(profileId, session),
                  icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      isPaused ? l10n.resumeSession : l10n.pauseSession,
                    ),
                  ),
                ),
              ),
            ] else if (!isCountdown) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isPaused
                      ? () => _resumeSession(profileId, session)
                      : () => _pauseSession(profileId, session),
                  icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      isPaused ? l10n.resumeSession : l10n.pauseSession,
                    ),
                  ),
                ),
              ),
            ],
            if (isCountdown && (remaining ?? 0) > 0) ...[
              const SizedBox(height: 12),
            ],
            if (!(isCountdown && (remaining ?? 0) <= 0)) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _openCompletionSheet(
                    profileId,
                    session,
                    activity,
                    countdownExpired: false,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(l10n.finishSession),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---- Actions -------------------------------------------------------------

  Future<void> _startSession(int profileId, Activity? activity) async {
    if (activity == null) return;
    final repo = ref.read(activityRepositoryProvider);
    final plannedSeconds = _mode == SessionMode.untimed
        ? null
        : _workMinutes * 60;
    final restSeconds = _mode == SessionMode.timedInterval
        ? _restMinutes * 60
        : null;
    await repo.startSession(
      activity.id!,
      profileId,
      mode: _mode.value,
      plannedDurationSeconds: plannedSeconds,
      restDurationSeconds: restSeconds,
    );
  }

  Future<void> _pauseSession(int profileId, ActivitySession session) async {
    await ref
        .read(activityRepositoryProvider)
        .pauseSession(session.id!, profileId, now: DateTime.now());
  }

  Future<void> _resumeSession(int profileId, ActivitySession session) async {
    await ref
        .read(activityRepositoryProvider)
        .resumeSession(session.id!, profileId, now: DateTime.now());
  }

  Future<void> _cancelSession(int profileId, ActivitySession session) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelSession),
        content: Text(l10n.cancelSessionConfirmation),
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
            child: Text(l10n.cancelSession),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref
          .read(activityRepositoryProvider)
          .cancelSession(session.id!, profileId, now: DateTime.now());
    } catch (_) {
      // Session may already be finished; ignore.
    }
    await _finishAndExit(profileId, cancelled: true);
  }

  Future<void> _openCompletionSheet(
    int profileId,
    ActivitySession session,
    Activity? activity, {
    required bool countdownExpired,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final elapsedAtFinish = session.elapsedSecondsAt(DateTime.now());
    final modeLabel = countdownExpired && session.accumulatedSeconds == 0
        ? sessionModeLabel(l10n, SessionMode.untimed.value)
        : sessionModeLabel(l10n, session.mode);
    await showActivityCompletionSheet(
      context,
      activityName: activity?.name ?? l10n.activeSession,
      modeLabel: modeLabel,
      durationLabel: formatClockDuration(Duration(seconds: elapsedAtFinish)),
      defaultLabel: activity?.name,
      onSave: (notes) => ref
          .read(activityRepositoryProvider)
          .completeSession(
            session.id!,
            profileId,
            notes: notes,
            countdownExpired: countdownExpired,
            now: DateTime.now(),
          ),
    );
    await _finishAndExit(profileId);
  }

  Future<void> _finishAndExit(int profileId, {bool cancelled = false}) async {
    if (!mounted) return;
    final repo = ref.read(activityRepositoryProvider);
    final stillActive = await repo.getActiveSession(profileId);
    if (!mounted) return;
    if (stillActive == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cancelled ? l10n.sessionCancelled : l10n.sessionCompleted,
          ),
        ),
      );
      if (context.mounted) {
        context.pop();
      }
    }
  }
}
