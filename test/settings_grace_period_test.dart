import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:rehab_track/data/services/notification/notification_service.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/notification_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/screens/settings/app_settings_screen.dart';

class FakeNotificationServiceForSettings extends NotificationService {
  FakeNotificationServiceForSettings();

  final List<Map<String, dynamic>> scheduledNotifications = [];

  @override
  bool get isInitialized => true;

  @override
  Future<bool> initialize() async => true;

  @override
  Future<bool> hasNotificationPermission() async => true;

  @override
  Future<bool> hasExactAlarmPermission() async => true;

  @override
  Future<void> waitForInitialization() async {}

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
    required String channelId,
    bool includeActions = false,
    bool isMeasurement = false,
    bool isDoctorVisit = false,
    bool playSound = true,
    bool enableVibration = true,
    NotificationVisibility visibility = NotificationVisibility.public,
  }) async {
    scheduledNotifications.add({
      'id': id,
      'channelId': channelId,
    });
  }
}

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

Widget _buildApp({
  required FakeSettingsRepo settings,
  Locale? locale,
  FakeNotificationServiceForSettings? notificationService,
}) {
  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(settings),
      currentActiveProfileIdProvider.overrideWith((ref) => null),
      notificationServiceProvider.overrideWithValue(
        notificationService ?? FakeNotificationServiceForSettings(),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: const AppSettingsScreen(),
    ),
  );
}

extension PumpGracePeriod on WidgetTester {
  Future<void> pumpGracePeriod({
    required FakeSettingsRepo settings,
    Locale? locale,
    FakeNotificationServiceForSettings? notificationService,
  }) async {
    await pumpWidget(_buildApp(
      settings: settings,
      locale: locale,
      notificationService: notificationService,
    ));
    await pump();
  }
}

void main() {
  setUpAll(() {
    tzdata.initializeTimeZones();
  });

  group('Settings grace period tile', () {
    testWidgets('shows Next item grace period tile in English', (
      tester,
    ) async {
      final settings = FakeSettingsRepo();
      await tester.pumpGracePeriod(settings: settings);

      expect(find.text('Next item grace period'), findsOneWidget);
      expect(find.text('15 minutes'), findsOneWidget);
    });

    testWidgets('shows Next item grace period tile in Georgian', (
      tester,
    ) async {
      final settings = FakeSettingsRepo();
      await tester.pumpGracePeriod(
        settings: settings,
        locale: const Locale('ka'),
      );

      expect(
        find.text('შემდეგი ჩანაწერის დაყოვნების პერიოდი'),
        findsOneWidget,
      );
      expect(find.text('15 წუთი'), findsOneWidget);
    });

    testWidgets('shows persisted value in subtitle', (tester) async {
      final settings = FakeSettingsRepo();
      await settings.setValue(
        'next_item_grace_period_minutes',
        '30',
      );
      await tester.pumpGracePeriod(settings: settings);
      await tester.pumpAndSettle();

      expect(find.text('30 minutes'), findsOneWidget);
    });

    testWidgets('tapping opens selection dialog', (tester) async {
      final settings = FakeSettingsRepo();
      await tester.pumpGracePeriod(settings: settings);

      await tester.tap(find.text('Next item grace period'));
      await tester.pumpAndSettle();

      final dialog = find.byType(SimpleDialog);
      expect(dialog, findsOneWidget);

      for (final label in ['5 minutes', '10 minutes', '15 minutes', '30 minutes', '60 minutes']) {
        expect(
          find.descendant(of: dialog, matching: find.text(label)),
          findsOneWidget,
        );
      }
    });

    testWidgets('choosing another value updates the tile', (tester) async {
      final settings = FakeSettingsRepo();
      await tester.pumpGracePeriod(settings: settings);

      await tester.tap(find.text('Next item grace period'));
      await tester.pumpAndSettle();

      final dialog = find.byType(SimpleDialog);
      await tester.tap(
        find.descendant(of: dialog, matching: find.text('30 minutes')),
      );
      await tester.pumpAndSettle();

      expect(find.text('30 minutes'), findsOneWidget);
    });

    testWidgets('no overflow on narrow screen', (tester) async {
      final settings = FakeSettingsRepo();
      await tester.binding.setSurfaceSize(const Size(320, 600));

      await tester.pumpGracePeriod(settings: settings);

      final tile = find.text('Next item grace period');
      expect(tile, findsOneWidget);
      expect(
        tester.widget<Text>(tile).overflow,
        isNot(TextOverflow.fade),
      );

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('timer icon is present', (tester) async {
      final settings = FakeSettingsRepo();
      await tester.pumpGracePeriod(settings: settings);

      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });

    testWidgets('chevron right icon is present', (tester) async {
      final settings = FakeSettingsRepo();
      await tester.pumpGracePeriod(settings: settings);

      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });

    testWidgets('section header Today is present', (tester) async {
      final settings = FakeSettingsRepo();
      await tester.pumpGracePeriod(settings: settings);

      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('Georgian layout no overflow on narrow screen', (
      tester,
    ) async {
      final settings = FakeSettingsRepo();
      await tester.binding.setSurfaceSize(const Size(320, 600));

      await tester.pumpGracePeriod(
        settings: settings,
        locale: const Locale('ka'),
      );

      final title = find.text('შემდეგი ჩანაწერის დაყოვნების პერიოდი');
      expect(title, findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('selected option shows filled radio icon in dialog', (
      tester,
    ) async {
      final settings = FakeSettingsRepo();
      await tester.pumpGracePeriod(settings: settings);

      await tester.tap(find.text('Next item grace period'));
      await tester.pumpAndSettle();

      final dialog = find.byType(SimpleDialog);
      final filledRadios = find.descendant(
        of: dialog,
        matching: find.byIcon(Icons.radio_button_checked),
      );
      expect(filledRadios, findsOneWidget);

      final emptyRadios = find.descendant(
        of: dialog,
        matching: find.byIcon(Icons.radio_button_unchecked),
      );
      expect(emptyRadios, findsNWidgets(4));
    });
  });

  group('Settings patient profile entry', () {
    testWidgets('does not show Patient Profile tile in English', (
      tester,
    ) async {
      final settings = FakeSettingsRepo();
      await tester.pumpGracePeriod(settings: settings);

      expect(find.text('Patient Profile'), findsNothing);
    });

    testWidgets('does not show Patient Profile tile in Georgian', (
      tester,
    ) async {
      final settings = FakeSettingsRepo();
      await tester.pumpGracePeriod(
        settings: settings,
        locale: const Locale('ka'),
      );

      expect(find.text('პაციენტის პროფილი'), findsNothing);
    });

    testWidgets('Language section is present with no leftover empty header', (
      tester,
    ) async {
      final settings = FakeSettingsRepo();
      await tester.pumpGracePeriod(settings: settings);

      expect(find.text('Language'), findsOneWidget);
    });

    testWidgets('Georgian Language section header is present', (
      tester,
    ) async {
      final settings = FakeSettingsRepo();
      await tester.pumpGracePeriod(
        settings: settings,
        locale: const Locale('ka'),
      );

      expect(find.text('ენა'), findsOneWidget);
    });

    testWidgets('selecting Georgian persists the language choice', (
      tester,
    ) async {
      final settings = FakeSettingsRepo();
      await tester.pumpGracePeriod(settings: settings);

      await tester.tap(find.text('ქართული'));
      await tester.pumpAndSettle();

      expect(await settings.getValue('app_language'), 'ka');
      final kaRadio = tester.widget<Icon>(find.byIcon(
        Icons.radio_button_checked,
      ));
      expect(kaRadio, isNotNull);
    });

    testWidgets('selecting English persists the language choice', (
      tester,
    ) async {
      final settings = FakeSettingsRepo();
      await tester.pumpGracePeriod(settings: settings);

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(await settings.getValue('app_language'), 'en');
    });
  });

  group('Reminder style tile', () {
    Future<void> pumpTall(WidgetTester tester, {
      required FakeSettingsRepo settings,
      Locale? locale,
      FakeNotificationServiceForSettings? notificationService,
    }) async {
      await tester.binding.setSurfaceSize(const Size(800, 2800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpGracePeriod(
        settings: settings,
        locale: locale,
        notificationService: notificationService,
      );
    }

    testWidgets('shows Reminder style tile with Standard subtitle', (
      tester,
    ) async {
      final settings = FakeSettingsRepo();
      await pumpTall(tester, settings: settings);

      expect(find.text('Reminder style'), findsOneWidget);
      expect(find.text('Standard'), findsOneWidget);
    });

    testWidgets('shows persisted Prominent style in subtitle', (tester) async {
      final settings = FakeSettingsRepo();
      await settings.setValue('reminder_style', 'prominent');
      await pumpTall(tester, settings: settings);
      await tester.pumpAndSettle();

      expect(find.text('Reminder style'), findsOneWidget);
      expect(find.text('Prominent'), findsOneWidget);
    });

    testWidgets('tapping opens dialog with both styles', (tester) async {
      final settings = FakeSettingsRepo();
      await pumpTall(tester, settings: settings);

      await tester.tap(find.text('Reminder style'));
      await tester.pumpAndSettle();

      final dialog = find.byType(SimpleDialog);
      expect(dialog, findsOneWidget);
      expect(
        find.descendant(of: dialog, matching: find.text('Standard')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('Prominent')),
        findsOneWidget,
      );
    });

    testWidgets('choosing Prominent persists and updates the tile', (
      tester,
    ) async {
      final settings = FakeSettingsRepo();
      await pumpTall(tester, settings: settings);

      await tester.tap(find.text('Reminder style'));
      await tester.pumpAndSettle();

      final dialog = find.byType(SimpleDialog);
      await tester.tap(
        find.descendant(of: dialog, matching: find.text('Prominent')),
      );
      await tester.pumpAndSettle();

      expect(await settings.getValue('reminder_style'), 'prominent');
      expect(find.text('Prominent'), findsOneWidget);
    });

    testWidgets('test notification uses prominent channel in prominent mode', (
      tester,
    ) async {
      final settings = FakeSettingsRepo();
      await settings.setValue('reminder_style', 'prominent');
      final notificationService = FakeNotificationServiceForSettings();
      await pumpTall(
        tester,
        settings: settings,
        notificationService: notificationService,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test medication reminder'));
      await tester.pumpAndSettle();

      expect(notificationService.scheduledNotifications, hasLength(1));
      expect(
        notificationService.scheduledNotifications.single['channelId'],
        NotificationService.prominentChannelId,
      );
      expect(
        notificationService.scheduledNotifications.single['id'],
        NotificationService.testMedicationNotificationId,
      );
    });

    testWidgets('test notification uses event channel in standard mode', (
      tester,
    ) async {
      final settings = FakeSettingsRepo();
      final notificationService = FakeNotificationServiceForSettings();
      await pumpTall(
        tester,
        settings: settings,
        notificationService: notificationService,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test measurement reminder'));
      await tester.pumpAndSettle();

      expect(notificationService.scheduledNotifications, hasLength(1));
      expect(
        notificationService.scheduledNotifications.single['channelId'],
        NotificationService.measurementChannelId,
      );
      expect(
        notificationService.scheduledNotifications.single['id'],
        NotificationService.testMeasurementNotificationId,
      );
    });

    testWidgets('Georgia layout shows Reminder style tile', (tester) async {
      final settings = FakeSettingsRepo();
      await pumpTall(
        tester,
        settings: settings,
        locale: const Locale('ka'),
      );

      expect(find.text('შეხსენების სტილი'), findsOneWidget);
    });
  });
}
