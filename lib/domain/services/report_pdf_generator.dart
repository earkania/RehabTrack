import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:rehab_track/domain/entities/report_data.dart';
import 'package:rehab_track/domain/entities/report_date_range.dart';
import 'package:rehab_track/domain/entities/report_section.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/domain/services/bmi.dart';
import 'package:rehab_track/domain/services/reading_status_calculator.dart';
import 'package:rehab_track/domain/services/report_localization.dart';
import 'package:rehab_track/domain/services/report_pdf_theme.dart';

/// Pre-loaded fonts for PDF rendering. Loaded asynchronously by the
/// presentation layer (rootBundle) and handed to the generator, keeping the
/// generator itself free of Flutter imports.
class ReportFonts {
  const ReportFonts({
    required this.regular,
    required this.bold,
    required this.georgianRegular,
    required this.georgianBold,
  });

  final pw.Font regular;
  final pw.Font bold;
  final pw.Font georgianRegular;
  final pw.Font georgianBold;
}

/// Renders an immutable [ReportData] into a polished PDF byte stream.
///
/// Layout: branded header with patient/period meta, unnumbered sections
/// with ending dividers, transposed measurement summary side-by-side with
/// a combined trend chart, compact two-line column headers, and a
/// page-footer with generation provenance.
class ReportPdfGenerator {
  Future<Uint8List> build({
    required ReportData data,
    required ReportLocalization loc,
    required ReportFonts fonts,
  }) async {
    final theme = ReportPdfTheme(fonts);
    final doc = pw.Document(theme: _pwThemeData(fonts));

    doc.addPage(
      pw.MultiPage(
        pageFormat: ReportPdfTheme.pageFormat,
        margin: ReportPdfTheme.pageMargin,
        header: (ctx) =>
            ctx.pageNumber == 1 ? _brandedHeader(data, loc, theme) : pw.SizedBox(),
        footer: (ctx) => _footer(ctx, loc, theme),
        build: (ctx) => _sections(data: data, loc: loc, t: theme),
      ),
    );

    return doc.save();
  }

  String buildFileName(ReportData data) {
    final titleSlug = data.configuration.effectiveTitle
        .replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final d = data.generatedAt;
    final dateStamp =
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return 'RehabTrack_${titleSlug.isEmpty ? 'Report' : titleSlug}_$dateStamp.pdf';
  }

  // =========================================================================
  //  THEME
  // =========================================================================

  pw.ThemeData _pwThemeData(ReportFonts fonts) => pw.ThemeData.withFont(
        base: fonts.regular,
        bold: fonts.bold,
      );

  // =========================================================================
  //  HEADER — page 1 only
  // =========================================================================

  pw.Widget _brandedHeader(
    ReportData data,
    ReportLocalization loc,
    ReportPdfTheme t,
  ) {
    final p = data.profileSummary;
    final hasPatient = p != null && p.fullName.trim().isNotEmpty;
    final hasPhone = p?.phone != null && p!.phone!.trim().isNotEmpty;
    final hasEmail = p?.email != null && p!.email!.trim().isNotEmpty;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Brand line
        pw.Text(
          'REHABTRACK',
          style: pw.TextStyle(
            font: t.fonts.bold,
            fontFallback: [t.fonts.georgianBold],
            fontSize: 11,
            color: ReportPdfTheme.secondary,
            letterSpacing: 1.5,
          ),
        ),
        pw.SizedBox(height: 4),
        // Two-sided title row: report title left, patient name right.
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Expanded(
              child: pw.Text(
                loc.titleFor(data.configuration),
                style: t.reportTitleStyle,
              ),
            ),
            if (hasPatient)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(p.fullName, style: t.patientNameStyle),
                  if (hasPhone)
                    pw.Text(p.phone!, style: t.metaStyle),
                  if (hasEmail)
                    pw.Text(p.email!, style: t.metaStyle),
                ],
              ),
          ],
        ),
        pw.SizedBox(height: 6),
        // Metadata line
        pw.Text(
          '${loc.periodLabel}: ${_rangeText(data, loc)}',
          style: t.metaStyle,
        ),
        pw.SizedBox(height: 2),
        pw.Text(loc.formatGeneratedAt(data.generatedAt), style: t.metaStyle),
        pw.Divider(
          color: ReportPdfTheme.divider,
          thickness: ReportPdfTheme.headerDividerThickness,
          height: 18,
        ),
      ],
    );
  }

  String _rangeText(ReportData data, ReportLocalization loc) {
    final c = data.configuration;
    final label = loc.rangeLabels[c.dateRangeType] ?? '';
    if (c.dateRangeType == ReportDateRangeType.allTime) return label;
    final range = ReportDateRangeResolver.resolve(
      c.dateRangeType,
      data.generatedAt,
      customStart: c.customStartDate,
      customEnd: c.customEndDate,
    );
    if (range.startInclusive == null || range.endExclusive == null) return label;
    return '$label (${loc.formatDate(range.startInclusive!)} – '
        '${loc.formatDate(range.endExclusive!)})';
  }

  // =========================================================================
  //  FOOTER
  // =========================================================================

  pw.Widget _footer(pw.Context ctx, ReportLocalization loc, ReportPdfTheme t) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(loc.generatedByLabel, style: t.footerStyle),
          pw.Text('${ctx.pageNumber} / ${ctx.pagesCount}', style: t.footerStyle),
        ],
      ),
    );
  }

  // =========================================================================
  //  BODY — section dispatch
  // =========================================================================

  List<pw.Widget> _sections({
    required ReportData data,
    required ReportLocalization loc,
    required ReportPdfTheme t,
  }) {
    final widgets = <pw.Widget>[];
    var renderedAny = false;

    for (final section in data.configuration.orderedSections) {
      if (data.isEmptySection(section)) continue;

      if (renderedAny) widgets.add(pw.SizedBox(height: ReportPdfTheme.sectionGap));

      // Force a new page before section heading if less than ~2 lines of
      // vertical space remain — prevents orphaned headings at page bottoms.
      widgets.add(pw.NewPage(freeSpace: 50));

      // Section heading (no numbering).
      widgets.add(_sectionHeading(loc.sectionTitles[section]!, t));
      widgets.add(pw.SizedBox(height: ReportPdfTheme.subsectionGap));

      switch (section) {
        case ReportSection.profile:
          widgets.add(_profileSection(data, loc, t));
        case ReportSection.medications:
          widgets.add(_medicationsSection(data, loc, t));
        case ReportSection.measurements:
          widgets.addAll(_measurementsSection(data, loc, t));
        case ReportSection.doctorVisits:
          widgets.add(_visitsSection(data, loc, t));
        case ReportSection.doctorPrescriptions:
          widgets.add(_prescriptionsSection(data, loc, t));
        case ReportSection.labAnalyses:
          widgets.add(_labAnalysesSection(data, loc, t));
        case ReportSection.diet:
          widgets.add(_dietSection(data, loc, t));
        case ReportSection.activities:
          widgets.add(_activitiesSection(data, loc, t));
      }

      // Section-ending divider (skip after the last rendered section).
      widgets.add(pw.SizedBox(height: ReportPdfTheme.subsectionGap));
      widgets.add(pw.Divider(
        color: ReportPdfTheme.divider,
        thickness: ReportPdfTheme.headerDividerThickness,
      ));

      renderedAny = true;
    }

    if (!renderedAny) {
      widgets.add(pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8),
        child: pw.Text(loc.emptyPeriodNote, style: t.captionStyle),
      ));
    }
    return widgets;
  }

  pw.Widget _sectionHeading(String title, ReportPdfTheme t) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: ReportPdfTheme.divider,
            width: ReportPdfTheme.headerDividerThickness,
          ),
        ),
      ),
      child: pw.Text(title, style: t.sectionHeadingStyle),
    );
  }

  // =========================================================================
  //  PROFILE — no phone/email (moved to header)
  // =========================================================================

  pw.Widget _profileSection(
    ReportData data,
    ReportLocalization loc,
    ReportPdfTheme t,
  ) {
    final p = data.profileSummary!;
    final rows = <(String, String)>[
      (loc.birthDateLabel,
          p.birthDate == null ? '—' : loc.formatDate(p.birthDate!)),
      (loc.genderLabel, loc.genderLabelFor(p.gender) ?? '—'),
      if (p.bloodType != null) (loc.bloodTypeLabel, p.bloodType!),
      if (p.heightCm != null) (loc.heightLabel, _num(p.heightCm!)),
      if (p.weightKg != null) (loc.weightLabel, _num(p.weightKg!)),
      if (p.bmi != null) (loc.bmiLabel, formatBmi(p.bmi!)),
      if (p.allergies != null && p.allergies!.isNotEmpty)
        (loc.allergiesLabel, p.allergies!),
      if (p.emergencyContactName != null || p.emergencyContactPhone != null)
        (
          loc.emergencyContactLabel,
          [p.emergencyContactName, p.emergencyContactPhone]
              .whereType<String>()
              .where((s) => s.trim().isNotEmpty)
              .join(' · ')
        ),
    ].where((r) => r.$2.isNotEmpty && r.$2 != '—').toList();

    // 2-column key/value grid.
    final pairs = <(String, String, String, String)>[];
    for (var i = 0; i < rows.length; i += 2) {
      final l1 = rows[i].$1;
      final v1 = rows[i].$2;
      if (i + 1 < rows.length) {
        pairs.add((l1, v1, rows[i + 1].$1, rows[i + 1].$2));
      } else {
        pairs.add((l1, v1, '', ''));
      }
    }

    return pw.Table(
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      columnWidths: {
        0: const pw.FlexColumnWidth(1.2),
        1: const pw.FlexColumnWidth(2.5),
        2: const pw.FlexColumnWidth(1.2),
        3: const pw.FlexColumnWidth(2.5),
      },
      children: [
        for (final (l1, v1, l2, v2) in pairs)
          pw.TableRow(
            children: [
              _kvLabel(l1, t),
              _kvValue(v1, t),
              _kvLabel(l2, t),
              _kvValue(v2, t),
            ],
          ),
      ],
    );
  }

  pw.Widget _kvLabel(String text, ReportPdfTheme t) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
          vertical: 2, horizontal: ReportPdfTheme.cellPaddingH),
      child: pw.Text(text, style: t.captionBoldStyle),
    );
  }

  pw.Widget _kvValue(String text, ReportPdfTheme t) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
          vertical: 2, horizontal: ReportPdfTheme.cellPaddingH),
      child: pw.Text(text, style: t.bodyStyle),
    );
  }

  // =========================================================================
  //  MEDICATIONS — column-major two-column, vertical divider
  // =========================================================================

  pw.Widget _medicationsSection(
    ReportData data,
    ReportLocalization loc,
    ReportPdfTheme t,
  ) {
    if (data.medications.isEmpty) return pw.SizedBox();
    if (data.medications.length < 5) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < data.medications.length; i++)
            _medicationItem(i + 1, data.medications[i], t),
        ],
      );
    }

    // >= 5: column-major split — left fills top-to-bottom, then right.
    final totalCount = data.medications.length;
    final leftCount = (totalCount / 2).ceil();
    final leftItems = data.medications.sublist(0, leftCount);
    final rightItems = data.medications.sublist(leftCount);

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < leftItems.length; i++)
                _medicationItem(i + 1, leftItems[i], t),
            ],
          ),
        ),
        pw.SizedBox(width: 8),
        // Subtle vertical divider.
        pw.Container(
          width: 0.5,
          color: ReportPdfTheme.divider,
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < rightItems.length; i++)
                _medicationItem(leftCount + i + 1, rightItems[i], t),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _medicationItem(int number, ReportMedication med, ReportPdfTheme t) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.RichText(
          text: pw.TextSpan(children: [
            pw.TextSpan(text: '$number. ', style: t.bodyBoldStyle),
            pw.TextSpan(text: med.name, style: t.bodyBoldStyle),
            if (med.doseAmount != null || med.doseUnit != null)
              pw.TextSpan(
                text:
                    '  ${[med.doseAmount, med.doseUnit].whereType<String>().join(' ')}',
                style: t.bodyStyle,
              ),
          ]),
        ),
        if (med.scheduleSummary != null) _bullet(med.scheduleSummary!, t),
        if (med.instructions != null) _bullet(med.instructions!, t),
      ],
    );
  }

  // =========================================================================
  //  MEASUREMENTS — side-by-side summary + combined chart + readings
  // =========================================================================

  List<pw.Widget> _measurementsSection(
    ReportData data,
    ReportLocalization loc,
    ReportPdfTheme t,
  ) {
    final widgets = <pw.Widget>[];
    for (final type in data.measurements) {
      // Type sub-heading.
      widgets.add(pw.Text(type.typeName, style: t.subsectionStyle));
      widgets.add(pw.SizedBox(height: ReportPdfTheme.subsectionGap));

      // Side-by-side: summary table ~35% + chart ~65%.
      if (type.readings.isNotEmpty && type.components.isNotEmpty) {
        widgets.add(pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 190,
              child: _transposedSummary(type, loc, t),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: _combinedChart(type, loc, t),
            ),
          ],
        ));
      } else {
        widgets.add(_transposedSummary(type, loc, t));
      }

      widgets.add(pw.SizedBox(height: ReportPdfTheme.subsectionGap));

      // Total readings count.
      widgets.add(pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 3),
        child: pw.Text(
          loc.totalReadingsLabel(type.totalReadingCount),
          style: t.captionStyle,
        ),
      ));

      // Individual readings table.
      widgets.addAll(_readingsSection(type, loc, t));
      widgets.add(pw.SizedBox(height: ReportPdfTheme.subsectionGap));
    }
    return widgets;
  }

  // ---- Transposed summary table -------------------------------------------

  pw.Widget _transposedSummary(
    ReportMeasurementTypeData type,
    ReportLocalization loc,
    ReportPdfTheme t,
  ) {
    final ranges = type.effectiveRanges;

    // Each metric row: (label, [(displayValue, rawValue)]).
    // rawValue is used for status classification; displayValue for rendering.
    final metrics = <(String, List<(String, double?)>)>[
      (
        loc.latestLabel,
        [for (final c in type.components)
          (c.latest != null ? _num(c.latest!) : '—', c.latest)]
      ),
      (
        loc.statAvg,
        [for (final c in type.components)
          (_num(c.average.roundToDouble()), c.average)]
      ),
      (
        loc.statMin,
        [for (final c in type.components)
          (_num(c.minimum), c.minimum)]
      ),
      (
        loc.statMax,
        [for (final c in type.components)
          (_num(c.maximum), c.maximum)]
      ),
    ];

    // Visible header row with dark background — matches recordings table.
    final headerRow = pw.TableRow(
      decoration: t.tableHeaderDecoration,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(
              vertical: ReportPdfTheme.cellPaddingV,
              horizontal: ReportPdfTheme.cellPaddingH),
          child: pw.Text('', style: t.tableHeaderStyle),
        ),
        for (final c in type.components)
          _measurementColumnHeader(
            label: _shortLabel(c.label, loc),
            unit: _unitForComponent(c, loc),
            t: t,
          ),
      ],
    );

    final dataRows = <pw.TableRow>[];
    for (var ri = 0; ri < metrics.length; ri++) {
      final (label, values) = metrics[ri];
      dataRows.add(pw.TableRow(
        decoration: ri.isEven ? t.tableAltRowDecoration : null,
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(
                vertical: ReportPdfTheme.cellPaddingV,
                horizontal: ReportPdfTheme.cellPaddingH),
            child: pw.Text(label, style: t.captionBoldStyle),
          ),
          for (var ci = 0; ci < values.length; ci++)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                  vertical: ReportPdfTheme.cellPaddingV,
                  horizontal: ReportPdfTheme.cellPaddingH),
              child: pw.Center(
                child: pw.Text(
                  values[ci].$1,
                  style: _statusTextStyle(
                    type.components[ci].fieldKey,
                    values[ci].$2,
                    ranges,
                    t.tableCellStyle,
                  ),
                ),
              ),
            ),
        ],
      ));
    }

    return pw.Table(
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      columnWidths: {
        0: const pw.FlexColumnWidth(1.2),
        for (var i = 1; i <= type.components.length; i++)
          i: const pw.FlexColumnWidth(1.8),
      },
      children: [headerRow, ...dataRows],
    );
  }

  // ---- Combined trend chart (all series on one chart) ---------------------

  pw.Widget _combinedChart(
    ReportMeasurementTypeData type,
    ReportLocalization loc,
    ReportPdfTheme t,
  ) {
    if (type.readings.isEmpty) return pw.SizedBox();
    final readingsAsc = type.readings.toList().reversed.toList();
    if (readingsAsc.length < 2) return pw.SizedBox();

    // Collect all values across all components for Y-axis computation.
    final allValues = <double>[];
    for (final row in readingsAsc) {
      for (final v in row.values) {
        allValues.add(v.value);
      }
    }
    if (allValues.isEmpty) return pw.SizedBox();

    final axis = _computeYAxis(allValues);

    // Adaptive X-axis label density: target ~5-8 visible labels.
    final xCount = readingsAsc.length;
    final targetLabels = 6;
    final labelInterval = xCount <= targetLabels
        ? 1
        : (xCount / targetLabels).ceil();

    // Short date labels for X-axis (e.g. "Jul 28", "Aug 3").
    final dateLabels = <String>[
      for (var i = 0; i < xCount; i++)
        if (i % labelInterval == 0 || i == xCount - 1)
          loc.formatCompactDate(readingsAsc[i].measuredAt)
        else
          '',
    ];

    // Chart axis text style: compact caption (8 pt) to avoid crowding.
    final axisTextStyle = pw.TextStyle(
      font: t.fonts.regular,
      fontSize: ReportPdfTheme.caption,
      color: ReportPdfTheme.secondary,
    );

    // Build one continuous line per component, with individual data-point
    // markers coloured by measurement status.
    //
    // The pdf package's LineDataSet draws both line + points with uniform
    // colour.  To keep the line continuous (series colour) while colouring
    // each marker independently, we use:
    //   • one LineDataSet(drawPoints: false)  → continuous series line
    //   • one PointDataSet per status group   → status-coloured markers
    //
    // Uses the effective ranges resolved by ReportBuilder (profile overrides
    // merged with defaults) — identical to what Measurement Trends uses.
    final ranges = type.effectiveRanges;

    final datasets = <pw.Dataset>[];
    for (var ci = 0; ci < type.components.length; ci++) {
      final fieldKey = type.components[ci].fieldKey;
      final seriesColor = _chartColor(ci);

      // Collect all points and classify each by status.
      final allPoints = <pw.PointChartValue>[];
      final byStatus = <ReadingStatus, List<pw.PointChartValue>>{};
      for (var ri = 0; ri < readingsAsc.length; ri++) {
        final row = readingsAsc[ri];
        if (ci < row.values.length) {
          final pt = pw.PointChartValue(ri.toDouble(), row.values[ci].value);
          allPoints.add(pt);
          final status = ReadingStatusCalculator.calculateFieldValue(
            fieldKey: fieldKey ?? '',
            value: row.values[ci].value,
            ranges: ranges,
          );
          byStatus.putIfAbsent(status, () => []);
          byStatus[status]!.add(pt);
        }
      }

      if (allPoints.length < 2) continue;

      // 1) Continuous line in the series colour (no visible markers).
      datasets.add(pw.LineDataSet(
        data: allPoints,
        color: seriesColor,
        lineWidth: 1.5,
        drawPoints: false,
      ));

      // 2) Status-coloured point markers (no connecting line).
      for (final entry in byStatus.entries) {
        if (entry.value.isEmpty) continue;
        datasets.add(pw.PointDataSet(
          data: entry.value,
          color: _statusPdfColor(entry.key),
          pointSize: 3,
          drawPoints: true,
        ));
      }
    }

    if (datasets.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Legend row — offset left to centre over the chart plot area,
        // accounting for Y-axis label space consumed by the CartesianGrid.
        pw.Container(
          padding: const pw.EdgeInsets.only(left: 30),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              for (var ci = 0; ci < type.components.length; ci++)
                pw.Container(
                  margin: const pw.EdgeInsets.only(right: 8),
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 10,
                        height: 3,
                        color: _chartColor(ci),
                      ),
                      pw.SizedBox(width: 3),
                      pw.Text(
                        _shortLabel(type.components[ci].label, loc),
                        style: t.captionStyle.copyWith(fontSize: ReportPdfTheme.caption),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        pw.SizedBox(height: 3),
        pw.SizedBox(
          height: 100,
          child: pw.Chart(
            grid: pw.CartesianGrid(
              xAxis: pw.FixedAxis<int>(
                List<int>.generate(xCount, (i) => i),
                format: (num v) => dateLabels[v.toInt()],
                textStyle: axisTextStyle,
              ),
              yAxis: pw.FixedAxis<double>(
                axis.ticks,
                format: (num v) => _num(v.toDouble()),
                textStyle: axisTextStyle,
                divisions: true,
                divisionsColor: PdfColors.grey200,
                divisionsWidth: 0.3,
              ),
            ),
            datasets: datasets,
          ),
        ),
      ],
    );
  }

  PdfColor _chartColor(int index) {
    const palette = [
      PdfColors.blue800,
      PdfColors.red700,
      PdfColors.teal700,
      PdfColors.amber800,
    ];
    return palette[index % palette.length];
  }

  /// Maps a [ReadingStatus] to a PDF colour matching the app's
  /// [ReadingStatusColor.forStatus]: green for in-range, blue for below,
  /// red for above, grey for unknown.
  PdfColor _statusPdfColor(ReadingStatus status) {
    return switch (status) {
      ReadingStatus.inRange    => ReportPdfTheme.statusNormal,
      ReadingStatus.belowRange => ReportPdfTheme.statusLow,
      ReadingStatus.aboveRange => ReportPdfTheme.statusHigh,
      ReadingStatus.unknown    => ReportPdfTheme.statusUnknown,
    };
  }

  /// Returns [base] styled with the status colour for the given
  /// [fieldKey]/[value]/[ranges].  If no ranges are available or the value is
  /// null, the base style is returned unchanged.
  pw.TextStyle _statusTextStyle(
    String? fieldKey,
    double? value,
    MeasurementRanges? ranges,
    pw.TextStyle base,
  ) {
    if (ranges == null || value == null) return base;
    final status = ReadingStatusCalculator.calculateFieldValue(
      fieldKey: fieldKey ?? '',
      value: value,
      ranges: ranges,
    );
    if (status == ReadingStatus.unknown) return base;
    return base.copyWith(color: _statusPdfColor(status));
  }

  // ---- Readings table (single or two-column) ------------------------------

  List<pw.Widget> _readingsSection(
    ReportMeasurementTypeData type,
    ReportLocalization loc,
    ReportPdfTheme t,
  ) {
    if (type.readings.isEmpty) return const [];

    const threshold = 12;
    if (type.readings.length >= threshold) {
      // Two-column side-by-side tables.
      final totalCount = type.readings.length;
      final leftCount = (totalCount / 2).ceil();
      final leftReadings = type.readings.sublist(0, leftCount);
      final rightReadings = type.readings.sublist(leftCount);

      return [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: _readingsTable(leftReadings, type, loc, t),
            ),
            pw.SizedBox(width: 6),
            pw.Container(
              width: 0.5,
              color: ReportPdfTheme.divider,
            ),
            pw.SizedBox(width: 6),
            pw.Expanded(
              child: _readingsTable(rightReadings, type, loc, t),
            ),
          ],
        ),
      ];
    }

    return [_readingsTable(type.readings, type, loc, t)];
  }

  /// Builds a compact readings table with two-line headers. Values are
  /// unit-free numbers, centered, with per-cell status coloring.
  pw.Widget _readingsTable(
    List<ReportReadingRow> readings,
    ReportMeasurementTypeData type,
    ReportLocalization loc,
    ReportPdfTheme t,
  ) {
    if (readings.isEmpty) return pw.SizedBox();

    final ranges = type.effectiveRanges;

    // Two-line header row with background decoration.
    final headerRow = pw.TableRow(
      decoration: t.tableHeaderDecoration,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(
              vertical: ReportPdfTheme.cellPaddingV,
              horizontal: ReportPdfTheme.cellPaddingH),
          child: pw.Text(loc.readingDateLabel, style: t.tableHeaderStyle),
        ),
        for (final c in type.components)
          _measurementColumnHeader(
            label: _shortLabel(c.label, loc),
            unit: _unitForComponent(c, loc),
            t: t,
          ),
      ],
    );

    final dataRows = <pw.TableRow>[];
    for (var ri = 0; ri < readings.length; ri++) {
      final row = readings[ri];
      final isEven = ri.isEven;
      dataRows.add(pw.TableRow(
        decoration: isEven ? t.tableAltRowDecoration : null,
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(
                vertical: ReportPdfTheme.cellPaddingV,
                horizontal: ReportPdfTheme.cellPaddingH),
            child: pw.Text(
              loc.formatDateTime(row.measuredAt),
              style: t.tableCellStyle,
            ),
          ),
          for (var i = 0; i < type.components.length; i++)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                  vertical: ReportPdfTheme.cellPaddingV,
                  horizontal: ReportPdfTheme.cellPaddingH),
              child: pw.Center(
                child: pw.Text(
                  i < row.values.length ? _num(row.values[i].value) : '—',
                  style: i < row.values.length
                      ? _statusTextStyle(
                          type.components[i].fieldKey,
                          row.values[i].value,
                          ranges,
                          t.tableCellStyle,
                        )
                      : t.tableCellStyle,
                ),
              ),
            ),
        ],
      ));
    }

    return pw.Table(
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        for (var i = 1; i <= type.components.length; i++)
          i: const pw.FlexColumnWidth(1.5),
      },
      border: pw.TableBorder(
        horizontalInside:
            pw.BorderSide(color: ReportPdfTheme.divider, width: 0.3),
        top: pw.BorderSide(color: ReportPdfTheme.divider, width: 0.4),
        bottom: pw.BorderSide(color: ReportPdfTheme.divider, width: 0.4),
      ),
      children: [headerRow, ...dataRows],
    );
  }

  // =========================================================================
  //  MEASUREMENT COLUMN HEADER — two-line: label + (unit)
  // =========================================================================

  pw.Widget _measurementColumnHeader({
    required String label,
    required String unit,
    required ReportPdfTheme t,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
          vertical: ReportPdfTheme.cellPaddingV,
          horizontal: ReportPdfTheme.cellPaddingH),
      child: pw.Column(
        children: [
          pw.Text(label, style: t.tableHeaderStyle),
          pw.Text('($unit)', style: t.captionStyle.copyWith(color: ReportPdfTheme.tableHeaderFg)),
        ],
      ),
    );
  }

  // =========================================================================
  //  DOCTOR VISITS
  // =========================================================================

  pw.Widget _visitsSection(
    ReportData data,
    ReportLocalization loc,
    ReportPdfTheme t,
  ) {
    return t.dataTable(
      headers: [
        loc.reportDateLabel,
        loc.doctorLabel,
        loc.organizationLabel,
        loc.reportStatusLabel,
        loc.reasonLabel,
      ],
      rows: [
        for (final v in data.doctorVisits)
          [
            loc.formatDateTime(v.scheduledAt),
            v.doctorName ?? '—',
            v.organizationName ?? '—',
            loc.visitStatusLabels[v.status] ?? v.status,
            v.reason ?? '—',
          ],
      ],
      stripeRows: true,
    );
  }

  // =========================================================================
  //  PRESCRIPTIONS — card layout
  // =========================================================================

  pw.Widget _prescriptionsSection(
    ReportData data,
    ReportLocalization loc,
    ReportPdfTheme t,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (final rx in data.doctorPrescriptions)
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 7),
            padding: const pw.EdgeInsets.all(7),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: ReportPdfTheme.divider, width: 0.5),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(rx.title, style: t.subsectionStyle),
                _labeledLine(loc.prescriptionDateLabel,
                    loc.formatDateTime(rx.prescriptionDate), t),
                _labeledLine(loc.doctorLabel, rx.doctorName, t),
                _labeledLine(loc.organizationLabel, rx.clinicName, t),
                _labeledLine(loc.reasonLabel, rx.reason, t),
                for (final med in rx.medications)
                  _bullet(_rxMedicationLine(med), t),
                _labeledLine(loc.notesLabel, rx.notes, t),
                if (rx.attachmentNames.isNotEmpty)
                  _labeledLine(
                      loc.attachmentsLabel(rx.attachmentNames.length),
                      rx.attachmentNames.join(', '),
                      t),
              ],
            ),
          ),
      ],
    );
  }

  String _rxMedicationLine(ReportRxMedication med) {
    final parts = [
      [med.doseAmount, med.doseUnit].whereType<String>().join(' ').trim(),
      med.frequency,
      med.timing,
      med.duration,
      med.instructions,
    ].where((p) => p != null && p.trim().isNotEmpty).toList();
    return parts.isEmpty ? med.name : '${med.name} (${parts.join(', ')})';
  }

  // =========================================================================
  //  LAB ANALYSES — card layout
  // =========================================================================

  pw.Widget _labAnalysesSection(
    ReportData data,
    ReportLocalization loc,
    ReportPdfTheme t,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (final lab in data.labAnalyses)
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 7),
            padding: const pw.EdgeInsets.all(7),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: ReportPdfTheme.divider, width: 0.5),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(lab.title, style: t.subsectionStyle),
                _labeledLine(loc.analysisDateLabel,
                    loc.formatDateTime(lab.analysisDate), t),
                if (lab.resultReceivedDate != null)
                  _labeledLine(loc.resultReceivedLabel,
                      loc.formatDateTime(lab.resultReceivedDate!), t),
                _labeledLine(loc.laboratoryLabel, lab.laboratoryName, t),
                _labeledLine(loc.orderingDoctorLabel, lab.orderingDoctorName, t),
                _labeledLine(loc.notesLabel, lab.notes, t),
                if (lab.attachmentNames.isNotEmpty)
                  _labeledLine(
                      loc.attachmentsLabel(lab.attachmentNames.length),
                      lab.attachmentNames.join(', '),
                      t),
              ],
            ),
          ),
      ],
    );
  }

  // =========================================================================
  //  DIET — hierarchical list
  // =========================================================================

  pw.Widget _dietSection(
    ReportData data,
    ReportLocalization loc,
    ReportPdfTheme t,
  ) {
    final diet = data.diet!;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (diet.guidanceByCategory.isNotEmpty) ...[
          pw.Text(loc.dietGuidanceHeading, style: t.subsectionStyle),
          pw.SizedBox(height: ReportPdfTheme.subsectionGap),
          for (final entry in diet.guidanceByCategory.entries) ...[
            pw.Text(
              loc.guidanceCategoryLabels[entry.key] ?? entry.key,
              style: t.bodyBoldStyle,
            ),
            for (final rule in entry.value)
              _bullet(
                rule.description == null
                    ? rule.title
                    : '${rule.title}${rule.source == null ? '' : ' (${rule.source})'} — ${rule.description}',
                t,
              ),
            pw.SizedBox(height: ReportPdfTheme.rowGap),
          ],
        ],
        if (diet.foodsByCategory.isNotEmpty) ...[
          for (final entry in diet.foodsByCategory.entries) ...[
            pw.Text(
              _foodCategoryTitle(entry.key, loc),
              style: t.subsectionStyle,
            ),
            for (final food in entry.value)
              _bullet(
                food.notes == null
                    ? food.name
                    : '${food.name} — ${food.notes}',
                t,
              ),
            pw.SizedBox(height: ReportPdfTheme.rowGap),
          ],
        ],
      ],
    );
  }

  // =========================================================================
  //  ACTIVITIES — summary + session table
  // =========================================================================

  pw.Widget _activitiesSection(
    ReportData data,
    ReportLocalization loc,
    ReportPdfTheme t,
  ) {
    final stats = data.activityStats;
    final durationText = stats != null && stats.totalActiveDuration.inSeconds > 0
        ? loc.formatDuration(stats.totalActiveDuration)
        : '—';
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (stats != null) ...[
          pw.Text(
            loc.activitySummary(
                stats.sessionCount, stats.completedCount, stats.cancelledCount),
            style: t.bodyStyle,
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            '${loc.totalActiveTimeLabel}: $durationText',
            style: t.bodyBoldStyle,
          ),
          pw.SizedBox(height: ReportPdfTheme.subsectionGap),
        ],
        pw.Text(loc.sessionHistoryHeading, style: t.subsectionStyle),
        pw.SizedBox(height: ReportPdfTheme.subsectionGap),
        t.dataTable(
          headers: [
            loc.reportDateLabel,
            loc.sectionTitles[ReportSection.activities]!,
            loc.durationLabel,
            loc.reportStatusLabel,
            loc.notesLabel,
          ],
          rows: [
            for (final s in data.activitySessions)
              [
                loc.formatDateTime(s.startedAt),
                s.activityName,
                s.activeDuration.inSeconds > 0
                    ? loc.formatDuration(s.activeDuration)
                    : '—',
                loc.sessionStatusLabels[s.status] ?? s.status,
                s.notes ?? '—',
              ],
          ],
          stripeRows: true,
        ),
      ],
    );
  }

  // =========================================================================
  //  SHARED HELPERS
  // =========================================================================

  pw.Widget _bullet(String text, ReportPdfTheme t) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 8),
      child: pw.Text('• $text', style: t.bodyStyle),
    );
  }

  pw.Widget _labeledLine(String label, String? value, ReportPdfTheme t) {
    if (value == null || value.trim().isEmpty) return pw.SizedBox();
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.RichText(
        text: pw.TextSpan(children: [
          pw.TextSpan(text: '$label: ', style: t.captionBoldStyle),
          pw.TextSpan(text: value, style: t.bodyStyle),
        ]),
      ),
    );
  }

  /// Builds a combined "Foods to Avoid" / "Recommended Foods" heading for
  /// the diet section, flattening the two-level hierarchy.
  String _foodCategoryTitle(String categoryKey, ReportLocalization loc) {
    final label = loc.foodCategoryLabels[categoryKey] ?? categoryKey;
    final foodsHeading = loc.dietFoodsHeading;
    return '$foodsHeading — $label';
  }

  /// Trims doubles: at most one decimal, no trailing ".0".
  String _num(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    final s = value.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  /// Short display label for a measurement component.
  /// Maps well-known lowercase keys to compact headings; falls back to the
  /// raw label for unknown types.
  String _shortLabel(String rawLabel, ReportLocalization loc) {
    final key = rawLabel.toLowerCase();
    if (key == 'systolic' || key == 'syst') return loc.systolicShortLabel;
    if (key == 'diastolic' || key == 'diast') return loc.diastolicShortLabel;
    if (key == 'pulse') return loc.pulseShortLabel;
    return rawLabel;
  }

  /// Resolves the unit string for a component, preferring the localised
  /// short unit where available.
  String _unitForComponent(ReportComponentStats c, ReportLocalization loc) {
    final unit = c.unit.toLowerCase();
    if (unit == 'mmhg') return loc.unitMmHgLabel;
    if (unit == 'bpm') return loc.unitBpmLabel;
    return c.unit;
  }

  // =========================================================================
  //  Y-AXIS COMPUTATION — shared with presentation MeasurementChartAxis
  //  (identical algorithm, inlined to avoid domain→presentation import).
  // =========================================================================

  static _YAxis _computeYAxis(List<double> values) {
    var min = values.reduce(math.min);
    var max = values.reduce(math.max);

    if (max == min) {
      final magnitude = math.max(max.abs(), 20.0);
      final span = _niceCeilNumber(magnitude * 0.5);
      min = max - span;
      max = max + span;
    }

    final range = max - min;
    final interval = _niceCeilNumber(range / 5);
    final pad = range * 0.05;

    // Always produce integer ticks — no decimal places for BP/Pulse charts.
    final niceMin = _alignDown(min - pad, interval, 0);
    final niceMax = _alignUp(max + pad, interval, 0);

    final tickStart = (niceMin / interval).round();
    final tickEnd = (niceMax / interval).round();
    final ticks = <double>[
      for (var i = tickStart; i <= tickEnd; i++) _clean(i * interval, 0),
    ];

    return _YAxis(ticks: ticks);
  }

  static double _niceCeilNumber(double value) {
    if (value <= 0) return 1.0;
    final exponent = (math.log(value) / math.ln10).floor();
    final fraction = value / math.pow(10, exponent).toDouble();
    final double niceFraction;
    if (fraction <= 1) {
      niceFraction = 1;
    } else if (fraction <= 2) {
      niceFraction = 2;
    } else if (fraction <= 5) {
      niceFraction = 5;
    } else {
      niceFraction = 10;
    }
    return niceFraction * math.pow(10, exponent).toDouble();
  }

  static double _alignDown(double value, double interval, int decimals) =>
      _clean((value / interval).floor() * interval, decimals);

  static double _alignUp(double value, double interval, int decimals) =>
      _clean((value / interval).ceil() * interval, decimals);

  static double _clean(double value, int decimals) {
    if (decimals == 0) return value.roundToDouble();
    final factor = math.pow(10, decimals).toDouble();
    return (value * factor).roundToDouble() / factor;
  }
}

/// Minimal Y-axis result (ticks only — the PDF chart infers bounds from the
/// tick list).
class _YAxis {
  const _YAxis({required this.ticks});
  final List<double> ticks;
}
