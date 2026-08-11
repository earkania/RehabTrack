import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/entities/diet.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/diet_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/screens/health/diet_category_visuals.dart';
import 'package:rehab_track/presentation/widgets/common/archived_toggle_button.dart';
import 'package:rehab_track/presentation/widgets/empty_state.dart';

/// Health → Diet. Two top-level sections — Foods (Food Guidance) and
/// General Guidance — switched with a compact segmented control. Each section
/// keeps its own search / filter / sort / archive state.
class DietScreen extends ConsumerStatefulWidget {
  const DietScreen({super.key, this.initialSection});

  final DietSection? initialSection;

  @override
  ConsumerState<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends ConsumerState<DietScreen> {
  final _foodsSearchController = TextEditingController();
  final _guidanceSearchController = TextEditingController();

  bool _showFoodsArchived = false;
  bool _showGuidanceArchived = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialSection != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(activeDietSectionProvider.notifier)
              .state = widget.initialSection!;
        }
      });
    }
    _foodsSearchController.addListener(() {
      ref.read(dietFoodSearchQueryProvider.notifier).state =
          _foodsSearchController.text;
    });
    _guidanceSearchController.addListener(() {
      ref.read(dietGuidanceSearchQueryProvider.notifier).state =
          _guidanceSearchController.text;
    });
  }

  @override
  void dispose() {
    _foodsSearchController.dispose();
    _guidanceSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeProfileId = ref.watch(currentActiveProfileIdProvider);
    final section = ref.watch(activeDietSectionProvider);
    final showArchived = section == DietSection.foods
        ? _showFoodsArchived
        : _showGuidanceArchived;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.diet),
        actions: [
          ArchivedToggleButton(
            isArchived: showArchived,
            showTooltip: section == DietSection.foods
                ? l10n.showArchivedDietItems
                : l10n.showArchivedGuidanceRules,
            showingTooltip: section == DietSection.foods
                ? l10n.showingArchivedDietItems
                : l10n.showingArchivedGuidanceRules,
            onPressed: () {
              setState(() {
                if (section == DietSection.foods) {
                  _showFoodsArchived = !_showFoodsArchived;
                } else {
                  _showGuidanceArchived = !_showGuidanceArchived;
                }
              });
            },
          ),
        ],
      ),
      floatingActionButton: showArchived
          ? null
          : FloatingActionButton(
              onPressed: () {
                context.push(
                  section == DietSection.foods
                      ? AppRoutes.healthDietFoodsAdd
                      : AppRoutes.healthDietGuidanceAdd,
                );
              },
              tooltip: section == DietSection.foods
                  ? l10n.addDietItem
                  : l10n.addGuidanceRule,
              child: const Icon(Icons.add),
            ),
      body: activeProfileId == null
          ? _buildNoProfile(context)
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<DietSection>(
                      segments: [
                        ButtonSegment(
                          value: DietSection.foods,
                          icon: const Icon(Icons.restaurant_menu_outlined),
                          label: Text(l10n.foods),
                        ),
                        ButtonSegment(
                          value: DietSection.guidance,
                          icon: const Icon(Icons.event_note_outlined),
                          label: Text(l10n.generalGuidance),
                        ),
                      ],
                      selected: {section},
                      onSelectionChanged: (selection) {
                        ref
                            .read(activeDietSectionProvider.notifier)
                            .state = selection.first;
                      },
                    ),
                  ),
                ),
                if (section == DietSection.foods)
                  _buildFoodsControls(context)
                else
                  _buildGuidanceControls(context),
                Expanded(
                  child: section == DietSection.foods
                      ? _buildFoodsList(context, activeProfileId, showArchived)
                      : _buildGuidanceList(
                          context, activeProfileId, showArchived),
                ),
              ],
            ),
    );
  }

  // ---- Controls -----------------------------------------------------------

  Widget _buildFoodsControls(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_showFoodsArchived) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _foodsSearchController,
              decoration: InputDecoration(
                hintText: l10n.searchFoods,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _CircleMenuButton<String>(
            icon: Icons.filter_list,
            tooltip: l10n.filter,
            selected: ref.watch(dietFoodCategoryFilterProvider) != null,
            onSelected: (value) {
              ref
                  .read(dietFoodCategoryFilterProvider.notifier)
                  .state = value == 'all' ? null : value;
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'all', child: Text(l10n.allDietItems)),
              PopupMenuItem(
                value: DietFoodCategory.allowed,
                child: Text(l10n.allowed),
              ),
              PopupMenuItem(
                value: DietFoodCategory.caution,
                child: Text(l10n.caution),
              ),
              PopupMenuItem(
                value: DietFoodCategory.avoid,
                child: Text(l10n.avoid),
              ),
            ],
          ),
          const SizedBox(width: 8),
          _CircleMenuButton<DietFoodSort>(
            icon: Icons.sort,
            tooltip: l10n.sort,
            selected:
                ref.watch(dietFoodSortProvider) != DietFoodSort.alphabeticalAZ,
            onSelected: (value) {
              ref.read(dietFoodSortProvider.notifier).state = value;
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: DietFoodSort.alphabeticalAZ,
                child: Text(l10n.alphabeticalAZ),
              ),
              PopupMenuItem(
                value: DietFoodSort.alphabeticalZA,
                child: Text(l10n.alphabeticalZA),
              ),
              PopupMenuItem(
                value: DietFoodSort.byCategory,
                child: Text(l10n.sortByCategory),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuidanceControls(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_showGuidanceArchived) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _guidanceSearchController,
              decoration: InputDecoration(
                hintText: l10n.searchGuidance,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _CircleMenuButton<String>(
            icon: Icons.filter_list,
            tooltip: l10n.filter,
            selected: ref.watch(dietGuidanceCategoryFilterProvider) != null,
            onSelected: (value) {
              ref
                  .read(dietGuidanceCategoryFilterProvider.notifier)
                  .state = value == 'all' ? null : value;
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Text(l10n.allGuidanceRules),
              ),
              PopupMenuItem(
                value: DietGuidanceCategory.diet,
                child: Text(l10n.dietGuidanceCategory),
              ),
              PopupMenuItem(
                value: DietGuidanceCategory.smoking,
                child: Text(l10n.smokingGuidanceCategory),
              ),
              PopupMenuItem(
                value: DietGuidanceCategory.hydration,
                child: Text(l10n.hydrationGuidanceCategory),
              ),
              PopupMenuItem(
                value: DietGuidanceCategory.caffeine,
                child: Text(l10n.caffeineGuidanceCategory),
              ),
              PopupMenuItem(
                value: DietGuidanceCategory.alcohol,
                child: Text(l10n.alcoholGuidanceCategory),
              ),
              PopupMenuItem(
                value: DietGuidanceCategory.other,
                child: Text(l10n.otherGuidanceCategory),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Lists --------------------------------------------------------------

  Widget _buildFoodsList(
    BuildContext context,
    int profileId,
    bool showArchived,
  ) {
    final foods = showArchived
        ? ref.watch(archivedDietFoodItemsProvider(profileId))
        : ref.watch(sortedDietFoodItemsProvider(profileId));

    return foods.when(
      data: (list) => _buildFoodsData(context, list, showArchived),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildError(context, error, isFoods: true),
    );
  }

  Widget _buildFoodsData(
    BuildContext context,
    List<DietItem> items,
    bool showArchived,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (items.isEmpty) {
      return EmptyState(
        icon: showArchived ? Icons.archive_outlined : Icons.restaurant_menu_outlined,
        title: showArchived ? l10n.noArchivedDietItems : l10n.noDietItems,
        subtitle: showArchived ? '' : l10n.noDietItemsDescription,
        actionLabel: showArchived ? null : l10n.addDietItem,
        onAction: showArchived
            ? null
            : () => context.push(AppRoutes.healthDietFoodsAdd),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _FoodListTile(
          item: item,
          archived: showArchived,
        );
      },
    );
  }

  Widget _buildGuidanceList(
    BuildContext context,
    int profileId,
    bool showArchived,
  ) {
    final rules = showArchived
        ? ref.watch(archivedDietGuidanceRulesProvider(profileId))
        : ref.watch(dietGuidanceSearchProvider(profileId));

    return rules.when(
      data: (list) => _buildGuidanceData(context, list, showArchived),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildError(context, error, isFoods: false),
    );
  }

  Widget _buildGuidanceData(
    BuildContext context,
    List<DietGuidanceRule> rules,
    bool showArchived,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (rules.isEmpty) {
      return EmptyState(
        icon: showArchived ? Icons.archive_outlined : Icons.event_note_outlined,
        title: showArchived ? l10n.noArchivedGuidanceRules : l10n.noGuidanceRules,
        subtitle: showArchived ? '' : l10n.noGuidanceRulesDescription,
        actionLabel: showArchived ? null : l10n.addGuidanceRule,
        onAction: showArchived
            ? null
            : () => context.push(AppRoutes.healthDietGuidanceAdd),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: rules.length,
      itemBuilder: (context, index) {
        final rule = rules[index];
        return _GuidanceListTile(
          rule: rule,
          archived: showArchived,
        );
      },
    );
  }

  Widget _buildError(BuildContext context, Object error, {required bool isFoods}) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            isFoods ? l10n.errorLoadingDietItems : l10n.errorLoadingGuidanceRules,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              if (isFoods) {
                ref.invalidate(dietFoodSearchQueryProvider);
                ref.invalidate(dietFoodCategoryFilterProvider);
                ref.invalidate(dietFoodSortProvider);
              } else {
                ref.invalidate(dietGuidanceSearchQueryProvider);
                ref.invalidate(dietGuidanceCategoryFilterProvider);
              }
            },
            child: Text(l10n.retry),
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
          const SizedBox(height: 8),
          Text(
            l10n.createProfileFirst,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _FoodListTile extends ConsumerWidget {
  const _FoodListTile({required this.item, required this.archived});

  final DietItem item;
  final bool archived;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final categoryLabel = foodCategoryLabel(l10n, item.category);
    final semanticLabel = '${item.name}, $categoryLabel';

    return Card(
      child: ListTile(
        leading: CategoryIconAvatar(
          icon: foodCategoryIcon(item.category),
          color: foodCategoryColor(colorScheme, item.category),
          label: categoryLabel,
        ),
        title: Semantics(
          label: semanticLabel,
          child: Tooltip(
            message: semanticLabel,
            child: Text(
              item.name,
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
                color: foodCategoryColor(colorScheme, item.category),
              ),
            ),
            if (item.foodGroup != null && item.foodGroup!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                item.foodGroup!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        trailing: archived ? _buildArchivedActions(context, ref) : null,
        onTap: () => context.push(
          AppRoutes.healthDietFoodsDetails(item.id!),
        ),
      ),
    );
  }

  Widget _buildArchivedActions(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      onSelected: (value) async {
        final profileId = ref.read(currentActiveProfileIdProvider);
        if (profileId == null) return;
        final repo = ref.read(dietRepositoryProvider);
        if (value == 'restore') {
          await repo.restoreFoodItem(item.id!, profileId);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.dietItemRestored)),
            );
          }
        } else if (value == 'delete') {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.deleteDietItem),
              content: Text(l10n.confirmDeleteDietItem),
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
            await repo.deleteFoodItem(item.id!, profileId);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.dietItemDeleted)),
              );
            }
          }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'restore',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.unarchive_outlined, size: 20),
            title: Text(l10n.restoreDietItem),
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
              l10n.deleteDietItem,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }
}

class _GuidanceListTile extends ConsumerWidget {
  const _GuidanceListTile({required this.rule, required this.archived});

  final DietGuidanceRule rule;
  final bool archived;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final categoryLabel = guidanceCategoryLabel(l10n, rule.category);
    final semanticLabel = '${rule.title}, $categoryLabel';

    return Card(
      child: ListTile(
        leading: CategoryIconAvatar(
          icon: guidanceCategoryIcon(rule.category),
          color: guidanceCategoryColor(colorScheme, rule.category),
          label: categoryLabel,
        ),
        title: Semantics(
          label: semanticLabel,
          child: Tooltip(
            message: semanticLabel,
            child: Text(
              rule.title,
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
                color: guidanceCategoryColor(colorScheme, rule.category),
              ),
            ),
            if (rule.description != null && rule.description!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                rule.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        trailing: archived ? _buildArchivedActions(context, ref) : null,
        onTap: () => context.push(
          AppRoutes.healthDietGuidanceDetails(rule.id!),
        ),
      ),
    );
  }

  Widget _buildArchivedActions(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      onSelected: (value) async {
        final profileId = ref.read(currentActiveProfileIdProvider);
        if (profileId == null) return;
        final repo = ref.read(dietRepositoryProvider);
        if (value == 'restore') {
          await repo.restoreGuidanceRule(rule.id!, profileId);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.guidanceRuleRestored)),
            );
          }
        } else if (value == 'delete') {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.deleteGuidanceRule),
              content: Text(l10n.confirmDeleteGuidanceRule),
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
            await repo.deleteGuidanceRule(rule.id!, profileId);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.guidanceRuleDeleted)),
              );
            }
          }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'restore',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.unarchive_outlined, size: 20),
            title: Text(l10n.restoreGuidanceRule),
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
              l10n.deleteGuidanceRule,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ],
    );
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
