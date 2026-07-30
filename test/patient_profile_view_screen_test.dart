import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/profile.dart';
import 'package:rehab_track/domain/repositories/profile_repository.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/screens/settings/patient_profile_view_screen.dart';

class FakeProfileRepository implements ProfileRepository {
  final Map<int, Profile> _profiles = {};
  int _nextId = 1;

  void addProfile(Profile profile) {
    final id = profile.id ?? _nextId++;
    _profiles[id] = profile.copyWith(id: id);
  }

  @override
  Stream<Profile?> watchActiveProfile(int profileId) {
    return Stream.value(_profiles[profileId]);
  }

  @override
  Future<Profile?> getActiveProfile(int profileId) async =>
      _profiles[profileId];

  @override
  Future<int> createProfile(Profile profile) async {
    final id = _nextId++;
    _profiles[id] = profile.copyWith(id: id);
    return id;
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    if (profile.id != null) _profiles[profile.id!] = profile;
  }

  @override
  Future<void> deleteProfile(int id) async {
    _profiles.remove(id);
  }

  @override
  Stream<List<Profile>> watchAllProfiles() async* {
    yield _profiles.values.toList();
  }

  @override
  Future<List<Profile>> getAllProfiles() async =>
      _profiles.values.toList();

  @override
  Future<void> setPrimaryProfile(int profileId) async {}

  @override
  Future<int> getProfileCount() async => _profiles.length;
}

Widget wrapScreen({
  int? activeProfileId,
  FakeProfileRepository? fakeRepo,
}) {
  final repo = fakeRepo ?? FakeProfileRepository();
  return ProviderScope(
    overrides: [
      profileRepositoryProvider.overrideWithValue(repo),
      if (activeProfileId != null)
        currentActiveProfileIdProvider.overrideWith((ref) => activeProfileId),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const PatientProfileViewScreen(),
    ),
  );
}

void main() {
  Profile makeProfile(
    int id, {
    String firstName = 'John',
    String lastName = 'Doe',
  }) {
    return Profile(
      id: id,
      firstName: firstName,
      lastName: lastName,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      isPrimary: true,
      isActive: true,
    );
  }

  group('PatientProfileViewScreen', () {
    testWidgets('exits loading state and shows content', (tester) async {
      final repo = FakeProfileRepository();
      repo.addProfile(makeProfile(1));

      await tester.pumpWidget(wrapScreen(
        activeProfileId: 1,
        fakeRepo: repo,
      ));

      // Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Pump to let stream emit
      await tester.pump();
      await tester.pump();

      // Loading should be gone, profile content should appear
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Patient Profile'), findsOneWidget);
    });

    testWidgets('empty valid profile shows editable empty state',
        (tester) async {
      final repo = FakeProfileRepository();
      repo.addProfile(makeProfile(1, firstName: '', lastName: ''));

      await tester.pumpWidget(wrapScreen(
        activeProfileId: 1,
        fakeRepo: repo,
      ));

      await tester.pump();
      await tester.pump();

      expect(find.text('Patient Profile'), findsOneWidget);
      expect(
        find.text('Profile information has not been entered yet.'),
        findsOneWidget,
      );
    });

    testWidgets('edit action is visible for empty profile', (tester) async {
      final repo = FakeProfileRepository();
      repo.addProfile(makeProfile(1, firstName: '', lastName: ''));

      await tester.pumpWidget(wrapScreen(
        activeProfileId: 1,
        fakeRepo: repo,
      ));

      await tester.pump();
      await tester.pump();

      // The "Add Profile Information" button should be visible
      expect(find.text('Add Profile Information'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsWidgets);
    });

    testWidgets('populated profile displays values', (tester) async {
      final repo = FakeProfileRepository();
      repo.addProfile(makeProfile(1, firstName: 'Alice', lastName: 'Smith'));

      await tester.pumpWidget(wrapScreen(
        activeProfileId: 1,
        fakeRepo: repo,
      ));

      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.text('Alice Smith'), findsOneWidget);
      expect(find.text('Personal Information'), findsOneWidget);
    });

    testWidgets('missing profile displays recovery UI', (tester) async {
      final repo = FakeProfileRepository();
      // No profiles added

      await tester.pumpWidget(wrapScreen(
        activeProfileId: 999,
        fakeRepo: repo,
      ));

      await tester.pump();
      await tester.pump();

      expect(find.text('Profile not set up'), findsOneWidget);
      expect(find.byIcon(Icons.person_add_outlined), findsOneWidget);
      expect(find.text('Add Profile Information'), findsOneWidget);
    });

    testWidgets('no active profile ID displays recovery UI', (tester) async {
      await tester.pumpWidget(wrapScreen(activeProfileId: null));

      await tester.pump();
      await tester.pump();

      expect(find.text('Profile not set up'), findsOneWidget);
      expect(find.byIcon(Icons.person_add_outlined), findsOneWidget);
    });

    testWidgets(
        'no infinite CircularProgressIndicator after provider settles',
        (tester) async {
      final repo = FakeProfileRepository();
      repo.addProfile(makeProfile(1));

      await tester.pumpWidget(wrapScreen(
        activeProfileId: 1,
        fakeRepo: repo,
      ));

      // Pump multiple times to ensure the provider fully settles
      for (var i = 0; i < 10; i++) {
        await tester.pump();
      }

      // The CircularProgressIndicator should NOT be present
      // (the profile content should be showing instead)
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Patient Profile'), findsOneWidget);
    });

    testWidgets('AppBar edit icon is visible', (tester) async {
      final repo = FakeProfileRepository();
      repo.addProfile(makeProfile(1, firstName: 'Test', lastName: 'User'));

      await tester.pumpWidget(wrapScreen(
        activeProfileId: 1,
        fakeRepo: repo,
      ));

      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('personal information section shows unavailable for empty fields',
        (tester) async {
      final repo = FakeProfileRepository();
      repo.addProfile(makeProfile(1, firstName: 'Test', lastName: 'User'));

      await tester.pumpWidget(wrapScreen(
        activeProfileId: 1,
        fakeRepo: repo,
      ));

      await tester.pump();
      await tester.pump();

      expect(find.text('Birth Date'), findsOneWidget);
      expect(find.text('Unavailable'), findsWidgets);
    });

    testWidgets('profile sections are present', (tester) async {
      final repo = FakeProfileRepository();
      repo.addProfile(makeProfile(1, firstName: 'Test', lastName: 'User'));

      await tester.pumpWidget(wrapScreen(
        activeProfileId: 1,
        fakeRepo: repo,
      ));

      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.text('Personal Information'), findsOneWidget);
    });
  });
}
