import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rehab_track/domain/entities/diet.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/diet_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/screens/health/diet_category_visuals.dart';

/// Add/Edit Food Guidance screen.
class DietFoodFormScreen extends ConsumerStatefulWidget {
  const DietFoodFormScreen({super.key, this.foodId});

  final int? foodId;

  @override
  ConsumerState<DietFoodFormScreen> createState() => _DietFoodFormScreenState();
}

class _DietFoodFormScreenState extends ConsumerState<DietFoodFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _foodGroupController = TextEditingController();
  final _notesController = TextEditingController();
  final _sourceController = TextEditingController();

  String _selectedCategory = DietFoodCategory.allowed;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.foodId != null;
    if (_isEditing) {
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    final profileId = ref.read(currentActiveProfileIdProvider);
    if (profileId == null || widget.foodId == null) return;
    final item = await ref
        .read(dietRepositoryProvider)
        .getFoodItem(widget.foodId!, profileId);

    if (item != null && mounted) {
      setState(() {
        _nameController.text = item.name;
        _selectedCategory = item.category;
        _foodGroupController.text = item.foodGroup ?? '';
        _notesController.text = item.notes ?? '';
        _sourceController.text = item.source ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _foodGroupController.dispose();
    _notesController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.foodId == null ? l10n.addDietItem : l10n.editDietItem),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.foodName,
                hintText: l10n.foodNameHint,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.foodNameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: l10n.foodCategory,
              ),
              items: [
                DropdownMenuItem(
                  value: DietFoodCategory.allowed,
                  child: Text(l10n.allowed),
                ),
                DropdownMenuItem(
                  value: DietFoodCategory.caution,
                  child: Text(l10n.caution),
                ),
                DropdownMenuItem(
                  value: DietFoodCategory.avoid,
                  child: Text(l10n.avoid),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _foodGroupController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.foodGroup,
                hintText: l10n.foodGroupHint,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.foodNotes,
                hintText: l10n.foodNotesHint,
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sourceController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.source,
                hintText: l10n.sourceHint,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _isEditing ? l10n.updateDietItem : l10n.saveDietItem,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final profileId = ref.read(currentActiveProfileIdProvider);
      if (profileId == null) {
        setState(() => _isLoading = false);
        return;
      }
      final repo = ref.read(dietRepositoryProvider);
      final now = DateTime.now();

      final item = DietItem(
        id: widget.foodId,
        profileId: profileId,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        foodGroup: _trimToNull(_foodGroupController.text),
        notes: _trimToNull(_notesController.text),
        source: _trimToNull(_sourceController.text),
        isArchived: false,
        createdAt: now,
        updatedAt: now,
      );

      if (widget.foodId == null) {
        await repo.createFoodItem(item);
      } else {
        await repo.updateFoodItem(item);
      }

      if (mounted) {
        if (context.mounted) {
          context.pop();
        }
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.foodId == null ? l10n.dietItemSaved : l10n.dietItemUpdated,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _trimToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
