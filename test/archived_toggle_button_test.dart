import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/presentation/widgets/common/archived_toggle_button.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(appBar: AppBar(actions: [child])));

  testWidgets('shows a plain outlined icon when the active list is shown',
      (tester) async {
    await tester.pumpWidget(
      wrap(
        ArchivedToggleButton(
          isArchived: false,
          showTooltip: 'Show archived',
          showingTooltip: 'Showing archived',
          onPressed: () {},
        ),
      ),
    );

    expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
    expect(find.byIcon(Icons.unarchive_rounded), findsNothing);
  });

  testWidgets('shows a filled selected state when the archived list is shown',
      (tester) async {
    await tester.pumpWidget(
      wrap(
        ArchivedToggleButton(
          isArchived: true,
          showTooltip: 'Show archived',
          showingTooltip: 'Showing archived',
          onPressed: () {},
        ),
      ),
    );

    expect(find.byIcon(Icons.unarchive_rounded), findsOneWidget);
    expect(find.byIcon(Icons.archive_outlined), findsNothing);

    // The IconButton gets a tonal container in the selected state.
    final iconButton = tester.widget<IconButton>(find.byType(IconButton));
    expect(iconButton.style?.backgroundColor, isNotNull);
  });

  testWidgets('exposes the state-specific semantics and invokes onPressed',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrap(
        ArchivedToggleButton(
          isArchived: false,
          showTooltip: 'Show archived',
          showingTooltip: 'Showing archived',
          onPressed: () => tapped = true,
        ),
      ),
    );

    final semantics = tester.getSemantics(find.byType(ArchivedToggleButton));
    expect(semantics.label, 'Show archived');
    expect(semantics.flagsCollection.isButton, isTrue);
    expect(semantics.flagsCollection.isSelected, Tristate.isFalse);

    await tester.tap(find.byType(IconButton));
    expect(tapped, isTrue);
  });

  testWidgets('selected semantics flag is set when archived', (tester) async {
    await tester.pumpWidget(
      wrap(
        ArchivedToggleButton(
          isArchived: true,
          showTooltip: 'Show archived',
          showingTooltip: 'Showing archived',
          onPressed: () {},
        ),
      ),
    );

    final semantics = tester.getSemantics(find.byType(ArchivedToggleButton));
    expect(semantics.label, 'Showing archived');
    expect(semantics.flagsCollection.isSelected, Tristate.isTrue);
  });
}
