import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/entities/activity.dart';
import 'package:rehab_track/domain/services/activity_formatters.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/activity_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/screens/activities/activity_category_visuals.dart';
import 'package:rehab_track/presentation/widgets/common/archived_toggle_button.dart';
import 'package:rehab_track/presentation/widgets/common/list_toolbar_icons.dart';
import 'package:rehab_track/presentation/widgets/empty_state.dart';

/// Health → Activities. Shows the activity list for the active profile with
/// search, category filter, sort and an archived toggle. A live banner for a
/// running/paused session is pinned on top while one is active.
class ActivityListScreen extends ConsumerStatefulWidget {
  const ActivityListScreen({super.key});

  @override
  ConsumerState<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends ConsumerState<ActivityListScreen> {
  final _searchController = TextEditingController();
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(activitySearchQueryProvider.notifier).state =
          _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeProfileId = ref.watch(currentActiveProfileIdProvider);
    final activeSession = ref
        .watch(activeSessionProvider(activeProfileId ?? -1))
        .valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _showArchived ? l10n.showingArchivedActivities : l10n.activities,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: l10n.sessionHistory,
            onPressed: () => context.push(AppRoutes.activityHistory),
          ),
          ArchivedToggleButton(
            isArchived: _showArchived,
            showTooltip: l10n.showArchivedActivities,
            showingTooltip: l10n.showingArchivedActivities,
            onPressed: () => setState(() => _showArchived = !_showArchived),
          ),
        ],
      ),
      floatingActionButton: _showArchived
          ? null
          : FloatingActionButton(
              onPressed: () => context.push(AppRoutes.activityAdd),
              tooltip: l10n.addActivity,
              child: const Icon(Icons.add),
            ),
      body: activeProfileId == null
          ? _buildNoProfile(context)
          : Column(
              children: [
                if (!_showArchived && activeSession != null)
                  _ActiveSessionBanner(session: activeSession),
                if (!_showArchived) _buildControls(context),
                Expanded(
                  child: _buildList(context, activeProfileId, _showArchived),
                ),
              ],
            ),
    );
  }

  Widget _buildNoProfile(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noActiveProfile,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchActivities,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _CircleMenuButton<String>(
            icon: toolbarCategoryFilterIcon,
            tooltip: l10n.filter,
            selected: ref.watch(activityCategoryFilterProvider) != null,
            onSelected: (value) {
              ref.read(activityCategoryFilterProvider.notifier).state =
                  value == 'all' ? null : value;
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'all', child: Text(l10n.allCategories)),
              ...ActivityCategoryValue.all.map(
                (category) => PopupMenuItem(
                  value: category,
                  child: Text(activityCategoryLabel(l10n, category)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          _CircleMenuButton<ActivitySort>(
            icon: toolbarSortIcon,
            tooltip: l10n.sort,
            selected:
                ref.watch(activitySortProvider) != ActivitySort.alphabeticalAZ,
            onSelected: (value) {
              ref.read(activitySortProvider.notifier).state = value;
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: ActivitySort.alphabeticalAZ,
                child: Text(l10n.alphabeticalAZ),
              ),
              PopupMenuItem(
                value: ActivitySort.alphabeticalZA,
                child: Text(l10n.alphabeticalZA),
              ),
              PopupMenuItem(
                value: ActivitySort.byCategory,
                child: Text(l10n.sortByCategory),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, int profileId, bool showArchived) {
    final activities = showArchived
        ? ref.watch(archivedActivitiesProvider(profileId))
        : ref.watch(filteredActivitiesProvider(profileId));

    return activities.when(
      data: (list) => _buildData(context, list, showArchived),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('$error')),
    );
  }

  Widget _buildData(
    BuildContext context,
    List<Activity> activities,
    bool showArchived,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (activities.isEmpty) {
      if (showArchived) {
        return EmptyState(
          icon: Icons.archive_outlined,
          title: l10n.activitiesEmpty,
          subtitle: l10n.showArchivedActivities,
        );
      }
      if (_searchController.text.isNotEmpty ||
          ref.read(activityCategoryFilterProvider) != null) {
        return EmptyState(
          icon: Icons.search_off_outlined,
          title: l10n.noActivitiesFound,
          subtitle: '',
        );
      }
      return EmptyState(
        icon: Icons.directions_walk_outlined,
        title: l10n.activitiesEmpty,
        subtitle: l10n.activitiesEmptySubtitle,
        actionLabel: l10n.addActivity,
        onAction: () => context.push(AppRoutes.activityAdd),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _ActivityListTile(activity: activity, archived: showArchived);
      },
    );
  }
}

/// Banner pinned above the list while a session is running or paused.
class _ActiveSessionBanner extends ConsumerWidget {
  const _ActiveSessionBanner({required this.session});

  final ActivitySession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final now = ref.watch(currentTimeProvider).value ?? DateTime.now();
    final elapsed = session.elapsedSecondsAt(now);
    final activity = ref
        .watch(
          activityByIdProvider((
            id: session.activityId,
            profileId: session.profileId,
          )),
        )
        .valueOrNull;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Card(
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
            '${formatClockDuration(Duration(seconds: elapsed))}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          trailing: FilledButton(
            onPressed: () => context.push(AppRoutes.activitySessionActive),
            child: Text(l10n.continueSession),
          ),
          onTap: () => context.push(AppRoutes.activitySessionActive),
        ),
      ),
    );
  }
}

class _ActivityListTile extends ConsumerWidget {
  const _ActivityListTile({required this.activity, required this.archived});

  final Activity activity;
  final bool archived;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final categoryLabel = activityCategoryLabel(l10n, activity.category);
    final semanticLabel = '${activity.name}, $categoryLabel';

    return Card(
      child: ListTile(
        leading: CategoryIconAvatar(
          icon: activityCategoryIcon(activity.category),
          color: activityCategoryColor(colorScheme, activity.category),
          label: categoryLabel,
        ),
        title: Semantics(
          label: semanticLabel,
          child: Tooltip(
            message: semanticLabel,
            child: Text(
              activity.name,
              style: theme.textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              categoryLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: activityCategoryColor(colorScheme, activity.category),
              ),
            ),
            if (activity.recommendedTimeMinutes != null) ...[
              const SizedBox(height: 2),
              Text(
                l10n.xMinutes(activity.recommendedTimeMinutes!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (activity.description != null &&
                activity.description!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                activity.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        trailing: _buildActions(context, ref),
        onTap: () => context.push(AppRoutes.activitySession(activity.id!)),
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      onSelected: (value) async {
        final profileId = ref.read(currentActiveProfileIdProvider);
        if (profileId == null) return;
        final repo = ref.read(activityRepositoryProvider);
        if (value == 'edit') {
          if (context.mounted) {
            context.push(AppRoutes.activityEdit(activity.id!));
          }
        } else if (value == 'archive') {
          await repo.archiveActivity(activity.id!, profileId);
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.activityArchived)));
          }
        } else if (value == 'restore') {
          await repo.restoreActivity(activity.id!, profileId);
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.activityRestored)));
          }
        } else if (value == 'delete') {
          await _confirmAndDelete(context, ref, profileId);
        }
      },
      itemBuilder: (context) => [
        if (!archived) ...[
          PopupMenuItem(
            value: 'edit',
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.edit_outlined, size: 20),
              title: Text(l10n.editActivity),
            ),
          ),
          PopupMenuItem(
            value: 'archive',
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.archive_outlined, size: 20),
              title: Text(l10n.archiveActivity),
            ),
          ),
        ] else ...[
          PopupMenuItem(
            value: 'restore',
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.unarchive_outlined, size: 20),
              title: Text(l10n.restoreActivity),
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.delete_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                l10n.delete,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    WidgetRef ref,
    int profileId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(activityRepositoryProvider);
    final sessionCount = await repo.countSessionsForActivity(activity.id!);
    if (!context.mounted) return;
    if (sessionCount > 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.activityHasSessions)));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.confirmDeleteActivity),
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
    if (confirmed == true) {
      await repo.deleteActivity(activity.id!, profileId);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.activityDeleted)));
      }
    }
  }
}

class _CircleMenuButton<T> extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool selected;
  final ValueChanged<T> onSelected;
  final List<PopupMenuEntry<T>> Function(BuildContext context) itemBuilder;

  const _CircleMenuButton({
    required this.icon,
    required this.tooltip,
    this.selected = false,
    required this.onSelected,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopupMenuButton<T>(
      tooltip: tooltip,
      onSelected: onSelected,
      itemBuilder: itemBuilder,
      child: Semantics(
        label: tooltip,
        button: true,
        selected: selected,
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected
                  ? colorScheme.secondaryContainer
                  : colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: selected ? colorScheme.secondary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: selected
                  ? colorScheme.onSecondaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
