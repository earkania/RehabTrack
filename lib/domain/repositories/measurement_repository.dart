import 'package:rehab_track/domain/entities/measurement.dart';

abstract class MeasurementRepository {
  Stream<List<MeasurementType>> watchMeasurementTypes(int? profileId);
  Future<List<MeasurementType>> getMeasurementTypes(int? profileId);
  Future<MeasurementType?> getMeasurementType(int id);
  Future<int> createMeasurementType(MeasurementType type);
  Future<void> updateMeasurementType(MeasurementType type);
  Future<void> deleteMeasurementType(int id);

  Stream<List<MeasurementRecord>> watchRecords(
    int profileId, {
    int? typeId,
    DateTime? from,
    DateTime? to,
  });
  Future<List<MeasurementRecord>> getRecords(
    int profileId, {
    int? typeId,
    DateTime? from,
    DateTime? to,
  });
  Future<int> createRecord(MeasurementRecord record);
  Future<void> deleteRecord(int id);

  Stream<List<MeasurementSchedule>> watchSchedules(int profileId);
  Future<int> createSchedule(MeasurementSchedule schedule);
  Future<void> updateSchedule(MeasurementSchedule schedule);
  Future<void> deleteSchedule(int id);
}
