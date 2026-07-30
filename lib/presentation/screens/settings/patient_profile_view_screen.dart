import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/domain/entities/profile.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/widgets/profile/profile_avatar.dart';

class PatientProfileViewScreen extends ConsumerWidget {
  const PatientProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileId = ref.watch(currentActiveProfileIdProvider);

    if (profileId == null) {
      return _buildRecoveryState(context, l10n);
    }

    final profileAsync = ref.watch(watchProfileByIdProvider(profileId));

    return profileAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.patientProfile)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.patientProfile)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.error),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(activeProfileIdProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
      data: (profile) {
        if (profile == null) {
          return _buildRecoveryState(context, l10n);
        }
        return _buildProfile(context, ref, l10n, profile);
      },
    );
  }

  Widget _buildRecoveryState(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.patientProfile)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_add_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.profileNotSetUp,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.profileNotSetUpDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  context.push('/settings/patient-profile/edit'),
              icon: const Icon(Icons.add),
              label: Text(l10n.addProfileInformation),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Profile profile,
  ) {
    final theme = Theme.of(context);
    final isEmptyProfile = profile.firstName.isEmpty && profile.lastName.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.patientProfile),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/settings/patient-profile/edit'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: ProfileAvatar(
              photoPath: profile.photoPath,
              firstName: profile.firstName,
              lastName: profile.lastName,
              radius: 56,
              isPrimary: profile.isPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (isEmptyProfile) ...[
            Center(
              child: Text(
                l10n.profileInformationNotEntered,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: FilledButton.tonalIcon(
                onPressed: () =>
                    context.push('/settings/patient-profile/edit'),
                icon: const Icon(Icons.edit),
                label: Text(l10n.addProfileInformation),
              ),
            ),
          ] else ...[
            Center(
              child: Text(
                profile.fullName,
                style: theme.textTheme.headlineSmall,
              ),
            ),
            if (profile.parsedRelationship != null) ...[
              const SizedBox(height: 4),
              Center(
                child: Text(
                  _relationshipLabel(profile.parsedRelationship!),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
          const SizedBox(height: 24),
          _buildSection(l10n.personalInformation, [
            _buildInfoTile(Icons.cake_outlined, l10n.birthDateLabel,
                _formatDate(profile.birthDate, l10n)),
            _buildInfoTile(Icons.person_outlined, l10n.gender,
                profile.gender ?? l10n.unavailable),
            _buildInfoTile(Icons.bloodtype_outlined, l10n.bloodType,
                profile.bloodType ?? l10n.unavailable),
            _buildInfoTile(Icons.height_outlined, l10n.heightLabel,
                profile.heightCm != null ? '${profile.heightCm} cm' : l10n.unavailable),
            _buildInfoTile(Icons.monitor_weight_outlined, l10n.weightLabel,
                profile.weightKg != null ? '${profile.weightKg} kg' : l10n.unavailable),
          ]),
          _buildSection(l10n.contactInformation, [
            _buildInfoTile(Icons.phone_outlined, l10n.phone,
                profile.phone ?? l10n.unavailable),
            _buildInfoTile(Icons.email_outlined, l10n.email,
                profile.email ?? l10n.unavailable),
            _buildInfoTile(Icons.location_on_outlined, l10n.address,
                profile.address ?? l10n.unavailable),
          ]),
          _buildSection(l10n.emergencyContact, [
            _buildInfoTile(Icons.contact_phone_outlined, l10n.nameLabel,
                profile.emergencyContactName ?? l10n.unavailable),
            _buildInfoTile(Icons.phone_outlined, l10n.phone,
                profile.emergencyContactPhone ?? l10n.unavailable),
          ]),
          if (profile.allergies != null && profile.allergies!.isNotEmpty)
            _buildSection(l10n.allergies, [
              _buildInfoTile(Icons.warning_amber_outlined, '',
                  profile.allergies!),
            ]),
          if (profile.notes != null && profile.notes!.isNotEmpty)
            _buildSection(l10n.notes, [
              _buildInfoTile(Icons.notes_outlined, '', profile.notes!),
            ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: label.isNotEmpty ? Text(label) : null,
      subtitle: Text(value),
      dense: true,
    );
  }

  String _formatDate(DateTime? date, AppLocalizations l10n) {
    if (date == null) return l10n.unavailable;
    return '${date.day}/${date.month}/${date.year}';
  }

  String _relationshipLabel(Relationship relationship) {
    return switch (relationship) {
      Relationship.self => 'Self',
      Relationship.child => 'Child',
      Relationship.spouse => 'Spouse',
      Relationship.parent => 'Parent',
      Relationship.sibling => 'Sibling',
      Relationship.grandparent => 'Grandparent',
      Relationship.grandchild => 'Grandchild',
      Relationship.other => 'Other',
    };
  }
}
