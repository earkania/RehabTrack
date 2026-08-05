import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:rehab_track/app.dart';
import 'package:rehab_track/presentation/screens/health/health_dashboard_screen.dart';
import 'package:rehab_track/presentation/screens/profile/profile_dashboard_screen.dart';
import 'package:rehab_track/presentation/screens/records/records_dashboard_screen.dart';
import 'package:rehab_track/presentation/screens/settings/app_settings_screen.dart';
import 'package:rehab_track/presentation/screens/settings/backup_and_restore_screen.dart';
import 'package:rehab_track/presentation/screens/settings/settings_dashboard_screen.dart';
import 'package:rehab_track/presentation/screens/today/today_screen.dart';
import 'package:rehab_track/presentation/widgets/dashboard/module_grid.dart';
import 'package:rehab_track/presentation/widgets/dashboard/module_grid_tile.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    Brightness? brightness,
    List<Locale>? locales,
    Size? physicalSize,
    double? devicePixelRatio,
    double? textScaleFactor,
  }) async {
    addTearDown(tester.binding.platformDispatcher.clearAllTestValues);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    if (brightness != null) {
      tester.binding.platformDispatcher.platformBrightnessTestValue =
          brightness;
    }
    if (locales != null) {
      tester.binding.platformDispatcher.localesTestValue = locales;
    }
    if (physicalSize != null) {
      tester.view.physicalSize = physicalSize;
      tester.view.devicePixelRatio = devicePixelRatio ?? 1.0;
    }
    if (textScaleFactor != null) {
      tester.binding.platformDispatcher.textScaleFactorTestValue =
          textScaleFactor;
    }

    await tester.pumpWidget(const ProviderScope(child: RehabTrackApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> tapSettingsTab(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pump();
    await tester.pumpAndSettle();
  }

  GoRouter routerOf(WidgetTester tester) =>
      GoRouter.of(tester.element(find.byType(TodayScreen)));

  group('Settings dashboard navigation', () {
    testWidgets('bottom navigation has five destinations', (tester) async {
      await pumpApp(tester);

      // Today tab is selected; the other four show their outlined icons.
      expect(find.byIcon(Icons.today), findsWidgets);
      expect(find.byIcon(Icons.health_and_safety_outlined), findsOneWidget);
      expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('tapping Settings opens the Settings dashboard',
        (tester) async {
      await pumpApp(tester);
      await tapSettingsTab(tester);

      expect(find.byType(SettingsDashboardScreen), findsOneWidget);
      expect(find.text('App Settings'), findsOneWidget);
      expect(find.text('Backup & Restore'), findsOneWidget);
    });

    testWidgets('Settings dashboard uses the two-column module grid',
        (tester) async {
      await pumpApp(tester);
      await tapSettingsTab(tester);

      expect(find.byType(ModuleGrid), findsOneWidget);
      expect(find.byType(ModuleGridTile), findsNWidgets(2));

      final appRect = tester.getRect(
        find.widgetWithText(ModuleGridTile, 'App Settings'),
      );
      final backupRect = tester.getRect(
        find.widgetWithText(ModuleGridTile, 'Backup & Restore'),
      );
      expect(appRect.width, backupRect.width);
      expect(appRect.height, backupRect.height);
    });

    testWidgets('Settings dashboard does not show reminder controls directly',
        (tester) async {
      await pumpApp(tester);
      await tapSettingsTab(tester);

      expect(find.byType(SettingsDashboardScreen), findsOneWidget);
      expect(find.text('Medication reminders'), findsNothing);
      expect(find.text('Measurement reminders'), findsNothing);
      expect(find.text('Notification permission'), findsNothing);
    });

    testWidgets('App Settings tile opens the existing settings content',
        (tester) async {
      // Tall surface so the lazy ListView builds every settings section.
      await pumpApp(
        tester,
        physicalSize: const Size(800, 2800),
        devicePixelRatio: 1.0,
      );
      await tapSettingsTab(tester);

      await tester.tap(find.widgetWithText(ModuleGridTile, 'App Settings'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(AppSettingsScreen), findsOneWidget);

      // Reminder controls.
      expect(find.text('Medication reminders'), findsOneWidget);
      expect(find.text('Measurement reminders'), findsOneWidget);
      expect(find.text('Sound'), findsOneWidget);
      expect(find.text('Vibration'), findsOneWidget);
      expect(find.text('Default snooze duration'), findsOneWidget);

      // Language and appearance.
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('System default'), findsOneWidget);

      // Notification permission and exact alarm status.
      expect(find.text('Notification permission'), findsOneWidget);
      expect(find.text('Exact alarm access'), findsOneWidget);

      // Test reminder actions.
      expect(find.text('Test medication reminder'), findsOneWidget);
      expect(find.text('Test measurement reminder'), findsOneWidget);
    });

    testWidgets('Backup & Restore tile opens the backup screen', (tester) async {
      await pumpApp(tester);
      await tapSettingsTab(tester);

      await tester.tap(find.widgetWithText(ModuleGridTile, 'Backup & Restore'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(BackupAndRestoreScreen), findsOneWidget);
      expect(
        find.textContaining('Create a copy of all your data'),
        findsOneWidget,
      );
    });

    testWidgets('backup screen offers creation and shows restore as coming soon',
        (tester) async {
      await pumpApp(tester);
      await tapSettingsTab(tester);

      await tester.tap(find.widgetWithText(ModuleGridTile, 'Backup & Restore'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Create backup'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.text('Backup information'), findsOneWidget);
      expect(
        find.text('Restore will be available in a future update.'),
        findsOneWidget,
      );
    });

    testWidgets('back from App Settings returns to the Settings dashboard',
        (tester) async {
      await pumpApp(tester);
      await tapSettingsTab(tester);

      await tester.tap(find.widgetWithText(ModuleGridTile, 'App Settings'));
      await tester.pumpAndSettle();
      expect(find.byType(AppSettingsScreen), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(SettingsDashboardScreen), findsOneWidget);
      expect(find.byType(AppSettingsScreen), findsNothing);
    });

    testWidgets('back from Backup & Restore returns to the Settings dashboard',
        (tester) async {
      await pumpApp(tester);
      await tapSettingsTab(tester);

      await tester.tap(find.widgetWithText(ModuleGridTile, 'Backup & Restore'));
      await tester.pumpAndSettle();
      expect(find.byType(BackupAndRestoreScreen), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(SettingsDashboardScreen), findsOneWidget);
      expect(find.byType(BackupAndRestoreScreen), findsNothing);
    });

    testWidgets('switching among all tabs keeps a valid screen',
        (tester) async {
      await pumpApp(tester);

      Future<void> switchTo(IconData outlinedIcon, Type screenType) async {
        await tester.tap(find.byIcon(outlinedIcon));
        await tester.pump();
        await tester.pumpAndSettle();
        expect(find.byType(screenType), findsOneWidget);
        expect(tester.takeException(), isNull);
      }

      await switchTo(
        Icons.health_and_safety_outlined,
        HealthDashboardScreen,
      );
      await switchTo(Icons.folder_outlined, RecordsDashboardScreen);
      await switchTo(Icons.person_outlined, ProfileDashboardScreen);
      await switchTo(Icons.settings_outlined, SettingsDashboardScreen);
      await switchTo(Icons.today_outlined, TodayScreen);
    });
  });

  group('Settings routing', () {
    testWidgets('/settings opens the dashboard', (tester) async {
      await pumpApp(tester);
      routerOf(tester).go('/settings');
      await tester.pumpAndSettle();

      expect(find.byType(SettingsDashboardScreen), findsOneWidget);
    });

    testWidgets('/settings/app opens App Settings', (tester) async {
      await pumpApp(tester);
      routerOf(tester).go('/settings/app');
      await tester.pumpAndSettle();

      expect(find.byType(AppSettingsScreen), findsOneWidget);
      expect(find.text('Medication reminders'), findsOneWidget);
    });

    testWidgets('/settings/backup-restore opens the backup screen',
        (tester) async {
      await pumpApp(tester);
      routerOf(tester).go('/settings/backup-restore');
      await tester.pumpAndSettle();

      expect(find.byType(BackupAndRestoreScreen), findsOneWidget);
    });

    testWidgets('unknown Settings child route fails safely', (tester) async {
      await pumpApp(tester);
      routerOf(tester).go('/settings/does-not-exist');
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Invalid page'), findsOneWidget);
    });
  });

  group('Settings dashboard themes and layouts', () {
    testWidgets('light theme works', (tester) async {
      await pumpApp(tester, brightness: Brightness.light);
      await tapSettingsTab(tester);

      expect(find.byType(SettingsDashboardScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dark theme works', (tester) async {
      await pumpApp(tester, brightness: Brightness.dark);
      await tapSettingsTab(tester);

      expect(find.byType(SettingsDashboardScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Georgian layout works without overflow', (tester) async {
      await pumpApp(tester, locales: const [Locale('ka')]);
      await tapSettingsTab(tester);

      expect(find.text('აპლიკაციის პარამეტრები'), findsOneWidget);
      expect(find.text('სარეზერვო ასლი და აღდგენა'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('narrow Pixel-sized screen has no overflow', (tester) async {
      await pumpApp(
        tester,
        physicalSize: const Size(1080, 2400),
        devicePixelRatio: 2.625,
      );
      await tapSettingsTab(tester);

      expect(find.byType(SettingsDashboardScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('large text has no overflow on dashboard and children',
        (tester) async {
      await pumpApp(tester, textScaleFactor: 2.0);
      await tapSettingsTab(tester);

      await tester.tap(find.widgetWithText(ModuleGridTile, 'Backup & Restore'));
      await tester.pumpAndSettle();
      expect(find.byType(BackupAndRestoreScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
