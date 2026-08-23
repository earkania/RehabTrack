import 'package:flutter/material.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rehab_track/core/theme/app_theme.dart';
import 'package:rehab_track/core/router/app_router.dart';
import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/presentation/providers/locale_provider.dart';
import 'package:rehab_track/presentation/providers/notification_provider.dart';

class RehabTrackApp extends ConsumerStatefulWidget {
  const RehabTrackApp({super.key});

  @override
  ConsumerState<RehabTrackApp> createState() => _RehabTrackAppState();
}

class _RehabTrackAppState extends ConsumerState<RehabTrackApp> {
  @override
  void initState() {
    super.initState();
    // Run the cold-start Alarm-style check after the first frame, when the
    // router is attached and the persisted reminder style is hydrated (main()
    // awaits _warmUpPersistedSettings before runApp). The notification
    // initializer intentionally does not do this during startup because the
    // initializer provider can be disposed before the style loads.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref
            .read(notificationActionBridgeProvider)
            .processAppLaunchAlarmPresentation();
      } catch (e, stack) {
        debugPrint('[RehabTrackApp] cold-start alarm presentation ERROR: $e');
        debugPrint('[RehabTrackApp] $stack');
      }
      _presentActiveAlarmIfNeeded();
    });
  }

  void _presentActiveAlarmIfNeeded() {
    final presentation = ref.read(activeAlarmPresentationProvider);
    if (presentation == null) return;
    final router = ref.read(routerProvider);
    // NOTE: currentConfiguration.uri does NOT reflect push()ed routes
    // (imperative matches are excluded), so it stays '/' after onAlarmPresent
    // pushed the alarm route. Comparing against it made this method push a
    // SECOND AlarmStyleScreen on every cold start; the buried duplicate then
    // fought the top one over the shared presentation. Compare the top-most
    // matched location instead.
    final config = router.routerDelegate.currentConfiguration;
    final topPath = config.isEmpty ? '' : config.last.matchedLocation;
    if (topPath == AppRoutes.alarm) return;
    router.push(AppRoutes.alarm);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'RehabTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}