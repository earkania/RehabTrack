import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/presentation/widgets/profile/profile_avatar.dart';

void main() {
  Widget buildTestWidget({
    String? firstName,
    String? lastName,
    String? photoPath,
    double radius = 40,
    bool isPrimary = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ProfileAvatar(
          firstName: firstName,
          lastName: lastName,
          photoPath: photoPath,
          radius: radius,
          isPrimary: isPrimary,
        ),
      ),
    );
  }

  group('ProfileAvatar', () {
    group('initials display', () {
      testWidgets('shows first letter of first and last name', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          firstName: 'John',
          lastName: 'Doe',
        ));

        expect(find.text('JD'), findsOneWidget);
      });

      testWidgets('shows uppercase initials', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          firstName: 'john',
          lastName: 'doe',
        ));

        expect(find.text('JD'), findsOneWidget);
      });

      testWidgets('shows ? when no names provided', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.text('?'), findsOneWidget);
      });

      testWidgets('shows first initial when only firstName given', (tester) async {
        await tester.pumpWidget(buildTestWidget(firstName: 'John'));

        expect(find.text('J'), findsOneWidget);
      });

      testWidgets('shows last initial when only lastName given', (tester) async {
        await tester.pumpWidget(buildTestWidget(lastName: 'Doe'));

        expect(find.text('D'), findsOneWidget);
      });

      testWidgets('handles empty string names', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          firstName: '',
          lastName: '',
        ));

        expect(find.text('?'), findsOneWidget);
      });
    });

    group('circle avatar', () {
      testWidgets('renders CircleAvatar', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          firstName: 'John',
          lastName: 'Doe',
        ));

        expect(find.byType(CircleAvatar), findsOneWidget);
      });

      testWidgets('uses custom radius', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          firstName: 'John',
          lastName: 'Doe',
          radius: 60,
        ));

        final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
        expect(avatar.radius, 60);
      });

      testWidgets('has background color based on name', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          firstName: 'John',
          lastName: 'Doe',
        ));

        final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
        expect(avatar.backgroundColor, isNotNull);
      });
    });

    group('primary badge', () {
      testWidgets('shows star icon when isPrimary is true', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          firstName: 'John',
          lastName: 'Doe',
          isPrimary: true,
        ));

        expect(find.byIcon(Icons.star), findsOneWidget);
      });

      testWidgets('hides star icon when isPrimary is false', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          firstName: 'John',
          lastName: 'Doe',
          isPrimary: false,
        ));

        expect(find.byIcon(Icons.star), findsNothing);
      });
    });

    group('photo display', () {
      testWidgets('shows initials when photoPath is null', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          firstName: 'John',
          lastName: 'Doe',
          photoPath: null,
        ));

        expect(find.text('JD'), findsOneWidget);
      });

      testWidgets('shows initials when photoPath points to nonexistent file',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(
          firstName: 'John',
          lastName: 'Doe',
          photoPath: '/nonexistent/path/photo.jpg',
        ));

        expect(find.text('JD'), findsOneWidget);
      });
    });
  });
}
