import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/profile.dart';
import 'package:rehab_track/domain/repositories/profile_repository.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/screens/settings/patient_profile_edit_screen.dart';

const List<String> _expectedBloodTypes = <String>[
  'O(I) Rh+',
  'O(I) Rh-',
  'A(II) Rh+',
  'A(II) Rh-',
  'B(III) Rh+',
  'B(III) Rh-',
  'AB(IV) Rh+',
  'AB(IV) Rh-',
];

class FakeProfileRepository implements ProfileRepository {
  final Map<int, Profile> _profiles = {};
  int _nextId = 1;

  Profile? getSavedProfile(int id) => _profiles[id];

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
  Future<List<Profile>> getAllProfiles() async => _profiles.values.toList();

  @override
  Future<void> setPrimaryProfile(int profileId) async {}

  @override
  Future<int> getProfileCount() async => _profiles.length;
}

Widget wrapScreen({required FakeProfileRepository repo, int? activeProfileId}) {
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
      home: const PatientProfileEditScreen(),
    ),
  );
}

Profile makeProfile(int id,
    {String firstName = 'Test',
    String lastName = 'User',
    String? bloodType}) {
  return Profile(
    id: id,
    firstName: firstName,
    lastName: lastName,
    bloodType: bloodType,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    isPrimary: true,
    isActive: true,
  );
}

Future<void> pumpEditScreen(
  WidgetTester tester,
  FakeProfileRepository repo, {
  int? activeProfileId,
}) async {
  tester.view.physicalSize = const Size(900, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() => tester.view.resetPhysicalSize());
  await tester.pumpWidget(wrapScreen(
    repo: repo,
    activeProfileId: activeProfileId,
  ));
  await tester.pumpAndSettle();
}

Finder bloodTypeDropdown() => find.byKey(const ValueKey('bloodTypeField'));

Future<void> openBloodTypeDropdown(WidgetTester tester) async {
  await tester.ensureVisible(bloodTypeDropdown());
  await tester.pumpAndSettle();
  await tester.tap(bloodTypeDropdown());
  await tester.pumpAndSettle();
}

Future<void> selectBloodType(WidgetTester tester, String value) async {
  await openBloodTypeDropdown(tester);
  await tester.tap(
    find.widgetWithText(DropdownMenuItem<String>, value),
  );
  await tester.pumpAndSettle();
}

Finder saveButton() => find.widgetWithText(FilledButton, 'Save');

Future<void> save(WidgetTester tester) async {
  await tester.ensureVisible(saveButton());
  await tester.pumpAndSettle();
  await tester.tap(saveButton());
  await tester.pumpAndSettle();
}

void main() {
  group('PatientProfileEditScreen blood type dropdown', () {
    testWidgets('blood type is a dropdown, not a free-text field',
        (tester) async {
      final repo = FakeProfileRepository();
      repo.addProfile(makeProfile(1));
      await pumpEditScreen(tester, repo, activeProfileId: 1);

      expect(bloodTypeDropdown(), findsOneWidget);
    });

    testWidgets('dropdown exposes all 8 canonical blood types',
        (tester) async {
      final repo = FakeProfileRepository();
      repo.addProfile(makeProfile(1));
      await pumpEditScreen(tester, repo, activeProfileId: 1);

      await openBloodTypeDropdown(tester);

      for (final type in _expectedBloodTypes) {
        expect(find.text(type), findsWidgets,
            reason: 'Expected $type to be present in the dropdown');
      }
    });

    testWidgets('selecting O(I) Rh+ and saving persists it; reopening preserves',
        (tester) async {
      final repo = FakeProfileRepository();
      repo.addProfile(makeProfile(1));
      await pumpEditScreen(tester, repo, activeProfileId: 1);

      await selectBloodType(tester, 'O(I) Rh+');
      await save(tester);

      expect(repo.getSavedProfile(1)!.bloodType, 'O(I) Rh+');

      // Reopen the screen (fresh widget tree) from the persisted data.
      await pumpEditScreen(tester, repo, activeProfileId: 1);
      expect(find.text('O(I) Rh+'), findsOneWidget);
    });

    testWidgets('changing to AB(IV) Rh- and saving persists it',
        (tester) async {
      final repo = FakeProfileRepository();
      repo.addProfile(makeProfile(1, bloodType: 'O(I) Rh+'));
      await pumpEditScreen(tester, repo, activeProfileId: 1);

      await selectBloodType(tester, 'AB(IV) Rh-');
      await save(tester);

      expect(repo.getSavedProfile(1)!.bloodType, 'AB(IV) Rh-');

      await pumpEditScreen(tester, repo, activeProfileId: 1);
      expect(find.text('AB(IV) Rh-'), findsOneWidget);
    });

    testWidgets('existing canonical stored value is selected on load',
        (tester) async {
      final repo = FakeProfileRepository();
      repo.addProfile(makeProfile(1, bloodType: 'B(III) Rh+'));
      await pumpEditScreen(tester, repo, activeProfileId: 1);

      expect(find.text('B(III) Rh+'), findsOneWidget);
    });

    testWidgets('unrelated save preserves an unset (optional) blood type',
        (tester) async {
      final repo = FakeProfileRepository();
      repo.addProfile(makeProfile(1)); // bloodType is null
      await pumpEditScreen(tester, repo, activeProfileId: 1);

      expect(find.text('Select blood type'), findsOneWidget);

      await save(tester);

      expect(repo.getSavedProfile(1)!.bloodType, isNull);
    });

    testWidgets('legacy noncanonical value does not crash and is preserved',
        (tester) async {
      final repo = FakeProfileRepository();
      repo.addProfile(makeProfile(1, bloodType: 'O+'));
      await pumpEditScreen(tester, repo, activeProfileId: 1);

      // No crash; no canonical value is shown as selected (field shows the
      // unselected/"select" hint state instead).
      expect(find.text('O(I) Rh+'), findsNothing);
      expect(find.text('Select blood type'), findsOneWidget);

      // Saving without touching blood type preserves the legacy value.
      await save(tester);

      expect(repo.getSavedProfile(1)!.bloodType, 'O+');
    });
  });
}
