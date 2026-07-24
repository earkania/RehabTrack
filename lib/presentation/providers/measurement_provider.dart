import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/domain/entities/measurement.dart';
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
