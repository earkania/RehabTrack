import 'package:rehab_track/domain/entities/medication.dart';

class DoseFormatter {
  DoseFormatter._();

  static String format(Medication medication) {
    final parts = <String>[];
    if (medication.doseAmount != null && medication.doseAmount!.isNotEmpty) {
      parts.add(medication.doseAmount!);
    }
    if (medication.doseUnit != null && medication.doseUnit!.isNotEmpty) {
      parts.add(medication.doseUnit!);
    }
    return parts.join(' ');
  }
}
