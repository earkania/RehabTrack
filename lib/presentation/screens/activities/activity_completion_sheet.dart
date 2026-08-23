import 'package:flutter/material.dart';

import 'package:rehab_track/l10n/app_localizations.dart';

/// Modal sheet that records a finished session: shows the activity, actual
/// duration and mode, and collects an optional label/note before saving.
class ActivityCompletionSheet extends StatefulWidget {
  const ActivityCompletionSheet({
    super.key,
    required this.activityName,
    required this.modeLabel,
    required this.durationLabel,
    this.defaultLabel,
    required this.onSave,
  });

  final String activityName;
  final String modeLabel;
  final String durationLabel;
  final String? defaultLabel;
  final Future<void> Function(String? notes) onSave;

  @override
  State<ActivityCompletionSheet> createState() =>
      _ActivityCompletionSheetState();
}

class _ActivityCompletionSheetState extends State<ActivityCompletionSheet> {
  final _notesController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.defaultLabel ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.recordSession, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.activityName,
                        style: theme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.modeLabel} · ${widget.durationLabel}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.check_circle_outline,
                  color: colorScheme.primary,
                  size: 32,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.sessionLabel,
                hintText: l10n.sessionLabelHint,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.saveSession),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      final notes = _trimToNull(_notesController.text);
      await widget.onSave(notes);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
      }
      rethrow;
    }
  }

  String? _trimToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

/// Shows the completion sheet as a modal bottom sheet and returns when the
/// user saves or dismisses it.
Future<void> showActivityCompletionSheet(
  BuildContext context, {
  required String activityName,
  required String modeLabel,
  required String durationLabel,
  String? defaultLabel,
  required Future<void> Function(String? notes) onSave,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ActivityCompletionSheet(
        activityName: activityName,
        modeLabel: modeLabel,
        durationLabel: durationLabel,
        defaultLabel: defaultLabel,
        onSave: onSave,
      ),
    ),
  );
}
