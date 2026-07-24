import 'package:rehab_track/domain/entities/dosage_form.dart';
import 'package:rehab_track/l10n/app_localizations.dart';

class DosageFormLocalizer {
  DosageFormLocalizer._();

  static String localize(DosageForm form, AppLocalizations l10n) {
    return switch (form) {
      DosageForm.tablet => l10n.tablet,
      DosageForm.capsule => l10n.capsule,
      DosageForm.drop => l10n.drop,
      DosageForm.ml => l10n.ml,
      DosageForm.puff => l10n.puff,
      DosageForm.unit => l10n.unit,
      DosageForm.sachet => l10n.sachet,
      DosageForm.spoon => l10n.spoon,
      DosageForm.injection => l10n.injection,
      DosageForm.topical => l10n.topical,
      DosageForm.other => l10n.other,
    };
  }

  static bool _shouldPluralize(AppLocalizations l10n) {
    return l10n.localeName != 'ka';
  }

  static String _pluralized(String formName, double quantity, AppLocalizations l10n) {
    if (quantity == 1 || !_shouldPluralize(l10n)) return formName;
    return '${formName}s';
  }

  static String localizeWithQuantity(
    double quantity,
    DosageForm form,
    AppLocalizations l10n, {
    String? customForm,
  }) {
    final formName = (customForm?.isNotEmpty == true) ? customForm! : localize(form, l10n);
    final qtyStr = quantity == quantity.roundToDouble()
        ? quantity.toInt().toString()
        : quantity.toString();
    return '$qtyStr ${_pluralized(formName, quantity, l10n)}';
  }

  static String localizeSnapshot({
    required double? quantity,
    required DosageForm? form,
    required AppLocalizations l10n,
    String? customForm,
  }) {
    if (quantity == null || quantity == 0 || form == null) return '';
    final formName = (customForm?.isNotEmpty == true) ? customForm! : localize(form, l10n);
    if (formName.isEmpty) return '';
    final qtyStr = quantity == quantity.roundToDouble()
        ? quantity.toInt().toString()
        : quantity.toString();
    return '$qtyStr ${_pluralized(formName, quantity, l10n)}';
  }
}
