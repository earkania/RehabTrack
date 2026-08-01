import 'package:flutter/material.dart';

import 'module_grid_tile.dart';

/// A reusable two-column, vertically scrolling module grid used by the
/// Health, Records, and Profile dashboards.
///
/// Tiles are laid out two per row (pairs), continuing on the next row for any
/// additional items. Each tile sizes itself to its content so long Georgian
/// labels and large text scales never overflow.
class ModuleGrid extends StatelessWidget {
  final List<ModuleGridTile> tiles;
  final Widget? header;
  final EdgeInsetsGeometry padding;
  final double spacing;

  const ModuleGrid({
    super.key,
    required this.tiles,
    this.header,
    this.padding = const EdgeInsets.all(16),
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final rowCount = (tiles.length + 1) ~/ 2;

    return ListView.builder(
      padding: padding,
      itemCount: (header != null ? 1 : 0) + rowCount,
      itemBuilder: (context, index) {
        if (header != null && index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: spacing),
            child: header,
          );
        }

        final tileIndex = (header != null ? index - 1 : index) * 2;
        final first = tiles[tileIndex];
        final second =
            tileIndex + 1 < tiles.length ? tiles[tileIndex + 1] : null;

        return Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: first),
                if (second != null) ...[
                  SizedBox(width: spacing),
                  Expanded(child: second),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
