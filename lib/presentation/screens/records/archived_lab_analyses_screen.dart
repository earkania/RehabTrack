import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/entities/lab_analysis.dart';
import 'package:rehab_track/domain/services/app_date_formatter.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/lab_analysis_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';

/// Archived Lab Analyses screen
class ArchivedLabAnalysesScreen extends ConsumerWidget {
  const ArchivedLabAnalysesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final activeProfileId = ref.watch(currentActiveProfileIdProvider);

    final analyses = ref.watch(archivedLabAnalysesProvider(activeProfileId ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.archivedAnalyses),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.recordsLabAnalyses),
        ),
      ),
      body: activeProfileId == null
          ? _buildNoProfile(context)
          : analyses.when(
              data: (analyses) => _buildList(context, analyses),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildError(context, ref, error),
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

  Widget _buildList(BuildContext context, List<LabAnalysis> analyses) {
    final l10n = AppLocalizations.of(context)!;

    if (analyses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.archive_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noArchivedAnalyses,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noArchivedAnalysesDesc,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
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

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
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
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'restore') {
                  // TODO: Restore analysis
                } else if (value == 'delete') {
                  // TODO: Delete analysis
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'restore',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.unarchive_outlined, size: 20),
                    title: Text(AppLocalizations.of(context)!.restoreAnalysis),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.delete_outlined, size: 20, color: Theme.of(context).colorScheme.error),
                    title: Text(
                      AppLocalizations.of(context)!.deleteLabAnalysis,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),
              ],
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