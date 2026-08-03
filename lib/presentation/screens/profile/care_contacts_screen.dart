import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/entities/care_contact.dart';
import 'package:rehab_track/domain/enums/enums.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/care_contact_provider.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/widgets/care_contacts/care_contact_list_item.dart';
import 'package:rehab_track/presentation/widgets/empty_state.dart';

/// Care Contacts list: search, type/favorites filters, active/archived view,
/// favorites, and an add action.
class CareContactsScreen extends ConsumerStatefulWidget {
  final bool startArchived;

  const CareContactsScreen({super.key, this.startArchived = false});

  @override
  ConsumerState<CareContactsScreen> createState() => _CareContactsScreenState();
}

class _CareContactsScreenState extends ConsumerState<CareContactsScreen> {
  late CareContactViewMode _viewMode;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewMode = widget.startArchived
        ? CareContactViewMode.archived
        : CareContactViewMode.active;
    _searchController.addListener(() {
      ref
          .read(careContactSearchQueryProvider.notifier)
          .state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArchived = _viewMode == CareContactViewMode.archived;
    final contactsAsync = isArchived
        ? ref.watch(archivedCareContactsProvider)
        : ref.watch(careContactsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArchived ? l10n.archivedContacts : l10n.careContacts,
        ),
        actions: [
          IconButton(
            icon: Icon(
              isArchived ? Icons.people_outline : Icons.archive_outlined,
            ),
            tooltip: isArchived ? l10n.showActive : l10n.showArchived,
            onPressed: () {
              setState(() {
                _viewMode = isArchived
                    ? CareContactViewMode.active
                    : CareContactViewMode.archived;
              });
            },
          ),
        ],
      ),
      floatingActionButton: isArchived
          ? null
          : FloatingActionButton(
              onPressed: () => _openAdd(context),
              tooltip: l10n.addCareContact,
              child: const Icon(Icons.add),
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchContacts,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          if (!isArchived) _buildFilterChips(),
          Expanded(
            child: _buildBody(
              context,
              l10n,
              contactsAsync,
              isArchived,
              ref.watch(
                isArchived
                    ? filteredArchivedCareContactsProvider
                    : filteredCareContactsProvider,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filter = ref.watch(careContactFilterProvider);
    final l10n = AppLocalizations.of(context)!;

    Widget filterButton(
      CareContactFilter value,
      IconData icon,
      IconData selectedIcon,
      String label,
    ) {
      final selected = filter == value;
      final colorScheme = Theme.of(context).colorScheme;
      return Semantics(
        label: label,
        button: true,
        selected: selected,
        child: Tooltip(
          message: label,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () =>
                ref.read(careContactFilterProvider.notifier).state = value,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? colorScheme.secondaryContainer
                    : colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color: selected ? colorScheme.secondary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Icon(
                selected ? selectedIcon : icon,
                color: selected
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          filterButton(
            CareContactFilter.all,
            Icons.people_outline,
            Icons.people,
            l10n.allContacts,
          ),
          filterButton(
            CareContactFilter.doctors,
            Icons.medical_services_outlined,
            Icons.medical_services,
            l10n.doctorOrSpecialist,
          ),
          filterButton(
            CareContactFilter.organizations,
            Icons.business_outlined,
            Icons.business,
            l10n.organizations,
          ),
          filterButton(
            CareContactFilter.insurance,
            Icons.verified_user_outlined,
            Icons.verified_user,
            l10n.insurance,
          ),
          filterButton(
            CareContactFilter.favorites,
            Icons.star_border,
            Icons.star,
            l10n.favorites,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue<List<CareContact>> contactsAsync,
    bool isArchived,
    List<CareContact> filtered,
  ) {
    return contactsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.error)),
      data: (_) {
        if (filtered.isEmpty) {
          if (isArchived) {
            return EmptyState(
              icon: Icons.archive_outlined,
              title: l10n.noArchivedContacts,
              subtitle: l10n.noArchivedContactsDescription,
            );
          }
          final isFiltered =
              isCareContactFilterActive(
                query: ref.read(careContactSearchQueryProvider),
                filter: ref.read(careContactFilterProvider),
              );
          if (isFiltered) {
            return EmptyState(
              icon: Icons.search_off,
              title: l10n.noContactsFound,
              subtitle: l10n.noContactsFoundDescription,
            );
          }
          return EmptyState(
            icon: Icons.contact_phone_outlined,
            title: l10n.noCareContacts,
            subtitle: l10n.noCareContactsDescription,
            actionLabel: l10n.addCareContact,
            onAction: () => _openAdd(context),
          );
        }
        return _buildList(context, l10n, filtered, isArchived);
      },
    );
  }

  Widget _buildList(
    BuildContext context,
    AppLocalizations l10n,
    List<CareContact> contacts,
    bool isArchived,
  ) {
    final query = ref.read(careContactSearchQueryProvider).trim();
    final filter = ref.read(careContactFilterProvider);
    final groupByType =
        !isArchived && query.isEmpty && filter == CareContactFilter.all;

    if (!groupByType) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: contacts.length,
        separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return CareContactListItem(
            contact: contact,
            showArchivedIndicator: isArchived,
            onToggleFavorite:
                isArchived ? null : (c) => _toggleFavorite(context, c),
            onRestore: isArchived ? (c) => _restore(context, l10n, c) : null,
            onTap: () => context.push(AppRoutes.careContactDetails(contact.id!)),
          );
        },
      );
    }

    final grouped = <CareContactType, List<CareContact>>{};
    for (final c in contacts) {
      grouped.putIfAbsent(c.contactType, () => []).add(c);
    }
    final order = [
      CareContactType.doctor,
      CareContactType.clinic,
      CareContactType.laboratory,
      CareContactType.pharmacy,
      CareContactType.insurance,
      CareContactType.other,
    ];
    final sections = order
        .where((t) => grouped[t] != null)
        .map((t) => (type: t, items: grouped[t]!))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                _groupLabel(l10n, section.type),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            ...List.generate(section.items.length, (i) {
              final contact = section.items[i];
              return CareContactListItem(
                contact: contact,
                onToggleFavorite: (c) => _toggleFavorite(context, c),
                onTap: () =>
                    context.push(AppRoutes.careContactDetails(contact.id!)),
              );
            }),
          ],
        );
      },
    );
  }

  String _groupLabel(AppLocalizations l10n, CareContactType type) {
    return switch (type) {
      CareContactType.doctor => l10n.doctorOrSpecialist,
      CareContactType.clinic => l10n.clinicOrHospital,
      CareContactType.laboratory => l10n.laboratory,
      CareContactType.pharmacy => l10n.pharmacy,
      CareContactType.insurance => l10n.insuranceCompany,
      CareContactType.other => l10n.other,
    };
  }

  void _openAdd(BuildContext context) {
    context.push(AppRoutes.careContactAdd);
  }

  Future<void> _toggleFavorite(BuildContext context, CareContact contact) async {
    final repo = ref.read(careContactRepositoryProvider);
    await repo.setFavorite(
      contact.profileId,
      contact.id!,
      !contact.isFavorite,
    );
  }

  Future<void> _restore(
    BuildContext context,
    AppLocalizations l10n,
    CareContact contact,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.restore),
        content: Text(l10n.confirmRestoreContact),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.restore),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final repo = ref.read(careContactRepositoryProvider);
    await repo.restoreContact(contact.profileId, contact.id!);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.contactRestored)),
      );
    }
  }
}
