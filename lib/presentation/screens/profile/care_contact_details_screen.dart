import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/entities/care_contact.dart';
import 'package:rehab_track/domain/enums/enums.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/care_contact_provider.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/utils/care_contact_actions.dart';
import 'package:rehab_track/presentation/utils/care_contact_localizer.dart';
import 'package:rehab_track/presentation/widgets/care_contacts/care_contact_avatar.dart';

/// Care Contact details with call/email/website/address actions, favorites,
/// archive/restore, and deliberate permanent deletion.
class CareContactDetailsScreen extends ConsumerWidget {
  final int contactId;

  const CareContactDetailsScreen({super.key, required this.contactId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final contactAsync = ref.watch(careContactByIdProvider(contactId));

    return contactAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.careContactDetails)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.careContactDetails)),
        body: Center(child: Text(l10n.error)),
      ),
      data: (contact) {
        if (contact == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.careContactDetails)),
            body: Center(child: Text(l10n.contactNotAvailable)),
          );
        }
        return _ContactDetailsView(contact: contact);
      },
    );
  }
}

class _ContactDetailsView extends ConsumerWidget {
  final CareContact contact;

  const _ContactDetailsView({required this.contact});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final showCall = hasPhone(contact.primaryPhone) ||
        hasPhone(contact.secondaryPhone);
    final showEmail = hasEmail(contact.email);
    final showWebsite = contact.website?.trim().isNotEmpty == true;
    final showAddress = contact.address?.trim().isNotEmpty == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.careContactDetails),
        actions: [
          IconButton(
            icon: Icon(
              contact.isFavorite ? Icons.star : Icons.star_border,
            ),
            tooltip: contact.isFavorite
                ? l10n.removeFromFavorites
                : l10n.addToFavorites,
            onPressed: () async {
              final repo = ref.read(careContactRepositoryProvider);
              await repo.setFavorite(
                contact.profileId,
                contact.id!,
                !contact.isFavorite,
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'edit':
                  context.push(AppRoutes.careContactEdit(contact.id!));
                case 'archive':
                  await _confirmArchive(context, ref, l10n);
                case 'restore':
                  await _restore(context, ref, l10n);
                case 'delete':
                  await _confirmDelete(context, ref, l10n);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.edit_outlined),
                  title: Text(l10n.edit),
                ),
              ),
              if (!contact.isArchived)
                PopupMenuItem(
                  value: 'archive',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.archive_outlined),
                    title: Text(l10n.archive),
                  ),
                ),
              if (contact.isArchived)
                PopupMenuItem(
                  value: 'restore',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.settings_backup_restore),
                    title: Text(l10n.restore),
                  ),
                ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.delete_outline,
                    color: colorScheme.error,
                  ),
                  title: Text(
                    l10n.deletePermanently,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CareContactAvatar(contact: contact, radius: 48),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              contact.effectiveDisplayName,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              CareContactLocalizer.typeLabel(l10n, contact.contactType),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (contact.isArchived)
            Center(
              child: Chip(
                avatar: const Icon(Icons.archive_outlined, size: 18),
                label: Text(l10n.archivedContacts),
              ),
            ),
          if (showCall || showEmail || showWebsite || showAddress) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (showCall)
                  _ActionChip(
                    icon: Icons.call_outlined,
                    label: l10n.call,
                    onPressed: () => _call(context, l10n),
                  ),
                if (showEmail)
                  _ActionChip(
                    icon: Icons.email_outlined,
                    label: l10n.sendEmail,
                    onPressed: () => _email(context, l10n),
                  ),
                if (showWebsite)
                  _ActionChip(
                    icon: Icons.language_outlined,
                    label: l10n.openWebsite,
                    onPressed: () => _website(context, l10n),
                  ),
                if (showAddress)
                  _ActionChip(
                    icon: Icons.map_outlined,
                    label: l10n.openAddress,
                    onPressed: () => _address(context, l10n),
                  ),
              ],
            ),
          ],
          if (contact.contactType == CareContactType.doctor) ...[
            _section(context, l10n.professionalInformation, [
              if (contact.specialty?.trim().isNotEmpty == true)
                _infoTile(Icons.work_outline, l10n.specialty, contact.specialty!),
              if (contact.organizationName?.trim().isNotEmpty == true)
                _infoTile(Icons.business_outlined, l10n.organization,
                    contact.organizationName!),
              if (contact.department?.trim().isNotEmpty == true)
                _infoTile(Icons.account_tree_outlined, l10n.department,
                    contact.department!),
            ]),
          ],
          if (contact.contactType.isOrganization) ...[
            _section(context, l10n.organizationInformation, [
              if (contact.organizationName?.trim().isNotEmpty == true)
                _infoTile(Icons.business_outlined, l10n.organizationName,
                    contact.organizationName!),
              if (contact.contactPerson?.trim().isNotEmpty == true)
                _infoTile(Icons.person_outline, l10n.contactPerson,
                    contact.contactPerson!),
              if (contact.department?.trim().isNotEmpty == true)
                _infoTile(Icons.account_tree_outlined, l10n.department,
                    contact.department!),
            ]),
          ],
          _section(context, l10n.contactInformation, [
            if (hasPhone(contact.primaryPhone))
              _infoTile(Icons.phone_outlined, l10n.primaryPhone,
                  contact.primaryPhone!),
            if (hasPhone(contact.secondaryPhone))
              _infoTile(Icons.phone_outlined, l10n.secondaryPhone,
                  contact.secondaryPhone!),
            if (hasEmail(contact.email))
              _infoTile(Icons.email_outlined, l10n.email, contact.email!),
            if (contact.website?.trim().isNotEmpty == true)
              _infoTile(Icons.language_outlined, l10n.website,
                  contact.website!),
            if (contact.address?.trim().isNotEmpty == true)
              _infoTile(
                  Icons.location_on_outlined, l10n.address, contact.address!),
            if (contact.workingHours?.trim().isNotEmpty == true)
              _infoTile(Icons.schedule_outlined, l10n.workingHours,
                  contact.workingHours!),
          ]),
          if (contact.contactType == CareContactType.insurance) ...[
            _section(context, l10n.policyAndMemberDetails, [
              if (contact.policyNumber?.trim().isNotEmpty == true)
                _infoTile(Icons.badge_outlined, l10n.policyNumber,
                    contact.policyNumber!),
              if (contact.memberNumber?.trim().isNotEmpty == true)
                _infoTile(Icons.credit_card_outlined, l10n.memberNumber,
                    contact.memberNumber!),
            ]),
          ],
          if (contact.notes?.trim().isNotEmpty == true)
            _section(context, l10n.notes, [
              _infoTile(Icons.notes_outlined, '', contact.notes!),
            ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: label.isNotEmpty ? Text(label) : null,
      subtitle: Text(value),
      dense: true,
    );
  }

  Future<void> _call(BuildContext context, AppLocalizations l10n) async {
    final phone = contact.primaryPhone?.trim().isNotEmpty == true
        ? contact.primaryPhone!
        : contact.secondaryPhone ?? '';
    final ok = await launchCall(phone);
    if (!ok && context.mounted) showActionFailed(context, l10n.actionFailed);
  }

  Future<void> _email(BuildContext context, AppLocalizations l10n) async {
    final ok = await launchEmail(contact.email!);
    if (!ok && context.mounted) showActionFailed(context, l10n.actionFailed);
  }

  Future<void> _website(BuildContext context, AppLocalizations l10n) async {
    final ok = await launchWebsite(contact.website!);
    if (!ok && context.mounted) showActionFailed(context, l10n.actionFailed);
  }

  Future<void> _address(BuildContext context, AppLocalizations l10n) async {
    final ok = await launchAddress(contact.address!);
    if (!ok && context.mounted) showActionFailed(context, l10n.actionFailed);
  }

  Future<void> _confirmArchive(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.archive),
        content: Text(l10n.confirmArchiveContact),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.archive),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final repo = ref.read(careContactRepositoryProvider);
    await repo.archiveContact(contact.profileId, contact.id!);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.contactArchived)),
      );
      context.pop();
    }
  }

  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final repo = ref.read(careContactRepositoryProvider);
    await repo.restoreContact(contact.profileId, contact.id!);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.contactRestored)),
      );
      context.pop();
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deletePermanently),
        content: Text(l10n.confirmDeleteContact),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final repo = ref.read(careContactRepositoryProvider);
    await repo.deleteContact(contact.profileId, contact.id!);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.contactDeleted)),
      );
      context.pop();
    }
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}
