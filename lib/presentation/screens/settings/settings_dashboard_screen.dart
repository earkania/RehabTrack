import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/widgets/dashboard/module_grid.dart';
import 'package:rehab_track/presentation/widgets/dashboard/module_grid_tile.dart';

/// Settings landing dashboard.
///
/// Uses the same two-column large-icon module grid as the Health, Records, and
/// Profile dashboards. Destinations:
///
/// * **App Settings** — the full settings screen (reminders, notifications,
///   language, appearance, security, tests).
/// * **Backup & Restore** — placeholder for a future backup/restore module.
class SettingsDashboardScreen extends StatelessWidget {
  const SettingsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ModuleGrid(
        tiles: [
          ModuleGridTile(
            icon: const Icon(Icons.settings_outlined),
            label: l10n.appSettings,
            onTap: () => context.push(AppRoutes.settingsApp),
          ),
          ModuleGridTile(
            icon: const Icon(Icons.settings_backup_restore),
            label: l10n.backupAndRestore,
            onTap: () => context.push(AppRoutes.settingsBackupRestore),
          ),
        ],
      ),
    );
  }
}
