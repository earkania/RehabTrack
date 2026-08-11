import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rehab_track/domain/entities/diet.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/diet_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/screens/health/diet_category_visuals.dart';

/// Add/Edit General Guidance rule screen.
class DietGuidanceFormScreen extends ConsumerStatefulWidget {
  const DietGuidanceFormScreen({super.key, this.ruleId});

  final int? ruleId;

  @override
  ConsumerState<DietGuidanceFormScreen> createState() =>
      _DietGuidanceFormScreenState();
}

class _DietGuidanceFormScreenState
    extends ConsumerState<DietGuidanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sourceController = TextEditingController();

  String _selectedCategory = DietGuidanceCategory.diet;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.ruleId != null;
    if (_isEditing) {
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    final profileId = ref.read(currentActiveProfileIdProvider);
    if (profileId == null || widget.ruleId == null) return;
    final rule = await ref
        .read(dietRepositoryProvider)
        .getGuidanceRule(widget.ruleId!, profileId);

    if (rule != null && mounted) {
      setState(() {
        _titleController.text = rule.title;
        _selectedCategory = rule.category;
        _descriptionController.text = rule.description ?? '';
        _sourceController.text = rule.source ?? '';
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.ruleId == null ? l10n.addGuidanceRule : l10n.editGuidanceRule,
        ),
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
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.guidanceTitle,
                hintText: l10n.guidanceTitleHint,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.guidanceTitleRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: l10n.guidanceCategory,
              ),
              items: [
                DropdownMenuItem(
                  value: DietGuidanceCategory.diet,
                  child: Text(l10n.dietGuidanceCategory),
                ),
                DropdownMenuItem(
                  value: DietGuidanceCategory.smoking,
                  child: Text(l10n.smokingGuidanceCategory),
                ),
                DropdownMenuItem(
                  value: DietGuidanceCategory.hydration,
                  child: Text(l10n.hydrationGuidanceCategory),
                ),
                DropdownMenuItem(
                  value: DietGuidanceCategory.caffeine,
                  child: Text(l10n.caffeineGuidanceCategory),
                ),
                DropdownMenuItem(
                  value: DietGuidanceCategory.other,
                  child: Text(l10n.otherGuidanceCategory),
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
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.guidanceDescription,
                hintText: l10n.guidanceDescriptionHint,
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
                        _isEditing
                            ? l10n.updateGuidanceRule
                            : l10n.saveGuidanceRule,
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

      final rule = DietGuidanceRule(
        id: widget.ruleId,
        profileId: profileId,
        title: _titleController.text.trim(),
        category: _selectedCategory,
        description: _trimToNull(_descriptionController.text),
        source: _trimToNull(_sourceController.text),
        sortOrder: null,
        isArchived: false,
        createdAt: now,
        updatedAt: now,
      );

      if (widget.ruleId == null) {
        await repo.createGuidanceRule(rule);
      } else {
        await repo.updateGuidanceRule(rule);
      }

      if (mounted) {
        if (context.mounted) {
          context.pop();
        }
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.ruleId == null
                  ? l10n.guidanceRuleSaved
                  : l10n.guidanceRuleUpdated,
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
