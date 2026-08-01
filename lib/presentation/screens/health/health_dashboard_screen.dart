import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/widgets/dashboard/module_grid.dart';
import 'package:rehab_track/presentation/widgets/dashboard/module_grid_tile.dart';

class HealthDashboardScreen extends StatelessWidget {
  const HealthDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.health)),
      body: ModuleGrid(
        tiles: [
          ModuleGridTile(
            icon: const Icon(Icons.medication_outlined),
            label: l10n.medications,
            onTap: () => context.push(AppRoutes.healthMedications),
          ),
          ModuleGridTile(
            icon: const Icon(Icons.monitor_heart_outlined),
            label: l10n.measurements,
            onTap: () => context.push(AppRoutes.healthMeasurements),
          ),
          ModuleGridTile(
            icon: const Icon(Icons.directions_walk_outlined),
            label: l10n.activities,
            onTap: () => context.push(AppRoutes.healthActivities),
          ),
          ModuleGridTile(
            icon: const Icon(Icons.restaurant),
            label: l10n.diet,
            onTap: () => context.push(AppRoutes.healthDiet),
          ),
        ],
      ),
    );
  }
}
