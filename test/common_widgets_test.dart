import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/widgets/common/date_field.dart';
import 'package:rehab_track/presentation/widgets/medication/time_picker_field.dart';

Widget _wrapWithL10n(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('DateField', () {
    testWidgets('renders label when no date selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithL10n(
          DateField(
            label: 'Start Date',
            date: null,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('Start Date'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('renders formatted date when date is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithL10n(
          DateField(
            label: 'Start Date',
            date: DateTime(2026, 3, 15),
            onTap: () {},
          ),
        ),
      );

      expect(find.text('15.03.2026'), findsOneWidget);
    });

    testWidgets('shows clear button when date is set and onClear provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithL10n(
          DateField(
            label: 'Start Date',
            date: DateTime(2026, 3, 15),
            onTap: () {},
            onClear: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsNothing);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        _wrapWithL10n(
          DateField(
            label: 'Start Date',
            date: null,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(DateField));
      expect(tapped, isTrue);
    });

    testWidgets('calls onClear when clear button tapped',
        (WidgetTester tester) async {
      bool cleared = false;

      await tester.pumpWidget(
        _wrapWithL10n(
          DateField(
            label: 'Start Date',
            date: DateTime(2026, 3, 15),
            onTap: () {},
            onClear: () => cleared = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.clear));
      expect(cleared, isTrue);
    });
  });

  group('TimePickerField', () {
    testWidgets('renders time text', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithL10n(
          TimePickerField(
            time: '08:00',
            onTimeSelected: (_) {},
          ),
        ),
      );

      expect(find.text('08:00'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('does not render remove button when onRemove is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithL10n(
          TimePickerField(
            time: '08:00',
            onTimeSelected: (_) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('renders remove button when onRemove is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithL10n(
          TimePickerField(
            time: '08:00',
            onTimeSelected: (_) {},
            onRemove: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('calls onRemove when close button tapped',
        (WidgetTester tester) async {
      bool removed = false;

      await tester.pumpWidget(
        _wrapWithL10n(
          TimePickerField(
            time: '08:00',
            onTimeSelected: (_) {},
            onRemove: () => removed = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      expect(removed, isTrue);
    });
  });
}
