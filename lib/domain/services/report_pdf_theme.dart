import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:rehab_track/domain/services/report_pdf_generator.dart';

/// Centralised styling for the Health Report PDF. Every visual constant lives
/// here so section renderers never scatter raw font sizes, paddings, or
/// colours. Instantiated once per document build from [ReportFonts].
class ReportPdfTheme {
  const ReportPdfTheme(this.fonts);

  final ReportFonts fonts;

  // ---- Page geometry --------------------------------------------------------

  static const PdfPageFormat pageFormat = PdfPageFormat.a4;

  /// ~10 mm on all sides. Left/right slightly wider for comfortable
  /// readability.
  static const pw.EdgeInsets pageMargin =
      pw.EdgeInsets.fromLTRB(28, 28, 28, 28);

  // ---- Colours --------------------------------------------------------------

  static const PdfColor primary = PdfColors.blueGrey800;
  static const PdfColor secondary = PdfColors.grey600;
  static const PdfColor muted = PdfColors.grey500;
  static const PdfColor divider = PdfColors.grey300;
  static const PdfColor tableHeaderBg = PdfColors.blueGrey700;
  static const PdfColor tableHeaderFg = PdfColors.white;
  static const PdfColor tableAltRow = PdfColors.grey100;

  // ---- Measurement status colours (PDF equivalents of app StatusColor) ------

  /// Matches ReadingStatusColor.forStatus() for inRange — green.
  static const PdfColor statusNormal = PdfColors.green800;

  /// Matches ReadingStatusColor.forStatus() for belowRange — blue.
  static const PdfColor statusLow = PdfColors.blue700;

  /// Matches ReadingStatusColor.forStatus() for aboveRange — red/error.
  static const PdfColor statusHigh = PdfColors.red700;

  /// Matches ReadingStatusColor.forStatus() for unknown — grey outline.
  static const PdfColor statusUnknown = PdfColors.grey500;

  // ---- Font sizes (pt) ------------------------------------------------------

  static const double reportTitle = 20;
  static const double patientName = 13;
  static const double sectionHeading = 12;
  static const double subsectionHeading = 10;
  static const double body = 9.5;
  static const double caption = 8;
  static const double tiny = 7;
  static const double footer = 7;

  // ---- Spacing (pt) ---------------------------------------------------------

  static const double sectionGap = 14;
  static const double subsectionGap = 6;
  static const double rowGap = 3;
  static const double cellPaddingV = 2.5;
  static const double cellPaddingH = 4;
  static const double headerDividerThickness = 0.6;

  // ---- Pre-built text styles ------------------------------------------------

  pw.TextStyle get reportTitleStyle => pw.TextStyle(
        font: fonts.bold,
        fontFallback: [fonts.georgianBold],
        fontSize: reportTitle,
        color: primary,
        lineSpacing: 0,
      );

  pw.TextStyle get patientNameStyle => pw.TextStyle(
        font: fonts.regular,
        fontFallback: [fonts.georgianRegular],
        fontSize: patientName,
        color: primary,
      );

  pw.TextStyle get metaStyle => pw.TextStyle(
        font: fonts.regular,
        fontFallback: [fonts.georgianRegular],
        fontSize: caption,
        color: secondary,
      );

  pw.TextStyle get sectionHeadingStyle => pw.TextStyle(
        font: fonts.bold,
        fontFallback: [fonts.georgianBold],
        fontSize: sectionHeading,
        color: primary,
      );

  pw.TextStyle get subsectionStyle => pw.TextStyle(
        font: fonts.bold,
        fontFallback: [fonts.georgianBold],
        fontSize: subsectionHeading,
        color: primary,
      );

  pw.TextStyle get bodyStyle => pw.TextStyle(
        font: fonts.regular,
        fontFallback: [fonts.georgianRegular],
        fontSize: body,
        color: PdfColors.black,
      );

  pw.TextStyle get bodyBoldStyle => pw.TextStyle(
        font: fonts.bold,
        fontFallback: [fonts.georgianBold],
        fontSize: body,
        color: PdfColors.black,
      );

  pw.TextStyle get captionStyle => pw.TextStyle(
        font: fonts.regular,
        fontFallback: [fonts.georgianRegular],
        fontSize: caption,
        color: secondary,
      );

  pw.TextStyle get captionBoldStyle => pw.TextStyle(
        font: fonts.bold,
        fontFallback: [fonts.georgianBold],
        fontSize: caption,
        color: secondary,
      );

  pw.TextStyle get tableHeaderStyle => pw.TextStyle(
        font: fonts.bold,
        fontFallback: [fonts.georgianBold],
        fontSize: caption,
        color: tableHeaderFg,
      );

  pw.TextStyle get tableCellStyle => pw.TextStyle(
        font: fonts.regular,
        fontFallback: [fonts.georgianRegular],
        fontSize: caption,
        color: PdfColors.black,
      );

  pw.TextStyle get tableCellBoldStyle => pw.TextStyle(
        font: fonts.bold,
        fontFallback: [fonts.georgianBold],
        fontSize: caption,
        color: PdfColors.black,
      );

  pw.TextStyle get footerStyle => pw.TextStyle(
        font: fonts.regular,
        fontFallback: [fonts.georgianRegular],
        fontSize: footer,
        color: muted,
      );

  // ---- Reusable table helpers -----------------------------------------------

  /// Subtle header decoration used by all summary and data tables.
  pw.BoxDecoration get tableHeaderDecoration =>
      const pw.BoxDecoration(color: tableHeaderBg);

  pw.BoxDecoration get tableAltRowDecoration =>
      const pw.BoxDecoration(color: tableAltRow);

  /// Vertical divider between two-column layouts.
  pw.Widget columnDivider() => pw.Container(
        width: 0.5,
        color: divider,
      );

  /// Standard section divider (horizontal rule).
  pw.Widget sectionDivider() => pw.Divider(
        color: divider,
        thickness: headerDividerThickness,
        height: sectionGap,
      );

  // ---- Table construction helpers -------------------------------------------

  /// Build a compact key/value table. Two label/value pairs per row when
  /// [twoColumn] is true, otherwise one per row.
  pw.Widget keyValueTable(
    List<(String label, String value)> rows, {
    bool twoColumn = false,
  }) {
    if (rows.isEmpty) return pw.SizedBox();
    if (!twoColumn) {
      return pw.Table(
        columnWidths: {0: const pw.FlexColumnWidth(1), 1: const pw.FlexColumnWidth(2)},
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          for (final (label, value) in rows)
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(right: 6, top: 2, bottom: 2),
                  child: pw.Text(label, style: captionBoldStyle),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
                  child: pw.Text(value, style: bodyStyle),
                ),
              ],
            ),
        ],
      );
    }
    // Two-column key/value layout: pairs of (label, value) side-by-side.
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
      children: [
        for (final (l1, v1, l2, v2) in pairs)
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.only(right: 6, top: 2, bottom: 2),
                child: pw.Text(l1, style: captionBoldStyle),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(right: 12, top: 2, bottom: 2),
                child: pw.Text(v1, style: bodyStyle),
              ),
              if (l2.isNotEmpty) ...[
                pw.Padding(
                  padding: const pw.EdgeInsets.only(right: 6, top: 2, bottom: 2),
                  child: pw.Text(l2, style: captionBoldStyle),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
                  child: pw.Text(v2, style: bodyStyle),
                ),
              ] else
                pw.SizedBox(),
              pw.SizedBox(),
            ],
          ),
      ],
    );
  }

  /// Professional data table with subtle header and optional row striping.
  pw.Widget dataTable({
    required List<String> headers,
    required List<List<String>> rows,
    bool stripeRows = false,
  }) {
    return pw.TableHelper.fromTextArray(
      headerCount: 1,
      headers: headers,
      cellAlignment: pw.Alignment.centerLeft,
      headerStyle: tableHeaderStyle,
      headerDecoration: tableHeaderDecoration,
      cellStyle: tableCellStyle,
      cellPadding:
          const pw.EdgeInsets.symmetric(vertical: cellPaddingV, horizontal: cellPaddingH),
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(color: divider, width: 0.3),
        top: pw.BorderSide(color: divider, width: 0.4),
        bottom: pw.BorderSide(color: divider, width: 0.4),
      ),
      rowDecoration: stripeRows ? tableAltRowDecoration : null,
      oddRowDecoration: null,
      data: rows,
    );
  }
}
