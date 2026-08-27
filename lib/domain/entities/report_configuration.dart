import 'package:rehab_track/domain/entities/report_date_range.dart';
import 'package:rehab_track/domain/entities/report_section.dart';

/// User-editable configuration for a Health Report.
///
/// Only stable identifiers are stored here (enums); localized display strings
/// are resolved at render time. Configuration is temporary UI state and is
/// intentionally not persisted.
class ReportConfiguration {
  ReportConfiguration({
    this.title = defaultTitle,
    required this.dateRangeType,
    this.customStartDate,
    this.customEndDate,
    Set<ReportSection>? selectedSections,
    required this.profileId,
  }) : selectedSections = selectedSections ?? ReportSection.all;

  static const String defaultTitle = 'Health Summary';

  final String title;
  final ReportDateRangeType dateRangeType;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  /// Selected sections; iteration order is the canonical report order.
  final Set<ReportSection> selectedSections;

  /// Reports belong to exactly one Patient Profile.
  final int profileId;

  /// Title trimmed for display/rendering.
  String get effectiveTitle {
    final trimmed = title.trim();
    return trimmed.isEmpty ? defaultTitle : trimmed;
  }

  /// A title is required; an empty/whitespace-only title is invalid.
  bool get hasValidTitle => title.trim().isNotEmpty;

  /// Custom ranges require both bounds with start on or before end.
  bool get hasValidCustomRange {
    if (dateRangeType != ReportDateRangeType.custom) return true;
    if (customStartDate == null || customEndDate == null) return false;
    final start = DateTime(
        customStartDate!.year, customStartDate!.month, customStartDate!.day);
    final end =
        DateTime(customEndDate!.year, customEndDate!.month, customEndDate!.day);
    return !start.isAfter(end);
  }

  bool get hasSelectedSection => selectedSections.isNotEmpty;

  /// Full validation used before building the report.
  bool get isValid =>
      hasValidTitle && hasValidCustomRange && hasSelectedSection;

  /// Sections in canonical order (declaration order), filtered by selection.
  List<ReportSection> get orderedSections => ReportSection.ordered
      .where((s) => selectedSections.contains(s))
      .toList();

  ReportConfiguration copyWith({
    String? title,
    ReportDateRangeType? dateRangeType,
    DateTime? customStartDate,
    DateTime? customEndDate,
    Set<ReportSection>? selectedSections,
    int? profileId,
  }) {
    return ReportConfiguration(
      title: title ?? this.title,
      dateRangeType: dateRangeType ?? this.dateRangeType,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      selectedSections: selectedSections ?? this.selectedSections,
      profileId: profileId ?? this.profileId,
    );
  }
}
