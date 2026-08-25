import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:rehab_track/domain/entities/report_data.dart';
import 'package:rehab_track/domain/entities/report_date_range.dart';
import 'package:rehab_track/domain/entities/report_section.dart';
import 'package:rehab_track/domain/services/report_localization.dart';

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

/// Pure pdf-package renderer: turns an immutable [ReportData] plus a
/// [ReportLocalization] bundle into a PDF file. No interpretation of values,
/// no attachment files embedded, no persistence beyond the requested output.
///
/// Layout contract: only sections selected in the configuration are rendered,
/// in canonical [ReportSection.order]; sections whose data is empty are
/// skipped entirely. Latin text renders with NotoSans and Georgian glyphs
/// fall back through the NotoSansGeorgian chain on every style.
class ReportPdfGenerator {
  static const PdfPageFormat _pageFormat = PdfPageFormat.a4;

  /// Renders the report into PDF bytes. Persistence (where the bytes are
  /// written) is the caller's responsibility — see `ReportStorageService`.
  Future<Uint8List> build({
    required ReportData data,
    required ReportLocalization loc,
    required ReportFonts fonts,
  }) async {
    final doc = pw.Document(theme: _theme(fonts));

    doc.addPage(
      pw.MultiPage(
        pageFormat: _pageFormat,
        margin: const pw.EdgeInsets.fromLTRB(36, 40, 36, 36),
        header: (context) => context.pageNumber == 1
            ? _header(data, loc, fonts)
            : pw.SizedBox(),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            '${context.pageNumber} / ${context.pagesCount}',
            style: _muted(fonts),
          ),
        ),
        build: (context) =>
            _body(data: data, loc: loc, fonts: fonts),
      ),
    );

    return doc.save();
  }

  /// `RehabTrack_<Title-Slug>_<yyyy-MM-dd>.pdf`. The slug keeps ASCII word
  /// characters; titles without any (e.g. Georgian) collapse to "Report" so
  /// filenames stay filesystem-safe in every language.
  String buildFileName(ReportData data) {
    final titleSlug = data.configuration.effectiveTitle
        .replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final dateStamp = '${data.generatedAt.year.toString().padLeft(4, '0')}-'
        '${data.generatedAt.month.toString().padLeft(2, '0')}-'
        '${data.generatedAt.day.toString().padLeft(2, '0')}';
    return 'RehabTrack_${titleSlug.isEmpty ? 'Report' : titleSlug}_$dateStamp.pdf';
  }

  // ---- Styling ---------------------------------------------------------------

  pw.ThemeData _theme(ReportFonts fonts) {
    return pw.ThemeData.withFont(
      base: fonts.regular,
      bold: fonts.bold,
    );
  }

  pw.TextStyle _muted(ReportFonts fonts) => pw.TextStyle(
        font: fonts.regular,
        fontFallback: [fonts.georgianRegular],
        fontSize: 8,
        color: PdfColors.grey600,
      );

  pw.TextStyle _sectionTitleStyle(ReportFonts fonts) => pw.TextStyle(
        font: fonts.bold,
        fontFallback: [fonts.georgianBold],
        fontSize: 13,
        color: PdfColors.blueGrey800,
      );

  pw.TextStyle _subHeadingStyle(ReportFonts fonts) => pw.TextStyle(
        font: fonts.bold,
        fontFallback: [fonts.georgianBold],
        fontSize: 10.5,
        color: PdfColors.blueGrey800,
      );

  // ---- Header ----------------------------------------------------------------

  pw.Widget _header(
    ReportData data,
    ReportLocalization loc,
    ReportFonts fonts,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(loc.titleFor(data.configuration),
            style: _sectionTitleStyle(fonts).copyWith(fontSize: 18)),
        pw.SizedBox(height: 4),
        pw.Text(loc.formatGeneratedAt(data.generatedAt), style: _muted(fonts)),
        pw.SizedBox(height: 2),
        pw.Text(
          '${loc.periodLabel}: ${_rangeText(data, loc)}',
          style: _muted(fonts),
        ),
        pw.Divider(color: PdfColors.grey400, thickness: 0.5),
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
    if (range.startInclusive == null || range.endExclusive == null) {
      return label;
    }
    return '$label (${loc.formatDate(range.startInclusive!)} – '
        '${loc.formatDate(range.endExclusive!)})';
  }

  // ---- Body ------------------------------------------------------------------

  List<pw.Widget> _body({
    required ReportData data,
    required ReportLocalization loc,
    required ReportFonts fonts,
  }) {
    final widgets = <pw.Widget>[];
    var renderedAny = false;

    for (final section in data.configuration.orderedSections) {
      if (data.isEmptySection(section)) continue;
      if (renderedAny) {
        widgets.add(pw.SizedBox(height: 14));
      }
      widgets.add(_sectionHeader(loc.sectionTitles[section]!, fonts));
      switch (section) {
        case ReportSection.profile:
          widgets.add(_profileSection(data, loc, fonts));
        case ReportSection.medications:
          widgets.add(_medicationsSection(data, loc, fonts));
        case ReportSection.measurements:
          widgets.add(_measurementsSection(data, loc, fonts));
        case ReportSection.doctorVisits:
          widgets.add(_visitsSection(data, loc, fonts));
        case ReportSection.doctorPrescriptions:
          widgets.add(_prescriptionsSection(data, loc, fonts));
        case ReportSection.labAnalyses:
          widgets.add(_labAnalysesSection(data, loc, fonts));
        case ReportSection.diet:
          widgets.add(_dietSection(data, loc, fonts));
        case ReportSection.activities:
          widgets.add(_activitiesSection(data, loc, fonts));
      }
      renderedAny = true;
    }

    if (!renderedAny) {
      widgets.add(pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8),
        child: pw.Text(loc.emptyPeriodNote, style: _muted(fonts)),
      ));
    }
    return widgets;
  }

  pw.Widget _sectionHeader(String title, ReportFonts fonts) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(title, style: _sectionTitleStyle(fonts)),
    );
  }

  pw.Widget _keyValueTable(
    List<(String, String)> rows,
    ReportFonts fonts,
  ) {
    return pw.TableHelper.fromTextArray(
      cellAlignment: pw.Alignment.centerLeft,
      cellStyle: pw.TextStyle(font: fonts.regular, fontFallback: [
        fonts.georgianRegular
      ]),
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 2.5),
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.4),
      data: [
        for (final (label, value) in rows)
          [
            pw.Text(label,
                style: pw.TextStyle(
                    font: fonts.bold, fontFallback: [fonts.georgianBold])),
            pw.Text(value,
                style: pw.TextStyle(
                    font: fonts.regular,
                    fontFallback: [fonts.georgianRegular])),
          ],
      ],
    );
  }

  List<pw.Widget> _labeledLine(String label, String? value, ReportFonts fonts) {
    if (value == null || value.trim().isEmpty) return const [];
    return [
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 1),
        child: pw.RichText(
          text: pw.TextSpan(children: [
            pw.TextSpan(
                text: '$label: ',
                style: pw.TextStyle(
                    font: fonts.bold, fontFallback: [fonts.georgianBold])),
            pw.TextSpan(
                text: value,
                style: pw.TextStyle(
                    font: fonts.regular,
                    fontFallback: [fonts.georgianRegular])),
          ]),
        ),
      ),
    ];
  }

  // ---- Sections ----------------------------------------------------------------

  pw.Widget _profileSection(
    ReportData data,
    ReportLocalization loc,
    ReportFonts fonts,
  ) {
    final p = data.profileSummary!;
    final rows = <(String, String)>[
      (loc.birthDateLabel, p.birthDate == null ? '' : loc.formatDate(p.birthDate!)),
      (loc.genderLabel, loc.genderLabelFor(p.gender) ?? ''),
      if (p.bloodType != null) (loc.bloodTypeLabel, p.bloodType!),
      if (p.heightCm != null) (loc.heightLabel, _num(p.heightCm!)),
      if (p.weightKg != null) (loc.weightLabel, _num(p.weightKg!)),
      if (p.allergies != null) (loc.allergiesLabel, p.allergies!),
      if (p.emergencyContactName != null || p.emergencyContactPhone != null)
        (
          loc.emergencyContactLabel,
          [p.emergencyContactName, p.emergencyContactPhone]
              .whereType<String>()
              .where((s) => s.trim().isNotEmpty)
              .join(' · ')
        ),
    ].where((r) => r.$2.isNotEmpty).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(p.fullName,
            style: _subHeadingStyle(fonts).copyWith(fontSize: 12)),
        pw.SizedBox(height: 4),
        _keyValueTable(rows, fonts),
      ],
    );
  }

  pw.Widget _medicationsSection(
    ReportData data,
    ReportLocalization loc,
    ReportFonts fonts,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (final med in data.medications)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 5),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.RichText(
                  text: pw.TextSpan(children: [
                    pw.TextSpan(
                        text: med.name,
                        style: pw.TextStyle(
                            font: fonts.bold,
                            fontFallback: [fonts.georgianBold])),
                    if (med.doseAmount != null || med.doseUnit != null)
                      pw.TextSpan(
                          text:
                              ' — ${[med.doseAmount, med.doseUnit].whereType<String>().join(' ')}',
                          style: pw.TextStyle(
                              font: fonts.regular,
                              fontFallback: [fonts.georgianRegular])),
                  ]),
                ),
                if (med.scheduleSummary != null)
                  _bullet(med.scheduleSummary!, fonts),
                if (med.instructions != null)
                  _bullet(med.instructions!, fonts),
              ],
            ),
          ),
      ],
    );
  }

  pw.Widget _bullet(String text, ReportFonts fonts) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 8),
      child: pw.Text('• $text',
          style: pw.TextStyle(
              fontSize: 9.5,
              font: fonts.regular,
              fontFallback: [fonts.georgianRegular])),
    );
  }

  pw.Widget _measurementsSection(
    ReportData data,
    ReportLocalization loc,
    ReportFonts fonts,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (final type in data.measurements) ...[
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 2, bottom: 3),
            child: pw.Text(type.typeName, style: _subHeadingStyle(fonts)),
          ),
          _statsTable(type, loc, fonts),
          if (type.isTruncated)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Text(
                loc.showingLatest(type.includedReadingCount,
                    type.totalReadingCount),
                style: _muted(fonts),
              ),
            ),
          pw.SizedBox(height: 3),
          _readingsTable(type, loc, fonts),
          pw.SizedBox(height: 8),
        ],
      ],
    );
  }

  pw.Widget _statsTable(
    ReportMeasurementTypeData type,
    ReportLocalization loc,
    ReportFonts fonts,
  ) {
    return pw.TableHelper.fromTextArray(
      headerCount: 1,
      headers: [
        '',
        loc.readingsHeader,
        loc.statMin,
        loc.statMax,
        loc.statAvg,
      ],
      cellAlignment: pw.Alignment.centerLeft,
      headerStyle: pw.TextStyle(
          font: fonts.bold,
          fontFallback: [fonts.georgianBold],
          fontSize: 9,
          color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
      cellStyle: pw.TextStyle(
          fontSize: 9,
          font: fonts.regular,
          fontFallback: [fonts.georgianRegular]),
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.4),
      data: [
        for (final c in type.components)
          [
            c.label,
            '${c.count}',
            '${_num(c.minimum)} ${c.unit}',
            '${_num(c.maximum)} ${c.unit}',
            '${_num(c.average)} ${c.unit}',
          ],
      ],
    );
  }

  pw.Widget _readingsTable(
    ReportMeasurementTypeData type,
    ReportLocalization loc,
    ReportFonts fonts,
  ) {
    final componentHeaders = type.components.map((c) => c.label).toList();
    return pw.TableHelper.fromTextArray(
      headerCount: componentHeaders.isEmpty ? 0 : 1,
      headers: [loc.readingsHeader, ...componentHeaders],
      cellAlignment: pw.Alignment.centerLeft,
      headerStyle: pw.TextStyle(
          font: fonts.bold,
          fontFallback: [fonts.georgianBold],
          fontSize: 8.5,
          color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey500),
      cellStyle: pw.TextStyle(
          fontSize: 8.5,
          font: fonts.regular,
          fontFallback: [fonts.georgianRegular]),
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 1.5, horizontal: 4),
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.4),
      data: [
        for (final row in type.readings)
          [
            loc.formatDateTime(row.measuredAt),
            for (var i = 0; i < type.components.length; i++)
              if (i < row.values.length)
                '${_num(row.values[i].value)} ${row.values[i].unit}'
              else
                '—',
          ],
      ],
    );
  }

  pw.Widget _visitsSection(
    ReportData data,
    ReportLocalization loc,
    ReportFonts fonts,
  ) {
    return pw.TableHelper.fromTextArray(
      headerCount: 1,
      headers: [
        loc.reportDateLabel,
        loc.doctorLabel,
        loc.organizationLabel,
        loc.reportStatusLabel,
        loc.reasonLabel,
      ],
      cellAlignment: pw.Alignment.centerLeft,
      headerStyle: pw.TextStyle(
          font: fonts.bold,
          fontFallback: [fonts.georgianBold],
          fontSize: 9,
          color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
      cellStyle: pw.TextStyle(
          fontSize: 9,
          font: fonts.regular,
          fontFallback: [fonts.georgianRegular]),
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.4),
      data: [
        for (final v in data.doctorVisits)
          [
            loc.formatDateTime(v.scheduledAt),
            v.doctorName ?? '—',
            v.organizationName ?? '—',
            loc.visitStatusLabels[v.status] ?? v.status,
            v.reason ?? '—',
          ],
      ],
    );
  }

  pw.Widget _prescriptionsSection(
    ReportData data,
    ReportLocalization loc,
    ReportFonts fonts,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (final rx in data.doctorPrescriptions)
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 7),
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(rx.title, style: _subHeadingStyle(fonts)),
                ..._labeledLine(
                    loc.prescriptionDateLabel,
                    loc.formatDateTime(rx.prescriptionDate),
                    fonts),
                ..._labeledLine(loc.doctorLabel, rx.doctorName, fonts),
                ..._labeledLine(
                    loc.organizationLabel, rx.clinicName, fonts),
                ..._labeledLine(loc.reasonLabel, rx.reason, fonts),
                for (final med in rx.medications)
                  _bullet(_rxMedicationLine(med), fonts),
                ..._labeledLine(loc.notesLabel, rx.notes, fonts),
                if (rx.attachmentNames.isNotEmpty)
                  ..._labeledLine(
                      loc.attachmentsLabel(rx.attachmentNames.length),
                      rx.attachmentNames.join(', '),
                      fonts),
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

  pw.Widget _labAnalysesSection(
    ReportData data,
    ReportLocalization loc,
    ReportFonts fonts,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (final lab in data.labAnalyses)
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 7),
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(lab.title, style: _subHeadingStyle(fonts)),
                ..._labeledLine(
                    loc.analysisDateLabel,
                    loc.formatDateTime(lab.analysisDate),
                    fonts),
                if (lab.resultReceivedDate != null)
                  ..._labeledLine(loc.resultReceivedLabel,
                      loc.formatDateTime(lab.resultReceivedDate!), fonts),
                ..._labeledLine(
                    loc.laboratoryLabel, lab.laboratoryName, fonts),
                ..._labeledLine(
                    loc.orderingDoctorLabel, lab.orderingDoctorName, fonts),
                ..._labeledLine(loc.notesLabel, lab.notes, fonts),
                if (lab.attachmentNames.isNotEmpty)
                  ..._labeledLine(
                      loc.attachmentsLabel(lab.attachmentNames.length),
                      lab.attachmentNames.join(', '),
                      fonts),
              ],
            ),
          ),
      ],
    );
  }

  pw.Widget _dietSection(
    ReportData data,
    ReportLocalization loc,
    ReportFonts fonts,
  ) {
    final diet = data.diet!;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (diet.guidanceByCategory.isNotEmpty) ...[
          pw.Text(loc.dietGuidanceHeading, style: _subHeadingStyle(fonts)),
          pw.SizedBox(height: 2),
          for (final entry in diet.guidanceByCategory.entries) ...[
            pw.Text(
              loc.guidanceCategoryLabels[entry.key] ?? entry.key,
              style: pw.TextStyle(
                  font: fonts.bold,
                  fontFallback: [fonts.georgianBold],
                  fontSize: 9.5),
            ),
            for (final rule in entry.value)
              _bullet(
                rule.description == null
                    ? rule.title
                    : '${rule.title}${rule.source == null ? '' : ' (${rule.source})'} — ${rule.description}',
                fonts,
              ),
            pw.SizedBox(height: 3),
          ],
        ],
        if (diet.foodsByCategory.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(loc.dietFoodsHeading, style: _subHeadingStyle(fonts)),
          pw.SizedBox(height: 2),
          for (final entry in diet.foodsByCategory.entries) ...[
            pw.Text(
              loc.foodCategoryLabels[entry.key] ?? entry.key,
              style: pw.TextStyle(
                  font: fonts.bold,
                  fontFallback: [fonts.georgianBold],
                  fontSize: 9.5),
            ),
            for (final food in entry.value)
              _bullet(
                food.notes == null
                    ? food.name
                    : '${food.name} — ${food.notes}',
                fonts,
              ),
            pw.SizedBox(height: 3),
          ],
        ],
      ],
    );
  }

  pw.Widget _activitiesSection(
    ReportData data,
    ReportLocalization loc,
    ReportFonts fonts,
  ) {
    final stats = data.activityStats;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (stats != null) ...[
          pw.Text(
            loc.activitySummary(
                stats.sessionCount, stats.completedCount, stats.cancelledCount),
            style: pw.TextStyle(
                font: fonts.regular,
                fontFallback: [fonts.georgianRegular],
                fontSize: 10),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            '${loc.totalActiveTimeLabel}: ${loc.formatDuration(stats.totalActiveDuration)}',
            style: pw.TextStyle(
                font: fonts.bold,
                fontFallback: [fonts.georgianBold],
                fontSize: 10),
          ),
          pw.SizedBox(height: 6),
        ],
        pw.Text(loc.sessionHistoryHeading, style: _subHeadingStyle(fonts)),
        pw.SizedBox(height: 3),
        pw.TableHelper.fromTextArray(
          headerCount: 1,
          headers: [
            loc.reportDateLabel,
            loc.sectionTitles[ReportSection.activities],
            loc.durationLabel,
            loc.reportStatusLabel,
            loc.notesLabel,
          ],
          cellAlignment: pw.Alignment.centerLeft,
          headerStyle: pw.TextStyle(
              font: fonts.bold,
              fontFallback: [fonts.georgianBold],
              fontSize: 9,
              color: PdfColors.white),
          headerDecoration:
              const pw.BoxDecoration(color: PdfColors.blueGrey700),
          cellStyle: pw.TextStyle(
              fontSize: 9,
              font: fonts.regular,
              fontFallback: [fonts.georgianRegular]),
          cellPadding:
              const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.4),
          data: [
            for (final s in data.activitySessions)
              [
                loc.formatDateTime(s.startedAt),
                s.activityName,
                loc.formatDuration(s.activeDuration),
                loc.sessionStatusLabels[s.status] ?? s.status,
                s.notes ?? '—',
              ],
          ],
        ),
      ],
    );
  }

  // ---- Value formatting ----------------------------------------------------------

  /// Trims doubles for display: at most one decimal place, no trailing ".0".
  String _num(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    final s = value.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }
}
