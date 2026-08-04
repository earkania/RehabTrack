import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/doctor_visit_provider.dart';
import 'package:rehab_track/presentation/widgets/dashboard/module_grid.dart';
import 'package:rehab_track/presentation/widgets/dashboard/module_grid_tile.dart';

class RecordsDashboardScreen extends ConsumerWidget {
  const RecordsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final upcomingCount = ref.watch(upcomingDoctorVisitCountProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.records)),
      body: ModuleGrid(
        tiles: [
          ModuleGridTile(
            icon: const Icon(Icons.science_outlined),
            label: l10n.labAnalyses,
            onTap: () => context.push(AppRoutes.recordsLabAnalyses),
          ),
          _DoctorVisitsTile(
            upcomingCount: upcomingCount,
            onTap: () => context.push(AppRoutes.recordsDoctorVisits),
          ),
          ModuleGridTile(
            icon: const Icon(Icons.assessment_outlined),
            label: l10n.reports,
            onTap: () => context.push(AppRoutes.recordsReports),
          ),
        ],
      ),
    );
  }
}

/// Doctor Visits module tile with a count badge overlaid at its top-right.
///
/// The badge is part of the tile's own visual composition (a [Stack]
/// overlay), so it never resizes the tile, adds a grid item, or shifts the
/// surrounding layout. It is excluded from the accessibility tree as a
/// separate control: the whole tile, including the badge area, is one
/// tappable button that opens Doctor Visits.
class _DoctorVisitsTile extends ModuleGridTile {
  final int upcomingCount;

  const _DoctorVisitsTile({
    required this.upcomingCount,
    required super.onTap,
  }) : super(
          icon: const Icon(Icons.medical_services_outlined),
          label: 'Doctor Visits',
        );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tile = ModuleGridTile(
      icon: const Icon(Icons.medical_services_outlined),
      label: l10n.doctorVisits,
      onTap: onTap,
    );

    if (upcomingCount <= 0) return tile;

    return Semantics(
      label: l10n.doctorVisitsUpcomingBadgeSemantics(upcomingCount),
      button: true,
      excludeSemantics: true,
      child: Stack(
        // Keep the badge from being clipped when it floats over the tile.
        clipBehavior: Clip.none,
        // Fill the grid cell so the tile keeps the exact same size as the
        // other dashboard tiles instead of shrinking to its content width.
        fit: StackFit.expand,
        children: [
          tile,
          Positioned(
            top: 4,
            right: 4,
            child: IgnorePointer(
              // IgnorePointer lets taps on the badge region reach the tile's
              // InkWell below, so the badge area opens Doctor Visits just like
              // the rest of the tile without adding a separate tap action.
              child: Badge(
                backgroundColor: Theme.of(context).colorScheme.primary,
                textColor: Theme.of(context).colorScheme.onPrimary,
                label: Text(
                  upcomingCount > 99 ? '99+' : '$upcomingCount',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
