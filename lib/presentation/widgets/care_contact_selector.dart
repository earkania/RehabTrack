import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import 'package:rehab_track/domain/entities/care_contact.dart';
import 'package:rehab_track/domain/enums/enums.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/care_contact_provider.dart';

/// Selector widget for picking a care contact
class CareContactSelector extends ConsumerWidget {
  const CareContactSelector({
    super.key,
    required this.label,
    this.selectedContactId,
    this.allowedTypes,
    this.onChanged,
    this.allowEmpty = true,
  });

  final String label;
  final int? selectedContactId;
  final List<String>? allowedTypes;
  final ValueChanged<int?>? onChanged;
  final bool allowEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final contactsAsync = ref.watch(careContactsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        contactsAsync.when(
          data: (contacts) {
            final filtered = contacts.where((c) {
              if (allowedTypes != null && allowedTypes!.isNotEmpty) {
                return allowedTypes!.contains(c.contactType.name);
              }
              return true;
            }).toList();

            final selected = selectedContactId != null
                ? contacts.firstWhereOrNull((c) => c.id == selectedContactId)
                : null;

            return InkWell(
              onTap: () async {
                final result = await showModalBottomSheet<int?>(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => _ContactSelectionSheet(
                    contacts: filtered,
                    initialSelection: selectedContactId,
                  ),
                );
                if (result != null && onChanged != null) {
                  onChanged!(result);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  selected?.effectiveDisplayName.isNotEmpty == true
                      ? selected!.effectiveDisplayName
                      : (allowEmpty
                          ? l10n.selectContact
                          : l10n.noEligibleContacts),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: selected != null
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            );
          },
          loading: () => InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            child: Text(
              l10n.loading,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          error: (error, stack) => InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              errorText: error.toString(),
            ),
            child: const SizedBox.shrink(),
          ),
        ),
        if (selectedContactId != null && onChanged != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: () => onChanged!(null),
              icon: const Icon(Icons.clear),
              label: Text(l10n.clearSelection),
            ),
          ),
      ],
    );
  }
}

class _ContactSelectionSheet extends StatelessWidget {
  const _ContactSelectionSheet({
    required this.contacts,
    required this.initialSelection,
  });

  final List<CareContact> contacts;
  final int? initialSelection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  l10n.selectContact,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: contacts.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.contacts_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noEligibleContacts,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.noContactsFoundDescription,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: contacts.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      final name = contact.effectiveDisplayName;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Text(
                            name.isNotEmpty
                                ? name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          name.isEmpty ? l10n.untitledContact : name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(_contactSubtitle(context, contact)),
trailing: Icon(
  initialSelection == contact.id
      ? Icons.check_circle
      : Icons.circle_outlined,
  color: initialSelection == contact.id
      ? Theme.of(context).colorScheme.primary
      : Theme.of(context).colorScheme.onSurfaceVariant,
),
onTap: () => Navigator.pop(context, contact.id),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: Text(l10n.clearSelection),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _contactTypeLabel(BuildContext context, CareContactType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case CareContactType.doctor:
        return l10n.doctorOrSpecialist;
      case CareContactType.clinic:
        return l10n.clinicOrHospital;
      case CareContactType.laboratory:
        return l10n.laboratory;
      case CareContactType.pharmacy:
        return l10n.pharmacy;
      case CareContactType.insurance:
        return l10n.insuranceCompany;
      default:
        return l10n.other;
    }
  }

  String _contactSubtitle(BuildContext context, CareContact contact) {
    final typeLabel = _contactTypeLabel(context, contact.contactType);
    final secondary = <String>[
      if (contact.contactType == CareContactType.doctor &&
          contact.specialty != null &&
          contact.specialty!.isNotEmpty)
        contact.specialty!,
      if (contact.organizationName != null &&
          contact.organizationName!.isNotEmpty &&
          contact.organizationName != contact.effectiveDisplayName)
        contact.organizationName!,
      if (contact.department != null && contact.department!.isNotEmpty)
        contact.department!,
      if (contact.primaryPhone != null && contact.primaryPhone!.isNotEmpty)
        contact.primaryPhone!,
    ];
    if (secondary.isEmpty) return typeLabel;
    return '$typeLabel · ${secondary.join(' · ')}';
  }
}