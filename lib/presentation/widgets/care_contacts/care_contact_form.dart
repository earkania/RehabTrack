import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rehab_track/domain/entities/care_contact.dart';
import 'package:rehab_track/domain/enums/enums.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/utils/care_contact_localizer.dart';
import 'package:rehab_track/presentation/widgets/care_contacts/care_contact_avatar.dart';

/// Type-aware Care Contact form shared by the Add and Edit screens. Handles
/// validation, whitespace trimming, nullable-field normalization, and photo
/// selection. Submits a fully-constructed [CareContact] via [onSubmit].
class CareContactForm extends ConsumerStatefulWidget {
  final CareContactType type;
  final CareContact? initial;
  final int? profileId;
  final Future<void> Function(CareContact contact) onSubmit;
  final bool Function()? isSaving;

  const CareContactForm({
    super.key,
    required this.type,
    this.initial,
    this.profileId,
    required this.onSubmit,
    this.isSaving,
  });

  @override
  ConsumerState<CareContactForm> createState() => _CareContactFormState();
}

class _CareContactFormState extends ConsumerState<CareContactForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _displayName;
  late final TextEditingController _specialty;
  late final TextEditingController _organizationName;
  late final TextEditingController _department;
  late final TextEditingController _contactPerson;
  late final TextEditingController _primaryPhone;
  late final TextEditingController _secondaryPhone;
  late final TextEditingController _email;
  late final TextEditingController _website;
  late final TextEditingController _address;
  late final TextEditingController _workingHours;
  late final TextEditingController _policyNumber;
  late final TextEditingController _memberNumber;
  late final TextEditingController _notes;

  String? _pendingPhotoPath;
  bool _saving = false;

  CareContactType get _type => widget.type;

  @override
  void initState() {
    super.initState();
    final c = widget.initial;
    _firstName = TextEditingController(text: c?.firstName ?? '');
    _lastName = TextEditingController(text: c?.lastName ?? '');
    // Prefill the display-name field only with an explicit user-entered alias.
    // Auto-generated values are cleared so the effective name stays in sync
    // with the underlying name fields.
    _displayName = TextEditingController(
      text: _type == CareContactType.doctor && c?.isExplicitDisplayName == true
          ? c!.displayName
          : '',
    );
    _specialty = TextEditingController(text: c?.specialty ?? '');
    _organizationName = TextEditingController(text: c?.organizationName ?? '');
    _department = TextEditingController(text: c?.department ?? '');
    _contactPerson = TextEditingController(text: c?.contactPerson ?? '');
    _primaryPhone = TextEditingController(text: c?.primaryPhone ?? '');
    _secondaryPhone = TextEditingController(text: c?.secondaryPhone ?? '');
    _email = TextEditingController(text: c?.email ?? '');
    _website = TextEditingController(text: c?.website ?? '');
    _address = TextEditingController(text: c?.address ?? '');
    _workingHours = TextEditingController(text: c?.workingHours ?? '');
    _policyNumber = TextEditingController(text: c?.policyNumber ?? '');
    _memberNumber = TextEditingController(text: c?.memberNumber ?? '');
    _notes = TextEditingController(text: c?.notes ?? '');
    _pendingPhotoPath = c?.photoPath;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _displayName.dispose();
    _specialty.dispose();
    _organizationName.dispose();
    _department.dispose();
    _contactPerson.dispose();
    _primaryPhone.dispose();
    _secondaryPhone.dispose();
    _email.dispose();
    _website.dispose();
    _address.dispose();
    _workingHours.dispose();
    _policyNumber.dispose();
    _memberNumber.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: GestureDetector(
              onTap: () => _showPhotoActions(context, l10n),
              child: Stack(
                children: [
                  CareContactAvatar(
                    contact: _previewContact(),
                    radius: 56,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () => _showPhotoActions(context, l10n),
              icon: const Icon(Icons.photo_camera_outlined, size: 18),
              label: Text(
                _pendingPhotoPath != null
                    ? l10n.changePhoto
                    : l10n.choosePhoto,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Chip(
            avatar: Icon(
              CareContactLocalizer.typeIcon(_type),
              size: 18,
            ),
            label: Text(CareContactLocalizer.typeLabel(l10n, _type)),
          ),
          const SizedBox(height: 16),
          ..._buildFields(context, l10n),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : () => _submit(context, l10n),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.initial == null
                          ? l10n.addCareContact
                          : l10n.save,
                    ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  List<Widget> _buildFields(BuildContext context, AppLocalizations l10n) {
    final fields = <Widget>[];
    void gap() => fields.add(const SizedBox(height: 12));

    if (_type == CareContactType.doctor) {
      fields.add(_sectionTitle(context, l10n.personalInformationLabel));
      fields.add(TextFormField(
        controller: _firstName,
        decoration: InputDecoration(
          labelText: '${l10n.firstName} *',
          border: const OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.next,
        validator: _requiredNameValidator(l10n),
      ));
      gap();
      fields.add(TextFormField(
        controller: _lastName,
        decoration: InputDecoration(
          labelText: l10n.lastName,
          border: const OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.next,
      ));
      gap();
      fields.add(TextFormField(
        controller: _displayName,
        decoration: InputDecoration(
          labelText: l10n.displayName,
          border: const OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.next,
      ));
      gap();
      fields.add(_sectionTitle(context, l10n.professionalInformation));
      fields.add(TextFormField(
        controller: _specialty,
        decoration: InputDecoration(
          labelText: l10n.specialty,
          border: const OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.next,
      ));
      gap();
      fields.add(TextFormField(
        controller: _organizationName,
        decoration: InputDecoration(
          labelText: l10n.organization,
          border: const OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.next,
      ));
      gap();
      fields.add(TextFormField(
        controller: _department,
        decoration: InputDecoration(
          labelText: l10n.department,
          border: const OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.next,
      ));
    } else {
      final requiredLabel = _type == CareContactType.insurance
          ? l10n.organizationName
          : l10n.organizationName;
      fields.add(_sectionTitle(context, l10n.organizationInformation));
      fields.add(TextFormField(
        controller: _organizationName,
        decoration: InputDecoration(
          labelText: '$requiredLabel *',
          border: const OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.next,
        validator: _requiredNameValidator(l10n),
      ));
      gap();
      if (_type != CareContactType.insurance) {
        fields.add(TextFormField(
          controller: _contactPerson,
          decoration: InputDecoration(
            labelText: l10n.contactPerson,
            border: const OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.next,
        ));
        gap();
        fields.add(TextFormField(
          controller: _department,
          decoration: InputDecoration(
            labelText: l10n.department,
            border: const OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.next,
        ));
        gap();
      }
    }

    fields.add(_sectionTitle(context, l10n.contactInformation));
    fields.add(TextFormField(
      controller: _primaryPhone,
      decoration: InputDecoration(
        labelText: _type == CareContactType.insurance
            ? l10n.primaryPhone
            : l10n.primaryPhone,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
    ));
    gap();
    fields.add(TextFormField(
      controller: _secondaryPhone,
      decoration: InputDecoration(
        labelText: _type == CareContactType.insurance
            ? l10n.secondaryPhone
            : l10n.secondaryPhone,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
    ));
    gap();
    fields.add(TextFormField(
      controller: _email,
      decoration: InputDecoration(
        labelText: l10n.email,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: _emailValidator(l10n),
    ));
    gap();
    fields.add(TextFormField(
      controller: _website,
      decoration: InputDecoration(
        labelText: l10n.website,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.next,
      validator: _websiteValidator(l10n),
    ));
    gap();
    fields.add(TextFormField(
      controller: _address,
      decoration: InputDecoration(
        labelText: l10n.address,
        border: const OutlineInputBorder(),
      ),
      maxLines: 2,
      textInputAction: TextInputAction.newline,
    ));
    if (_type.isOrganization) {
      gap();
      fields.add(TextFormField(
        controller: _workingHours,
        decoration: InputDecoration(
          labelText: l10n.workingHours,
          border: const OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.next,
      ));
    }

    if (_type == CareContactType.insurance) {
      gap();
      fields.add(_sectionTitle(context, l10n.policyAndMemberDetails));
      fields.add(TextFormField(
        controller: _policyNumber,
        decoration: InputDecoration(
          labelText: l10n.policyNumber,
          border: const OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.next,
      ));
      gap();
      fields.add(TextFormField(
        controller: _memberNumber,
        decoration: InputDecoration(
          labelText: l10n.memberNumber,
          border: const OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.next,
      ));
    }

    gap();
    fields.add(TextFormField(
      controller: _notes,
      decoration: InputDecoration(
        labelText: l10n.notes,
        border: const OutlineInputBorder(),
      ),
      maxLines: 3,
      textInputAction: TextInputAction.newline,
    ));

    return fields;
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  String? Function(String?) _requiredNameValidator(AppLocalizations l10n) {
    return (v) =>
        v == null || v.trim().isEmpty ? l10n.requiredField : null;
  }

  String? Function(String?) _emailValidator(AppLocalizations l10n) {
    return (v) {
      if (v == null || v.trim().isEmpty) return null;
      final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      return pattern.hasMatch(v.trim()) ? null : l10n.invalidEmail;
    };
  }

  String? Function(String?) _websiteValidator(AppLocalizations l10n) {
    return (v) {
      if (v == null || v.trim().isEmpty) return null;
      final trimmed = v.trim();
      final normalized = trimmed.startsWith('http://') ||
              trimmed.startsWith('https://')
          ? trimmed
          : 'https://$trimmed';
      final uri = Uri.tryParse(normalized);
      if (uri == null || uri.host.isEmpty) return l10n.invalidWebsite;
      return null;
    };
  }

  String? _nullable(TextEditingController c) {
    final value = c.text.trim();
    return value.isEmpty ? null : value;
  }

  CareContact _buildContact() {
    final now = DateTime.now();
    final initial = widget.initial;
    final organizationName = _nullable(_organizationName);
    final explicitFromField = _displayName.text.trim();

    // Compatibility rule: the display_name column stores ONLY explicit
    // user-entered aliases; auto-generated fallback values are never persisted.
    // A stored value that equals the type-name fallback is treated as generated
    // and cleared, so the effective name always reflects the current fields.
    // An explicit custom alias is preserved unchanged.
    final String displayName;
    if (_type == CareContactType.doctor) {
      // Doctor form has a visible Display Name field: store exactly what the
      // user entered (possibly empty). Stale generated values were not
      // prefilled, so they can no longer silently persist.
      displayName = explicitFromField;
    } else {
      // Organization forms have no Display Name field. Preserve an existing
      // explicit alias, but drop auto-generated values so the effective name
      // stays derived from the organization name.
      final stored = initial?.displayName.trim() ?? '';
      final storedIsExplicit = stored.isNotEmpty &&
          stored != CareContact.fallbackName(
            contactType: _type,
            firstName: initial?.firstName,
            lastName: initial?.lastName,
            organizationName: initial?.organizationName,
          );
      displayName = storedIsExplicit ? stored : '';
    }

    return CareContact(
      id: initial?.id,
      profileId: widget.profileId ?? initial?.profileId ?? 0,
      contactType: _type,
      displayName: displayName,
      firstName: _type == CareContactType.doctor ? _nullable(_firstName) : null,
      lastName: _type == CareContactType.doctor ? _nullable(_lastName) : null,
      specialty: _type == CareContactType.doctor ? _nullable(_specialty) : null,
      organizationName: organizationName,
      department: _nullable(_department),
      contactPerson:
          _type == CareContactType.doctor ? null : _nullable(_contactPerson),
      primaryPhone: _nullable(_primaryPhone),
      secondaryPhone: _nullable(_secondaryPhone),
      email: _nullable(_email),
      website: _nullable(_website),
      address: _nullable(_address),
      workingHours:
          _type.isOrganization ? _nullable(_workingHours) : null,
      policyNumber:
          _type == CareContactType.insurance ? _nullable(_policyNumber) : null,
      memberNumber:
          _type == CareContactType.insurance ? _nullable(_memberNumber) : null,
      notes: _nullable(_notes),
      photoPath: _pendingPhotoPath,
      isFavorite: initial?.isFavorite ?? false,
      isArchived: initial?.isArchived ?? false,
      createdAt: initial?.createdAt ?? now,
      updatedAt: now,
    );
  }

  CareContact _previewContact() {
    final contact = _buildContact();
    return CareContact(
      id: contact.id,
      profileId: contact.profileId,
      contactType: _type,
      displayName: contact.displayName,
      firstName: contact.firstName,
      lastName: contact.lastName,
      organizationName: contact.organizationName,
      photoPath: _pendingPhotoPath,
      isFavorite: contact.isFavorite,
      isArchived: contact.isArchived,
      createdAt: contact.createdAt,
      updatedAt: contact.updatedAt,
    );
  }

  Future<void> _submit(BuildContext context, AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final contact = _buildContact();
      await widget.onSubmit(contact);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.initial == null ? l10n.contactSaved : l10n.contactUpdated,
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.editCareContactFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showPhotoActions(BuildContext context, AppLocalizations l10n) {
    final hasPhoto = _pendingPhotoPath != null;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.choosePhoto,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.chooseFromGallery),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery, l10n);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(l10n.takePhoto),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera, l10n);
                },
              ),
              if (hasPhoto)
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    l10n.removePhoto,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _pendingPhotoPath = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(
    ImageSource source,
    AppLocalizations l10n,
  ) async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null) return;

      final imageService = ref.read(careContactImageServiceProvider);
      // Use the contact id when editing; new contacts are staged with a temp id.
      final contactId = widget.initial?.id ?? _temporaryContactId;
      final imageBytes = await picked.readAsBytes();
      final newPath = await imageService.importContactPhoto(
        contactId: contactId,
        imageBytes: imageBytes,
      );

      final oldPath = _pendingPhotoPath;
      if (oldPath != null && oldPath != newPath) {
        await imageService.removeContactPhoto(oldPath);
      }

      if (mounted) setState(() => _pendingPhotoPath = newPath);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.failedToSaveContactPhoto)),
      );
    }
  }

  int get _temporaryContactId => DateTime.now().millisecondsSinceEpoch & 0x7fffffff;
}
