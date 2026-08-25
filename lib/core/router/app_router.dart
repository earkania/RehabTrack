import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/domain/entities/report_data.dart';
import 'package:rehab_track/l10n/app_localizations.dart';

import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/presentation/screens/records/lab_analyses_screen.dart';
import 'package:rehab_track/presentation/screens/records/lab_analysis_form_screen.dart';
import 'package:rehab_track/presentation/screens/records/lab_analysis_details_screen.dart';
import 'package:rehab_track/presentation/screens/records/archived_lab_analyses_screen.dart';
import 'package:rehab_track/presentation/screens/records/doctor_prescriptions_screen.dart';
import 'package:rehab_track/presentation/screens/records/doctor_prescription_form_screen.dart';
import 'package:rehab_track/presentation/screens/records/doctor_prescription_details_screen.dart';
import 'package:rehab_track/presentation/screens/records/archived_doctor_prescriptions_screen.dart';
import 'package:rehab_track/presentation/screens/reports/report_config_screen.dart';
import 'package:rehab_track/presentation/screens/reports/report_preview_screen.dart';
import 'package:rehab_track/presentation/screens/today/today_screen.dart';
import 'package:rehab_track/presentation/screens/health/health_dashboard_screen.dart';
import 'package:rehab_track/presentation/screens/health/measurements_screen.dart';
import 'package:rehab_track/presentation/screens/health/diet_screen.dart';
import 'package:rehab_track/presentation/screens/health/diet_food_form_screen.dart';
import 'package:rehab_track/presentation/screens/health/diet_food_details_screen.dart';
import 'package:rehab_track/presentation/screens/health/diet_guidance_form_screen.dart';
import 'package:rehab_track/presentation/screens/health/diet_guidance_details_screen.dart';
import 'package:rehab_track/presentation/screens/records/records_dashboard_screen.dart';
import 'package:rehab_track/presentation/screens/records/doctor_visits_screen.dart';
import 'package:rehab_track/presentation/screens/records/doctor_visit_form_screen.dart';
import 'package:rehab_track/presentation/screens/records/doctor_visit_details_screen.dart';
import 'package:rehab_track/presentation/screens/activities/activity_list_screen.dart';
import 'package:rehab_track/presentation/screens/activities/activity_form_screen.dart';
import 'package:rehab_track/presentation/screens/activities/activity_session_screen.dart';
import 'package:rehab_track/presentation/screens/activities/activity_history_screen.dart';
import 'package:rehab_track/presentation/screens/activities/activity_history_details_screen.dart';
import 'package:rehab_track/presentation/screens/profile/profile_dashboard_screen.dart';
import 'package:rehab_track/presentation/screens/profile/care_contacts_screen.dart';
import 'package:rehab_track/presentation/screens/profile/add_care_contact_screen.dart';
import 'package:rehab_track/presentation/screens/profile/edit_care_contact_screen.dart';
import 'package:rehab_track/presentation/screens/profile/care_contact_details_screen.dart';
import 'package:rehab_track/presentation/screens/activities/medication_list_screen.dart';
import 'package:rehab_track/presentation/screens/activities/add_medication_screen.dart';
import 'package:rehab_track/presentation/widgets/medication/medication_form.dart';
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
import 'package:rehab_track/presentation/screens/health/measurement_schedule_list_screen.dart';
import 'package:rehab_track/presentation/screens/health/reference_range_screen.dart';
import 'package:rehab_track/presentation/screens/settings/settings_dashboard_screen.dart';
import 'package:rehab_track/presentation/screens/settings/app_settings_screen.dart';
import 'package:rehab_track/presentation/screens/settings/backup_and_restore_screen.dart';
import 'package:rehab_track/presentation/screens/settings/manage_backups_screen.dart';
import 'package:rehab_track/presentation/screens/settings/patient_profile_view_screen.dart';
import 'package:rehab_track/presentation/screens/settings/patient_profile_edit_screen.dart';
import 'package:rehab_track/presentation/screens/settings/notification_diagnostics_screen.dart';
import 'package:rehab_track/presentation/screens/settings/alarm_style_screen.dart';
import 'package:rehab_track/presentation/screens/common/module_placeholder_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      return RouteRedirector.redirect(state.uri.toString());
    },
    errorBuilder: (context, state) => const _InvalidRouteScreen(),
    routes: [
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TodayScreen()),
          ),
          GoRoute(
            path: AppRoutes.health,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HealthDashboardScreen()),
          ),
          GoRoute(
            path: AppRoutes.records,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: RecordsDashboardScreen()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileDashboardScreen()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsDashboardScreen()),
          ),
        ],
      ),
      // Alarm-style full-screen presentation (top-level: no nav bar, full-screen)
      GoRoute(
        path: AppRoutes.alarm,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: AlarmStyleScreen()),
      ),
      // Health
      GoRoute(
        path: AppRoutes.healthMedications,
        builder: (context, state) => const MedicationListScreen(),
      ),
      GoRoute(
        path: AppRoutes.healthMeasurements,
        builder: (context, state) => const MeasurementsScreen(),
      ),
      GoRoute(
        path: AppRoutes.healthActivities,
        builder: (context, state) => const ActivityListScreen(),
      ),
      GoRoute(
        path: AppRoutes.activityAdd,
        builder: (context, state) => const ActivityFormScreen(),
      ),
      GoRoute(
        path: '/health/activities/:id/edit',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const _InvalidRouteScreen();
          }
          return ActivityFormScreen(activityId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.activitySessionActive,
        builder: (context, state) => const ActivitySessionScreen(),
      ),
      GoRoute(
        path: '/health/activities/:id/session',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const _InvalidRouteScreen();
          }
          return ActivitySessionScreen(activityId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.activityHistory,
        builder: (context, state) => const ActivityHistoryScreen(),
      ),
      GoRoute(
        path: '/health/activities/history/:sessionId',
        builder: (context, state) {
          final sessionId = int.tryParse(
            state.pathParameters['sessionId'] ?? '',
          );
          if (sessionId == null) {
            return const _InvalidRouteScreen();
          }
          return ActivityHistoryDetailsScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: AppRoutes.healthDiet,
        builder: (context, state) => const DietScreen(),
      ),
      GoRoute(
        path: AppRoutes.healthDietFoodsAdd,
        builder: (context, state) => const DietFoodFormScreen(),
      ),
      GoRoute(
        path: '/health/diet/foods/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const _InvalidRouteScreen();
          }
          return DietFoodDetailsScreen(foodId: id);
        },
      ),
      GoRoute(
        path: '/health/diet/foods/:id/edit',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const _InvalidRouteScreen();
          }
          return DietFoodFormScreen(foodId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.healthDietGuidanceAdd,
        builder: (context, state) => const DietGuidanceFormScreen(),
      ),
      GoRoute(
        path: '/health/diet/guidance/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const _InvalidRouteScreen();
          }
          return DietGuidanceDetailsScreen(ruleId: id);
        },
      ),
      GoRoute(
        path: '/health/diet/guidance/:id/edit',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const _InvalidRouteScreen();
          }
          return DietGuidanceFormScreen(ruleId: id);
        },
      ),
      // Records
      GoRoute(
        path: AppRoutes.recordsLabAnalyses,
        builder: (context, state) => const LabAnalysesScreen(),
      ),
      GoRoute(
        path: AppRoutes.recordsLabAnalysesAdd,
        builder: (context, state) => const LabAnalysisFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.recordsLabAnalysesArchived,
        builder: (context, state) => const ArchivedLabAnalysesScreen(),
      ),
      GoRoute(
        path: '/records/lab-analyses/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const _InvalidRouteScreen();
          }
          return LabAnalysisDetailsScreen(analysisId: id);
        },
      ),
      GoRoute(
        path: '/records/lab-analyses/:id/edit',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const _InvalidRouteScreen();
          }
          return LabAnalysisFormScreen(analysisId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.recordsDoctorVisits,
        builder: (context, state) => const DoctorVisitsScreen(),
      ),
      GoRoute(
        path: AppRoutes.doctorVisitAdd,
        builder: (context, state) => const DoctorVisitFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.recordsPrescriptions,
        builder: (context, state) => const DoctorPrescriptionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.recordsPrescriptionsAdd,
        builder: (context, state) => const DoctorPrescriptionFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.recordsPrescriptionsArchived,
        builder: (context, state) => const ArchivedDoctorPrescriptionsScreen(),
      ),
      GoRoute(
        path: '/records/prescriptions/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const _InvalidRouteScreen();
          }
          return DoctorPrescriptionDetailsScreen(prescriptionId: id);
        },
      ),
      GoRoute(
        path: '/records/prescriptions/:id/edit',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const _InvalidRouteScreen();
          }
          return DoctorPrescriptionFormScreen(prescriptionId: id);
        },
      ),
      GoRoute(
        path: '/records/doctor-visits/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const _InvalidRouteScreen();
          }
          return DoctorVisitDetailsScreen(visitId: id);
        },
      ),
      GoRoute(
        path: '/records/doctor-visits/:id/edit',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const _InvalidRouteScreen();
          }
          return DoctorVisitFormScreen(visitId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.recordsReports,
        builder: (context, state) => const ReportConfigScreen(),
      ),
      GoRoute(
        path: AppRoutes.recordsReportsPreview,
        builder: (context, state) {
          final data = state.extra;
          if (data is ReportData) {
            return ReportPreviewScreen(data: data);
          }
          return const ReportConfigScreen();
        },
      ),
      // Profile
      GoRoute(
        path: AppRoutes.patientProfile,
        builder: (context, state) => const PatientProfileViewScreen(),
      ),
      GoRoute(
        path: AppRoutes.patientProfileEdit,
        builder: (context, state) => const PatientProfileEditScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileCareContacts,
        builder: (context, state) => const CareContactsScreen(),
      ),
      GoRoute(
        path: AppRoutes.careContactArchived,
        builder: (context, state) =>
            const CareContactsScreen(startArchived: true),
      ),
      GoRoute(
        path: AppRoutes.careContactAdd,
        builder: (context, state) => const AddCareContactScreen(),
      ),
      GoRoute(
        path: '/profile/contacts/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const _InvalidRouteScreen();
          }
          return CareContactDetailsScreen(contactId: id);
        },
      ),
      GoRoute(
        path: '/profile/contacts/:id/edit',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const _InvalidRouteScreen();
          }
          return EditCareContactScreen(contactId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.profileDoctors,
        builder: (context, state) => ModulePlaceholderScreen(
          icon: Icons.badge_outlined,
          title: AppLocalizations.of(context)!.doctors,
        ),
      ),
      GoRoute(
        path: AppRoutes.profileEmergencyContacts,
        builder: (context, state) => ModulePlaceholderScreen(
          icon: Icons.emergency_outlined,
          title: AppLocalizations.of(context)!.emergencyContacts,
        ),
      ),
      GoRoute(
        path: AppRoutes.profileMedicalNotes,
        builder: (context, state) => ModulePlaceholderScreen(
          icon: Icons.note_alt_outlined,
          title: AppLocalizations.of(context)!.medicalNotes,
        ),
      ),
      GoRoute(
        path: AppRoutes.medicationAdd,
        builder: (context, state) => AddMedicationScreen(
          initialData: state.extra as MedicationFormData?,
        ),
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
          final scheduleId = int.tryParse(
            state.pathParameters['scheduleId'] ?? '',
          );
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
          final alternativeId = int.tryParse(
            state.pathParameters['alternativeId'] ?? '',
          );
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
          final typeId = int.tryParse(state.pathParameters['typeId'] ?? '');
          if (typeId == null) {
            return const _InvalidRouteScreen();
          }
          final extra = state.extra as RecordNowExtra?;
          return MeasurementEntryScreen(
            measurementTypeId: typeId,
            recordNowExtra: extra,
          );
        },
      ),
      GoRoute(
        path: '/measurements/measurement/:typeId/history',
        builder: (context, state) {
          final typeId = int.tryParse(state.pathParameters['typeId'] ?? '');
          if (typeId == null) {
            return const _InvalidRouteScreen();
          }
          return MeasurementHistoryScreen(measurementTypeId: typeId);
        },
      ),
      GoRoute(
        path: '/measurements/measurement/:typeId/trends',
        builder: (context, state) {
          final typeId = int.tryParse(state.pathParameters['typeId'] ?? '');
          if (typeId == null) {
            return const _InvalidRouteScreen();
          }
          return MeasurementTrendsScreen(measurementTypeId: typeId);
        },
      ),
      GoRoute(
        path: '/measurements/measurement/record/:recordId/edit',
        builder: (context, state) {
          final recordId = int.tryParse(state.pathParameters['recordId'] ?? '');
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
        path: AppRoutes.settingsApp,
        builder: (context, state) => const AppSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsBackupRestore,
        builder: (context, state) => const BackupAndRestoreScreen(),
      ),
      GoRoute(
        path: AppRoutes.manageBackups,
        builder: (context, state) => const ManageBackupsScreen(),
      ),
      GoRoute(
        path: '/settings/notification-diagnostics',
        builder: (context, state) => const NotificationDiagnosticsScreen(),
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
        path: '/measurements/measurement/:typeId/schedules',
        builder: (context, state) {
          final typeId = int.tryParse(state.pathParameters['typeId'] ?? '');
          if (typeId == null) {
            return const _InvalidRouteScreen();
          }
          return MeasurementScheduleListScreen(measurementTypeId: typeId);
        },
      ),
      GoRoute(
        path: '/measurements/measurement/:typeId/schedule/add',
        builder: (context, state) {
          final typeId = int.tryParse(state.pathParameters['typeId'] ?? '');
          if (typeId == null) {
            return const _InvalidRouteScreen();
          }
          return MeasurementScheduleScreen(measurementTypeId: typeId);
        },
      ),
      GoRoute(
        path: '/measurements/measurement/:typeId/schedule/:scheduleId/edit',
        builder: (context, state) {
          final typeId = int.tryParse(state.pathParameters['typeId'] ?? '');
          final scheduleId = int.tryParse(
            state.pathParameters['scheduleId'] ?? '',
          );
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
    if (location.startsWith('/health')) return 1;
    if (location.startsWith('/records')) return 2;
    if (location.startsWith('/profile')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    // Dismiss any open popup menu before switching tabs.
    // PopupMenuButton pushes a PopupRoute onto the shell navigator;
    // GoRouter.context.go does not pop modal routes, so we must do it explicitly.
    final navigator = shellNavigatorKey.currentState;
    if (navigator != null) {
      navigator.popUntil((route) => route is! PopupRoute);
    }

    switch (index) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        context.go(AppRoutes.health);
      case 2:
        context.go(AppRoutes.records);
      case 3:
        context.go(AppRoutes.profile);
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
            icon: Icons.health_and_safety_outlined,
            selectedIcon: Icons.health_and_safety,
            label: l10n.health,
          ),
          _NavItem(
            icon: Icons.folder_outlined,
            selectedIcon: Icons.folder,
            label: l10n.records,
          ),
          _NavItem(
            icon: Icons.person_outlined,
            selectedIcon: Icons.person,
            label: l10n.profile,
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
                                        .copyWith(color: colorScheme.onSurface),
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
