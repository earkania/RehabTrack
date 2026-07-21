import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rehab_track/app.dart';

void main() {
  testWidgets('App renders with bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RehabTrackApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsAtLeastNWidgets(1));
    expect(find.text('Health'), findsAtLeastNWidgets(1));
    expect(find.text('Activities'), findsAtLeastNWidgets(1));
    expect(find.text('Records'), findsAtLeastNWidgets(1));
    expect(find.text('Settings'), findsAtLeastNWidgets(1));
  });
}
