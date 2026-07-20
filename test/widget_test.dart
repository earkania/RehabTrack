import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_track/app.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const RehabTrackApp());
    expect(find.text('Today'), findsOneWidget);
  });
}
