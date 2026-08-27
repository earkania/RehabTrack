/// BMI (Body Mass Index) is derived data — not stored — computed on demand
/// from the patient's Height (cm) and Weight (kg).
///
/// Kept independent of Flutter UI so it can be shared by the Patient Profile
/// view and the Health Report renderers, and unit-tested in isolation.
library;

/// Computes BMI from Height in centimetres and Weight in kilograms.
///
/// Formula: BMI = weightKg / (heightMeters * heightMeters)
///
/// Returns `null` whenever BMI cannot be computed safely:
///  * either value is null
///  * either value is not positive (zero or negative)
///  * either value is non-finite (NaN / Infinity)
///  * the resulting BMI is non-finite (e.g. an extremely small height)
double? calculateBmi({required double? heightCm, required double? weightKg}) {
  if (heightCm == null || weightKg == null) return null;
  if (!heightCm.isFinite || !weightKg.isFinite) return null;
  if (heightCm <= 0 || weightKg <= 0) return null;

  final heightMeters = heightCm / 100.0;
  final bmi = weightKg / (heightMeters * heightMeters);
  if (!bmi.isFinite) return null;
  return bmi;
}

/// Formats a BMI for display with exactly one decimal place, e.g. `24.2`
/// or `25.0`. Only call with a non-null [bmi] produced by [calculateBmi].
String formatBmi(double bmi) => bmi.toStringAsFixed(1);
