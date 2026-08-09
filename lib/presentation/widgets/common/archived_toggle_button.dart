import 'package:flutter/material.dart';

/// App bar action toggling between the active and archived views of a list.
///
/// When the archived view is active ([isArchived] is true) the button renders
/// a clearly selected state (filled icon, accent colour and a tonal container)
/// so it's obvious which view is currently shown.
class ArchivedToggleButton extends StatelessWidget {
  const ArchivedToggleButton({
    super.key,
    required this.isArchived,
    required this.showTooltip,
    required this.showingTooltip,
    required this.onPressed,
  });

  /// Whether the archived view is currently displayed.
  final bool isArchived;

  /// Semantics/tooltip label when the active list is shown (action to show
  /// the archived list).
  final String showTooltip;

  /// Semantics label (and tooltip) when the archived list is currently shown.
  final String showingTooltip;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tooltip = isArchived ? showingTooltip : showTooltip;

    return Semantics(
      container: true,
      label: tooltip,
      button: true,
      selected: isArchived,
      child: Tooltip(
        message: tooltip,
        child: IconButton(
          onPressed: onPressed,
          style: isArchived
              ? IconButton.styleFrom(
                  backgroundColor: colorScheme.secondaryContainer,
                  foregroundColor: colorScheme.onSecondaryContainer,
                )
              : IconButton.styleFrom(
                  foregroundColor: colorScheme.onSurfaceVariant,
                ),
          icon: Icon(
            isArchived ? Icons.unarchive_rounded : Icons.archive_outlined,
            size: isArchived ? 24 : 22,
          ),
        ),
      ),
    );
  }
}