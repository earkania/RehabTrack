import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/entities/diet.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/diet_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/screens/health/diet_category_visuals.dart';

/// Food Guidance details screen.
class DietFoodDetailsScreen extends ConsumerStatefulWidget {
  const DietFoodDetailsScreen({super.key, required this.foodId});

  final int foodId;

  @override
  ConsumerState<DietFoodDetailsScreen> createState() =>
      _DietFoodDetailsScreenState();
}

class _DietFoodDetailsScreenState extends ConsumerState<DietFoodDetailsScreen> {
  DietItem? _item;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profileId = ref.read(currentActiveProfileIdProvider);
    if (profileId == null) {
      setState(() => _isLoading = false);
      return;
    }
    final item = await ref
        .read(dietRepositoryProvider)
        .getFoodItem(widget.foodId, profileId);

    setState(() {
      _item = item;
      _isLoading = false;
    });
  }

  Future<void> _openEdit() async {
    await context.push(AppRoutes.healthDietFoodsEdit(widget.foodId));
    if (mounted) {
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dietItemDetails),
        actions: [
          if (_item != null)
            PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'edit':
                    await _openEdit();
                    break;
                  case 'archive':
                    _archiveItem();
                    break;
                  case 'restore':
                    _restoreItem();
                    break;
                  case 'delete':
                    _confirmDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.edit_outlined, size: 20),
                    title: Text(l10n.editDietItem),
                  ),
                ),
                if (!_item!.isArchived)
                  PopupMenuItem(
                    value: 'archive',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.archive_outlined, size: 20),
                      title: Text(l10n.archiveDietItem),
                    ),
                  )
                else
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
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Future<void> _archiveItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.archiveDietItem),
        content: Text(AppLocalizations.of(context)!.archiveDietItemConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.archive),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final profileId = ref.read(currentActiveProfileIdProvider);
        if (profileId == null) return;
        await ref
            .read(dietRepositoryProvider)
            .archiveFoodItem(widget.foodId, profileId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.dietItemArchived)),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
          );
        }
      }
    }
  }

  Future<void> _restoreItem() async {
    try {
      final profileId = ref.read(currentActiveProfileIdProvider);
      if (profileId == null) return;
      await ref
          .read(dietRepositoryProvider)
          .restoreFoodItem(widget.foodId, profileId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.dietItemRestored)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
        );
      }
    }
  }

  void _confirmDelete() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteDietItem),
        content: Text(l10n.confirmDeleteDietItem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteItem();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem() async {
    try {
      final profileId = ref.read(currentActiveProfileIdProvider);
      if (profileId == null) return;
      await ref.read(dietRepositoryProvider).deleteFoodItem(widget.foodId, profileId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.dietItemDeleted)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
        );
      }
    }
  }

  Widget _buildContent() {
    if (_item == null) {
      return Center(
        child: Text(AppLocalizations.of(context)!.dietItemNotFound),
      );
    }

    final item = _item!;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryLabel = foodCategoryLabel(l10n, item.category);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CategoryIconAvatar(
                icon: foodCategoryIcon(item.category),
                color: foodCategoryColor(colorScheme, item.category),
                label: categoryLabel,
              ),
              const SizedBox(width: 12),
              _CategoryChip(label: categoryLabel),
            ],
          ),
          const SizedBox(height: 16),
          _DetailRow(
            label: l10n.foodCategory,
            value: categoryLabel,
          ),
          const SizedBox(height: 8),
          if (item.foodGroup != null && item.foodGroup!.isNotEmpty) ...[
            _DetailRow(label: l10n.foodGroup, value: item.foodGroup!),
            const SizedBox(height: 8),
          ],
          if (item.source != null && item.source!.isNotEmpty) ...[
            _DetailRow(label: l10n.source, value: item.source!),
            const SizedBox(height: 8),
          ],
          if (item.notes != null && item.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              l10n.foodNotes,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              item.notes!,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
          ],
          if (item.isArchived) ...[
            const SizedBox(height: 16),
            _ArchivedBanner(text: l10n.dietItemIsArchived),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;

  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
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

class _ArchivedBanner extends StatelessWidget {
  final String text;

  const _ArchivedBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.archive_outlined,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
