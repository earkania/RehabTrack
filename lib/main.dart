import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'package:rehab_track/app.dart';
import 'package:rehab_track/presentation/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final container = ProviderContainer();

  // Initialize notification actions and schedule recovery at startup.
  // This must happen before runApp so that the callback is registered
  // before any notification can be received.
  container.read(notificationInitializerProvider);
  // Activate the reminder-toggle watcher so it reacts to changes.
  container.read(reminderToggleWatcherProvider);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const RehabTrackApp(),
    ),
  );
}
