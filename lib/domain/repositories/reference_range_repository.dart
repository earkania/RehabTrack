import 'package:rehab_track/domain/entities/profile_reference_range.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';

abstract class ReferenceRangeRepository {
  Future<MeasurementRanges?> getEffectiveRanges(
    int profileId,
    String typeKey,
  );

  Stream<List<ProfileReferenceRange>> watchProfileRanges(
    int profileId,
  );

  Future<List<ProfileReferenceRange>> getProfileRanges(
    int profileId,
  );

  Future<void> saveProfileRange({
    required int profileId,
    required String typeKey,
    required String fieldKey,
    double? minValue,
    double? maxValue,
  });

  Future<void> removeProfileRange({
    required int profileId,
    required String typeKey,
    required String fieldKey,
  });

  Future<void> clearAllProfileRanges({
    required int profileId,
    required String typeKey,
  });
}
