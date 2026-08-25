/// Sections a Health Report can include.
///
/// The declaration order is the canonical report order used by both the
/// preview and the generated PDF; it must never be localized or re-sorted.
enum ReportSection {
  profile,
  medications,
  measurements,
  doctorVisits,
  doctorPrescriptions,
  labAnalyses,
  diet,
  activities;

  /// All sections in canonical report order.
  static const List<ReportSection> ordered = ReportSection.values;

  /// Default selection: every section enabled.
  static Set<ReportSection> get all => ReportSection.values.toSet();
}
