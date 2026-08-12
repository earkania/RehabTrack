import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';
import 'package:rehab_track/domain/repositories/settings_repository.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';
import 'package:rehab_track/presentation/widgets/today/today_agenda_item.dart';
import 'package:rehab_track/presentation/widgets/today/today_next_item_card.dart';
import 'package:rehab_track/presentation/widgets/today/today_relative_time_label.dart';

class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<String?> getValue(String key) async => null;

  @override
  Future<void> setValue(String key, String value) async {}

  @override
  Future<void> remove(String key) async {}

  @override
  Stream<Map<String, String>> watchAll() => const Stream.empty();

  @override
  Future<Map<String, String>> getAll() async => {};
}

TodayAgendaItem _item({
  DateTime? at,
  TodayAgendaItemStatus status = TodayAgendaItemStatus.upcoming,
  TodayAgendaItemType type = TodayAgendaItemType.medication,
  String? measurementTypeKey,
  String title = 'Medication A',
}) {
  return TodayAgendaItem(
    id: 'id1',
    type: type,
    sourceScheduleId: 1,
    scheduledDateTime: at ?? DateTime(2025, 7, 25, 10, 0),
    title: title,
    status: status,
    measurementTypeKey: measurementTypeKey,
  );
}

Widget _wrapWithClock(Widget child, {required DateTime now, Widget? home, Locale? locale}) {
  return ProviderScope(
    overrides: [
      currentMinuteProvider.overrideWith((ref) => now),
      nextItemGracePeriodProvider.overrideWith(
        (ref) => NextItemGracePeriodNotifier(_FakeSettingsRepository()),
      ),
      todayAutoRefreshProvider.overrideWith((ref) {}),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: home ?? Scaffold(body: child),
    ),
  );
}

void main() {
  group('TodayRelativeTimeLabel', () {
    testWidgets('shows countdown for a future occurrence today', (tester) async {
      final now = DateTime(2025, 7, 25, 10, 0);
      final item = _item(at: DateTime(2025, 7, 25, 14, 30));

      await tester.pumpWidget(_wrapWithClock(TodayRelativeTimeLabel(item: item), now: now));

      expect(find.text('In 4h 30m'), findsOneWidget);
    });

    testWidgets('shows whole-hour countdown', (tester) async {
      final now = DateTime(2025, 7, 25, 10, 0);
      final item = _item(at: DateTime(2025, 7, 25, 12, 0));

      await tester.pumpWidget(_wrapWithClock(TodayRelativeTimeLabel(item: item), now: now));

      expect(find.text('In 2h'), findsOneWidget);
    });

    testWidgets('shows minute-only countdown', (tester) async {
      final now = DateTime(2025, 7, 25, 10, 0);
      final item = _item(at: DateTime(2025, 7, 25, 10, 45));

      await tester.pumpWidget(_wrapWithClock(TodayRelativeTimeLabel(item: item), now: now));

      expect(find.text('In 45m'), findsOneWidget);
    });

    testWidgets('shows nothing inside the grace period', (tester) async {
      final now = DateTime(2025, 7, 25, 10, 0);
      final item = _item(
        at: DateTime(2025, 7, 25, 10, 0),
        status: TodayAgendaItemStatus.due,
      );

      await tester.pumpWidget(_wrapWithClock(TodayRelativeTimeLabel(item: item), now: now));

      expect(find.text('In 0m'), findsNothing);
      expect(
        find.byType(TodayRelativeTimeLabel),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(TodayRelativeTimeLabel),
          matching: find.byType(Text),
        ),
        findsNothing,
      );
    });

    testWidgets('shows overdue after the grace period', (tester) async {
      final now = DateTime(2025, 7, 25, 10, 16);
      final item = _item(
        at: DateTime(2025, 7, 25, 10, 0),
        status: TodayAgendaItemStatus.overdue,
      );

      await tester.pumpWidget(_wrapWithClock(TodayRelativeTimeLabel(item: item), now: now));

      expect(find.text('16m overdue'), findsOneWidget);
    });

    testWidgets('measures overdue from the scheduled time, not the grace end',
        (tester) async {
      final now = DateTime(2025, 7, 25, 10, 16);
      final item = _item(
        at: DateTime(2025, 7, 25, 10, 0),
        status: TodayAgendaItemStatus.overdue,
      );

      await tester.pumpWidget(_wrapWithClock(TodayRelativeTimeLabel(item: item), now: now));

      expect(find.text('16m overdue'), findsOneWidget);
      expect(find.text('1m overdue'), findsNothing);
    });

    testWidgets('shows nothing for a completed occurrence', (tester) async {
      final now = DateTime(2025, 7, 25, 10, 30);
      final item = _item(
        at: DateTime(2025, 7, 25, 10, 0),
        status: TodayAgendaItemStatus.completed,
      );

      await tester.pumpWidget(_wrapWithClock(TodayRelativeTimeLabel(item: item), now: now));

      expect(
        find.descendant(
          of: find.byType(TodayRelativeTimeLabel),
          matching: find.byType(Text),
        ),
        findsNothing,
      );
    });

    testWidgets('shows nothing for an occurrence scheduled tomorrow',
        (tester) async {
      final now = DateTime(2025, 7, 25, 10, 0);
      final item = _item(at: DateTime(2025, 7, 26, 14, 0));

      await tester.pumpWidget(_wrapWithClock(TodayRelativeTimeLabel(item: item), now: now));

      expect(find.textContaining('In '), findsNothing);
    });

    testWidgets('shows nothing for an occurrence scheduled yesterday',
        (tester) async {
      final now = DateTime(2025, 7, 25, 10, 0);
      final item = _item(at: DateTime(2025, 7, 24, 8, 0));

      await tester.pumpWidget(_wrapWithClock(TodayRelativeTimeLabel(item: item), now: now));

      expect(find.textContaining('overdue'), findsNothing);
    });

    testWidgets('exposes spoken semantics for the countdown', (tester) async {
      final now = DateTime(2025, 7, 25, 10, 0);
      final item = _item(at: DateTime(2025, 7, 25, 14, 30));

      await tester.pumpWidget(_wrapWithClock(TodayRelativeTimeLabel(item: item), now: now));

      expect(
        find.bySemanticsLabel(RegExp('Medication A.*in 4 hours 30 minutes')),
        findsOneWidget,
      );
    });

    testWidgets('exposes spoken semantics for overdue', (tester) async {
      final now = DateTime(2025, 7, 25, 10, 16);
      final item = _item(
        at: DateTime(2025, 7, 25, 10, 0),
        status: TodayAgendaItemStatus.overdue,
      );

      await tester.pumpWidget(_wrapWithClock(TodayRelativeTimeLabel(item: item), now: now));

      expect(
        find.bySemanticsLabel(RegExp('Medication A.*16 minutes overdue')),
        findsOneWidget,
      );
    });
  });

  group('TodayRelativeTimeLabel in TodayAgendaItemWidget', () {
    testWidgets('shows countdown for a future medication', (tester) async {
      final now = DateTime(2025, 7, 25, 10, 0);
      final item = _item(
        at: DateTime(2025, 7, 25, 11, 30),
        title: 'Concor',
      );

      await tester.pumpWidget(_wrapWithClock(TodayAgendaItemWidget(item: item), now: now));

      expect(find.text('In 1h 30m'), findsOneWidget);
    });

    testWidgets('shows overdue for a past medication', (tester) async {
      final now = DateTime(2025, 7, 25, 10, 16);
      final item = _item(
        at: DateTime(2025, 7, 25, 10, 0),
        status: TodayAgendaItemStatus.overdue,
        title: 'Aspirin',
      );

      await tester.pumpWidget(_wrapWithClock(TodayAgendaItemWidget(item: item), now: now));

      expect(find.text('16m overdue'), findsOneWidget);
    });
  });

  group('TodayRelativeTimeLabel in TodayNextItemCard', () {
    testWidgets('shows countdown on the next item card', (tester) async {
      final now = DateTime(2025, 7, 25, 10, 0);
      final item = _item(at: DateTime(2025, 7, 25, 14, 30), title: 'Aspirin');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentMinuteProvider.overrideWith((ref) => now),
            nextItemGracePeriodProvider.overrideWith(
              (ref) => NextItemGracePeriodNotifier(_FakeSettingsRepository()),
            ),
            todayAutoRefreshProvider.overrideWith((ref) {}),
            nextTodayItemProvider.overrideWith((ref) => item),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: TodayNextItemCard()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('In 4h 30m'), findsOneWidget);
    });

    testWidgets('no label when the next item is inside the grace period',
        (tester) async {
      final now = DateTime(2025, 7, 25, 10, 0);
      final item = _item(
        at: DateTime(2025, 7, 25, 10, 0),
        status: TodayAgendaItemStatus.due,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentMinuteProvider.overrideWith((ref) => now),
            nextItemGracePeriodProvider.overrideWith(
              (ref) => NextItemGracePeriodNotifier(_FakeSettingsRepository()),
            ),
            todayAutoRefreshProvider.overrideWith((ref) {}),
            nextTodayItemProvider.overrideWith((ref) => item),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: TodayNextItemCard()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('In '), findsNothing);
      expect(find.textContaining('overdue'), findsNothing);
    });
  });

  group('Georgian TodayRelativeTimeLabel', () {
    testWidgets('shows concise Georgian overdue text', (tester) async {
      final now = DateTime(2025, 7, 25, 10, 37);
      final item = _item(
        at: DateTime(2025, 7, 25, 10, 0),
        status: TodayAgendaItemStatus.overdue,
      );

      await tester.pumpWidget(_wrapWithClock(
        TodayRelativeTimeLabel(item: item),
        now: now,
        locale: const Locale('ka'),
      ));

      expect(find.text('37წთ გადაცილება'), findsOneWidget);
    });

    testWidgets('shows Georgian whole-hour overdue text', (tester) async {
      final now = DateTime(2025, 7, 25, 11, 0);
      final item = _item(
        at: DateTime(2025, 7, 25, 10, 0),
        status: TodayAgendaItemStatus.overdue,
      );

      await tester.pumpWidget(_wrapWithClock(
        TodayRelativeTimeLabel(item: item),
        now: now,
        locale: const Locale('ka'),
      ));

      expect(find.text('1სთ გადაცილება'), findsOneWidget);
    });

    testWidgets('shows Georgian hours-and-minutes overdue text',
        (tester) async {
      final now = DateTime(2025, 7, 25, 11, 20);
      final item = _item(
        at: DateTime(2025, 7, 25, 10, 0),
        status: TodayAgendaItemStatus.overdue,
      );

      await tester.pumpWidget(_wrapWithClock(
        TodayRelativeTimeLabel(item: item),
        now: now,
        locale: const Locale('ka'),
      ));

      expect(find.text('1სთ 20წთ გადაცილება'), findsOneWidget);
    });

    testWidgets('no overflow on Pixel 7 portrait for overdue labels',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final overdue in [
        const Duration(minutes: 37),
        const Duration(minutes: 60),
        const Duration(minutes: 80),
        const Duration(hours: 24),
      ]) {
        final now = DateTime(2025, 7, 25, 10, 0).add(overdue);
        final item = _item(
          at: DateTime(2025, 7, 25, 10, 0),
          status: TodayAgendaItemStatus.overdue,
        );

        await tester.pumpWidget(_wrapWithClock(
          TodayRelativeTimeLabel(item: item),
          now: now,
          locale: const Locale('ka'),
        ));

        expect(tester.takeException(), isNull);
      }
    });
  });
}
