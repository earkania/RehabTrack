import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/widgets/dashboard/module_grid.dart';
import 'package:rehab_track/presentation/widgets/dashboard/module_grid_tile.dart';
import 'package:rehab_track/presentation/widgets/profile/profile_avatar.dart';

class ProfileDashboardScreen extends ConsumerWidget {
  const ProfileDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: ModuleGrid(
        header: _ActiveProfileHeader(),
        tiles: [
          ModuleGridTile(
            icon: const Icon(Icons.account_circle_outlined),
            label: l10n.patientProfile,
            onTap: () => context.push(AppRoutes.patientProfile),
          ),
          ModuleGridTile(
            icon: const Icon(Icons.contact_phone_outlined),
            label: l10n.careContacts,
            onTap: () => context.push(AppRoutes.profileCareContacts),
          ),
          ModuleGridTile(
            icon: const Icon(Icons.emergency_outlined),
            label: l10n.emergencyContacts,
            onTap: () => context.push(AppRoutes.profileEmergencyContacts),
          ),
          ModuleGridTile(
            icon: const Icon(Icons.note_alt_outlined),
            label: l10n.medicalNotes,
            onTap: () => context.push(AppRoutes.profileMedicalNotes),
          ),
        ],
      ),
    );
  }
}

/// Compact active-profile summary shown at the top of the Profile dashboard.
/// Reuses the existing profile providers and fallback name/avatar behavior.
class _ActiveProfileHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final profileId = ref.watch(currentActiveProfileIdProvider);
    final profileAsync = profileId != null
        ? ref.watch(watchProfileByIdProvider(profileId))
        : null;
    final profile = profileAsync?.valueOrNull;

    final hasName =
        profile != null &&
        (profile.firstName.isNotEmpty || profile.lastName.isNotEmpty);
    final displayName = hasName
        ? '${profile.firstName} ${profile.lastName}'.trim()
        : l10n.patientProfile;

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ProfileAvatar(
              photoPath: profile?.photoPath,
              firstName: profile?.firstName,
              lastName: profile?.lastName,
              radius: 24,
              isPrimary: profile?.isPrimary ?? false,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.activeProfile,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
