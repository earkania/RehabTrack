import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/care_contact_provider.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/widgets/care_contacts/care_contact_form.dart';

/// Edit an existing Care Contact.
class EditCareContactScreen extends ConsumerWidget {
  final int contactId;

  const EditCareContactScreen({super.key, required this.contactId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final contactAsync = ref.watch(careContactByIdProvider(contactId));

    return contactAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.editCareContact)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.editCareContact)),
        body: Center(child: Text(l10n.error)),
      ),
      data: (contact) {
        if (contact == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.editCareContact)),
            body: Center(child: Text(l10n.contactNotAvailable)),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(l10n.editCareContact)),
          body: CareContactForm(
            type: contact.contactType,
            initial: contact,
            profileId: contact.profileId,
            onSubmit: (updated) async {
              final repo = ref.read(careContactRepositoryProvider);
              await repo.updateContact(updated);
              if (context.mounted) context.pop(true);
            },
          ),
        );
      },
    );
  }
}
