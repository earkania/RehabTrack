import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rehab_track/domain/entities/report_configuration.dart';
import 'package:rehab_track/domain/entities/report_data.dart';
import 'package:rehab_track/domain/entities/report_date_range.dart';
import 'package:rehab_track/domain/entities/report_section.dart';
import 'package:rehab_track/domain/services/report_localization.dart';
import 'package:rehab_track/domain/services/report_pdf_generator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ReportFonts fonts;

  setUpAll(() async {
    Future<pw.Font> load(String path) async =>
        pw.Font.ttf(await rootBundle.load(path));
    fonts = ReportFonts(
      regular: await load('assets/fonts/NotoSans-Regular.ttf'),
      bold: await load('assets/fonts/NotoSans-Bold.ttf'),
      georgianRegular:
          await load('assets/fonts/NotoSansGeorgian-Regular.ttf'),
      georgianBold: await load('assets/fonts/NotoSansGeorgian-Bold.ttf'),
    );
  });


  ReportData sampleData({String title = 'Health Summary'}) {
    final configuration = ReportConfiguration(
      title: title,
      dateRangeType: ReportDateRangeType.last30Days,
      profileId: 1,
    );
    return ReportData(
      configuration: configuration,
      generatedAt: DateTime(2026, 8, 24, 12),
      profileSummary: const ReportProfileSummary(fullName: 'Nino Beridze'),
      activitySessions: [
        ReportActivitySessionEntry(
          startedAt: DateTime(2026, 8, 20, 8),
          activityName: 'Knee exercises',
          activeDuration: const Duration(minutes: 15),
          status: 'completed',
        ),
      ],
    );
  }

  test('generates valid PDF bytes with a sanitized default filename',
      () async {
    final bytes = await ReportPdfGenerator().build(
      data: sampleData(),
      loc: _testLocalization(),
      fonts: fonts,
    );

    expect(bytes.lengthInBytes, greaterThan(1000));
    expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    final name =
        ReportPdfGenerator().buildFileName(sampleData());
    expect(name, 'RehabTrack_Health_Summary_2026-08-24.pdf');
  });

  test('non-ASCII titles collapse to Report in the filename', () {
    final generator = ReportPdfGenerator();
    final name =
        generator.buildFileName(sampleData(title: 'ჯანმრთელობის მიმოხილვა'));
    expect(name, 'RehabTrack_Report_2026-08-24.pdf');
    final mixed =
        generator.buildFileName(sampleData(title: 'Cardio Follow Up'));
    expect(mixed, 'RehabTrack_Cardio_Follow_Up_2026-08-24.pdf');
  });

  test('renders every selected section without throwing', () async {
    final data = sampleData();
    // Force every section on; empty ones are skipped by design.
    final fullConfig = ReportConfiguration(
      dateRangeType: ReportDateRangeType.last30Days,
      selectedSections: {...ReportSection.ordered},
      profileId: 1,
    );
    final full = ReportData(
      configuration: fullConfig,
      generatedAt: data.generatedAt,
      profileSummary: data.profileSummary,
      medications: [
        const ReportMedication(
            name: 'Aspirin', scheduleSummary: '09:00', active: true),
      ],
      measurements: [
        ReportMeasurementTypeData(
          typeName: 'Blood Pressure',
          readingCountInRange: 2,
          totalReadingCount: 3,
          includedReadingCount: 2,
          rangeStart: DateTime(2026, 7, 25),
          rangeEnd: DateTime(2026, 8, 25),
          components: const [
            ReportComponentStats(
                label: 'systolic',
                unit: 'mmHg',
                count: 2,
                minimum: 118,
                maximum: 124,
                average: 121),
          ],
          readings: [
            ReportReadingRow(measuredAt: DateTime(2026, 8, 20), values: const [
              ReportValueCell(label: 'systolic', value: 120, unit: 'mmHg'),
            ]),
            ReportReadingRow(measuredAt: DateTime(2026, 8, 21), values: const [
              ReportValueCell(label: 'systolic', value: 122, unit: 'mmHg'),
            ]),
          ],
        ),
      ],
      doctorVisits: [
        ReportDoctorVisitEntry(
          scheduledAt: DateTime(2026, 8, 20),
          doctorName: 'Dr. Smith',
          status: 'completed',
        ),
      ],
      doctorPrescriptions: [
        ReportPrescriptionEntry(
          title: 'Rx',
          prescriptionDate: DateTime(2026, 8, 20),
          medications: const [],
          attachmentNames: const ['scan.pdf'],
        ),
      ],
      labAnalyses: [
        ReportLabAnalysisEntry(
          title: 'Blood Panel',
          category: 'laboratory',
          analysisDate: DateTime(2026, 8, 20),
        ),
      ],
      diet: ReportDietData(
        guidanceByCategory: {
          'smoking': [const ReportGuidanceRule(title: 'No smoking')],
        },
        foodsByCategory: {},
      ),
      activityStats: ReportActivityStats(
        sessionCount: 1,
        completedCount: 1,
        cancelledCount: 0,
        totalActiveDuration: const Duration(minutes: 15),
      ),
      activitySessions: data.activitySessions,
    );
    // The all-section document must contain the truncation note path and
    // every section renderer without throwing.
    final Uint8List bytes = await ReportPdfGenerator().build(
      data: full,
      loc: _testLocalization(),
      fonts: fonts,
    );
    expect(bytes.lengthInBytes, greaterThan(1000));
  });
}

/// Minimal English label bundle so the pure-dart generator can run without
/// Flutter localizations.
ReportLocalization _testLocalization() {
  String f(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
  return ReportLocalization(
    defaultTitle: 'Health Summary',
    sectionTitles: {
      for (final s in ReportSection.values) s: s.name,
    },
    rangeLabels: {
      ReportDateRangeType.last7Days: 'Last 7 days',
      ReportDateRangeType.last30Days: 'Last 30 days',
      ReportDateRangeType.last90Days: 'Last 3 months',
      ReportDateRangeType.allTime: 'All time',
      ReportDateRangeType.custom: 'Custom range',
    },
    periodLabel: 'Period',
    reportDateLabel: 'Date',
    reportStatusLabel: 'Status',
    birthDateLabel: 'Birth Date',
    genderLabel: 'Gender',
    maleLabel: 'Male',
    femaleLabel: 'Female',
    genderOtherLabel: 'Other',
    bloodTypeLabel: 'Blood Type',
    heightLabel: 'Height',
    weightLabel: 'Weight',
    allergiesLabel: 'Allergies',
    emergencyContactLabel: 'Emergency Contact',
    statMin: 'Min',
    statMax: 'Max',
    statAvg: 'Avg',
    readingsHeader: 'Readings',
    showingLatest: (included, total) => 'Showing latest \$included of \$total',
    emptyPeriodNote: 'Nothing recorded.',
    attachmentsLabel: (count) => 'Attachments (\$count)',
    notesLabel: 'Notes',
    instructionsLabel: 'Instructions',
    sourceLabel: 'Source',
    frequencyLabel: 'Frequency',
    timingLabel: 'Timing',
    durationLabel: 'Duration',
    foodGroupLabel: 'Food Group',
    doctorLabel: 'Doctor',
    organizationLabel: 'Organization',
    reasonLabel: 'Reason',
    prescriptionDateLabel: 'Prescription Date',
    analysisDateLabel: 'Analysis Date',
    resultReceivedLabel: 'Result Received',
    laboratoryLabel: 'Laboratory',
    orderingDoctorLabel: 'Ordering Doctor',
    visitStatusLabels: const {
      'scheduled': 'Scheduled',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
      'missed': 'Missed',
    },
    sessionStatusLabels: const {
      'completed': 'Completed',
      'cancelled': 'Cancelled',
    },
    guidanceCategoryLabels: const {
      'diet': 'Diet',
      'smoking': 'Smoking',
      'hydration': 'Hydration',
      'caffeine': 'Caffeine',
      'alcohol': 'Alcohol',
      'other': 'Other',
    },
    foodCategoryLabels: const {
      'allowed': 'Allowed',
      'caution': 'Caution',
      'avoid': 'Avoid',
      'other': 'Other',
    },
    dietFoodsHeading: 'Foods',
    dietGuidanceHeading: 'General Guidance',
    activitySummary: (count, completed, cancelled) =>
        '\$count sessions',
    totalActiveTimeLabel: 'Total active time',
    sessionHistoryHeading: 'Session History',
    formatDate: f,
    formatDateTime: (d) => '${f(d)} 10:00',
    formatDuration: (d) => '${d.inMinutes}m',
  )..formatGeneratedAt = (d) => 'Generated: \${f(d)}';
}
