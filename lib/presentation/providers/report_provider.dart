import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rehab_track/data/services/report/report_storage_service.dart';
import 'package:rehab_track/domain/services/report_builder.dart';
import 'package:rehab_track/domain/services/report_pdf_generator.dart';
import 'package:rehab_track/presentation/providers/activity_provider.dart'
    show activityRepositoryProvider;
import 'package:rehab_track/presentation/providers/database_provider.dart'
    show
        careContactRepositoryProvider,
        doctorVisitRepositoryProvider,
        medicationRepositoryProvider,
        measurementRepositoryProvider,
        profileRepositoryProvider;
import 'package:rehab_track/presentation/providers/diet_provider.dart'
    show dietRepositoryProvider;
import 'package:rehab_track/presentation/providers/doctor_prescription_provider.dart'
    show doctorPrescriptionRepositoryProvider;
import 'package:rehab_track/presentation/providers/lab_analysis_provider.dart'
    show labAnalysisRepositoryProvider;

/// Asynchronously loaded PDF fonts (Latin + Georgian fallback chains).
final reportPdfFontsProvider = FutureProvider<ReportFonts>((ref) async {
  Future<pw.Font> loadFont(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return pw.Font.ttf(data);
  }

  return ReportFonts(
    regular: await loadFont('assets/fonts/NotoSans-Regular.ttf'),
    bold: await loadFont('assets/fonts/NotoSans-Bold.ttf'),
    georgianRegular:
        await loadFont('assets/fonts/NotoSansGeorgian-Regular.ttf'),
    georgianBold: await loadFont('assets/fonts/NotoSansGeorgian-Bold.ttf'),
  );
});

/// Fully wired [ReportBuilder] over the existing module repositories.
final reportBuilderProvider = Provider<ReportBuilder>((ref) {
  return ReportBuilder(
    profileRepository: ref.watch(profileRepositoryProvider),
    medicationRepository: ref.watch(medicationRepositoryProvider),
    measurementRepository: ref.watch(measurementRepositoryProvider),
    doctorVisitRepository: ref.watch(doctorVisitRepositoryProvider),
    doctorPrescriptionRepository:
        ref.watch(doctorPrescriptionRepositoryProvider),
    labAnalysisRepository: ref.watch(labAnalysisRepositoryProvider),
    dietRepository: ref.watch(dietRepositoryProvider),
    activityRepository: ref.watch(activityRepositoryProvider),
    careContactRepository: ref.watch(careContactRepositoryProvider),
  );
});

/// Shared generator instance (stateless).
final reportPdfGeneratorProvider = Provider<ReportPdfGenerator>(
  (ref) => ReportPdfGenerator(),
);

/// Persists generated report PDFs to a user-accessible Downloads location and
/// opens/shares the saved file. Overridable in tests.
final reportStorageServiceProvider = Provider<ReportStorageService>(
  (ref) => ReportStorageService(),
);
