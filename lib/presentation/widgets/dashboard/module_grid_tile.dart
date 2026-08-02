import 'package:flutter/material.dart';

/// A large-icon module tile for the Health / Records / Profile dashboards.
///
/// Inspired by a file manager's large-icon view: a large centered icon with a
/// centered one- or two-line label beneath it. The whole tile is tappable.
class ModuleGridTile extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;
  final String? semanticsLabel;
  final bool enabled;

  const ModuleGridTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.semanticsLabel,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveLabel = semanticsLabel ?? label;

    return Semantics(
      label: effectiveLabel,
      button: true,
      enabled: enabled,
      excludeSemantics: true,
      child: Material(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 120),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconTheme.merge(
                    data: IconThemeData(
                      size: 64,
                      color: enabled
                          ? colorScheme.primary
                          : colorScheme.outline,
                    ),
                    child: icon,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: enabled
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
