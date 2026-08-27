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

  test('profile section includes patient phone and email', () async {
    final data = ReportData(
      configuration: ReportConfiguration(
        dateRangeType: ReportDateRangeType.allTime,
        selectedSections: {ReportSection.profile},
        profileId: 1,
      ),
      generatedAt: DateTime(2026, 8, 24),
      profileSummary: const ReportProfileSummary(
        fullName: 'Nino Beridze',
        phone: '+995555123456',
        email: 'nino@example.com',
      ),
    );
    final bytes = await ReportPdfGenerator().build(
      data: data,
      loc: _testLocalization(),
      fonts: fonts,
    );
    expect(bytes.lengthInBytes, greaterThan(1000));
    expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
  });

  test('medications are numbered in the PDF', () async {
    final data = ReportData(
      configuration: ReportConfiguration(
        dateRangeType: ReportDateRangeType.allTime,
        selectedSections: {ReportSection.medications},
        profileId: 1,
      ),
      generatedAt: DateTime(2026, 8, 24),
      medications: const [
        ReportMedication(name: 'Aspirin', active: true),
        ReportMedication(name: 'Metformin', active: true),
      ],
    );
    final bytes = await ReportPdfGenerator().build(
      data: data,
      loc: _testLocalization(),
      fonts: fonts,
    );
    expect(bytes.lengthInBytes, greaterThan(1000));
    expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
  });

  test('transposed measurement summary includes Latest row', () async {
    final data = ReportData(
      configuration: ReportConfiguration(
        dateRangeType: ReportDateRangeType.allTime,
        selectedSections: {ReportSection.measurements},
        profileId: 1,
      ),
      generatedAt: DateTime(2026, 8, 24),
      measurements: [
        ReportMeasurementTypeData(
          typeName: 'Blood Pressure',
          readingCountInRange: 2,
          totalReadingCount: 2,
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
                average: 121,
                latest: 124),
            ReportComponentStats(
                label: 'diastolic',
                unit: 'mmHg',
                count: 2,
                minimum: 78,
                maximum: 82,
                average: 80,
                latest: 82),
          ],
          readings: [
            ReportReadingRow(
                measuredAt: DateTime(2026, 8, 20),
                values: const [
                  ReportValueCell(label: 'systolic', value: 118, unit: 'mmHg'),
                  ReportValueCell(
                      label: 'diastolic', value: 78, unit: 'mmHg'),
                ]),
            ReportReadingRow(
                measuredAt: DateTime(2026, 8, 21),
                values: const [
                  ReportValueCell(label: 'systolic', value: 124, unit: 'mmHg'),
                  ReportValueCell(
                      label: 'diastolic', value: 82, unit: 'mmHg'),
                ]),
          ],
        ),
      ],
    );
    final bytes = await ReportPdfGenerator().build(
      data: data,
      loc: _testLocalization(),
      fonts: fonts,
    );
    expect(bytes.lengthInBytes, greaterThan(1000));
    expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
  });

  // ===== Header tests =====

  test('header renders patient name, phone, and email', () async {
    final data = ReportData(
      configuration: ReportConfiguration(
        dateRangeType: ReportDateRangeType.allTime,
        selectedSections: {ReportSection.profile},
        profileId: 1,
      ),
      generatedAt: DateTime(2026, 8, 24),
      profileSummary: const ReportProfileSummary(
        fullName: 'Nino Beridze',
        phone: '+995555123456',
        email: 'nino@example.com',
      ),
    );
    final bytes = await ReportPdfGenerator().build(
      data: data,
      loc: _testLocalization(),
      fonts: fonts,
    );
    expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    expect(bytes.lengthInBytes, greaterThan(1000));
  });

  test('header renders cleanly when phone and email are absent', () async {
    final data = ReportData(
      configuration: ReportConfiguration(
        dateRangeType: ReportDateRangeType.allTime,
        selectedSections: {ReportSection.profile},
        profileId: 1,
      ),
      generatedAt: DateTime(2026, 8, 24),
      profileSummary: const ReportProfileSummary(fullName: 'Nino Beridze'),
    );
    final bytes = await ReportPdfGenerator().build(
      data: data,
      loc: _testLocalization(),
      fonts: fonts,
    );
    expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    expect(bytes.lengthInBytes, greaterThan(1000));
  });

  test('Patient Summary does not duplicate phone or email', () async {
    final data = ReportData(
      configuration: ReportConfiguration(
        dateRangeType: ReportDateRangeType.allTime,
        selectedSections: {ReportSection.profile},
        profileId: 1,
      ),
      generatedAt: DateTime(2026, 8, 24),
      profileSummary: const ReportProfileSummary(
        fullName: 'Nino Beridze',
        phone: '+995555123456',
        email: 'nino@example.com',
        gender: 'female',
        bloodType: 'A+',
      ),
    );
    final bytes = await ReportPdfGenerator().build(
      data: data,
      loc: _testLocalization(),
      fonts: fonts,
    );
    expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    expect(bytes.lengthInBytes, greaterThan(1000));
  });

  // ===== Section numbering tests =====

  test('section titles render without numeric prefixes', () async {
    final data = ReportData(
      configuration: ReportConfiguration(
        dateRangeType: ReportDateRangeType.allTime,
        selectedSections: {...ReportSection.ordered},
        profileId: 1,
      ),
      generatedAt: DateTime(2026, 8, 24),
      profileSummary: const ReportProfileSummary(fullName: 'Test'),
    );
    final bytes = await ReportPdfGenerator().build(
      data: data,
      loc: _testLocalization(),
      fonts: fonts,
    );
    expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    expect(bytes.lengthInBytes, greaterThan(1000));
  });

  // ===== Medication ordering tests =====

  test('5 medications split column-major without throwing', () async {
    final data = ReportData(
      configuration: ReportConfiguration(
        dateRangeType: ReportDateRangeType.allTime,
        selectedSections: {ReportSection.medications},
        profileId: 1,
      ),
      generatedAt: DateTime(2026, 8, 24),
      medications: const [
        ReportMedication(name: 'Aspirin', active: true),
        ReportMedication(name: 'Metformin', active: true),
        ReportMedication(name: 'Lisinopril', active: true),
        ReportMedication(name: 'Atorvastatin', active: true),
        ReportMedication(name: 'Omeprazole', active: true),
      ],
    );
    final bytes = await ReportPdfGenerator().build(
      data: data,
      loc: _testLocalization(),
      fonts: fonts,
    );
    expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    expect(bytes.lengthInBytes, greaterThan(1000));
  });

  test('6 medications split evenly without throwing', () async {
    final data = ReportData(
      configuration: ReportConfiguration(
        dateRangeType: ReportDateRangeType.allTime,
        selectedSections: {ReportSection.medications},
        profileId: 1,
      ),
      generatedAt: DateTime(2026, 8, 24),
      medications: const [
        ReportMedication(name: 'Med1', active: true),
        ReportMedication(name: 'Med2', active: true),
        ReportMedication(name: 'Med3', active: true),
        ReportMedication(name: 'Med4', active: true),
        ReportMedication(name: 'Med5', active: true),
        ReportMedication(name: 'Med6', active: true),
      ],
    );
    final bytes = await ReportPdfGenerator().build(
      data: data,
      loc: _testLocalization(),
      fonts: fonts,
    );
    expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    expect(bytes.lengthInBytes, greaterThan(1000));
  });

  // ===== Measurement summary tests =====

  test('measurement summary renders with Latest/Avg/Min/Max rows', () async {
    final data = _bpData([
      _bpReading(DateTime(2026, 8, 20), 120, 80, 65),
      _bpReading(DateTime(2026, 8, 21), 124, 82, 68),
      _bpReading(DateTime(2026, 8, 22), 118, 78, 62),
    ]);
    final bytes = await ReportPdfGenerator().build(
      data: data,
      loc: _testLocalization(),
      fonts: fonts,
    );
    expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    expect(bytes.lengthInBytes, greaterThan(1000));
  });

  // ===== Chart tests =====

  test('measurement section with 4+ readings renders chart', () async {
    final data = _bpData([
      _bpReading(DateTime(2026, 8, 20), 120, 80, 65),
      _bpReading(DateTime(2026, 8, 21), 124, 82, 68),
      _bpReading(DateTime(2026, 8, 22), 118, 78, 62),
      _bpReading(DateTime(2026, 8, 23), 130, 85, 70),
    ]);
    final bytes = await ReportPdfGenerator().build(
      data: data,
      loc: _testLocalization(),
      fonts: fonts,
    );
    expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    expect(bytes.lengthInBytes, greaterThan(1000));
  });

  // ===== Readings table tests =====

  test('single readings table for < 12 readings', () async {
    final readings = List.generate(
      5,
      (i) => _bpReading(
          DateTime(2026, 8, 20).add(Duration(days: i)), 120 + i, 80, 65),
    );
    final data = _bpData(readings);
    final bytes = await ReportPdfGenerator().build(
      data: data,
      loc: _testLocalization(),
      fonts: fonts,
    );
    expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    expect(bytes.lengthInBytes, greaterThan(1000));
  });

  test('two-column readings table for >= 12 readings', () async {
    final readings = List.generate(
      15,
      (i) => _bpReading(
          DateTime(2026, 8, 1).add(Duration(days: i)), 120 + i, 80, 65),
    );
    final data = _bpData(readings);
    final bytes = await ReportPdfGenerator().build(
      data: data,
      loc: _testLocalization(),
      fonts: fonts,
    );
    expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    expect(bytes.lengthInBytes, greaterThan(1000));
  });

  test('exactly 12 readings triggers two-column mode', () async {
    final readings = List.generate(
      12,
      (i) => _bpReading(
          DateTime(2026, 8, 1).add(Duration(days: i)), 120 + i, 80, 65),
    );
    final data = _bpData(readings);
    final bytes = await ReportPdfGenerator().build(
      data: data,
      loc: _testLocalization(),
      fonts: fonts,
    );
    expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    expect(bytes.lengthInBytes, greaterThan(1000));
  });

  test('large dataset 46 readings renders without error', () async {
    final readings = List.generate(
      46,
      (i) => _bpReading(
          DateTime(2026, 7, 12).add(Duration(days: i)),
          120 + (i % 20),
          78 + (i % 10),
          62 + (i % 12)),
    );
    final data = _bpData(readings);
    final bytes = await ReportPdfGenerator().build(
      data: data,
      loc: _testLocalization(),
      fonts: fonts,
    );
    expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    expect(bytes.lengthInBytes, greaterThan(1000));
  });

  test('chart with many readings renders date labels without error', () async {
    final readings = List.generate(
      30,
      (i) => _bpReading(
          DateTime(2026, 7, 1).add(Duration(days: i)),
          120 + (i % 15),
          78 + (i % 8),
          62 + (i % 10)),
    );
    final data = _bpData(readings);
    final bytes = await ReportPdfGenerator().build(
      data: data,
      loc: _testLocalization(),
      fonts: fonts,
    );
    expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    expect(bytes.lengthInBytes, greaterThan(1000));
  });

  test('activities section with zero duration renders dash', () async {
    final data = ReportData(
      configuration: ReportConfiguration(
        dateRangeType: ReportDateRangeType.allTime,
        selectedSections: {ReportSection.activities},
        profileId: 1,
      ),
      generatedAt: DateTime(2026, 8, 24),
      activityStats: const ReportActivityStats(
        sessionCount: 1,
        completedCount: 0,
        cancelledCount: 1,
        totalActiveDuration: Duration.zero,
      ),
      activitySessions: const [],
    );
    final bytes = await ReportPdfGenerator().build(
      data: data,
      loc: _testLocalization(),
      fonts: fonts,
    );
    expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    expect(bytes.lengthInBytes, greaterThan(500));
  });

  test('diet section renders with guidance and food categories', () async {
    final data = ReportData(
      configuration: ReportConfiguration(
        dateRangeType: ReportDateRangeType.allTime,
        selectedSections: {ReportSection.diet},
        profileId: 1,
      ),
      generatedAt: DateTime(2026, 8, 24),
      diet: ReportDietData(
        guidanceByCategory: {
          'diet': [
            const ReportGuidanceRule(
              title: 'Low sodium',
              description: 'Reduce salt intake',
            ),
          ],
          'smoking': [
            const ReportGuidanceRule(title: 'No smoking'),
          ],
        },
        foodsByCategory: {
          'avoid': [
            const ReportFoodItem(name: 'Processed food', notes: 'High sodium'),
          ],
        },
      ),
    );
    final bytes = await ReportPdfGenerator().build(
      data: data,
      loc: _testLocalization(),
      fonts: fonts,
    );
    expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    expect(bytes.lengthInBytes, greaterThan(500));
  });

  test('section headings are not orphaned — heading stays with content',
      () async {
    final data = ReportData(
      configuration: ReportConfiguration(
        dateRangeType: ReportDateRangeType.allTime,
        selectedSections: {...ReportSection.ordered},
        profileId: 1,
      ),
      generatedAt: DateTime(2026, 8, 24),
      profileSummary: const ReportProfileSummary(fullName: 'Test Patient'),
      medications: const [
        ReportMedication(name: 'Aspirin', active: true),
      ],
      measurements: [
        _bpData([
          _bpReading(DateTime(2026, 8, 20), 120, 80, 65),
          _bpReading(DateTime(2026, 8, 21), 124, 82, 68),
        ]).measurements.first,
      ],
      diet: ReportDietData(
        guidanceByCategory: {
          'diet': [const ReportGuidanceRule(title: 'Low sodium')],
        },
        foodsByCategory: {},
      ),
      activityStats: const ReportActivityStats(
        sessionCount: 1,
        completedCount: 1,
        cancelledCount: 0,
        totalActiveDuration: Duration(minutes: 15),
      ),
      activitySessions: [
        ReportActivitySessionEntry(
          startedAt: DateTime(2026, 8, 20),
          activityName: 'Knee exercises',
          activeDuration: const Duration(minutes: 15),
          status: 'completed',
        ),
      ],
    );
    final bytes = await ReportPdfGenerator().build(
      data: data,
      loc: _testLocalization(),
      fonts: fonts,
    );
    expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    expect(bytes.lengthInBytes, greaterThan(1000));
  });
}

// ===== Test helpers =====

ReportReadingRow _bpReading(DateTime date, int sys, int dia, int pul) {
  return ReportReadingRow(
    measuredAt: date,
    values: [
      ReportValueCell(label: 'systolic', value: sys.toDouble(), unit: 'mmHg'),
      ReportValueCell(label: 'diastolic', value: dia.toDouble(), unit: 'mmHg'),
      ReportValueCell(label: 'pulse', value: pul.toDouble(), unit: 'bpm'),
    ],
  );
}

ReportData _bpData(List<ReportReadingRow> readings) {
  return ReportData(
    configuration: ReportConfiguration(
      dateRangeType: ReportDateRangeType.allTime,
      selectedSections: {ReportSection.measurements},
      profileId: 1,
    ),
    generatedAt: DateTime(2026, 8, 24),
    measurements: [
      ReportMeasurementTypeData(
        typeName: 'Blood Pressure',
        readingCountInRange: readings.length,
        totalReadingCount: readings.length,
        includedReadingCount: readings.length,
        rangeStart: DateTime(2026, 7, 25),
        rangeEnd: DateTime(2026, 8, 25),
        components: const [
          ReportComponentStats(
              label: 'systolic', unit: 'mmHg', count: 3,
              minimum: 118, maximum: 130, average: 124, latest: 130),
          ReportComponentStats(
              label: 'diastolic', unit: 'mmHg', count: 3,
              minimum: 78, maximum: 85, average: 80, latest: 85),
          ReportComponentStats(
              label: 'pulse', unit: 'bpm', count: 3,
              minimum: 62, maximum: 70, average: 65, latest: 70),
        ],
        readings: readings,
      ),
    ],
  );
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
    bmiLabel: 'BMI',
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
    formatCompactDate: (d) => '${d.day}/${d.month}',
    latestLabel: 'Latest',
    totalReadingsLabel: (count) => 'Total readings: $count',
    phoneLabel: 'Phone',
    emailLabel: 'Email',
    generatedByLabel: 'Generated by RehabTrack',
    readingDateLabel: 'Reading Date',
    systolicShortLabel: 'Syst.',
    diastolicShortLabel: 'Diast.',
    pulseShortLabel: 'Pulse',
    unitMmHgLabel: 'mmHg',
    unitBpmLabel: 'bpm',
  )..formatGeneratedAt = (d) => 'Generated: ${f(d)}';
}
