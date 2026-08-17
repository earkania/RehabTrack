import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/data/services/notification/alarm_style_capability_service.dart';
import 'package:rehab_track/data/services/notification/notification_service.dart';
import 'package:rehab_track/domain/entities/alarm_sound_selection.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/notification_provider.dart';
import 'package:rehab_track/presentation/screens/settings/app_settings_screen.dart';

class FakeSettingsRepo implements SettingsRepository {
  final Map<String, String> _store = {};

  @override
  Future<String?> getValue(String key) async => _store[key];

  @override
  Future<void> setValue(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
  }

  @override
  Stream<Map<String, String>> watchAll() async* {
    yield Map.from(_store);
  }

  @override
  Future<Map<String, String>> getAll() async => Map.from(_store);
}

class FakeNotificationServiceForAlarmSound extends NotificationService {
  FakeNotificationServiceForAlarmSound({this.pickedSound});

  final AlarmSoundSelection? pickedSound;

  int previewStartedCount = 0;
  int previewStoppedCount = 0;

  @override
  bool get isInitialized => true;

  @override
  Future<bool> initialize() async => true;

  @override
  Future<bool> hasNotificationPermission() async => true;

  @override
  Future<bool> hasExactAlarmPermission() async => true;

  @override
  Future<AlarmSoundSelection?> pickAlarmSound({String? currentUri}) async =>
      pickedSound;

  @override
  Future<bool> startAlarmSoundPreview({String? uri}) async {
    previewStartedCount++;
    return true;
  }

  @override
  Future<void> stopAlarmSoundPreview() async {
    previewStoppedCount++;
  }
}

Widget _buildApp({
  required FakeSettingsRepo settings,
  required FakeNotificationServiceForAlarmSound service,
}) {
  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(settings),
      notificationServiceProvider.overrideWithValue(service),
      alarmStyleCapabilityProvider.overrideWith((ref) async =>
          const AlarmStyleCapability(
            status: AlarmStyleCapabilityStatus.available,
            fullScreenAllowed: true,
            notificationPermission: true,
            exactAlarmAccess: true,
            alarmChannelEnabled: true,
          )),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AppSettingsScreen(),
    ),
  );
}

Future<void> pumpAlarmSoundSettings(WidgetTester tester, {
  required FakeSettingsRepo settings,
  required FakeNotificationServiceForAlarmSound service,
}) async {
  await tester.binding.setSurfaceSize(const Size(800, 2200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_buildApp(settings: settings, service: service));
  await tester.pumpAndSettle();
}

void main() {
  group('Alarm sound section (Alarm-style mode)', () {
    testWidgets('shows Alarm sound tile with System default subtitle', (
      tester,
    ) async {
      final settings = FakeSettingsRepo()
        .._store['reminder_style'] = 'alarmStyle';
      final service = FakeNotificationServiceForAlarmSound();
      await pumpAlarmSoundSettings(
        tester,
        settings: settings,
        service: service,
      );

      expect(find.text('Alarm sound'), findsOneWidget);
      expect(find.text('System default'), findsWidgets);
    });

    testWidgets('shows persisted custom sound title in subtitle', (
      tester,
    ) async {
      final settings = FakeSettingsRepo()
        .._store['reminder_style'] = 'alarmStyle'
        .._store['alarm_sound_uri'] = 'content://media/alarm/5'
        .._store['alarm_sound_title'] = 'Morning Bell';
      final service = FakeNotificationServiceForAlarmSound();
      await pumpAlarmSoundSettings(
        tester,
        settings: settings,
        service: service,
      );

      expect(find.text('Alarm sound'), findsOneWidget);
      expect(find.text('Morning Bell'), findsOneWidget);
    });

    testWidgets('tapping opens a dialog with system default and choose sound', (
      tester,
    ) async {
      final settings = FakeSettingsRepo()
        .._store['reminder_style'] = 'alarmStyle';
      final service = FakeNotificationServiceForAlarmSound();
      await pumpAlarmSoundSettings(
        tester,
        settings: settings,
        service: service,
      );

      await tester.tap(find.text('Alarm sound'));
      await tester.pumpAndSettle();

      final dialog = find.byType(SimpleDialog);
      expect(dialog, findsOneWidget);
      expect(
        find.descendant(of: dialog, matching: find.text('System default')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('Choose sound')),
        findsOneWidget,
      );
    });

    testWidgets('choosing System default clears a persisted selection', (
      tester,
    ) async {
      final settings = FakeSettingsRepo()
        .._store['reminder_style'] = 'alarmStyle'
        .._store['alarm_sound_uri'] = 'content://media/alarm/5'
        .._store['alarm_sound_title'] = 'Morning Bell';
      final service = FakeNotificationServiceForAlarmSound();
      await pumpAlarmSoundSettings(
        tester,
        settings: settings,
        service: service,
      );

      await tester.tap(find.text('Alarm sound'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(SimpleDialog),
          matching: find.text('System default'),
        ),
      );
      await tester.pumpAndSettle();

      expect(await settings.getValue('alarm_sound_uri'), isNull);
      expect(find.text('System default'), findsWidgets);
    });

    testWidgets('choosing a sound persists the picker result', (tester) async {
      final settings = FakeSettingsRepo()
        .._store['reminder_style'] = 'alarmStyle';
      final service = FakeNotificationServiceForAlarmSound(
        pickedSound: const AlarmSoundSelection(
          uri: 'content://media/alarm/9',
          title: 'Chime',
        ),
      );
      await pumpAlarmSoundSettings(
        tester,
        settings: settings,
        service: service,
      );

      await tester.tap(find.text('Alarm sound'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(SimpleDialog),
          matching: find.text('Choose sound'),
        ),
      );
      await tester.pumpAndSettle();

      expect(await settings.getValue('alarm_sound_uri'),
          'content://media/alarm/9');
      expect(find.text('Chime'), findsOneWidget);
    });

    testWidgets('Test sound starts the preview and Stop test stops it', (
      tester,
    ) async {
      final settings = FakeSettingsRepo()
        .._store['reminder_style'] = 'alarmStyle';
      final service = FakeNotificationServiceForAlarmSound();
      await pumpAlarmSoundSettings(
        tester,
        settings: settings,
        service: service,
      );

      await tester.tap(find.text('Test sound'));
      await tester.pumpAndSettle();

      expect(service.previewStartedCount, 1);
      expect(find.text('Stop test'), findsOneWidget);

      await tester.tap(find.text('Stop test'));
      await tester.pumpAndSettle();

      expect(service.previewStoppedCount, 1);
      expect(find.text('Test sound'), findsOneWidget);
    });

    testWidgets('section is not shown outside Alarm-style mode', (
      tester,
    ) async {
      final settings = FakeSettingsRepo()
        .._store['reminder_style'] = 'prominent';
      final service = FakeNotificationServiceForAlarmSound();
      await pumpAlarmSoundSettings(
        tester,
        settings: settings,
        service: service,
      );

      expect(find.text('Alarm sound'), findsNothing);
    });
  });
}