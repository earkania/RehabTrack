import 'package:flutter/material.dart';
import 'package:rehab_track/domain/entities/care_contact.dart';
import 'package:rehab_track/domain/enums/enums.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/utils/care_contact_localizer.dart';
import 'package:rehab_track/presentation/widgets/care_contacts/care_contact_avatar.dart';

/// A single Care Contact row in the list. Shows avatar, display name, type,
/// and relevant secondary details. Never shows policy or member numbers.
class CareContactListItem extends StatelessWidget {
  final CareContact contact;
  final VoidCallback onTap;
  final bool showArchivedIndicator;
  final void Function(CareContact contact)? onToggleFavorite;
  final void Function(CareContact contact)? onRestore;

  const CareContactListItem({
    super.key,
    required this.contact,
    required this.onTap,
    this.showArchivedIndicator = false,
    this.onToggleFavorite,
    this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final subtitleParts = <String>[
      CareContactLocalizer.typeLabel(l10n, contact.contactType),
      if (contact.contactType == _doctor && contact.specialty?.isNotEmpty == true)
        contact.specialty!,
      if (contact.contactType == _doctor &&
          contact.organizationName?.isNotEmpty == true)
        contact.organizationName!,
      if (contact.contactType != _doctor &&
          contact.department?.isNotEmpty == true)
        contact.department!,
    ];

    return Semantics(
      label: contact.effectiveDisplayName,
      button: true,
      excludeSemantics: true,
      child: ListTile(
        leading: CareContactAvatar(contact: contact, radius: 26),
        title: Text(
          contact.effectiveDisplayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subtitleParts.isNotEmpty)
              Text(
                subtitleParts.join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            if (contact.primaryPhone?.isNotEmpty == true)
              Text(
                contact.primaryPhone!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showArchivedIndicator && contact.isArchived) ...[
              Semantics(
                label: l10n.archivedContacts,
                child: Icon(
                  Icons.archive_outlined,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (onToggleFavorite != null) ...[
              if (showArchivedIndicator && contact.isArchived)
                const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  contact.isFavorite ? Icons.star : Icons.star_border,
                  size: 20,
                ),
                onPressed: () => onToggleFavorite!(contact),
                tooltip: contact.isFavorite
                    ? l10n.removeFromFavorites
                    : l10n.addToFavorites,
              ),
            ],
            if (onRestore != null) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.settings_backup_restore, size: 20),
                onPressed: () => onRestore!(contact),
                tooltip: l10n.restore,
              ),
            ],
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  static const _doctor = CareContactType.doctor;
}
