import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/domain/entities/default_reference_ranges.dart';
import 'package:rehab_track/domain/entities/profile_reference_range.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/domain/repositories/reference_range_repository.dart';

class ReferenceRangeRepositoryImpl implements ReferenceRangeRepository {
  final db.AppDatabase _database;

  ReferenceRangeRepositoryImpl(this._database);

  @override
  Future<MeasurementRanges?> getEffectiveRanges(
    int profileId,
    String typeKey,
  ) async {
    final profileRanges = await (_database.select(
          _database.profileReferenceRanges,
        )
          ..where((r) =>
              r.profileId.equals(profileId) & r.typeKey.equals(typeKey)))
        .get();

    final profileFieldRanges = <String, ReferenceRange>{};
    for (final row in profileRanges) {
      profileFieldRanges[row.fieldKey] = ReferenceRange(
        minValue: row.minValue,
        maxValue: row.maxValue,
      );
    }

    final defaults = DefaultReferenceRanges.rangesForType(typeKey);

    if (profileFieldRanges.isEmpty) {
      return defaults;
    }

    final baseFieldRanges =
        defaults?.fieldRanges ?? <String, ReferenceRange>{};

    final mergedFieldRanges = <String, ReferenceRange>{};
    final allFieldKeys = <String>{...baseFieldRanges.keys, ...profileFieldRanges.keys};

    for (final fieldKey in allFieldKeys) {
      final profileRange = profileFieldRanges[fieldKey];
      final defaultRange = baseFieldRanges[fieldKey];

      if (profileRange != null && profileRange.hasRange) {
        mergedFieldRanges[fieldKey] = profileRange;
      } else if (defaultRange != null) {
        mergedFieldRanges[fieldKey] = defaultRange;
      }
    }

    if (mergedFieldRanges.isEmpty) return null;
    return MeasurementRanges(fieldRanges: mergedFieldRanges);
  }

  @override
  Stream<List<ProfileReferenceRange>> watchProfileRanges(
    int profileId,
  ) {
    return (_database.select(_database.profileReferenceRanges)
          ..where((r) => r.profileId.equals(profileId))
          ..orderBy([
            (r) => OrderingTerm.asc(r.typeKey),
            (r) => OrderingTerm.asc(r.fieldKey),
          ]))
        .watch()
        .map((rows) => rows.map(_rowToDomain).toList());
  }

  @override
  Future<List<ProfileReferenceRange>> getProfileRanges(
    int profileId,
  ) async {
    final rows = await (_database.select(
          _database.profileReferenceRanges,
        )
          ..where((r) => r.profileId.equals(profileId))
          ..orderBy([
            (r) => OrderingTerm.asc(r.typeKey),
            (r) => OrderingTerm.asc(r.fieldKey),
          ]))
        .get();
    return rows.map(_rowToDomain).toList();
  }

  @override
  Future<void> saveProfileRange({
    required int profileId,
    required String typeKey,
    required String fieldKey,
    double? minValue,
    double? maxValue,
  }) async {
    final now = DateTime.now();

    final existing = await (_database.select(
          _database.profileReferenceRanges,
        )
          ..where((r) =>
              r.profileId.equals(profileId) &
              r.typeKey.equals(typeKey) &
              r.fieldKey.equals(fieldKey)))
        .getSingleOrNull();

    if (existing != null) {
      await (_database.update(_database.profileReferenceRanges)
            ..where((r) => r.id.equals(existing.id)))
          .write(
        db.ProfileReferenceRangesCompanion(
          minValue: Value(minValue),
          maxValue: Value(maxValue),
          updatedAt: Value(now),
        ),
      );
    } else {
      await _database
          .into(_database.profileReferenceRanges)
          .insert(
        db.ProfileReferenceRangesCompanion.insert(
          profileId: profileId,
          typeKey: typeKey,
          fieldKey: fieldKey,
          minValue: Value(minValue),
          maxValue: Value(maxValue),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  @override
  Future<void> removeProfileRange({
    required int profileId,
    required String typeKey,
    required String fieldKey,
  }) async {
    await (_database.delete(_database.profileReferenceRanges)
          ..where((r) =>
              r.profileId.equals(profileId) &
              r.typeKey.equals(typeKey) &
              r.fieldKey.equals(fieldKey)))
        .go();
  }

  @override
  Future<void> clearAllProfileRanges({
    required int profileId,
    required String typeKey,
  }) async {
    await (_database.delete(_database.profileReferenceRanges)
          ..where(
              (r) => r.profileId.equals(profileId) & r.typeKey.equals(typeKey)))
        .go();
  }

  ProfileReferenceRange _rowToDomain(db.ProfileReferenceRange row) {
    return ProfileReferenceRange(
      id: row.id,
      profileId: row.profileId,
      typeKey: row.typeKey,
      fieldKey: row.fieldKey,
      minValue: row.minValue,
      maxValue: row.maxValue,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
