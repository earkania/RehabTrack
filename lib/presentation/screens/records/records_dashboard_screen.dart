import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/widgets/dashboard/module_grid.dart';
import 'package:rehab_track/presentation/widgets/dashboard/module_grid_tile.dart';

class RecordsDashboardScreen extends StatelessWidget {
  const RecordsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.records)),
      body: ModuleGrid(
        tiles: [
          ModuleGridTile(
            icon: const Icon(Icons.science_outlined),
            label: l10n.labAnalyses,
            onTap: () => context.push(AppRoutes.recordsLabAnalyses),
          ),
          ModuleGridTile(
            icon: const Icon(Icons.medical_services_outlined),
            label: l10n.doctorVisits,
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
