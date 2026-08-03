import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/care_contact.dart';
import 'package:rehab_track/domain/enums/enums.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/widgets/care_contacts/care_contact_form.dart';

void main() {
  CareContact makeContact({
    CareContactType type = CareContactType.doctor,
    String displayName = '',
    String? firstName,
    String? lastName,
    String? organizationName,
  }) {
    final now = DateTime(2026);
    return CareContact(
      profileId: 1,
      contactType: type,
      displayName: displayName,
      firstName: firstName,
      lastName: lastName,
      organizationName: organizationName,
      createdAt: now,
      updatedAt: now,
    );
  }

  Widget wrap(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }

  Future<void> pumpForm(
    WidgetTester tester,
    Widget form,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(wrap(form));
    await tester.pump();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
  }

  group('CareContactForm display name rules', () {
    testWidgets('clears stale generated organization display name on edit',
        (tester) async {
      final initial = makeContact(
        type: CareContactType.clinic,
        displayName: 'City Clinic',
        organizationName: 'City Clinic',
      );
      CareContact? submitted;
      await pumpForm(
        tester,
        CareContactForm(
          type: CareContactType.clinic,
          initial: initial,
          onSubmit: (c) async => submitted = c,
        ),
      );

      final orgField = find.widgetWithText(
        TextFormField,
        'Organization Name *',
      );
      expect(orgField, findsOneWidget);
      await tester.enterText(orgField, 'City Central Hospital');
      await save(tester);

      expect(submitted, isNotNull);
      // Generated value equal to the fallback is cleared.
      expect(submitted!.displayName, '');
      expect(submitted!.organizationName, 'City Central Hospital');
      expect(
        submitted!.effectiveDisplayName,
        'City Central Hospital',
      );
    });

    testWidgets('preserves explicit organization alias on edit',
        (tester) async {
      final initial = makeContact(
        type: CareContactType.clinic,
        displayName: 'Main Clinic',
        organizationName: 'City Clinic',
      );
      CareContact? submitted;
      await pumpForm(
        tester,
        CareContactForm(
          type: CareContactType.clinic,
          initial: initial,
          onSubmit: (c) async => submitted = c,
        ),
      );

      final orgField = find.widgetWithText(
        TextFormField,
        'Organization Name *',
      );
      await tester.enterText(orgField, 'City Central Hospital');
      await save(tester);

      expect(submitted!.displayName, 'Main Clinic');
      expect(submitted!.organizationName, 'City Central Hospital');
    });

    testWidgets('doctor display-name field stays empty for generated name',
        (tester) async {
      final initial = makeContact(
        type: CareContactType.doctor,
        displayName: 'John Smith',
        firstName: 'John',
        lastName: 'Smith',
      );
      CareContact? submitted;
      await pumpForm(
        tester,
        CareContactForm(
          type: CareContactType.doctor,
          initial: initial,
          onSubmit: (c) async => submitted = c,
        ),
      );

      final displayField = find.widgetWithText(
        TextFormField,
        'Display Name',
      );
      expect(displayField, findsOneWidget);
      expect(
        tester.widget<TextFormField>(displayField).controller!.text,
        isEmpty,
      );

      await save(tester);

      expect(submitted!.displayName, '');
      expect(submitted!.firstName, 'John');
      expect(submitted!.lastName, 'Smith');
      expect(submitted!.effectiveDisplayName, 'John Smith');
    });

    testWidgets('doctor display-name field prefills explicit alias',
        (tester) async {
      final initial = makeContact(
        type: CareContactType.doctor,
        displayName: 'Dr. Smith',
        firstName: 'John',
        lastName: 'Smith',
      );
      CareContact? submitted;
      await pumpForm(
        tester,
        CareContactForm(
          type: CareContactType.doctor,
          initial: initial,
          onSubmit: (c) async => submitted = c,
        ),
      );

      final displayField = find.widgetWithText(
        TextFormField,
        'Display Name',
      );
      expect(
        tester.widget<TextFormField>(displayField).controller!.text,
        'Dr. Smith',
      );

      await save(tester);

      expect(submitted!.displayName, 'Dr. Smith');
    });
  });
}
