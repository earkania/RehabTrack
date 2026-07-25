import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/l10n/app_localizations.dart';

import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/presentation/screens/today/today_screen.dart';
import 'package:rehab_track/presentation/screens/health/health_screen.dart';
import 'package:rehab_track/presentation/screens/activities/medication_list_screen.dart';
import 'package:rehab_track/presentation/screens/activities/add_medication_screen.dart';
import 'package:rehab_track/presentation/screens/activities/edit_medication_screen.dart';
import 'package:rehab_track/presentation/screens/activities/medication_detail_screen.dart';
import 'package:rehab_track/presentation/screens/activities/add_schedule_screen.dart';
import 'package:rehab_track/presentation/screens/activities/edit_schedule_screen.dart';
import 'package:rehab_track/presentation/screens/activities/add_alternative_screen.dart';
import 'package:rehab_track/presentation/screens/activities/edit_alternative_screen.dart';
import 'package:rehab_track/presentation/screens/activities/medication_history_screen.dart';
import 'package:rehab_track/presentation/screens/health/measurement_entry_screen.dart';
import 'package:rehab_track/presentation/screens/health/measurement_edit_screen.dart';
import 'package:rehab_track/presentation/screens/health/measurement_history_screen.dart';
import 'package:rehab_track/presentation/screens/health/measurement_trends_screen.dart';
import 'package:rehab_track/presentation/screens/health/measurement_schedule_screen.dart';
import 'package:rehab_track/presentation/screens/health/reference_range_screen.dart';
import 'package:rehab_track/presentation/screens/records/records_screen.dart';
import 'package:rehab_track/presentation/screens/settings/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      return RouteRedirector.redirect(state.uri.toString());
    },
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TodayScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.measurements,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HealthScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.medications,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MedicationListScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.records,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RecordsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.medicationAdd,
        builder: (context, state) => const AddMedicationScreen(),
      ),
      GoRoute(
        path: '/medications/medication/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const _InvalidRouteScreen();
          }
          return MedicationDetailScreen(medicationId: id);
        },
      ),
      GoRoute(
        path: '/medications/medication/:id/history',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const _InvalidRouteScreen();
          }
          return MedicationHistoryScreen(medicationId: id);
        },
      ),
      GoRoute(
        path: '/medications/medication/:id/edit',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const _InvalidRouteScreen();
          }
          return EditMedicationScreen(medicationId: id);
        },
      ),
      GoRoute(
        path: '/medications/medication/:id/schedule/add',
        builder: (context, state) {
          final medicationId = int.tryParse(state.pathParameters['id'] ?? '');
          if (medicationId == null) {
            return const _InvalidRouteScreen();
          }
          return AddScheduleScreen(medicationId: medicationId);
        },
      ),
      GoRoute(
        path: '/medications/medication/:id/schedule/:scheduleId/edit',
        builder: (context, state) {
          final medicationId = int.tryParse(state.pathParameters['id'] ?? '');
          final scheduleId =
              int.tryParse(state.pathParameters['scheduleId'] ?? '');
          if (medicationId == null || scheduleId == null) {
            return const _InvalidRouteScreen();
          }
          return EditScheduleScreen(
            medicationId: medicationId,
            scheduleId: scheduleId,
          );
        },
      ),
      GoRoute(
        path: '/medications/medication/:id/alternative/add',
        builder: (context, state) {
          final medicationId = int.tryParse(state.pathParameters['id'] ?? '');
          if (medicationId == null) {
            return const _InvalidRouteScreen();
          }
          return AddAlternativeScreen(medicationId: medicationId);
        },
      ),
      GoRoute(
        path: '/medications/medication/:id/alternative/:alternativeId/edit',
        builder: (context, state) {
          final medicationId = int.tryParse(state.pathParameters['id'] ?? '');
          final alternativeId =
              int.tryParse(state.pathParameters['alternativeId'] ?? '');
          if (medicationId == null || alternativeId == null) {
            return const _InvalidRouteScreen();
          }
          return EditAlternativeScreen(
            medicationId: medicationId,
            alternativeId: alternativeId,
          );
        },
      ),
      GoRoute(
        path: '/measurements/measurement/:typeId/add',
        builder: (context, state) {
          final typeId =
              int.tryParse(state.pathParameters['typeId'] ?? '');
          if (typeId == null) {
            return const _InvalidRouteScreen();
          }
          return MeasurementEntryScreen(measurementTypeId: typeId);
        },
      ),
      GoRoute(
        path: '/measurements/measurement/:typeId/history',
        builder: (context, state) {
          final typeId =
              int.tryParse(state.pathParameters['typeId'] ?? '');
          if (typeId == null) {
            return const _InvalidRouteScreen();
          }
          return MeasurementHistoryScreen(measurementTypeId: typeId);
        },
      ),
      GoRoute(
        path: '/measurements/measurement/:typeId/trends',
        builder: (context, state) {
          final typeId =
              int.tryParse(state.pathParameters['typeId'] ?? '');
          if (typeId == null) {
            return const _InvalidRouteScreen();
          }
          return MeasurementTrendsScreen(measurementTypeId: typeId);
        },
      ),
      GoRoute(
        path: '/measurements/measurement/record/:recordId/edit',
        builder: (context, state) {
          final recordId =
              int.tryParse(state.pathParameters['recordId'] ?? '');
          if (recordId == null) {
            return const _InvalidRouteScreen();
          }
          return MeasurementEditScreen(recordId: recordId);
        },
      ),
      GoRoute(
        path: AppRoutes.measurementRanges,
        builder: (context, state) => const ReferenceRangeScreen(),
      ),
      GoRoute(
        path: '/measurements/ranges/:typeKey',
        builder: (context, state) {
          final typeKey = state.pathParameters['typeKey'] ?? '';
          if (typeKey.isEmpty) {
            return const _InvalidRouteScreen();
          }
          return TypeRangeDetailScreen(typeKey: typeKey);
        },
      ),
      GoRoute(
        path: '/measurements/measurement/:typeId/schedule/add',
        builder: (context, state) {
          final typeId =
              int.tryParse(state.pathParameters['typeId'] ?? '');
          if (typeId == null) {
            return const _InvalidRouteScreen();
          }
          return MeasurementScheduleScreen(measurementTypeId: typeId);
        },
      ),
      GoRoute(
        path: '/measurements/measurement/:typeId/schedule/:scheduleId/edit',
        builder: (context, state) {
          final typeId =
              int.tryParse(state.pathParameters['typeId'] ?? '');
          final scheduleId =
              int.tryParse(state.pathParameters['scheduleId'] ?? '');
          if (typeId == null || scheduleId == null) {
            return const _InvalidRouteScreen();
          }
          return MeasurementScheduleScreen(
            measurementTypeId: typeId,
            scheduleId: scheduleId,
          );
        },
      ),
    ],
  );
});

class _InvalidRouteScreen extends StatelessWidget {
  const _InvalidRouteScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.error)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.invalidRoute,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () => context.go('/'),
              child: Text(l10n.back),
            ),
          ],
        ),
      ),
    );
  }
}

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/measurements')) return 1;
    if (location.startsWith('/medications')) return 2;
    if (location.startsWith('/records')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        context.go(AppRoutes.measurements);
      case 2:
        context.go(AppRoutes.medications);
      case 3:
        context.go(AppRoutes.records);
      case 4:
        context.go(AppRoutes.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: child,
      bottomNavigationBar: _CenteredNavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onItemTapped: (index) => _onItemTapped(context, index),
        items: [
          _NavItem(
            icon: Icons.today_outlined,
            selectedIcon: Icons.today,
            label: l10n.today,
          ),
          _NavItem(
            icon: Icons.monitor_heart_outlined,
            selectedIcon: Icons.monitor_heart,
            label: l10n.measurements,
          ),
          _NavItem(
            icon: Icons.medication_outlined,
            selectedIcon: Icons.medication,
            label: l10n.medications,
          ),
          _NavItem(
            icon: Icons.folder_outlined,
            selectedIcon: Icons.folder,
            label: l10n.records,
          ),
          _NavItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class _CenteredNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final List<_NavItem> items;

  const _CenteredNavigationBar({
    required this.selectedIndex,
    required this.onItemTapped,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark
          ? colorScheme.surfaceContainer
          : colorScheme.surfaceContainerLow,
      elevation: 3,
      child: SafeArea(
        child: SizedBox(
          height: 80,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == selectedIndex;

              return Expanded(
                child: InkWell(
                  onTap: () => onItemTapped(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 64,
                        height: 32,
                        child: Center(
                          child: isSelected
                              ? Icon(item.selectedIcon, size: 24)
                              : Icon(item.icon, size: 24),
                        ),
                      ),
                      SizedBox(
                        height: isSelected ? 36 : 0,
                        child: isSelected
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Text(
                                    item.label,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.visible,
                                    style: theme.textTheme.labelMedium!
                                        .copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
