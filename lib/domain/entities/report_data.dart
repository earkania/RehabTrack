import 'package:rehab_track/domain/entities/report_configuration.dart';
import 'package:rehab_track/domain/entities/report_section.dart';

/// Fully prepared Health Report: the immutable input consumed by BOTH the
/// preview UI and the PDF generator so they can never diverge.
///
/// Values are kept raw (DateTime/double/stable string identifiers); localized
/// labels and date/unit formatting happen at render time through the shared
/// report localization bundle. The builder only prepares sections that were
/// selected; unselected sections stay null.
class ReportData {
  const ReportData({
    required this.configuration,
    required this.generatedAt,
    this.profileSummary,
    this.medications = const [],
    this.measurements = const [],
    this.doctorVisits = const [],
    this.doctorPrescriptions = const [],
    this.labAnalyses = const [],
    this.diet,
    this.activityStats,
    this.activitySessions = const [],
  });

  final ReportConfiguration configuration;
  final DateTime generatedAt;

  // ---- Prepared sections (null when the section was not selected) ---------

  /// Patient summary. Intentionally NOT filtered by the report date range.
  final ReportProfileSummary? profileSummary;

  /// Current active medications. Not a historical adherence report.
  final List<ReportMedication> medications;

  /// One entry per measurement type that has readings in range.
  final List<ReportMeasurementTypeData> measurements;

  final List<ReportDoctorVisitEntry> doctorVisits;
  final List<ReportPrescriptionEntry> doctorPrescriptions;
  final List<ReportLabAnalysisEntry> labAnalyses;

  /// Current diet guidance (foods + general rules). Not date-filtered.
  final ReportDietData? diet;

  /// Completed/cancelled session statistics within the report period.
  final ReportActivityStats? activityStats;
  final List<ReportActivitySessionEntry> activitySessions;

  bool isEmptySection(ReportSection section) {
    switch (section) {
      case ReportSection.profile:
        return profileSummary == null;
      case ReportSection.medications:
        return medications.isEmpty;
      case ReportSection.measurements:
        return measurements.isEmpty;
      case ReportSection.doctorVisits:
        return doctorVisits.isEmpty;
      case ReportSection.doctorPrescriptions:
        return doctorPrescriptions.isEmpty;
      case ReportSection.labAnalyses:
        return labAnalyses.isEmpty;
      case ReportSection.diet:
        return diet == null ||
            (diet!.guidanceByCategory.isEmpty && diet!.foodsByCategory.isEmpty);
      case ReportSection.activities:
        return activitySessions.isEmpty && (activityStats?.sessionCount ?? 0) == 0;
    }
  }
}

/// Concise patient identity/attributes for the summary section. Only fields
/// that actually exist on the Profile entity are represented here; rows with
/// null values are hidden by renderers.
class ReportProfileSummary {
  const ReportProfileSummary({
    required this.fullName,
    this.birthDate,
    this.gender,
    this.bloodType,
    this.heightCm,
    this.weightKg,
    this.allergies,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });

  final String fullName;
  final DateTime? birthDate;
  final String? gender;

  /// Stable stored value (e.g. 'A+'); rendered verbatim.
  final String? bloodType;
  final double? heightCm;
  final double? weightKg;
  final String? allergies;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
}

/// A currently-active medication with its primary schedule context.
class ReportMedication {
  const ReportMedication({
    required this.name,
    this.doseAmount,
    this.doseUnit,
    this.scheduleSummary,
    this.instructions,
    this.startDate,
    this.endDate,
    required this.active,
  });

  final String name;
  final String? doseAmount;
  final String? doseUnit;

  /// Human-readable time-of-day summary of active schedules, e.g. '09:00, 21:00'.
  final String? scheduleSummary;
  final String? instructions;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool active;
}

/// Descriptive statistics for ONE component of a measurement type
/// (e.g. Systolic). No interpretation is attached — numbers only.
class ReportComponentStats {
  const ReportComponentStats({
    required this.label,
    required this.unit,
    required this.count,
    required this.minimum,
    required this.maximum,
    required this.average,
  });

  final String label;
  final String unit;
  final int count;
  final double minimum;
  final double maximum;
  final double average;
}

/// One individual reading row for the compact readings table.
class ReportReadingRow {
  const ReportReadingRow({required this.measuredAt, required this.values});

  final DateTime measuredAt;

  /// Component values in canonical order.
  final List<ReportValueCell> values;
}

class ReportValueCell {
  const ReportValueCell({required this.label, required this.value, required this.unit});

  final String label;
  final double value;
  final String unit;
}

/// All prepared data for one measurement type in the report.
class ReportMeasurementTypeData {
  const ReportMeasurementTypeData({
    required this.typeName,
    required this.readingCountInRange,
    required this.totalReadingCount,
    required this.includedReadingCount,
    required this.rangeStart,
    required this.rangeEnd,
    required this.components,
    required this.readings,
  });

  final String typeName;

  /// Readings inside the resolved report period.
  final int readingCountInRange;

  /// Total stored readings for the type (to explain any truncation).
  final int totalReadingCount;

  /// How many rows are actually carried into the preview/PDF.
  final int includedReadingCount;

  final DateTime? rangeStart;
  final DateTime? rangeEnd;

  /// Per-component descriptive statistics in canonical order
  /// (Blood Pressure: Systolic, Diastolic, Pulse).
  final List<ReportComponentStats> components;

  /// Newest-first compact reading rows (possibly truncated, see counts).
  final List<ReportReadingRow> readings;

  bool get isTruncated => includedReadingCount < totalReadingCount;
}

class ReportDoctorVisitEntry {
  const ReportDoctorVisitEntry({
    required this.scheduledAt,
    this.doctorName,
    this.organizationName,

    /// Stable enum name ('completed' | 'cancelled' | 'missed' | 'scheduled').
    required this.status,
    this.reason,
    this.notes,
  });

  final DateTime scheduledAt;
  final String? doctorName;
  final String? organizationName;
  final String status;
  final String? reason;
  final String? notes;
}

class ReportRxMedication {
  const ReportRxMedication({
    required this.name,
    this.doseAmount,
    this.doseUnit,
    this.instructions,
    this.frequency,
    this.timing,
    this.duration,
  });

  final String name;
  final String? doseAmount;
  final String? doseUnit;
  final String? instructions;
  final String? frequency;
  final String? timing;
  final String? duration;
}

class ReportPrescriptionEntry {
  const ReportPrescriptionEntry({
    required this.title,
    required this.prescriptionDate,
    this.doctorName,
    this.clinicName,
    this.reason,
    this.notes,
    this.medications = const [],

    /// Attachment display names ONLY; files are never embedded in v1.
    this.attachmentNames = const [],
  });

  final String title;
  final DateTime prescriptionDate;
  final String? doctorName;
  final String? clinicName;
  final String? reason;
  final String? notes;
  final List<ReportRxMedication> medications;
  final List<String> attachmentNames;
}

class ReportLabAnalysisEntry {
  const ReportLabAnalysisEntry({
    required this.title,

    /// Stable category ('laboratory'|'cardiology'|'imaging'|'pathology'|other).
    required this.category,
    required this.analysisDate,
    this.resultReceivedDate,
    this.laboratoryName,
    this.orderingDoctorName,
    this.notes,
    this.attachmentNames = const [],
  });

  final String title;
  final String category;
  final DateTime analysisDate;
  final DateTime? resultReceivedDate;
  final String? laboratoryName;
  final String? orderingDoctorName;
  final String? notes;
  final List<String> attachmentNames;
}

/// Current diet guidance grouped by STABLE category identifiers.
class ReportDietData {
  const ReportDietData({
    required this.guidanceByCategory,
    required this.foodsByCategory,
  });

  /// key: 'diet'|'smoking'|'hydration'|'caffeine'|'alcohol'|'other'.
  final Map<String, List<ReportGuidanceRule>> guidanceByCategory;

  /// key: 'allowed'|'caution'|'avoid'.
  final Map<String, List<ReportFoodItem>> foodsByCategory;
}

class ReportGuidanceRule {
  const ReportGuidanceRule({
    required this.title,
    this.description,
    this.source,
  });

  final String title;
  final String? description;
  final String? source;
}

class ReportFoodItem {
  const ReportFoodItem({required this.name, this.foodGroup, this.notes});

  final String name;
  final String? foodGroup;
  final String? notes;
}

/// Descriptive session statistics for the report period.
class ReportActivityStats {
  const ReportActivityStats({
    required this.sessionCount,
    required this.completedCount,
    required this.cancelledCount,
    required this.totalActiveDuration,
  });

  final int sessionCount;
  final int completedCount;
  final int cancelledCount;
  final Duration totalActiveDuration;
}

class ReportActivitySessionEntry {
  const ReportActivitySessionEntry({
    required this.startedAt,
    required this.activityName,
    required this.activeDuration,
    this.plannedDuration,
    required this.status,
    this.notes,
  });

  final DateTime startedAt;
  final String activityName;
  final Duration activeDuration;
  final Duration? plannedDuration;

  /// Stable enum name ('completed' | 'cancelled').
  final String status;
  final String? notes;
}
