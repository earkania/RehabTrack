import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/l10n/app_localizations.dart';

import 'package:rehab_track/core/localization/app_locale.dart';
import 'package:rehab_track/presentation/providers/locale_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildSectionHeader(context, 'Language'),
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
          _buildSectionHeader(context, 'Appearance'),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            subtitle: const Text('System default'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          _buildSectionHeader(context, 'Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Enable notifications'),
            value: true,
            onChanged: (value) {},
          ),
          const Divider(),
          _buildSectionHeader(context, 'Security'),
          SwitchListTile(
            secondary: const Icon(Icons.lock_outline),
            title: const Text('App lock'),
            subtitle: const Text('Disabled'),
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
