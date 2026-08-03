import 'package:flutter/material.dart';
import 'package:rehab_track/domain/enums/enums.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/utils/care_contact_localizer.dart';

/// Shows a bottom sheet for choosing a contact type. Returns the chosen type
/// or null when dismissed.
Future<CareContactType?> showContactTypeSelector(
  BuildContext context,
  AppLocalizations l10n,
) {
  return showModalBottomSheet<CareContactType>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  l10n.selectContactType,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
              _TypeOption(
                icon: CareContactLocalizer.typeIcon(CareContactType.doctor),
                label: l10n.doctorOrSpecialist,
                onTap: () => Navigator.pop(ctx, CareContactType.doctor),
              ),
              _TypeOption(
                icon: CareContactLocalizer.typeIcon(CareContactType.clinic),
                label: l10n.clinicOrHospital,
                onTap: () => Navigator.pop(ctx, CareContactType.clinic),
              ),
              _TypeOption(
                icon: CareContactLocalizer.typeIcon(CareContactType.laboratory),
                label: l10n.laboratory,
                onTap: () => Navigator.pop(ctx, CareContactType.laboratory),
              ),
              _TypeOption(
                icon: CareContactLocalizer.typeIcon(CareContactType.pharmacy),
                label: l10n.pharmacy,
                onTap: () => Navigator.pop(ctx, CareContactType.pharmacy),
              ),
              _TypeOption(
                icon: CareContactLocalizer.typeIcon(CareContactType.insurance),
                label: l10n.insuranceCompany,
                onTap: () => Navigator.pop(ctx, CareContactType.insurance),
              ),
              _TypeOption(
                icon: CareContactLocalizer.typeIcon(CareContactType.other),
                label: l10n.other,
                onTap: () => Navigator.pop(ctx, CareContactType.other),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _TypeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TypeOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Semantics(
        button: true,
        label: label,
        child: Material(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, color: colorScheme.primary, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
