import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rehab_track/domain/entities/profile.dart';
import 'package:rehab_track/domain/services/app_date_formatter.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/widgets/profile/profile_avatar.dart';

class PatientProfileEditScreen extends ConsumerStatefulWidget {
  const PatientProfileEditScreen({super.key});

  @override
  ConsumerState<PatientProfileEditScreen> createState() =>
      _PatientProfileEditScreenState();
}

class _PatientProfileEditScreenState
    extends ConsumerState<PatientProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _bloodTypeController;
  late TextEditingController _allergiesController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;
  late TextEditingController _notesController;

  DateTime? _birthDate;
  String? _selectedGender;
  String? _selectedRelationship;
  bool _isSaving = false;
  bool _initialized = false;
  String? _pendingPhotoPath;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _bloodTypeController = TextEditingController();
    _allergiesController = TextEditingController();
    _emergencyNameController = TextEditingController();
    _emergencyPhoneController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initializeFromProfile(Profile profile) {
    if (_initialized) return;
    _initialized = true;
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _phoneController.text = profile.phone ?? '';
    _emailController.text = profile.email ?? '';
    _addressController.text = profile.address ?? '';
    _heightController.text = profile.heightCm?.toString() ?? '';
    _weightController.text = profile.weightKg?.toString() ?? '';
    _bloodTypeController.text = profile.bloodType ?? '';
    _allergiesController.text = profile.allergies ?? '';
    _emergencyNameController.text = profile.emergencyContactName ?? '';
    _emergencyPhoneController.text = profile.emergencyContactPhone ?? '';
    _notesController.text = profile.notes ?? '';
    _birthDate = profile.birthDate;
    _selectedGender = profile.gender;
    _selectedRelationship = profile.relationshipToOwner;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileId = ref.watch(currentActiveProfileIdProvider);

    if (profileId == null) {
      return _buildCreateForm(context, l10n);
    }

    final profileAsync = ref.watch(watchProfileByIdProvider(profileId));

    return profileAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.editPatientProfile)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.editPatientProfile)),
        body: Center(child: Text(l10n.error)),
      ),
      data: (profile) {
        if (profile == null) {
          return _buildCreateForm(context, l10n);
        }
        _initializeFromProfile(profile);
        return _buildForm(context, l10n, profile);
      },
    );
  }

  Widget _buildCreateForm(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addProfileInformation)),
      body: _buildFormBody(
        context,
        l10n,
        Profile(
          firstName: '',
          lastName: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isPrimary: true,
          isActive: true,
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    AppLocalizations l10n,
    Profile profile,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editPatientProfile),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => _save(l10n, profile),
            child: Text(l10n.save),
          ),
        ],
      ),
      body: _buildFormBody(context, l10n, profile),
    );
  }

  Widget _buildFormBody(
    BuildContext context,
    AppLocalizations l10n,
    Profile profile,
  ) {
    final displayPhotoPath = _pendingPhotoPath ?? profile.photoPath;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: GestureDetector(
              onTap: () => _showPhotoActions(context, l10n, profile),
              child: Stack(
                children: [
                  ProfileAvatar(
                    photoPath: displayPhotoPath,
                    firstName: profile.firstName,
                    lastName: profile.lastName,
                    radius: 56,
                    isPrimary: profile.isPrimary,
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
              onPressed: () => _showPhotoActions(context, l10n, profile),
              icon: const Icon(Icons.photo_camera_outlined, size: 18),
              label: Text(
                displayPhotoPath != null
                    ? l10n.changeProfilePhoto
                    : l10n.profilePhoto,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.personalInformation,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _firstNameController,
            decoration: InputDecoration(
              labelText: '${l10n.firstName} *',
              border: const OutlineInputBorder(),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? l10n.nameRequired : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _lastNameController,
            decoration: InputDecoration(
              labelText: '${l10n.lastName} *',
              border: const OutlineInputBorder(),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? l10n.nameRequired : null,
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.birthDateLabel),
            subtitle: Text(
              _birthDate != null
                  ? AppDateFormatter.of(context).formatShortDate(_birthDate!)
                  : l10n.selectDate,
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _birthDate ?? DateTime(1990),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _birthDate = picked);
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedGender,
            decoration: InputDecoration(
              labelText: l10n.gender,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'male', child: Text(l10n.male)),
              DropdownMenuItem(value: 'female', child: Text(l10n.female)),
              DropdownMenuItem(value: 'other', child: Text(l10n.other)),
            ],
            onChanged: (v) => setState(() => _selectedGender = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedRelationship,
            decoration: InputDecoration(
              labelText: l10n.relationship,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'self', child: Text(l10n.self_)),
              DropdownMenuItem(value: 'child', child: Text(l10n.child_)),
              DropdownMenuItem(value: 'spouse', child: Text(l10n.spouse_)),
              DropdownMenuItem(value: 'parent', child: Text(l10n.parent_)),
              DropdownMenuItem(value: 'sibling', child: Text(l10n.sibling_)),
              DropdownMenuItem(
                  value: 'grandparent', child: Text(l10n.grandparent_)),
              DropdownMenuItem(
                  value: 'grandchild', child: Text(l10n.grandchild_)),
              DropdownMenuItem(value: 'other', child: Text(l10n.other_)),
            ],
            onChanged: (v) => setState(() => _selectedRelationship = v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _heightController,
                  decoration: InputDecoration(
                    labelText: l10n.heightCm,
                    border: const OutlineInputBorder(),
                    suffixText: 'cm',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _weightController,
                  decoration: InputDecoration(
                    labelText: l10n.weightKg,
                    border: const OutlineInputBorder(),
                    suffixText: 'kg',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _bloodTypeController,
            decoration: InputDecoration(
              labelText: l10n.bloodType,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.contactInformation,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: l10n.phone,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: l10n.email,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: l10n.address,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.emergencyContact,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emergencyNameController,
            decoration: InputDecoration(
              labelText: l10n.emergencyContactNameLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emergencyPhoneController,
            decoration: InputDecoration(
              labelText: l10n.emergencyContactPhoneLabel,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.additionalInformation,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _allergiesController,
            decoration: InputDecoration(
              labelText: l10n.allergies,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: l10n.notes,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSaving ? null : () => _save(l10n, profile),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.save),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showPhotoActions(
    BuildContext context,
    AppLocalizations l10n,
    Profile profile,
  ) {
    final hasPhoto = profile.photoPath != null || _pendingPhotoPath != null;

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
                l10n.changeProfilePhoto,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.chooseFromGallery),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery, l10n, profile);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(l10n.takePhoto),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera, l10n, profile);
                },
              ),
              if (hasPhoto)
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    l10n.removeProfilePhoto,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(ctx);
                    _removePhoto(l10n, profile);
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
    Profile profile,
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

      final imageService = ref.read(profileImageServiceProvider);
      final profileId = profile.id;
      if (profileId == null) return;

      final imageBytes = await picked.readAsBytes();
      final newPath = await imageService.importProfilePhoto(
        profileId: profileId,
        imageBytes: imageBytes,
      );

      // Delete old managed photo after new one is saved
      final oldPath = profile.photoPath;
      if (oldPath != null && oldPath != newPath) {
        await imageService.removeProfilePhoto(oldPath);
      }

      // Save profile with new photo path
      final repo = ref.read(profileRepositoryProvider);
      final updated = profile.copyWith(
        photoPath: newPath,
        updatedAt: DateTime.now(),
      );
      await repo.updateProfile(updated);

      setState(() => _pendingPhotoPath = newPath);
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToSavePhoto)),
        );
      }
    }
  }

  Future<void> _removePhoto(AppLocalizations l10n, Profile profile) async {
    final photoPath = _pendingPhotoPath ?? profile.photoPath;
    if (photoPath == null) return;

    try {
      final imageService = ref.read(profileImageServiceProvider);
      await imageService.removeProfilePhoto(photoPath);

      final repo = ref.read(profileRepositoryProvider);
      final updated = profile.copyWith(
        photoPath: null,
        updatedAt: DateTime.now(),
      );
      await repo.updateProfile(updated);

      setState(() => _pendingPhotoPath = null);
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToSavePhoto)),
        );
      }
    }
  }

  Future<void> _save(AppLocalizations l10n, Profile profile) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(profileRepositoryProvider);
      final updated = profile.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        birthDate: _birthDate,
        gender: _selectedGender,
        heightCm: double.tryParse(_heightController.text),
        weightKg: double.tryParse(_weightController.text),
        bloodType: _bloodTypeController.text.isEmpty
            ? null
            : _bloodTypeController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        address:
            _addressController.text.isEmpty ? null : _addressController.text,
        relationshipToOwner: _selectedRelationship,
        emergencyContactName: _emergencyNameController.text.isEmpty
            ? null
            : _emergencyNameController.text,
        emergencyContactPhone: _emergencyPhoneController.text.isEmpty
            ? null
            : _emergencyPhoneController.text,
        allergies: _allergiesController.text.isEmpty
            ? null
            : _allergiesController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        photoPath: _pendingPhotoPath ?? profile.photoPath,
        updatedAt: DateTime.now(),
      );

      if (profile.id != null) {
        await repo.updateProfile(updated);
      } else {
        final newId = await repo.createProfile(updated);
        await ref.read(activeProfileIdProvider.notifier).setActiveProfileId(newId);
      }

      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileUpdated)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToSaveProfile)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
