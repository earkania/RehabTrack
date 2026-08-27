import 'package:flutter/widgets.dart';

import 'package:rehab_track/domain/entities/report_configuration.dart';
import 'package:rehab_track/domain/entities/report_date_range.dart';
import 'package:rehab_track/domain/entities/report_section.dart';
import 'package:rehab_track/domain/services/activity_formatters.dart';
import 'package:rehab_track/domain/services/app_date_formatter.dart';
import 'package:rehab_track/l10n/app_localizations.dart';

/// Everything the report renderers (preview + PDF) need to turn raw
/// [ReportData] values into localized output: labels plus date/time
/// formatting closures.
///
/// The PDF generator itself stays free of Flutter imports; it only consumes
/// this bundle, so it can be unit-tested without a widget tree.
class ReportLocalization {
  ReportLocalization({
    required this.defaultTitle,
    required this.sectionTitles,
    required this.rangeLabels,
    required this.periodLabel,
    required this.reportDateLabel,
    required this.reportStatusLabel,
    required this.birthDateLabel,
    required this.genderLabel,
    required this.maleLabel,
    required this.femaleLabel,
    required this.genderOtherLabel,
    required this.bloodTypeLabel,
    required this.heightLabel,
    required this.weightLabel,
    required this.allergiesLabel,
    required this.emergencyContactLabel,
    required this.statMin,
    required this.statMax,
    required this.statAvg,
    required this.readingsHeader,
    required this.showingLatest,
    required this.emptyPeriodNote,
    required this.attachmentsLabel,
    required this.notesLabel,
    required this.instructionsLabel,
    required this.sourceLabel,
    required this.frequencyLabel,
    required this.timingLabel,
    required this.durationLabel,
    required this.foodGroupLabel,
    required this.doctorLabel,
    required this.organizationLabel,
    required this.reasonLabel,
    required this.prescriptionDateLabel,
    required this.analysisDateLabel,
    required this.resultReceivedLabel,
    required this.laboratoryLabel,
    required this.orderingDoctorLabel,
    required this.visitStatusLabels,
    required this.sessionStatusLabels,
    required this.guidanceCategoryLabels,
    required this.foodCategoryLabels,
    required this.dietFoodsHeading,
    required this.dietGuidanceHeading,
    required this.activitySummary,
    required this.totalActiveTimeLabel,
    required this.sessionHistoryHeading,
    required this.formatDate,
    required this.formatDateTime,
    required this.formatDuration,
    required this.formatCompactDate,
    required this.latestLabel,
    required this.totalReadingsLabel,
    required this.phoneLabel,
    required this.emailLabel,
    required this.generatedByLabel,
    required this.readingDateLabel,
    required this.systolicShortLabel,
    required this.diastolicShortLabel,
    required this.pulseShortLabel,
    required this.unitMmHgLabel,
    required this.unitBpmLabel,
  });

  final String defaultTitle;
  final Map<ReportSection, String> sectionTitles;
  final Map<ReportDateRangeType, String> rangeLabels;
  final String periodLabel;
  final String reportDateLabel;
  final String reportStatusLabel;
  final String birthDateLabel;
  final String genderLabel;
  final String maleLabel;
  final String femaleLabel;
  final String genderOtherLabel;
  final String bloodTypeLabel;
  final String heightLabel;
  final String weightLabel;
  final String allergiesLabel;
  final String emergencyContactLabel;
  final String statMin;
  final String statMax;
  final String statAvg;
  final String readingsHeader;

  /// `String Function(int included, int total)` disclosure for truncated
  /// reading tables.
  final String Function(int included, int total) showingLatest;
  final String emptyPeriodNote;

  /// `String Function(int count)`.
  final String Function(int count) attachmentsLabel;
  final String notesLabel;
  final String instructionsLabel;
  final String sourceLabel;
  final String frequencyLabel;
  final String timingLabel;
  final String durationLabel;
  final String foodGroupLabel;
  final String doctorLabel;
  final String organizationLabel;
  final String reasonLabel;
  final String prescriptionDateLabel;
  final String analysisDateLabel;
  final String resultReceivedLabel;
  final String laboratoryLabel;
  final String orderingDoctorLabel;

  /// Stable visit status name -> label ('scheduled'|'completed'|'cancelled'|'missed').
  final Map<String, String> visitStatusLabels;

  /// Stable session status name -> label ('completed'|'cancelled').
  final Map<String, String> sessionStatusLabels;

  /// Guidance category key ('diet'|'smoking'|'hydration'|'caffeine'|
  /// 'alcohol'|'other') -> label.
  final Map<String, String> guidanceCategoryLabels;

  /// Food category key ('allowed'|'caution'|'avoid'|'other') -> label.
  final Map<String, String> foodCategoryLabels;
  final String dietFoodsHeading;
  final String dietGuidanceHeading;

  /// `String Function(int count, int completed, int cancelled)`.
  final String Function(int count, int completed, int cancelled)
      activitySummary;
  final String totalActiveTimeLabel;
  final String sessionHistoryHeading;

  final String Function(DateTime) formatDate;
  final String Function(DateTime) formatDateTime;
  final String Function(Duration) formatDuration;

  /// Compact date for chart X-axis labels (e.g. "4 Aug" / "4 აგვ").
  final String Function(DateTime) formatCompactDate;
  final String latestLabel;

  /// `String Function(int count)` for "Total readings: N".
  final String Function(int count) totalReadingsLabel;
  final String phoneLabel;
  final String emailLabel;
  final String generatedByLabel;
  final String readingDateLabel;
  final String systolicShortLabel;
  final String diastolicShortLabel;
  final String pulseShortLabel;
  final String unitMmHgLabel;
  final String unitBpmLabel;

  /// Full "Generated: …" line for the document header.
  late final String Function(DateTime) formatGeneratedAt;

  factory ReportLocalization.of(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formatter = AppDateFormatter.of(context);
    return ReportLocalization(
      defaultTitle: l10n.reportDefaultTitle,
      sectionTitles: {
        ReportSection.profile: l10n.reportPatientSummary,
        ReportSection.medications: l10n.medications,
        ReportSection.measurements: l10n.measurements,
        ReportSection.doctorVisits: l10n.doctorVisits,
        ReportSection.doctorPrescriptions: l10n.doctorPrescriptions,
        ReportSection.labAnalyses: l10n.labAnalyses,
        ReportSection.diet: l10n.diet,
        ReportSection.activities: l10n.activities,
      },
      rangeLabels: {
        ReportDateRangeType.last7Days: l10n.reportRangeLastWeek,
        ReportDateRangeType.last30Days: l10n.reportRangeLastMonth,
        ReportDateRangeType.last90Days: l10n.reportRangeLast3Months,
        ReportDateRangeType.allTime: l10n.reportRangeAllTime,
        ReportDateRangeType.custom: l10n.reportRangeCustom,
      },
      periodLabel: l10n.reportPeriodLabel,
      reportDateLabel: l10n.reportDateLabel,
      reportStatusLabel: l10n.reportStatusLabel,
      birthDateLabel: l10n.reportBirthDateLabel,
      genderLabel: l10n.gender,
      maleLabel: l10n.male,
      femaleLabel: l10n.female,
      genderOtherLabel: l10n.reportGenderOther,
      bloodTypeLabel: l10n.bloodType,
      heightLabel: l10n.heightCm,
      weightLabel: l10n.weightKg,
      allergiesLabel: l10n.allergies,
      emergencyContactLabel: l10n.emergencyContact,
      statMin: l10n.reportStatMin,
      statMax: l10n.reportStatMax,
      statAvg: l10n.reportStatAvg,
      readingsHeader: l10n.readingCount,
      showingLatest: l10n.reportShowingLatest,
      emptyPeriodNote: l10n.reportEmptyPeriodNote,
      attachmentsLabel: l10n.reportAttachmentsCount,
      notesLabel: l10n.notes,
      instructionsLabel: l10n.instructions,
      sourceLabel: l10n.source,
      frequencyLabel: l10n.frequency,
      timingLabel: l10n.timing,
      durationLabel: l10n.duration,
      foodGroupLabel: l10n.foodGroup,
      doctorLabel: l10n.doctor,
      organizationLabel: l10n.organization,
      reasonLabel: l10n.visitReason,
      prescriptionDateLabel: l10n.prescriptionDate,
      analysisDateLabel: l10n.analysisDate,
      resultReceivedLabel: l10n.resultReceivedDate,
      laboratoryLabel: l10n.laboratory,
      orderingDoctorLabel: l10n.orderingDoctor,
      visitStatusLabels: {
        'scheduled': l10n.scheduled,
        'completed': l10n.completedStatus,
        'cancelled': l10n.cancelledStatus,
        'missed': l10n.missed,
      },
      sessionStatusLabels: {
        'completed': l10n.completedStatus,
        'cancelled': l10n.cancelledStatus,
      },
      guidanceCategoryLabels: {
        'diet': l10n.dietGuidanceCategory,
        'smoking': l10n.smokingGuidanceCategory,
        'hydration': l10n.hydrationGuidanceCategory,
        'caffeine': l10n.caffeineGuidanceCategory,
        'alcohol': l10n.alcoholGuidanceCategory,
        'other': l10n.otherGuidanceCategory,
      },
      foodCategoryLabels: {
        'allowed': l10n.allowed,
        'caution': l10n.caution,
        'avoid': l10n.avoid,
        'other': l10n.otherGuidanceCategory,
      },
      dietFoodsHeading: l10n.reportDietFoodsHeading,
      dietGuidanceHeading: l10n.reportDietGuidanceHeading,
      activitySummary: l10n.reportActivitySummary,
      totalActiveTimeLabel: l10n.reportTotalActiveTime,
      sessionHistoryHeading: l10n.reportSessionHistoryHeading,
      formatDate: formatter.formatMediumDate,
      formatDateTime: formatter.formatMediumDateTime,
      formatDuration: formatHm,
      formatCompactDate: formatter.formatMonthDay,
      latestLabel: l10n.reportLatest,
      totalReadingsLabel: l10n.reportTotalReadingsCount,
      phoneLabel: l10n.reportPatientPhone,
      emailLabel: l10n.reportPatientEmail,
      generatedByLabel: l10n.reportGeneratedBy,
      readingDateLabel: l10n.reportReadingDate,
      systolicShortLabel: l10n.reportSystolicShort,
      diastolicShortLabel: l10n.reportDiastolicShort,
      pulseShortLabel: l10n.reportPulseShort,
      unitMmHgLabel: l10n.reportUnitMmHg,
      unitBpmLabel: l10n.reportUnitBpm,
    )..formatGeneratedAt =
        (dt) => l10n.reportGeneratedAt(formatter.formatMediumDateTime(dt));
  }

  /// Title actually rendered: a configuration left on the default English
  /// title is replaced with the localized default; user-entered titles are
  /// shown verbatim.
  String titleFor(ReportConfiguration configuration) {
    final effective = configuration.effectiveTitle;
    if (effective == ReportConfiguration.defaultTitle) return defaultTitle;
    return effective;
  }

  String? genderLabelFor(String? stored) {
    switch (stored) {
      case 'male':
        return maleLabel;
      case 'female':
        return femaleLabel;
      case 'other':
        return genderOtherLabel;
      default:
        return stored?.trim().isEmpty ?? true ? null : stored!.trim();
    }
  }
}
