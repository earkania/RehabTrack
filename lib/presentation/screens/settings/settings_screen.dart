import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/l10n/app_localizations.dart';

import 'package:rehab_track/core/localization/app_locale.dart';
import 'package:rehab_track/presentation/providers/locale_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/widgets/profile/profile_avatar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    final profileId = ref.watch(currentActiveProfileIdProvider);
    final profileAsync = profileId != null
        ? ref.watch(watchProfileByIdProvider(profileId))
        : null;
    final profile = profileAsync?.valueOrNull;

    final hasName =
        profile != null &&
        (profile.firstName.isNotEmpty || profile.lastName.isNotEmpty);
    final displayName = hasName ? profile.fullName : l10n.patientProfile;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildSectionHeader(context, l10n.patientProfile),
          ListTile(
            leading: ProfileAvatar(
              photoPath: profile?.photoPath,
              firstName: profile?.firstName,
              lastName: profile?.lastName,
              radius: 20,
              isPrimary: profile?.isPrimary ?? false,
            ),
            title: Text(displayName),
            subtitle: Text(l10n.activeProfile),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/patient-profile'),
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.language),
          _buildLanguageTile(
            context,
            ref,
            title: 'System',
            locale: AppLocale.system,
            currentLocale: currentLocale,
          ),
          _buildLanguageTile(
            context,
            ref,
            title: 'English',
            locale: AppLocale.english,
            currentLocale: currentLocale,
          ),
          _buildLanguageTile(
            context,
            ref,
            title: 'ქართული',
            locale: AppLocale.georgian,
            currentLocale: currentLocale,
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.theme),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: Text(l10n.theme),
            subtitle: Text(l10n.systemDefault),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.notifications),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: Text(l10n.enableNotifications),
            value: true,
            onChanged: (value) {},
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.security),
          SwitchListTile(
            secondary: const Icon(Icons.lock_outline),
            title: Text(l10n.appLock),
            subtitle: Text(l10n.disabled),
            value: false,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required AppLocale locale,
    required Locale? currentLocale,
  }) {
    final isSelected = currentLocale == locale.locale;

    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(title),
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(locale);
      },
    );
  }
}
