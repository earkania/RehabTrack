import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/domain/enums/enums.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/widgets/care_contacts/care_contact_form.dart';
import 'package:rehab_track/presentation/widgets/care_contacts/contact_type_selector_sheet.dart';

/// Add a new Care Contact. Prompts for a contact type first (unless one is
/// provided), then shows the type-aware form.
class AddCareContactScreen extends ConsumerStatefulWidget {
  final CareContactType? initialType;

  const AddCareContactScreen({super.key, this.initialType});

  @override
  ConsumerState<AddCareContactScreen> createState() =>
      _AddCareContactScreenState();
}

class _AddCareContactScreenState extends ConsumerState<AddCareContactScreen> {
  CareContactType? _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    if (_selectedType == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _pickType();
      });
    }
  }

  Future<void> _pickType() async {
    final l10n = AppLocalizations.of(context)!;
    final type = await showContactTypeSelector(context, l10n);
    if (type == null) {
      if (!mounted) return;
      context.pop();
      return;
    }
    if (!mounted) return;
    setState(() => _selectedType = type);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selected = _selectedType;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addCareContact)),
      body: selected == null
          ? const Center(child: CircularProgressIndicator())
          : CareContactForm(
              type: selected,
              profileId: ref.watch(currentActiveProfileIdProvider),
              onSubmit: (contact) async {
                final repo = ref.read(careContactRepositoryProvider);
                await repo.createContact(contact);
                if (!context.mounted) return;
                context.pop(true);
              },
            ),
    );
  }
}
