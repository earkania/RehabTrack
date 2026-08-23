import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/activity.dart';
import 'package:rehab_track/domain/entities/diet.dart';
import 'package:rehab_track/domain/entities/doctor_prescription.dart';
import 'package:rehab_track/domain/entities/lab_analysis.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/activity_provider.dart';
import 'package:rehab_track/presentation/providers/diet_provider.dart';
import 'package:rehab_track/presentation/providers/doctor_prescription_provider.dart';
import 'package:rehab_track/presentation/providers/lab_analysis_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/screens/activities/activity_list_screen.dart';
import 'package:rehab_track/presentation/screens/health/diet_screen.dart';
import 'package:rehab_track/presentation/screens/records/doctor_prescriptions_screen.dart';
import 'package:rehab_track/presentation/screens/records/lab_analyses_screen.dart';
import 'package:rehab_track/presentation/widgets/common/list_toolbar_icons.dart';

/// Verifies that Activities, Diet, Lab Analyses and Doctor Prescriptions all
/// render the same shared category-filter (filter_alt) and sort (list_arrow)
/// toolbar icons, and that both buttons keep working.
void main() {
  Widget wrap(Widget home, ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );
  }

  Future<void> pumpScreen(
    WidgetTester tester,
    Widget home,
    List<Override> overrides,
  ) async {
    final container = ProviderContainer(
      overrides: [
        currentActiveProfileIdProvider.overrideWith((ref) => 7),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(wrap(home, container));
    await tester.pump();
    await tester.pumpAndSettle();
    return;
  }

  testWidgets('Activities uses the shared filter_alt and list_arrow icons',
      (tester) async {
    await pumpScreen(tester, const ActivityListScreen(), [
      filteredActivitiesProvider.overrideWith(
        (ref, id) => Stream.value(<Activity>[]),
      ),
      archivedActivitiesProvider.overrideWith(
        (ref, id) => Stream.value(<Activity>[]),
      ),
      activeSessionProvider.overrideWith((ref, id) => Stream.value(null)),
    ]);

    expect(find.byIcon(toolbarCategoryFilterIcon), findsOneWidget);
    expect(find.byIcon(toolbarSortIcon), findsOneWidget);
  });

  testWidgets('Activities category filter still applies and marks active',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        currentActiveProfileIdProvider.overrideWith((ref) => 7),
        filteredActivitiesProvider.overrideWith(
          (ref, id) => Stream.value(<Activity>[]),
        ),
        archivedActivitiesProvider.overrideWith(
          (ref, id) => Stream.value(<Activity>[]),
        ),
        activeSessionProvider.overrideWith((ref, id) => Stream.value(null)),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(wrap(const ActivityListScreen(), container));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(toolbarCategoryFilterIcon));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PopupMenuItem<String>).at(1));
    await tester.pumpAndSettle();

    expect(container.read(activityCategoryFilterProvider), isNotNull);

    final semantics = tester.getSemantics(
      find.byIcon(toolbarCategoryFilterIcon),
    );
    expect(semantics.flagsCollection.isSelected, Tristate.isTrue);
  });

  testWidgets('Activities sort menu still updates the sort state',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        currentActiveProfileIdProvider.overrideWith((ref) => 7),
        filteredActivitiesProvider.overrideWith(
          (ref, id) => Stream.value(<Activity>[]),
        ),
        archivedActivitiesProvider.overrideWith(
          (ref, id) => Stream.value(<Activity>[]),
        ),
        activeSessionProvider.overrideWith((ref, id) => Stream.value(null)),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(wrap(const ActivityListScreen(), container));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(toolbarSortIcon));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PopupMenuItem<ActivitySort>).at(1));
    await tester.pumpAndSettle();

    expect(container.read(activitySortProvider), ActivitySort.alphabeticalZA);
  });

  testWidgets('Diet foods section uses the shared filter and sort icons',
      (tester) async {
    await pumpScreen(tester, const DietScreen(), [
      sortedDietFoodItemsProvider.overrideWith(
        (ref, id) => Stream.value(<DietItem>[]),
      ),
      archivedDietFoodItemsProvider.overrideWith(
        (ref, id) => Stream.value(<DietItem>[]),
      ),
      dietGuidanceSearchProvider.overrideWith(
        (ref, id) => Stream.value(<DietGuidanceRule>[]),
      ),
      archivedDietGuidanceRulesProvider.overrideWith(
        (ref, id) => Stream.value(<DietGuidanceRule>[]),
      ),
    ]);

    // Foods toolbar shows one filter button and one sort button.
    expect(find.byIcon(toolbarCategoryFilterIcon), findsOneWidget);
    expect(find.byIcon(toolbarSortIcon), findsOneWidget);
  });

  testWidgets('Lab Analyses uses the shared icons and sort menu still opens',
      (tester) async {
    await pumpScreen(tester, const LabAnalysesScreen(), [
      sortedLabAnalysesProvider.overrideWith(
        (ref, id) => Stream.value(<LabAnalysis>[]),
      ),
      archivedLabAnalysesProvider.overrideWith(
        (ref, id) => Stream.value(<LabAnalysis>[]),
      ),
    ]);

    expect(find.byIcon(toolbarCategoryFilterIcon), findsOneWidget);
    expect(find.byIcon(toolbarSortIcon), findsOneWidget);

    await tester.tap(find.byIcon(toolbarSortIcon));
    await tester.pumpAndSettle();
    expect(find.byType(PopupMenuItem<LabAnalysisSort>), findsWidgets);
  });

  testWidgets('Doctor Prescriptions uses the shared filter_alt and '
      'list_arrow icons', (tester) async {
    await pumpScreen(tester, const DoctorPrescriptionsScreen(), [
      sortedDoctorPrescriptionsProvider.overrideWith(
        (ref, id) => Stream.value(<DoctorPrescription>[]),
      ),
      archivedDoctorPrescriptionsProvider.overrideWith(
        (ref, id) => Stream.value(<DoctorPrescription>[]),
      ),
    ]);

    expect(find.byIcon(toolbarCategoryFilterIcon), findsOneWidget);
    expect(find.byIcon(toolbarSortIcon), findsOneWidget);
  });

  test('shared icon constants pin the exact Material glyphs', () {
    // Category filter: Google Material filter_alt_24 via Flutter Icons.
    expect(toolbarCategoryFilterIcon, Icons.filter_alt);
    // Sort: Google Material Symbols list_arrow (codepoint fff33).
    expect(toolbarSortIcon.codePoint, 0xfff33);
    expect(toolbarSortIcon.fontFamily, 'MaterialSymbolsOutlined');
  });
}
