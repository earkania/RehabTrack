import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/core/router/app_router.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';
import 'package:rehab_track/presentation/widgets/today/today_agenda_item.dart';

Widget _buildShellApp({required int initialIndex}) {
  final locations = ['/', '/health', '/records', '/profile', '/settings'];
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: locations[initialIndex],
    routes: [
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => ScaffoldWithNavBar(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: _TodayWithAgenda(),
            ),
          ),
          GoRoute(
            path: '/health',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: _FakeScreen(label: 'Health'),
            ),
          ),
          GoRoute(
            path: '/records',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: _FakeScreen(label: 'Records'),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: _FakeScreen(label: 'Profile'),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: _FakeScreen(label: 'Settings'),
            ),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      selectedAgendaDateProvider.overrideWith((ref) => DateTime(2000, 1, 1)),
      todayAutoRefreshProvider.overrideWith((ref) {}),
      currentMinuteProvider.overrideWith((ref) => DateTime(2000, 1, 1)),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

class _TodayWithAgenda extends StatelessWidget {
  const _TodayWithAgenda();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final items = [
      TodayAgendaItem(
        id: 'med_1',
        type: TodayAgendaItemType.medication,
        sourceScheduleId: 1,
        scheduledDateTime: now.add(const Duration(hours: 1)),
        title: 'Concor 5mg',
        status: TodayAgendaItemStatus.upcoming,
      ),
      TodayAgendaItem(
        id: 'meas_1',
        type: TodayAgendaItemType.measurement,
        sourceScheduleId: 2,
        scheduledDateTime: now.add(const Duration(hours: 2)),
        title: 'Blood Pressure',
        measurementTypeKey: 'blood_pressure',
        status: TodayAgendaItemStatus.upcoming,
      ),
    ];

    return ListView(
      children: items.map((item) => TodayAgendaItemWidget(item: item)).toList(),
    );
  }
}

class _FakeScreen extends StatelessWidget {
  final String label;
  const _FakeScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(label));
  }
}

/// Tap a nav tab by its unselected icon.
/// The _CenteredNavigationBar uses Icons.xxx_outlined for unselected tabs.
Finder _navIcon(IconData icon) => find.byIcon(icon);

void main() {
  group('Popup dismissal on tab switch', () {
    testWidgets('popup closes when switching to Health', (tester) async {
      await tester.pumpWidget(_buildShellApp(initialIndex: 0));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      expect(find.text('Mark as Taken'), findsOneWidget);

      await tester.tap(_navIcon(Icons.health_and_safety_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Mark as Taken'), findsNothing);
    });

    testWidgets('popup closes when switching to Records', (tester) async {
      await tester.pumpWidget(_buildShellApp(initialIndex: 0));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      expect(find.text('Mark as Taken'), findsOneWidget);

      await tester.tap(_navIcon(Icons.folder_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Mark as Taken'), findsNothing);
    });

    testWidgets('popup closes when switching to Profile', (tester) async {
      await tester.pumpWidget(_buildShellApp(initialIndex: 0));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      expect(find.text('Mark as Taken'), findsOneWidget);

      await tester.tap(_navIcon(Icons.person_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Mark as Taken'), findsNothing);
    });

    testWidgets('popup closes when switching to Settings', (tester) async {
      await tester.pumpWidget(_buildShellApp(initialIndex: 0));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      expect(find.text('Mark as Taken'), findsOneWidget);

      await tester.tap(_navIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Mark as Taken'), findsNothing);
    });

    testWidgets('switching tabs does not pop the destination page', (tester) async {
      await tester.pumpWidget(_buildShellApp(initialIndex: 0));
      await tester.pumpAndSettle();

      await tester.tap(_navIcon(Icons.health_and_safety_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Health'), findsWidgets);

      await tester.tap(_navIcon(Icons.folder_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Records'), findsWidgets);

      await tester.tap(_navIcon(Icons.today_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(TodayAgendaItemWidget), findsWidgets);
    });

    testWidgets('returning to Today does not reopen popup', (tester) async {
      await tester.pumpWidget(_buildShellApp(initialIndex: 0));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      expect(find.text('Mark as Taken'), findsOneWidget);

      await tester.tap(_navIcon(Icons.health_and_safety_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Mark as Taken'), findsNothing);

      await tester.tap(_navIcon(Icons.today_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Mark as Taken'), findsNothing);
    });

    testWidgets('tapping outside closes popup', (tester) async {
      await tester.pumpWidget(_buildShellApp(initialIndex: 0));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      expect(find.text('Mark as Taken'), findsOneWidget);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Mark as Taken'), findsNothing);
    });

    testWidgets('selecting popup action closes popup', (tester) async {
      await tester.pumpWidget(_buildShellApp(initialIndex: 0));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      expect(find.text('Mark as Taken'), findsOneWidget);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Mark as Taken'), findsNothing);
      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('widget disposal with open popup does not throw', (tester) async {
      await tester.pumpWidget(_buildShellApp(initialIndex: 0));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      expect(find.text('Mark as Taken'), findsOneWidget);

      await tester.tap(_navIcon(Icons.health_and_safety_outlined));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
