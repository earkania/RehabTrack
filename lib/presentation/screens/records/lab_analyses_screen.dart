import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/entities/lab_analysis.dart';
import 'package:rehab_track/domain/services/app_date_formatter.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/lab_analysis_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/widgets/common/archived_toggle_button.dart';

/// Lab Analyses list screen
class LabAnalysesScreen extends ConsumerStatefulWidget {
  const LabAnalysesScreen({super.key, this.startArchived = false});

  final bool startArchived;

  @override
  ConsumerState<LabAnalysesScreen> createState() => _LabAnalysesScreenState();
}

class _LabAnalysesScreenState extends ConsumerState<LabAnalysesScreen> {
  bool _showArchived = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _showArchived = widget.startArchived;
    _searchController.addListener(() {
      ref.read(labAnalysisSearchQueryProvider.notifier).state =
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

    final analyses = _showArchived
        ? ref.watch(archivedLabAnalysesProvider(activeProfileId ?? 0))
        : ref.watch(sortedLabAnalysesProvider(activeProfileId ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.labAnalyses),
        actions: [
          ArchivedToggleButton(
            isArchived: _showArchived,
            showTooltip: l10n.showArchivedAnalyses,
            showingTooltip: l10n.showingArchivedAnalyses,
            onPressed: () {
              setState(() {
                _showArchived = !_showArchived;
              });
            },
          ),
        ],
      ),
      floatingActionButton: _showArchived
          ? null
          : FloatingActionButton(
              onPressed: () => context.push(AppRoutes.recordsLabAnalysesAdd),
              child: const Icon(Icons.add),
            ),
      body: activeProfileId == null
          ? _buildNoProfile()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: l10n.searchAnalyses,
                            prefixIcon: const Icon(Icons.search),
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Filters
                      _CircleMenuButton<String>(
                        icon: Icons.filter_list,
                        tooltip: l10n.filter,
                        selected: ref.watch(labAnalysisCategoryFilterProvider) !=
                            null,
                        onSelected: (value) {
                          ref.read(labAnalysisCategoryFilterProvider.notifier).state =
                              value == 'all' ? null : value;
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'all',
                            child: Text(l10n.allAnalyses),
                          ),
                          PopupMenuItem(
                            value: 'laboratory',
                            child: Text(l10n.laboratory),
                          ),
                          PopupMenuItem(
                            value: 'cardiology',
                            child: Text(l10n.cardiology),
                          ),
                          PopupMenuItem(
                            value: 'imaging',
                            child: Text(l10n.imaging),
                          ),
                          PopupMenuItem(
                            value: 'pathology',
                            child: Text(l10n.pathology),
                          ),
                          PopupMenuItem(
                            value: 'other',
                            child: Text(l10n.other),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // Sort
                      _CircleMenuButton<LabAnalysisSort>(
                        icon: Icons.sort,
                        tooltip: l10n.sort,
                        selected: ref.watch(labAnalysisSortProvider) !=
                            LabAnalysisSort.newestFirst,
                        onSelected: (value) {
                          ref.read(labAnalysisSortProvider.notifier).state = value;
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: LabAnalysisSort.newestFirst,
                            child: Text(l10n.newestFirst),
                          ),
                          PopupMenuItem(
                            value: LabAnalysisSort.oldestFirst,
                            child: Text(l10n.oldestFirst),
                          ),
                          PopupMenuItem(
                            value: LabAnalysisSort.titleAscending,
                            child: Text(l10n.titleAscending),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: analyses.when(
                    data: (analyses) => _buildList(analyses),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => _buildError(error),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNoProfile() {
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

  Widget _buildList(List<LabAnalysis> analyses) {
    final l10n = AppLocalizations.of(context)!;

    if (analyses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.science_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              _showArchived ? l10n.noArchivedAnalyses : l10n.noLabAnalyses,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _showArchived
                  ? l10n.noArchivedAnalysesDesc
                  : l10n.noLabAnalysesDesc,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (!_showArchived) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.push(AppRoutes.recordsLabAnalysesAdd),
                icon: const Icon(Icons.add),
                label: Text(l10n.addLabAnalysis),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: analyses.length,
      itemBuilder: (context, index) {
        final analysis = analyses[index];
        return _AnalysisListTile(analysis: analysis);
      },
    );
  }

  Widget _buildError(Object error) {
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
            l10n.errorLoadingAnalyses,
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
              ref.invalidate(labAnalysisSearchQueryProvider);
              ref.invalidate(labAnalysisCategoryFilterProvider);
              ref.invalidate(labAnalysisSortProvider);
            },
            child: Text(l10n.retry),
          ),
        ],
      ),
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

class _AnalysisListTile extends StatelessWidget {
  final LabAnalysis analysis;

  const _AnalysisListTile({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: _CategoryIcon(category: analysis.category),
        title: Tooltip(
          message: analysis.title,
          child: Text(
            analysis.title,
            style: theme.textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _formatDate(context, analysis.analysisDate),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (analysis.category.isNotEmpty) ...[
              const SizedBox(height: 2),
              _CategoryChip(category: analysis.category),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (analysis.laboratoryContactId != null ||
                analysis.orderingDoctorContactId != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.local_hospital_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
        onTap: () => context.push(
          AppRoutes.recordsLabAnalysesDetails(analysis.id!),
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final formatter = AppDateFormatter.of(context);
    final now = DateTime.now();
    final diff = date.difference(now).inDays.abs();

    if (diff == 0) {
      return l10n.today;
    } else if (diff == 1) {
      return l10n.tomorrow;
    } else if (diff < 7) {
      return formatter.formatWeekday(date);
    } else {
      return formatter.formatMediumDate(date);
    }
  }
}

class _CategoryIcon extends StatelessWidget {
  final String category;

  const _CategoryIcon({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    IconData icon;
    Color color;

    switch (category) {
      case 'laboratory':
        icon = Icons.biotech_outlined;
        color = Colors.blue;
        break;
      case 'cardiology':
        icon = Icons.favorite_outlined;
        color = Colors.red;
        break;
      case 'imaging':
        icon = Icons.image_outlined;
        color = Colors.purple;
        break;
      case 'pathology':
        icon = Icons.science_outlined;
        color = Colors.green;
        break;
      default:
        icon = Icons.folder_outlined;
        color = theme.colorScheme.onSurfaceVariant;
    }

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String label;

    switch (category) {
      case 'laboratory':
        label = l10n.laboratory;
        break;
      case 'cardiology':
        label = l10n.cardiology;
        break;
      case 'imaging':
        label = l10n.imaging;
        break;
      case 'pathology':
        label = l10n.pathology;
        break;
      default:
        label = l10n.other;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 10),
      ),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      labelPadding: EdgeInsets.zero,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }
}