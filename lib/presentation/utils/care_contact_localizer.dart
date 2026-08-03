import 'package:flutter/material.dart';
import 'package:rehab_track/domain/enums/enums.dart';
import 'package:rehab_track/l10n/app_localizations.dart';

/// Maps care contact types to localized labels and Material icons.
class CareContactLocalizer {
  CareContactLocalizer._();

  static String typeLabel(AppLocalizations l10n, CareContactType type) {
    return switch (type) {
      CareContactType.doctor => l10n.doctorOrSpecialist,
      CareContactType.clinic => l10n.clinicOrHospital,
      CareContactType.laboratory => l10n.laboratory,
      CareContactType.pharmacy => l10n.pharmacy,
      CareContactType.insurance => l10n.insuranceCompany,
      CareContactType.other => l10n.other,
    };
  }

  static IconData typeIcon(CareContactType type) {
    return switch (type) {
      CareContactType.doctor => Icons.medical_services_outlined,
      CareContactType.clinic => Icons.local_hospital_outlined,
      CareContactType.laboratory => Icons.science_outlined,
      CareContactType.pharmacy => Icons.local_pharmacy_outlined,
      CareContactType.insurance => Icons.health_and_safety_outlined,
      CareContactType.other => Icons.contact_page_outlined,
    };
  }
}
