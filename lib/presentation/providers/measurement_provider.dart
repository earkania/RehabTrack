import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
import 'package:rehab_track/domain/entities/measurement_chart.dart';
import 'package:rehab_track/domain/entities/measurement_data_point.dart';
import 'package:rehab_track/domain/entities/measurement_period.dart';
import 'package:rehab_track/domain/entities/measurement_statistics.dart';
import 'package:rehab_track/domain/entities/reading_status_summary.dart';
import 'package:rehab_track/domain/services/measurement_chart_builder.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';

final activeMeasurementTypesProvider =
    StreamProvider.autoDispose<List<MeasurementType>>((ref) {
  final profileId = ref.watch(activeProfileIdProvider);
  final repo = ref.watch(measurementRepositoryProvider);
  return repo.watchActiveMeasurementTypes(profileId);
});

final measurementTypeProvider =
    FutureProvider.autoDispose.family<MeasurementType?, int>(
      (ref, id) async {
        final repo = ref.watch(measurementRepositoryProvider);
        return repo.getMeasurementType(id);
      },
    );

final measurementTypeByKeyProvider =
    FutureProvider.autoDispose.family<MeasurementType?, String>(
      (ref, key) async {
        final repo = ref.watch(measurementRepositoryProvider);
        return repo.getMeasurementTypeByKey(key);
      },
    );

final measurementTypeFieldsProvider =
    StreamProvider.autoDispose.family<List<MeasurementTypeField>, int>(
      (ref, typeId) {
        final repo = ref.watch(measurementRepositoryProvider);
        return repo.watchFieldsForType(typeId);
      },
    );

final measurementRecordsProvider = StreamProvider.autoDispose
    .family<List<MeasurementRecord>, ({int typeId, DateTime? from, DateTime? to})>(
      (ref, params) {
        final profileId = ref.watch(activeProfileIdProvider);
        if (profileId == null) {
          return const Stream.empty();
        }
        final repo = ref.watch(measurementRepositoryProvider);
        return repo.watchRecords(
          profileId,
          typeId: params.typeId,
          from: params.from,
          to: params.to,
        );
      },
    );

final measurementRecordProvider =
    FutureProvider.autoDispose.family<MeasurementRecord?, int>(
      (ref, id) async {
        final repo = ref.watch(measurementRepositoryProvider);
        return repo.getRecord(id);
      },
    );

final measurementRecordValuesProvider =
    FutureProvider.autoDispose.family<List<MeasurementRecordValue>, int>(
      (ref, recordId) async {
        final repo = ref.watch(measurementRepositoryProvider);
        return repo.getValuesForRecord(recordId);
      },
    );

// --- Trend / Chart providers ---

typedef TrendParams = ({int measurementTypeId, MeasurementPeriod period});

class TrendData {
  final List<MeasurementDataPoint> dataPoints;
  final List<MeasurementChartSeries> chartSeries;
  final Map<String, MeasurementStatistics> fieldStatistics;
  final ReadingStatusSummary statusSummary;

  const TrendData({
    required this.dataPoints,
    required this.chartSeries,
    required this.fieldStatistics,
    required this.statusSummary,
  });

  static const empty = TrendData(
    dataPoints: [],
    chartSeries: [],
    fieldStatistics: {},
    statusSummary: ReadingStatusSummary.empty,
  );
}

final trendDataProvider =
    FutureProvider.autoDispose.family<TrendData, TrendParams>(
      (ref, params) async {
        final profileId = ref.watch(activeProfileIdProvider);
        if (profileId == null) return TrendData.empty;

        final repo = ref.watch(measurementRepositoryProvider);
        final period = params.period;

        final records = await repo.getRecords(
          profileId,
          typeId: params.measurementTypeId,
          from: period.from,
          ascending: true,
        );

        if (records.isEmpty) return TrendData.empty;

        final recordIds = records.map((r) => r.id!).toList();
        final allValues = await repo.getValuesForRecords(recordIds);

        final dataPoints = records
            .map(
              (r) => MeasurementDataPoint(
                record: r,
                values: allValues[r.id!] ?? [],
              ),
            )
            .toList();

        final type = await repo.getMeasurementType(
          params.measurementTypeId,
        );
        if (type == null) return TrendData.empty;

        final fields = await repo.getFieldsForType(
          params.measurementTypeId,
        );

        final typeKey = type.key ?? '';
        final rangesRepo = ref.read(referenceRangeRepositoryProvider);
        final ranges = await rangesRepo.getEffectiveRanges(
          profileId,
          typeKey,
        );

        final chartSeries = MeasurementChartBuilder.buildSeries(
          typeKey: typeKey,
          dataPoints: dataPoints,
          fields: fields,
          ranges: ranges,
        );

        final fieldStatistics =
            MeasurementChartBuilder.computeFieldStatistics(
          series: chartSeries,
        );

        final statusSummary =
            MeasurementChartBuilder.computeStatusSummary(
          series: chartSeries,
        );

        return TrendData(
          dataPoints: dataPoints,
          chartSeries: chartSeries,
          fieldStatistics: fieldStatistics,
          statusSummary: statusSummary,
        );
      },
    );

final trendTypeProvider =
    FutureProvider.autoDispose.family<MeasurementType?, int>(
      (ref, typeId) async {
        final repo = ref.watch(measurementRepositoryProvider);
        return repo.getMeasurementType(typeId);
      },
    );
