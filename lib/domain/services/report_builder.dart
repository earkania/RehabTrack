import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/measurement_statistics.dart';
import 'package:rehab_track/domain/entities/schedule_config.dart';
import 'package:rehab_track/domain/repositories/activity_repository.dart';
import 'package:rehab_track/domain/repositories/care_contact_repository.dart';
import 'package:rehab_track/domain/repositories/diet_repository.dart';
import 'package:rehab_track/domain/repositories/doctor_prescription_repository.dart';
import 'package:rehab_track/domain/repositories/doctor_visit_repository.dart';
import 'package:rehab_track/domain/repositories/lab_analysis_repository.dart';
import 'package:rehab_track/domain/repositories/medication_repository.dart';
import 'package:rehab_track/domain/repositories/measurement_repository.dart';
import 'package:rehab_track/domain/repositories/profile_repository.dart';
import 'package:rehab_track/domain/repositories/reference_range_repository.dart';

import 'package:rehab_track/domain/entities/report_configuration.dart';
import 'package:rehab_track/domain/entities/report_data.dart';
import 'package:rehab_track/domain/entities/report_date_range.dart';
import 'package:rehab_track/domain/entities/report_section.dart';

/// Builds a fully prepared [ReportData] from existing module repositories.
///
/// Responsibilities:
/// - Validate the configuration and resolve the half-open date range.
/// - Read data ONLY through repository interfaces (never Drift directly).
/// - Prepare only the selected sections, keeping every section list in
///   canonical [ReportSection.order] semantics (newest-first rows).
/// - Keep values raw; localization/formatting happens at render time.
///
/// Inclusion rules (v1):
/// - Patient summary: NOT date-filtered (identity data).
/// - Medications: CURRENT ACTIVE medications only, regardless of period
///   (historical adherence inference is deliberately avoided).
/// - Measurements: readings with timestamp inside the range; per-component
///   descriptive statistics; newest-first rows capped at 200 per type with an
///   explicit truncation count carried on the model.
/// - Doctor visits: scheduledDateTime within the range (any status,
///   non-archived), newest first.
/// - Prescriptions / lab analyses: prescriptionDate / analysisDate within the
///   range via the repositories' date-filtered search queries (non-archived),
///   newest first. Attachment FILES are never embedded — display names only.
/// - Diet: current (active) guidance and food items, NOT date-filtered.
/// - Activities: finished sessions (completed/cancelled) started within the
///   range; running/paused sessions are never included. Newest first.
class ReportBuilder {
  ReportBuilder({
    required this._profileRepository,
    required this._medicationRepository,
    required this._measurementRepository,
    required this._doctorVisitRepository,
    required this._doctorPrescriptionRepository,
    required this._labAnalysisRepository,
    required this._dietRepository,
    required this._activityRepository,
    required this._careContactRepository,
    required this._referenceRangeRepository,
  });

  /// Maximum reading rows carried per measurement type; older readings are
  /// dropped but counted so renderers can disclose truncation.
  static const int maxReadingRowsPerType = 200;

  final ProfileRepository _profileRepository;
  final MedicationRepository _medicationRepository;
  final MeasurementRepository _measurementRepository;
  final DoctorVisitRepository _doctorVisitRepository;
  final DoctorPrescriptionRepository _doctorPrescriptionRepository;
  final LabAnalysisRepository _labAnalysisRepository;
  final DietRepository _dietRepository;
  final ActivityRepository _activityRepository;
  final CareContactRepository _careContactRepository;
  final ReferenceRangeRepository _referenceRangeRepository;

  Future<ReportData> build(
    ReportConfiguration configuration, {
    DateTime? now,
  }) async {
    if (!configuration.isValid) {
      throw ArgumentError.value(
        configuration,
        'configuration',
        'Report configuration is invalid',
      );
    }
    final generatedAt = now ?? DateTime.now();
    final range = ReportDateRangeResolver.resolve(
      configuration.dateRangeType,
      generatedAt,
      customStart: configuration.customStartDate,
      customEnd: configuration.customEndDate,
    );
    final profileId = configuration.profileId;
    final selected = configuration.selectedSections.toSet();

    final activityEntries = selected.contains(ReportSection.activities)
        ? await _buildActivityEntries(profileId, range)
        : const <ReportActivitySessionEntry>[];

    return ReportData(
      configuration: configuration,
      generatedAt: generatedAt,
      profileSummary: selected.contains(ReportSection.profile)
          ? await _buildProfileSummary(profileId)
          : null,
      medications: selected.contains(ReportSection.medications)
          ? await _buildMedications(profileId)
          : const [],
      measurements: selected.contains(ReportSection.measurements)
          ? await _buildMeasurements(profileId, range)
          : const [],
      doctorVisits: selected.contains(ReportSection.doctorVisits)
          ? await _buildDoctorVisits(profileId, range)
          : const [],
      doctorPrescriptions: selected.contains(ReportSection.doctorPrescriptions)
          ? await _buildPrescriptions(profileId, range)
          : const [],
      labAnalyses: selected.contains(ReportSection.labAnalyses)
          ? await _buildLabAnalyses(profileId, range)
          : const [],
      diet: selected.contains(ReportSection.diet)
          ? await _buildDiet(profileId)
          : null,
      activityStats: _computeActivityStats(activityEntries),
      activitySessions: activityEntries,
    );
  }

  // ---- Patient summary ------------------------------------------------------

  Future<ReportProfileSummary?> _buildProfileSummary(int profileId) async {
    final profile = await _profileRepository.getActiveProfile(profileId);
    if (profile == null) return null;
    return ReportProfileSummary(
      fullName: profile.fullName,
      birthDate: profile.birthDate,
      gender: profile.gender,
      bloodType: profile.bloodType,
      heightCm: profile.heightCm,
      weightKg: profile.weightKg,
      phone: profile.phone,
      email: profile.email,
      allergies: profile.allergies,
      emergencyContactName: profile.emergencyContactName,
      emergencyContactPhone: profile.emergencyContactPhone,
    );
  }

  // ---- Medications ----------------------------------------------------------

  Future<List<ReportMedication>> _buildMedications(int profileId) async {
    final medications =
        await _medicationRepository.getActiveMedications(profileId);
    final sorted = [...medications]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final result = <ReportMedication>[];
    for (final med in sorted) {
      var times = <String>[];
      String? instructions;
      final id = med.id;
      if (id != null) {
        final schedules =
            await _medicationRepository.getSchedulesForMedication(id);
        for (final schedule in schedules.where((s) => s.active)) {
          for (final t in ScheduleConfig.normalizeTimes(
              schedule.scheduleConfig.times)) {
            if (!times.contains(t)) times = [...times, t];
          }
          final trimmed = schedule.instructions?.trim() ?? '';
          if (instructions == null && trimmed.isNotEmpty) {
            instructions = trimmed;
          }
        }
      } else {
        times = const [];
      }
      result.add(ReportMedication(
        name: med.name,
        doseAmount: med.doseAmount?.trim().isEmpty ?? true
            ? null
            : med.doseAmount!.trim(),
        doseUnit: med.doseUnit?.trim().isEmpty ?? true
            ? null
            : med.doseUnit!.trim(),
        scheduleSummary: times.isEmpty ? null : times.join(', '),
        instructions: instructions,
        startDate: med.startDate,
        endDate: med.endDate,
        active: med.active,
      ));
    }
    return result;
  }

  // ---- Measurements ---------------------------------------------------------

  /// Canonical component order per measurement type, mirroring the chart
  /// builder: Blood Pressure is fixed to systolic/diastolic/pulse, other
  /// types follow their field display order.
  List<String> _canonicalFieldKeys(
    String? typeKey,
    List<MeasurementTypeField> fields,
  ) {
    if (typeKey == 'blood_pressure') {
      return ['systolic', 'diastolic', 'pulse'];
    }
    final sorted = [...fields]..sort(
        (a, b) => a.displayOrder.compareTo(b.displayOrder),
      );
    return sorted.map((f) => f.fieldKey).toList();
  }

  Future<List<ReportMeasurementTypeData>> _buildMeasurements(
    int profileId,
    ResolvedReportDateRange range,
  ) async {
    final types = await _measurementRepository.getMeasurementTypes(profileId);
    final activeTypes = types.where((t) => t.active).toList()
      ..sort((a, b) {
        final byOrder = a.displayOrder.compareTo(b.displayOrder);
        if (byOrder != 0) return byOrder;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    final result = <ReportMeasurementTypeData>[];
    for (final type in activeTypes) {
      final typeId = type.id;
      if (typeId == null) continue;

      // Drift stores timestamps with second precision; use the inclusive end
      // helper so the last second of the period is covered by `<= to` queries.
      final records = await _measurementRepository.getRecords(
        profileId,
        typeId: typeId,
        from: range.startInclusive,
        to: range.inclusiveQueryEnd,
        ascending: true,
      );
      if (records.isEmpty) continue;

      // Resolve effective measurement boundaries (profile overrides merged
      // with defaults) — same logic used by Measurement Trends.
      final typeKey = type.key;
      final effectiveRanges = typeKey != null
          ? await _referenceRangeRepository.getEffectiveRanges(
              profileId, typeKey)
          : null;

      final fields = await _measurementRepository.getFieldsForType(typeId);
      final fieldKeys = _canonicalFieldKeys(type.key, fields);
      final fieldByKey = {for (final f in fields) f.fieldKey: f};
      final valueMap = await _measurementRepository.getValuesForRecords(
        records.map((r) => r.id!).toList(),
      );

      // Collect values per canonical component. Records WITH stored component
      // values contribute through their matched fieldKey; legacy records with
      // no component rows fall back to the positional columns
      // (primary -> index 0, secondary -> 1, tertiary -> 2).
      double? valueFor(MeasurementRecord record, int index, String key) {
        final rowValues = valueMap[record.id!] ?? const [];
        if (rowValues.isNotEmpty) {
          for (final v in rowValues) {
            if (v.fieldKey == key) return v.numericValue;
          }
          return null;
        }
        return switch (index) {
          0 => record.valuePrimary,
          1 => record.valueSecondary,
          2 => record.valueTertiary,
          _ => null,
        };
      }

      String unitFor(int index, String key) =>
          fieldByKey[key]?.defaultUnit ?? type.unit;

      final presentKeys = <String>[];
      final componentValues = <String, List<double>>{};
      final componentUnits = <String, String>{};
      final componentLatest = <String, double>{};
      for (var i = 0; i < fieldKeys.length; i++) {
        final key = fieldKeys[i];
        final values = <double>[];
        for (final record in records) {
          final v = valueFor(record, i, key);
          if (v != null) values.add(v);
        }
        if (values.isEmpty) continue;
        presentKeys.add(key);
        componentValues[key] = values;
        componentUnits[key] = unitFor(i, key);
        // Derive latest from the most recent record with a value (records
        // are ascending, so scan in reverse).
        for (var ri = records.length - 1; ri >= 0; ri--) {
          final v = valueFor(records[ri], i, key);
          if (v != null) {
            componentLatest[key] = v;
            break;
          }
        }
      }

      final components = <ReportComponentStats>[];
      for (final key in presentKeys) {
        final stats = MeasurementStatistics.compute(componentValues[key]!);
        components.add(ReportComponentStats(
          label: fieldByKey[key]?.label ?? key,
          unit: componentUnits[key]!,
          count: stats.count,
          minimum: stats.minimum!,
          maximum: stats.maximum!,
          average: stats.average!,
          latest: componentLatest[key],
          fieldKey: key,
        ));
      }

      // Compact rows: newest first, capped at maxReadingRowsPerType.
      final included =
          records.reversed.take(maxReadingRowsPerType).toList();
      final readings = <ReportReadingRow>[];
      for (final record in included) {
        final cells = <ReportValueCell>[];
        for (var i = 0; i < presentKeys.length; i++) {
          final key = presentKeys[i];
          final v = valueFor(record, i, key);
          if (v != null) {
            cells.add(ReportValueCell(
              label: fieldByKey[key]?.label ?? key,
              value: v,
              unit: componentUnits[key]!,
            ));
          }
        }
        readings.add(ReportReadingRow(
          measuredAt: record.timestamp,
          values: cells,
        ));
      }

      result.add(ReportMeasurementTypeData(
        typeName: type.name,
        typeKey: type.key,
        effectiveRanges: effectiveRanges,
        readingCountInRange: records.length,
        totalReadingCount: records.length,
        includedReadingCount: included.length,
        rangeStart: range.startInclusive,
        rangeEnd: range.endExclusive,
        components: components,
        readings: readings,
      ));
    }
    return result;
  }

  // ---- Doctor visits --------------------------------------------------------

  Future<List<ReportDoctorVisitEntry>> _buildDoctorVisits(
    int profileId,
    ResolvedReportDateRange range,
  ) async {
    final start = range.startInclusive ?? DateTime(1970);
    final end = range.endExclusive ?? DateTime(2100);
    final visits = await _doctorVisitRepository.getVisitsBetween(
      profileId,
      start,
      end,
    );

    final result = <ReportDoctorVisitEntry>[];
    for (final visit in visits) {
      String? doctorName;
      String? organizationName;
      if (visit.doctorContactId != null) {
        final contact = await _careContactRepository.getContactById(
          profileId,
          visit.doctorContactId!,
        );
        doctorName = contact?.effectiveDisplayName;
      }
      if (visit.organizationContactId != null) {
        final contact = await _careContactRepository.getContactById(
          profileId,
          visit.organizationContactId!,
        );
        organizationName = contact?.effectiveDisplayName;
      }
      result.add(ReportDoctorVisitEntry(
        scheduledAt: visit.scheduledDateTime,
        doctorName: doctorName,
        organizationName: organizationName,
        status: visit.status.name,
        reason: visit.reason?.trim().isEmpty ?? true
            ? null
            : visit.reason!.trim(),
        notes:
            visit.notes?.trim().isEmpty ?? true ? null : visit.notes!.trim(),
      ));
    }
    return result;
  }

  // ---- Prescriptions ----------------------------------------------------------

  Future<List<ReportPrescriptionEntry>> _buildPrescriptions(
    int profileId,
    ResolvedReportDateRange range,
  ) async {
    final prescriptions = await _doctorPrescriptionRepository
        .searchPrescriptions(
          profileId,
          includeArchived: false,
          startDate: range.startInclusive,
          endDate: range.inclusiveQueryEnd,
        )
        .first;

    final result = <ReportPrescriptionEntry>[];
    for (final prescription in prescriptions) {
      final id = prescription.id!;
      final medications =
          await _doctorPrescriptionRepository.getMedications(id);
      final attachments =
          await _doctorPrescriptionRepository.getAttachments(id);

      String? doctorName;
      String? clinicName;
      if (prescription.doctorContactId != null) {
        final contact = await _careContactRepository.getContactById(
          profileId,
          prescription.doctorContactId!,
        );
        doctorName = contact?.effectiveDisplayName;
      }
      if (prescription.clinicContactId != null) {
        final contact = await _careContactRepository.getContactById(
          profileId,
          prescription.clinicContactId!,
        );
        clinicName = contact?.effectiveDisplayName;
      }

      result.add(ReportPrescriptionEntry(
        title: prescription.title,
        prescriptionDate: prescription.prescriptionDate,
        doctorName: doctorName,
        clinicName: clinicName,
        reason: prescription.reason?.trim().isEmpty ?? true
            ? null
            : prescription.reason!.trim(),
        notes: prescription.notes?.trim().isEmpty ?? true
            ? null
            : prescription.notes!.trim(),
        medications: medications
            .map((m) => ReportRxMedication(
                  name: m.medicationName,
                  doseAmount: m.doseAmount,
                  doseUnit: m.doseUnit,
                  instructions: m.instructions,
                  frequency: m.frequency,
                  timing: m.timing,
                  duration: m.duration,
                ))
            .toList(),
        attachmentNames: attachments.map((a) => a.displayName).toList(),
      ));
    }
    return result;
  }

  // ---- Lab analyses -------------------------------------------------------------

  Future<List<ReportLabAnalysisEntry>> _buildLabAnalyses(
    int profileId,
    ResolvedReportDateRange range,
  ) async {
    final analyses = await _labAnalysisRepository
        .searchAnalyses(
          profileId,
          includeArchived: false,
          startDate: range.startInclusive,
          endDate: range.inclusiveQueryEnd,
        )
        .first;

    final result = <ReportLabAnalysisEntry>[];
    for (final analysis in analyses) {
      String? laboratoryName;
      String? orderingDoctorName;
      if (analysis.laboratoryContactId != null) {
        final contact = await _careContactRepository.getContactById(
          profileId,
          analysis.laboratoryContactId!,
        );
        laboratoryName = contact?.effectiveDisplayName;
      }
      if (analysis.orderingDoctorContactId != null) {
        final contact = await _careContactRepository.getContactById(
          profileId,
          analysis.orderingDoctorContactId!,
        );
        orderingDoctorName = contact?.effectiveDisplayName;
      }
      final attachments =
          await _labAnalysisRepository.getAttachments(analysis.id!);

      result.add(ReportLabAnalysisEntry(
        title: analysis.title,
        category: analysis.category,
        analysisDate: analysis.analysisDate,
        resultReceivedDate: analysis.resultReceivedDate,
        laboratoryName: laboratoryName,
        orderingDoctorName: orderingDoctorName,
        notes: analysis.notes?.trim().isEmpty ?? true
            ? null
            : analysis.notes!.trim(),
        attachmentNames: attachments.map((a) => a.displayName).toList(),
      ));
    }
    return result;
  }

  // ---- Diet ---------------------------------------------------------------------

  /// Current guidance only — intentionally not filtered by the report period.
  Future<ReportDietData?> _buildDiet(int profileId) async {
    final rules = await _dietRepository.searchGuidanceRules(profileId).first;
    final foods = await _dietRepository.searchFoodItems(profileId).first;

    const guidanceOrder = [
      'diet',
      'smoking',
      'hydration',
      'caffeine',
      'alcohol',
      'other',
    ];
    const foodOrder = ['allowed', 'caution', 'avoid'];
    const knownCategories = {...guidanceOrder, ...foodOrder};

    final guidanceByCategory = <String, List<ReportGuidanceRule>>{};
    for (final rule in rules) {
      final category =
          knownCategories.contains(rule.category) ? rule.category : 'other';
      guidanceByCategory.putIfAbsent(category, () => []).add(
            ReportGuidanceRule(
              title: rule.title,
              description: rule.description?.trim().isEmpty ?? true
                  ? null
                  : rule.description!.trim(),
              source: rule.source,
            ),
          );
    }
    final orderedGuidance = <String, List<ReportGuidanceRule>>{
      for (final c in guidanceOrder)
        if (guidanceByCategory.containsKey(c)) c: guidanceByCategory[c]!,
    };

    final foodsByCategory = <String, List<ReportFoodItem>>{};
    for (final food in foods) {
      final category =
          knownCategories.contains(food.category) ? food.category : 'other';
      foodsByCategory.putIfAbsent(category, () => []).add(
            ReportFoodItem(
              name: food.name,
              foodGroup: food.foodGroup,
              notes: food.notes?.trim().isEmpty ?? true
                  ? null
                  : food.notes!.trim(),
            ),
          );
    }
    // Food categories outside allowed/caution/avoid collapse into 'caution'
    // is WRONG semantically; keep unknown ones under a trailing bucket keyed
    // 'other' instead (renderers localize it as "Other").
    final otherFoods = foodsByCategory.remove('other');
    final orderedFoods = <String, List<ReportFoodItem>>{
      for (final c in foodOrder)
        if (foodsByCategory.containsKey(c)) c: foodsByCategory[c]!,
      'other': ?otherFoods,
    };

    if (orderedGuidance.isEmpty && orderedFoods.isEmpty) return null;
    return ReportDietData(
      guidanceByCategory: orderedGuidance,
      foodsByCategory: orderedFoods,
    );
  }

  // ---- Activities -----------------------------------------------------------------

  Future<List<ReportActivitySessionEntry>> _buildActivityEntries(
    int profileId,
    ResolvedReportDateRange range,
  ) async {
    final start = range.startInclusive ?? DateTime(1970);
    final end = range.endExclusive ?? DateTime(2100);
    final sessions =
        await _activityRepository.getSessionsBetween(profileId, start, end);
    if (sessions.isEmpty) return const [];

    final activities =
        await _activityRepository.watchAllActivities(profileId).first;
    final names = <int, String>{
      for (final activity in activities)
        if (activity.id != null) activity.id!: activity.name,
    };

    return sessions.map((session) {
      return ReportActivitySessionEntry(
        startedAt: session.startedAt,
        activityName: names[session.activityId] ?? '',
        activeDuration: Duration(seconds: session.accumulatedSeconds),
        plannedDuration: session.plannedDurationSeconds == null
            ? null
            : Duration(seconds: session.plannedDurationSeconds!),
        status: session.status,
        notes: session.notes?.trim().isEmpty ?? true
            ? null
            : session.notes!.trim(),
      );
    }).toList();
  }

  ReportActivityStats? _computeActivityStats(
    List<ReportActivitySessionEntry> sessions,
  ) {
    if (sessions.isEmpty) return null;
    var completed = 0;
    var cancelled = 0;
    var totalActive = Duration.zero;
    for (final s in sessions) {
      switch (s.status) {
        case 'completed':
          completed++;
        case 'cancelled':
          cancelled++;
      }
      totalActive += s.activeDuration;
    }
    return ReportActivityStats(
      sessionCount: sessions.length,
      completedCount: completed,
      cancelledCount: cancelled,
      totalActiveDuration: totalActive,
    );
  }
}
