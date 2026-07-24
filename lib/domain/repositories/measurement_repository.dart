import 'package:rehab_track/domain/entities/measurement.dart';

abstract class MeasurementRepository {
  // --- MeasurementTypes ---
  Stream<List<MeasurementType>> watchActiveMeasurementTypes(
    int? profileId,
  );
  Stream<List<MeasurementType>> watchMeasurementTypes(
    int? profileId,
  );
  Future<List<MeasurementType>> getMeasurementTypes(
    int? profileId,
  );
  Future<MeasurementType?> getMeasurementType(int id);
  Future<MeasurementType?> getMeasurementTypeByKey(String key);
  Future<int> createMeasurementType(MeasurementType type);
  Future<void> updateMeasurementType(MeasurementType type);
  Future<void> deactivateMeasurementType(int id);

  // --- MeasurementTypeFields ---
  Stream<List<MeasurementTypeField>> watchFieldsForType(
    int measurementTypeId,
  );
  Future<List<MeasurementTypeField>> getFieldsForType(
    int measurementTypeId,
  );

  // --- MeasurementRecords ---
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
  Future<MeasurementRecord?> getRecord(int id);
  Future<int> createRecord(
    MeasurementRecord record,
    List<MeasurementRecordValue> values,
  );
  Future<void> updateRecord(
    MeasurementRecord record,
    List<MeasurementRecordValue> values,
  );
  Future<void> deleteRecord(int id);

  // --- MeasurementRecordValues ---
  Future<List<MeasurementRecordValue>> getValuesForRecord(
    int measurementRecordId,
  );

  // --- MeasurementSchedules ---
  Stream<List<MeasurementSchedule>> watchSchedules(int profileId);
  Future<int> createSchedule(MeasurementSchedule schedule);
  Future<void> updateSchedule(MeasurementSchedule schedule);
  Future<void> deleteSchedule(int id);
}
