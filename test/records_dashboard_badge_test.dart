import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/app.dart';
import 'package:rehab_track/presentation/providers/doctor_visit_provider.dart';
import 'package:rehab_track/presentation/screens/records/doctor_visits_screen.dart';
import 'package:rehab_track/presentation/widgets/dashboard/module_grid_tile.dart';

void main() {
  Future<void> goToRecordsTab(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.folder_outlined));
    await tester.pump();
    await tester.pumpAndSettle();
  }

  Future<void> pumpApp(
    WidgetTester tester, {
    required int count,
    Brightness? brightness,
    Locale? locale,
    Size? physicalSize,
    double? devicePixelRatio,
  }) async {
    addTearDown(tester.binding.platformDispatcher.clearAllTestValues);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    if (brightness != null) {
      tester.binding.platformDispatcher.platformBrightnessTestValue =
          brightness;
    }
    if (locale != null) {
      tester.binding.platformDispatcher.localesTestValue = [locale];
    }
    if (physicalSize != null) {
      tester.view.physicalSize = physicalSize;
      tester.view.devicePixelRatio = devicePixelRatio ?? 1.0;
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          upcomingDoctorVisitCountProvider.overrideWithValue(count),
        ],
        child: const RehabTrackApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await goToRecordsTab(tester);
  }

  Finder doctorTile() =>
      find.widgetWithText(ModuleGridTile, 'Doctor Visits');

  group('Records dashboard Doctor Visits badge', () {
    testWidgets('tile keeps the same width and height as other Records tiles',
        (tester) async {
      await pumpApp(tester, count: 3);

      final doctorRect = tester.getRect(doctorTile());
      final labRect = tester.getRect(
        find.widgetWithText(ModuleGridTile, 'Lab Analyses'),
      );

      expect(doctorRect.width, labRect.width);
      expect(doctorRect.height, labRect.height);
    });

    testWidgets('badge overlays the top-right of the Doctor Visits tile',
        (tester) async {
      await pumpApp(tester, count: 3);

      final doctorRect = tester.getRect(doctorTile());
      final badgeRect = tester.getRect(find.byType(Badge));

      // Insets from the tile's top and right edges stay small.
      expect(badgeRect.right, lessThanOrEqualTo(doctorRect.right));
      expect(badgeRect.right, greaterThanOrEqualTo(doctorRect.right - 16));
      expect(badgeRect.top, greaterThanOrEqualTo(doctorRect.top));
      expect(badgeRect.top, lessThanOrEqualTo(doctorRect.top + 16));

      // The badge sits in the top-right corner, not over the centered label.
      expect(badgeRect.center.dx, greaterThan(doctorRect.center.dx));
      expect(badgeRect.center.dy, lessThan(doctorRect.center.dy));
    });

    testWidgets('badge does not add an extra grid item', (tester) async {
      await pumpApp(tester, count: 3);

      // Only the four module tiles: Lab Analyses, Doctor Prescriptions,
      // Doctor Visits, Reports.
      expect(find.byType(ModuleGridTile), findsNWidgets(4));
    });

    testWidgets('badge does not reduce the Doctor Visits tile width',
        (tester) async {
      await pumpApp(tester, count: 3);

      final doctorRect = tester.getRect(doctorTile());
      final labRect = tester.getRect(
        find.widgetWithText(ModuleGridTile, 'Lab Analyses'),
      );

      expect(doctorRect.width, labRect.width);
      expect(find.byType(Badge), findsOneWidget);
    });

    testWidgets('zero count hides the badge', (tester) async {
      await pumpApp(tester, count: 0);

      expect(find.byType(Badge), findsNothing);
    });

    testWidgets('positive count shows the correct number', (tester) async {
      await pumpApp(tester, count: 2);

      expect(
        find.descendant(
          of: find.byType(Badge),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('large values use a compact 99+ representation',
        (tester) async {
      await pumpApp(tester, count: 220);

      expect(
        find.descendant(
          of: find.byType(Badge),
          matching: find.text('99+'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tapping the badge area opens Doctor Visits', (tester) async {
      await pumpApp(tester, count: 5);

      final badgeRect = tester.getRect(find.byType(Badge));
      await tester.tapAt(badgeRect.center);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(DoctorVisitsScreen), findsOneWidget);
    });

    testWidgets('badge uses contrast colors in light theme', (tester) async {
      await pumpApp(tester, count: 3, brightness: Brightness.light);

      final badgeWidget = tester.widget<Badge>(find.byType(Badge));
      final colorScheme =
          Theme.of(tester.element(find.byType(Badge))).colorScheme;

      expect(find.byType(Badge), findsOneWidget);
      expect(badgeWidget.backgroundColor, colorScheme.primary);
      expect(badgeWidget.textColor, colorScheme.onPrimary);
      expect(colorScheme.primary, isNot(colorScheme.onPrimary));
      expect(tester.takeException(), isNull);
    });

    testWidgets('badge uses contrast colors in dark theme', (tester) async {
      await pumpApp(tester, count: 3, brightness: Brightness.dark);

      final badgeWidget = tester.widget<Badge>(find.byType(Badge));
      final colorScheme =
          Theme.of(tester.element(find.byType(Badge))).colorScheme;

      expect(find.byType(Badge), findsOneWidget);
      expect(badgeWidget.backgroundColor, colorScheme.primary);
      expect(badgeWidget.textColor, colorScheme.onPrimary);
      expect(colorScheme.primary, isNot(colorScheme.onPrimary));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Georgian layout shows the badge without overflow',
        (tester) async {
      await pumpApp(tester, count: 3, locale: const Locale('ka'));

      expect(find.text('ექიმთან ვიზიტები'), findsOneWidget);
      expect(find.byType(Badge), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('narrow Pixel-sized screen has no overflow', (tester) async {
      // Pixel 7 logical dimensions: 1080x2400 at 2.625 -> ~411x914 dp.
      await pumpApp(
        tester,
        count: 3,
        physicalSize: const Size(1080, 2400),
        devicePixelRatio: 2.625,
      );

      expect(find.byType(Badge), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}