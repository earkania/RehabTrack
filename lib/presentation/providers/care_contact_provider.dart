import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/domain/entities/care_contact.dart';
import 'package:rehab_track/domain/enums/enums.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';

/// Filter modes for the Care Contacts list.
enum CareContactFilter {
  all,
  doctors,
  organizations,
  insurance,
  favorites,
}

/// Whether the Care Contacts list is showing the active or archived contacts.
enum CareContactViewMode {
  active,
  archived,
}

/// Active (non-archived) contacts for the active profile.
final careContactsProvider =
    StreamProvider.autoDispose<List<CareContact>>((ref) {
  final profileId = ref.watch(currentActiveProfileIdProvider);
  if (profileId == null) return Stream.value(const []);
  return ref.watch(careContactRepositoryProvider).watchActiveContacts(profileId);
});

/// Archived contacts for the active profile.
final archivedCareContactsProvider =
    StreamProvider.autoDispose<List<CareContact>>((ref) {
  final profileId = ref.watch(currentActiveProfileIdProvider);
  if (profileId == null) return Stream.value(const []);
  return ref
      .watch(careContactRepositoryProvider)
      .watchArchivedContacts(profileId);
});

/// Watches a single contact by ID for the active profile. Emits null when the
/// contact does not belong to the active profile.
final careContactByIdProvider =
    StreamProvider.autoDispose.family<CareContact?, int>((ref, contactId) {
  final profileId = ref.watch(currentActiveProfileIdProvider);
  if (profileId == null) return Stream.value(null);
  return ref
      .watch(careContactRepositoryProvider)
      .watchContactById(profileId, contactId);
});

/// Case-insensitive search query applied to the visible contact list.
final careContactSearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

final careContactFilterProvider =
    StateProvider.autoDispose<CareContactFilter>((ref) => CareContactFilter.all);

final careContactViewModeProvider =
    StateProvider.autoDispose<CareContactViewMode>(
  (ref) => CareContactViewMode.active,
);

/// Active contacts filtered by type, favorites, and search query.
final filteredCareContactsProvider =
    Provider.autoDispose<List<CareContact>>((ref) {
  final contacts = ref.watch(careContactsProvider).valueOrNull ?? const [];
  final query = ref.watch(careContactSearchQueryProvider).trim().toLowerCase();
  final filter = ref.watch(careContactFilterProvider);
  return _applyFilters(contacts, query: query, filter: filter);
});

/// Archived contacts filtered by search query only (favorites/type filters are
/// not applied in archived mode so the user can always find and restore).
final filteredArchivedCareContactsProvider =
    Provider.autoDispose<List<CareContact>>((ref) {
  final contacts =
      ref.watch(archivedCareContactsProvider).valueOrNull ?? const [];
  final query = ref.watch(careContactSearchQueryProvider).trim().toLowerCase();
  return _applyFilters(contacts, query: query, filter: CareContactFilter.all);
});

/// Whether any active/type/favorite filter or search is narrowing the list.
/// When filtering is active the list is not grouped by contact type.
bool isCareContactFilterActive({
  required String query,
  required CareContactFilter filter,
}) {
  return query.trim().isNotEmpty || filter != CareContactFilter.all;
}

List<CareContact> _applyFilters(
  List<CareContact> contacts, {
  required String query,
  required CareContactFilter filter,
}) {
  var result = contacts;
  switch (filter) {
    case CareContactFilter.all:
      break;
    case CareContactFilter.doctors:
      result = result
          .where((c) => c.contactType == CareContactType.doctor)
          .toList();
    case CareContactFilter.organizations:
      result = result
          .where((c) => c.contactType != CareContactType.doctor)
          .toList();
    case CareContactFilter.insurance:
      result = result
          .where((c) => c.contactType == CareContactType.insurance)
          .toList();
    case CareContactFilter.favorites:
      result = result.where((c) => c.isFavorite).toList();
  }
  if (query.isEmpty) return result;

  bool matches(CareContact c) {
    bool contains(String? value) =>
        value != null && value.toLowerCase().contains(query);
    return contains(c.effectiveDisplayName) ||
        contains(c.firstName) ||
        contains(c.lastName) ||
        contains(c.specialty) ||
        contains(c.organizationName) ||
        contains(c.department) ||
        contains(c.primaryPhone) ||
        contains(c.secondaryPhone) ||
        contains(c.email);
  }

  return result.where(matches).toList();
}
