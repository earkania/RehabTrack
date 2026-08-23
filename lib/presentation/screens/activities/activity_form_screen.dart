import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rehab_track/domain/entities/activity.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/activity_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/screens/activities/activity_category_visuals.dart';

/// Add/Edit Activity screen.
class ActivityFormScreen extends ConsumerStatefulWidget {
  const ActivityFormScreen({super.key, this.activityId});

  final int? activityId;

  @override
  ConsumerState<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends ConsumerState<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = ActivityCategoryValue.exercise;
  bool _isLoading = false;
  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.activityId != null;
    if (_isEditing) {
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    final profileId = ref.read(currentActiveProfileIdProvider);
    if (profileId == null || widget.activityId == null) return;
    final activity = await ref
        .read(activityRepositoryProvider)
        .getActivity(widget.activityId!, profileId);

    if (activity != null && mounted) {
      setState(() {
        _nameController.text = activity.name;
        _selectedCategory = activity.category;
        _durationController.text =
            activity.recommendedTimeMinutes?.toString() ?? '';
        _descriptionController.text = activity.description ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editActivity : l10n.addActivity),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.archive_outlined),
              tooltip: l10n.archiveActivity,
              onPressed: _isLoading ? null : _archive,
            ),
          TextButton(onPressed: _save, child: Text(l10n.save)),
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
                labelText: l10n.activityName,
                hintText: l10n.activityNameHint,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.activityNameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(labelText: l10n.activityCategory),
              items: ActivityCategoryValue.all
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(activityCategoryLabel(l10n, category)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.recommendedTimeMinutes,
                hintText: l10n.recommendedTimeMinutesHint,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final parsed = int.tryParse(value.trim());
                if (parsed == null || parsed <= 0) {
                  return l10n.recommendedTimeMinutesHint;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.activityDescription,
                hintText: l10n.activityDescriptionHint,
                alignLabelWithHint: true,
              ),
              maxLines: 4,
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
                        _isEditing ? l10n.updateActivity : l10n.saveActivity,
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
      final repo = ref.read(activityRepositoryProvider);
      final now = DateTime.now();

      final durationText = _durationController.text.trim();
      final recommended = durationText.isEmpty
          ? null
          : int.tryParse(durationText);

      final activity = Activity(
        id: widget.activityId,
        profileId: profileId,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        description: _trimToNull(_descriptionController.text),
        recommendedTimeMinutes: recommended,
        isArchived: false,
        createdAt: now,
        updatedAt: now,
      );

      if (widget.activityId == null) {
        await repo.createActivity(activity);
      } else {
        await repo.updateActivity(activity);
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        if (context.mounted) {
          context.pop();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.activityId == null
                  ? l10n.activitySaved
                  : l10n.activityUpdated,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _archive() async {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading || widget.activityId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.archiveActivity),
        content: Text(l10n.archiveActivityConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.archiveActivity),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final profileId = ref.read(currentActiveProfileIdProvider);
    if (profileId == null) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(activityRepositoryProvider)
          .archiveActivity(widget.activityId!, profileId);
      if (mounted) {
        if (context.mounted) {
          context.pop();
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.activityArchived)));
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
