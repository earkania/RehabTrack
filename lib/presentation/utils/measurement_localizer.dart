import 'package:rehab_track/l10n/app_localizations.dart';

class MeasurementLocalizer {
  MeasurementLocalizer._();

  static String typeName(AppLocalizations l10n, String? key) {
    return switch (key) {
      'blood_pressure' => l10n.bloodPressure,
      'pulse' => l10n.pulse,
      'weight' => l10n.weight,
      'blood_glucose' => l10n.bloodGlucose,
      'spo2' => l10n.spo2,
      'temperature' => l10n.temperature,
      _ => key ?? '',
    };
  }

  static String fieldName(AppLocalizations l10n, String fieldKey) {
    return switch (fieldKey) {
      'systolic' => l10n.systolic,
      'diastolic' => l10n.diastolic,
      'pulse' => l10n.pulse,
      'weight' => l10n.weight,
      'glucose' => l10n.bloodGlucose,
      'spo2' => l10n.spo2,
      'temperature' => l10n.temperature,
      _ => fieldKey,
    };
  }
}
