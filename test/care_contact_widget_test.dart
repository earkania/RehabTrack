import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/domain/entities/care_contact.dart';
import 'package:rehab_track/domain/enums/enums.dart';
import 'package:rehab_track/domain/repositories/care_contact_repository.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/screens/profile/care_contacts_screen.dart';
import 'package:rehab_track/presentation/widgets/care_contacts/care_contact_list_item.dart';

class FakeCareContactRepository implements CareContactRepository {
  final List<CareContact> _contacts = [];

  void add(CareContact contact) {
    _contacts.add(contact);
  }

  @override
  Stream<List<CareContact>> watchActiveContacts(int profileId) async* {
    yield _contacts
        .where((c) => c.profileId == profileId && !c.isArchived)
        .toList();
  }

  @override
  Stream<List<CareContact>> watchArchivedContacts(int profileId) async* {
    yield _contacts
        .where((c) => c.profileId == profileId && c.isArchived)
        .toList();
  }

  @override
  Stream<List<CareContact>> watchAllContacts(int profileId) async* {
    yield _contacts.where((c) => c.profileId == profileId).toList();
  }

  @override
  Stream<CareContact?> watchContactById(int profileId, int contactId) async* {
    final matches =
        _contacts.where((c) => c.profileId == profileId && c.id == contactId);
    yield matches.isEmpty ? null : matches.first;
  }

  @override
  Future<CareContact?> getContactById(int profileId, int contactId) async {
    final matches =
        _contacts.where((c) => c.profileId == profileId && c.id == contactId);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<int> createContact(CareContact contact) async {
    _contacts.add(contact);
    return _contacts.length;
  }

  @override
  Future<void> updateContact(CareContact contact) async {}

  @override
  Future<void> archiveContact(int profileId, int contactId) async {}

  @override
  Future<void> restoreContact(int profileId, int contactId) async {}

  @override
  Future<void> deleteContact(int profileId, int contactId) async {}

  @override
  Future<void> setFavorite(int profileId, int contactId, bool favorite) async {}
}

Widget wrapWithRouter(Widget home, {List<Override> overrides = const []}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => home,
      ),
      GoRoute(
        path: '/profile/contacts/new',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('ADD_PLACEHOLDER')),
        ),
      ),
      GoRoute(
        path: '/profile/contacts/:id',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('DETAILS_PLACEHOLDER')),
        ),
      ),
      GoRoute(
        path: '/profile/contacts/:id/edit',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('EDIT_PLACEHOLDER')),
        ),
      ),
    ],
  );
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

List<Override> repoOverrides(FakeCareContactRepository repo) {
  return [
    careContactRepositoryProvider.overrideWithValue(repo),
    currentActiveProfileIdProvider.overrideWith((ref) => 1),
  ];
}

/// Wider surface for filter-bar tests that tap multiple icon buttons.
void useWideSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1600, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
}

CareContact makeContact({
  int id = 1,
  int profileId = 1,
  CareContactType type = CareContactType.doctor,
  String displayName = 'Dr. Smith',
  bool isFavorite = false,
  bool isArchived = false,
}) {
  final now = DateTime(2026);
  return CareContact(
    id: id,
    profileId: profileId,
    contactType: type,
    displayName: displayName,
    createdAt: now,
    updatedAt: now,
    isFavorite: isFavorite,
    isArchived: isArchived,
  );
}

void main() {
  group('CareContactListItem', () {
    testWidgets('shows display name, type, and phone but not sensitive fields',
        (tester) async {
      final now = DateTime(2026);
      final contact = CareContact(
        id: 1,
        profileId: 1,
        contactType: CareContactType.insurance,
        displayName: 'Geo Insurance',
        organizationName: 'Geo Insurance',
        primaryPhone: '555-0100',
        policyNumber: 'POL-SECRET',
        memberNumber: 'MEM-SECRET',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(wrapWithRouter(
        Scaffold(
          body: CareContactListItem(
            contact: contact,
            onTap: () {},
          ),
        ),
      ));

      expect(find.text('Geo Insurance'), findsOneWidget);
      expect(find.text('555-0100'), findsOneWidget);
      expect(find.text('POL-SECRET'), findsNothing);
      expect(find.text('MEM-SECRET'), findsNothing);
    });

    testWidgets('shows single favorite toggle and archived indicator',
        (tester) async {
      final now = DateTime(2026);
      final contact = CareContact(
        id: 1,
        profileId: 1,
        contactType: CareContactType.doctor,
        displayName: 'Dr. Smith',
        isFavorite: true,
        isArchived: true,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(wrapWithRouter(
        Scaffold(
          body: CareContactListItem(
            contact: contact,
            onTap: () {},
            showArchivedIndicator: true,
            onToggleFavorite: (_) {},
          ),
        ),
      ));

      // One canonical favorite control: a filled star toggle (not a duplicate
      // indicator plus toggle).
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsNothing);
      expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
    });

    testWidgets('favorite toggle uses outlined star when not favorite',
        (tester) async {
      final now = DateTime(2026);
      final contact = CareContact(
        id: 1,
        profileId: 1,
        contactType: CareContactType.doctor,
        displayName: 'Dr. Smith',
        isFavorite: false,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(wrapWithRouter(
        Scaffold(
          body: CareContactListItem(
            contact: contact,
            onTap: () {},
            onToggleFavorite: (_) {},
          ),
        ),
      ));

      expect(find.byIcon(Icons.star), findsNothing);
      expect(find.byIcon(Icons.star_border), findsOneWidget);
    });
  });

  group('CareContactsScreen', () {
    testWidgets('shows five fixed icon-only filter buttons', (tester) async {
      final repo = FakeCareContactRepository();

      await tester.pumpWidget(wrapWithRouter(
        const CareContactsScreen(),
        overrides: repoOverrides(repo),
      ));
      await tester.pump();
      await tester.pump();

      for (final label in [
        'All Contacts',
        'Doctor or Specialist',
        'Organizations',
        'Insurance',
        'Favorites',
      ]) {
        expect(find.byTooltip(label), findsOneWidget);
      }
    });

    testWidgets('add button is a compact plus-only FAB', (tester) async {
      final repo = FakeCareContactRepository();

      await tester.pumpWidget(wrapWithRouter(
        const CareContactsScreen(),
        overrides: repoOverrides(repo),
      ));
      await tester.pump();
      await tester.pump();

      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      // No extended label: the FAB contains only an add icon.
      expect(
        find.descendant(of: fab, matching: find.byIcon(Icons.add)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: fab, matching: find.byType(Text)),
        findsNothing,
      );
    });

    testWidgets('tapping the favorite star does not open details',
        (tester) async {
      final repo = FakeCareContactRepository();
      repo.add(makeContact(id: 42, displayName: 'Dr. Alice'));

      await tester.pumpWidget(wrapWithRouter(
        const CareContactsScreen(),
        overrides: repoOverrides(repo),
      ));
      await tester.pump();
      await tester.pump();

      final star = find.descendant(
        of: find.byType(CareContactListItem),
        matching: find.byIcon(Icons.star_border),
      );
      expect(star, findsOneWidget);
      await tester.tap(star);
      await tester.pump();
      await tester.pump();

      // Still on the list screen, no navigation to details.
      expect(find.text('DETAILS_PLACEHOLDER'), findsNothing);
      expect(find.text('Dr. Alice'), findsOneWidget);
    });
  });

  group('CareContactsScreen', () {
    testWidgets('shows empty state when there are no contacts', (tester) async {
      final repo = FakeCareContactRepository();

      await tester.pumpWidget(wrapWithRouter(
        const CareContactsScreen(),
        overrides: repoOverrides(repo),
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('Care Contacts'), findsWidgets);
      expect(find.text('No care contacts yet'), findsOneWidget);
      expect(find.text('Add Care Contact'), findsWidgets);
    });

    testWidgets('renders contact rows and groups them by type', (tester) async {
      final repo = FakeCareContactRepository();
      repo.add(makeContact(id: 1, displayName: 'Dr. Alice'));
      repo.add(makeContact(
        id: 2,
        type: CareContactType.clinic,
        displayName: 'City Clinic',
      ));

      await tester.pumpWidget(wrapWithRouter(
        const CareContactsScreen(),
        overrides: repoOverrides(repo),
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('Dr. Alice'), findsOneWidget);
      expect(find.text('City Clinic'), findsOneWidget);
      // Group headers.
      expect(find.text('Doctor or Specialist'), findsWidgets);
      expect(find.text('Clinic or Hospital'), findsWidgets);
    });

    testWidgets('filter chip narrows the list', (tester) async {
      final repo = FakeCareContactRepository();
      repo.add(makeContact(id: 1, displayName: 'Dr. Alice'));
      repo.add(makeContact(
        id: 2,
        type: CareContactType.clinic,
        displayName: 'City Clinic',
      ));

      await tester.pumpWidget(wrapWithRouter(
        const CareContactsScreen(),
        overrides: repoOverrides(repo),
      ));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byTooltip('Organizations'));
      await tester.pump();
      await tester.pump();

      expect(find.text('City Clinic'), findsOneWidget);
      expect(find.text('Dr. Alice'), findsNothing);
    });

    testWidgets('search narrows the list', (tester) async {
      final repo = FakeCareContactRepository();
      repo.add(makeContact(id: 1, displayName: 'Dr. Alice'));
      repo.add(makeContact(id: 2, displayName: 'Dr. Bob'));

      await tester.pumpWidget(wrapWithRouter(
        const CareContactsScreen(),
        overrides: repoOverrides(repo),
      ));
      await tester.pump();
      await tester.pump();

      await tester.enterText(
        find.byType(TextField).first,
        'alice',
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Dr. Alice'), findsOneWidget);
      expect(find.text('Dr. Bob'), findsNothing);
    });

    testWidgets('tapping a row opens details route', (tester) async {
      final repo = FakeCareContactRepository();
      repo.add(makeContact(id: 42, displayName: 'Dr. Alice'));

      await tester.pumpWidget(wrapWithRouter(
        const CareContactsScreen(),
        overrides: repoOverrides(repo),
      ));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Dr. Alice'));
      await tester.pump();
      await tester.pump();

      expect(find.text('DETAILS_PLACEHOLDER'), findsOneWidget);
    });

    testWidgets('favorites filter shows only favorites', (tester) async {
      useWideSurface(tester);
      final repo = FakeCareContactRepository();
      repo.add(makeContact(
        id: 1,
        displayName: 'Dr. Fav',
        isFavorite: true,
      ));
      repo.add(makeContact(id: 2, displayName: 'Dr. Plain'));

      await tester.pumpWidget(wrapWithRouter(
        const CareContactsScreen(),
        overrides: repoOverrides(repo),
      ));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byTooltip('Favorites'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Dr. Fav'), findsOneWidget);
      expect(find.text('Dr. Plain'), findsNothing);
    });

    testWidgets('archived toggle shows archived contacts', (tester) async {
      final repo = FakeCareContactRepository();
      repo.add(makeContact(id: 1, displayName: 'Dr. Old', isArchived: true));

      await tester.pumpWidget(wrapWithRouter(
        const CareContactsScreen(),
        overrides: repoOverrides(repo),
      ));
      await tester.pump();
      await tester.pump();

      // Active view: FAB is present.
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // The app-bar action toggles to archived view (tooltip 'Show archived').
      await tester.tap(find.byTooltip('Show archived'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Archived Contacts'), findsWidgets);
      expect(find.text('Dr. Old'), findsOneWidget);
      // No FAB in archived mode (hero flight animation settled).
      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });
}
