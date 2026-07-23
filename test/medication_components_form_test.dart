import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/medication_component.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/widgets/medication/medication_components_form.dart';

Widget _wrapWithL10n(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('MedicationComponentsForm - layout ordering', () {
    testWidgets('component name field appears above dose fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithL10n(
        MedicationComponentsForm.forMedication(
          components: const [],
          onChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      final nameLabel = find.text('Component Name (optional)');
      final doseAmountLabel = find.text('Dose Amount');
      final doseUnitLabel = find.text('Dose Unit');

      expect(nameLabel, findsOneWidget);
      expect(doseAmountLabel, findsOneWidget);
      expect(doseUnitLabel, findsOneWidget);

      final nameBox =
          nameLabel.evaluate().first.renderObject! as RenderBox;
      final doseBox =
          doseAmountLabel.evaluate().first.renderObject! as RenderBox;
      final unitBox =
          doseUnitLabel.evaluate().first.renderObject! as RenderBox;

      final nameY = nameBox.localToGlobal(Offset.zero).dy;
      final doseY = doseBox.localToGlobal(Offset.zero).dy;
      final unitY = unitBox.localToGlobal(Offset.zero).dy;

      expect(nameY, lessThan(doseY));
      expect(doseY, lessThanOrEqualTo(unitY));
    });

    testWidgets('does not overflow on a narrow screen (320px)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_wrapWithL10n(
        MedicationComponentsForm.forMedication(
          components: [
            MedicationComponent(
              medicationId: 1,
              componentName: 'Aspirin',
              doseAmount: '10',
              doseUnit: 'mg',
              createdAt: DateTime(2026),
            ),
            MedicationComponent(
              medicationId: 1,
              componentName: 'Clopidogrel',
              doseAmount: '2.5',
              doseUnit: 'mg',
              createdAt: DateTime(2026),
            ),
          ],
          onChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      // If there were overflow errors, the framework would have thrown.
      // Since pumpAndSettle completed without exception, no overflow occurred.
    });

    testWidgets('alternative form uses same layout',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithL10n(
        MedicationComponentsForm.forAlternative(
          components: const [],
          onChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      final nameLabel = find.text('Component Name (optional)');
      final doseAmountLabel = find.text('Dose Amount');

      expect(nameLabel, findsOneWidget);
      expect(doseAmountLabel, findsOneWidget);

      final nameBox =
          nameLabel.evaluate().first.renderObject! as RenderBox;
      final doseBox =
          doseAmountLabel.evaluate().first.renderObject! as RenderBox;
      final nameY = nameBox.localToGlobal(Offset.zero).dy;
      final doseY = doseBox.localToGlobal(Offset.zero).dy;

      expect(nameY, lessThan(doseY));
    });
  });

  group('MedicationComponentsForm - deletion stability', () {
    testWidgets('deleting first component removes first, not last',
        (WidgetTester tester) async {
      List<MedicationComponent> changedComponents = [];

      await tester.pumpWidget(_wrapWithL10n(
        MedicationComponentsForm.forMedication(
          components: [
            MedicationComponent(
              medicationId: 1,
              doseAmount: '10',
              doseUnit: 'mg',
              createdAt: DateTime(2026),
            ),
            MedicationComponent(
              medicationId: 1,
              doseAmount: '20',
              doseUnit: 'mg',
              createdAt: DateTime(2026),
            ),
            MedicationComponent(
              medicationId: 1,
              doseAmount: '30',
              doseUnit: 'mg',
              createdAt: DateTime(2026),
            ),
          ],
          onChanged: (c) => changedComponents = c,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('10'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);

      final removeButtons = find.byIcon(Icons.remove_circle_outline);
      expect(removeButtons, findsNWidgets(3));
      await tester.tap(removeButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('10'), findsNothing);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(changedComponents.length, 2);
      expect(changedComponents[0].doseAmount, '20');
      expect(changedComponents[1].doseAmount, '30');
    });

    testWidgets('deleting middle component preserves other values',
        (WidgetTester tester) async {
      List<MedicationComponent> changedComponents = [];

      await tester.pumpWidget(_wrapWithL10n(
        MedicationComponentsForm.forMedication(
          components: [
            MedicationComponent(
              medicationId: 1,
              doseAmount: '10',
              doseUnit: 'mg',
              createdAt: DateTime(2026),
            ),
            MedicationComponent(
              medicationId: 1,
              doseAmount: '20',
              doseUnit: 'mg',
              createdAt: DateTime(2026),
            ),
            MedicationComponent(
              medicationId: 1,
              doseAmount: '30',
              doseUnit: 'mg',
              createdAt: DateTime(2026),
            ),
          ],
          onChanged: (c) => changedComponents = c,
        ),
      ));
      await tester.pumpAndSettle();

      final removeButtons = find.byIcon(Icons.remove_circle_outline);
      await tester.tap(removeButtons.at(1));
      await tester.pumpAndSettle();

      expect(find.text('10'), findsOneWidget);
      expect(find.text('20'), findsNothing);
      expect(find.text('30'), findsOneWidget);
      expect(changedComponents.length, 2);
      expect(changedComponents[0].doseAmount, '10');
      expect(changedComponents[1].doseAmount, '30');
    });

    testWidgets('deleting last component preserves remaining values',
        (WidgetTester tester) async {
      List<MedicationComponent> changedComponents = [];

      await tester.pumpWidget(_wrapWithL10n(
        MedicationComponentsForm.forMedication(
          components: [
            MedicationComponent(
              medicationId: 1,
              doseAmount: '10',
              doseUnit: 'mg',
              createdAt: DateTime(2026),
            ),
            MedicationComponent(
              medicationId: 1,
              doseAmount: '20',
              doseUnit: 'mg',
              createdAt: DateTime(2026),
            ),
            MedicationComponent(
              medicationId: 1,
              doseAmount: '30',
              doseUnit: 'mg',
              createdAt: DateTime(2026),
            ),
          ],
          onChanged: (c) => changedComponents = c,
        ),
      ));
      await tester.pumpAndSettle();

      final removeButtons = find.byIcon(Icons.remove_circle_outline);
      await tester.tap(removeButtons.last);
      await tester.pumpAndSettle();

      expect(find.text('10'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('30'), findsNothing);
      expect(changedComponents.length, 2);
      expect(changedComponents[0].doseAmount, '10');
      expect(changedComponents[1].doseAmount, '20');
    });

    testWidgets('controller values do not swap after deletion',
        (WidgetTester tester) async {
      final formKey = GlobalKey<MedicationComponentsFormState>();

      await tester.pumpWidget(_wrapWithL10n(
        MedicationComponentsForm.forMedication(
          key: formKey,
          components: [
            MedicationComponent(
              medicationId: 1,
              doseAmount: '10',
              doseUnit: 'mg',
              createdAt: DateTime(2026),
            ),
            MedicationComponent(
              medicationId: 1,
              doseAmount: '20',
              doseUnit: 'ml',
              createdAt: DateTime(2026),
            ),
          ],
          onChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      // Layout order per row: [name, doseAmt, doseUnit]
      // Row1: [name1, doseAmt1(10), unit1(mg)]
      // Row2: [name2, doseAmt2(20), unit2(ml)]
      // All fields: [name1, 10, mg, name2, 20, ml]
      final allFields = find.byType(TextFormField);
      await tester.enterText(allFields.at(4), '99');
      await tester.pumpAndSettle();

      final removeButtons = find.byIcon(Icons.remove_circle_outline);
      await tester.tap(removeButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('99'), findsOneWidget);
      expect(find.text('10'), findsNothing);
    });
  });

  group('MedicationComponentsForm - componentName field', () {
    testWidgets('medication form shows componentName optional field',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithL10n(
        MedicationComponentsForm.forMedication(
          components: const [],
          onChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Component Name (optional)'), findsOneWidget);
    });

    testWidgets('alternative form shows componentName optional field',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithL10n(
        MedicationComponentsForm.forAlternative(
          components: const [],
          onChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Component Name (optional)'), findsOneWidget);
    });

    testWidgets('componentName values stay with correct rows after edits',
        (WidgetTester tester) async {
      List<MedicationComponent> changedComponents = [];

      await tester.pumpWidget(_wrapWithL10n(
        MedicationComponentsForm.forMedication(
          components: [
            MedicationComponent(
              medicationId: 1,
              componentName: 'Aspirin',
              doseAmount: '10',
              doseUnit: 'mg',
              createdAt: DateTime(2026),
            ),
            MedicationComponent(
              medicationId: 1,
              componentName: 'Clopidogrel',
              doseAmount: '2.5',
              doseUnit: 'mg',
              createdAt: DateTime(2026),
            ),
          ],
          onChanged: (c) => changedComponents = c,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Aspirin'), findsOneWidget);
      expect(find.text('Clopidogrel'), findsOneWidget);

      final removeButtons = find.byIcon(Icons.remove_circle_outline);
      await tester.tap(removeButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('Aspirin'), findsNothing);
      expect(find.text('Clopidogrel'), findsOneWidget);
      expect(changedComponents.length, 1);
      expect(changedComponents[0].componentName, 'Clopidogrel');
    });

    testWidgets('blank componentName normalizes to null in output',
        (WidgetTester tester) async {
      List<MedicationComponent> changedComponents = [];

      await tester.pumpWidget(_wrapWithL10n(
        MedicationComponentsForm.forMedication(
          components: const [],
          onChanged: (c) => changedComponents = c,
        ),
      ));
      await tester.pumpAndSettle();

      // Layout: [name, doseAmt, doseUnit] — enter dose at index 1
      final doseFields = find.byType(TextFormField);
      await tester.enterText(doseFields.at(1), '5');
      await tester.pumpAndSettle();

      expect(changedComponents.length, 1);
      expect(changedComponents[0].componentName, isNull);
    });

    testWidgets('unnamed components load correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithL10n(
        MedicationComponentsForm.forMedication(
          components: [
            MedicationComponent(
              medicationId: 1,
              doseAmount: '500',
              doseUnit: 'mg',
              createdAt: DateTime(2026),
            ),
          ],
          onChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('500'), findsOneWidget);
      final editableTexts = find.byType(EditableText);
      final hasMgUnit = editableTexts.evaluate().any((el) {
        final ctrl = el.widget as EditableText;
        return ctrl.controller.text == 'mg';
      });
      expect(hasMgUnit, isTrue);
    });

    testWidgets('named components load and preserve names',
        (WidgetTester tester) async {
      List<MedicationComponent> changedComponents = [];

      await tester.pumpWidget(_wrapWithL10n(
        MedicationComponentsForm.forMedication(
          components: [
            MedicationComponent(
              medicationId: 1,
              componentName: 'Tripliksam',
              doseAmount: '10',
              doseUnit: 'mg',
              createdAt: DateTime(2026),
            ),
          ],
          onChanged: (c) => changedComponents = c,
        ),
      ));
      await tester.pumpAndSettle();

      final editableTexts = find.byType(EditableText);
      final nameFound = editableTexts.evaluate().any((el) {
        final ctrl = el.widget as EditableText;
        return ctrl.controller.text == 'Tripliksam';
      });
      expect(nameFound, isTrue);
      expect(find.text('10'), findsOneWidget);

      // Layout: [name, doseAmt, doseUnit] — trigger change via doseAmt at index 1
      final allFields = find.byType(TextFormField);
      await tester.enterText(allFields.at(1), '20');
      await tester.pumpAndSettle();

      expect(changedComponents.length, 1);
      expect(changedComponents[0].componentName, 'Tripliksam');
      expect(changedComponents[0].doseAmount, '20');
    });
  });

  group('MedicationComponentsForm - add component', () {
    testWidgets('adding component creates new row with componentName field',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithL10n(
        MedicationComponentsForm.forMedication(
          components: const [],
          onChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Component Name (optional)'), findsOneWidget);

      await tester.tap(find.text('Add Component'));
      await tester.pumpAndSettle();

      expect(find.text('Component Name (optional)'), findsNWidgets(2));
    });
  });
}
