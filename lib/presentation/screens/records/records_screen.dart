import 'package:flutter/material.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/widgets/empty_state.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.records),
      ),
      body: EmptyState(
        icon: Icons.folder,
        title: l10n.noDataYet,
        subtitle: l10n.addFirstItem,
      ),
    );
  }
}
