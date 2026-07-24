import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/data/repositories/reference_range_repository_impl.dart';
import 'package:rehab_track/domain/entities/default_reference_ranges.dart';
import 'package:rehab_track/domain/entities/profile_reference_range.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/domain/services/reading_status_calculator.dart';

void main() {
  late db.AppDatabase database;
  late ReferenceRangeRepositoryImpl repo;
  late int profileId;

  setUp(() async {
    database = db.AppDatabase.test();
    repo = ReferenceRangeRepositoryImpl(database);

    profileId = await database.into(database.profiles).insert(
      db.ProfilesCompanion.insert(
        firstName: 'Test',
        lastName: 'User',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  group('ProfileReferenceRange entity', () {
    test('copyWith preserves all fields', () {
      final range = ProfileReferenceRange(
        id: 1,
        profileId: 10,
        typeKey: 'blood_pressure',
        fieldKey: 'systolic',
        minValue: 90.0,
        maxValue: 120.0,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

      final copy = range.copyWith(minValue: 85.0);
      expect(copy.id, 1);
      expect(copy.profileId, 10);
      expect(copy.typeKey, 'blood_pressure');
      expect(copy.fieldKey, 'systolic');
      expect(copy.minValue, 85.0);
      expect(copy.maxValue, 120.0);
    });

    test('minValue and maxValue are nullable', () {
      final range = ProfileReferenceRange(
        id: 1,
        profileId: 1,
        typeKey: 'pulse',
        fieldKey: 'pulse',
        minValue: null,
        maxValue: null,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      expect(range.minValue, isNull);
      expect(range.maxValue, isNull);
    });

    test('copyWith clearMinValue and clearMaxValue work', () {
      final range = ProfileReferenceRange(
        id: 1,
        profileId: 1,
        typeKey: 'pulse',
        fieldKey: 'pulse',
        minValue: 60.0,
        maxValue: 100.0,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      final cleared = range.copyWith(clearMinValue: true, clearMaxValue: true);
      expect(cleared.minValue, isNull);
      expect(cleared.maxValue, isNull);
    });
  });

  group('ReferenceRangeRepositoryImpl', () {
    test('saveProfileRange creates new row', () async {
      await repo.saveProfileRange(
        profileId: profileId,
        typeKey: 'blood_pressure',
        fieldKey: 'systolic',
        minValue: 90.0,
        maxValue: 130.0,
      );

      final ranges = await repo.getProfileRanges(profileId);
      expect(ranges.length, 1);
      expect(ranges.first.typeKey, 'blood_pressure');
      expect(ranges.first.fieldKey, 'systolic');
      expect(ranges.first.minValue, 90.0);
      expect(ranges.first.maxValue, 130.0);
    });

    test('saveProfileRange updates existing row', () async {
      await repo.saveProfileRange(
        profileId: profileId,
        typeKey: 'blood_pressure',
        fieldKey: 'systolic',
        minValue: 90.0,
        maxValue: 130.0,
      );

      await repo.saveProfileRange(
        profileId: profileId,
        typeKey: 'blood_pressure',
        fieldKey: 'systolic',
        minValue: 85.0,
        maxValue: 125.0,
      );

      final ranges = await repo.getProfileRanges(profileId);
      expect(ranges.length, 1);
      expect(ranges.first.minValue, 85.0);
      expect(ranges.first.maxValue, 125.0);
    });

    test('saveProfileRange with null min/max creates row with null values',
        () async {
      await repo.saveProfileRange(
        profileId: profileId,
        typeKey: 'pulse',
        fieldKey: 'pulse',
        minValue: null,
        maxValue: 100.0,
      );

      final ranges = await repo.getProfileRanges(profileId);
      expect(ranges.length, 1);
      expect(ranges.first.minValue, isNull);
      expect(ranges.first.maxValue, 100.0);
    });

    test('removeProfileRange deletes specific row', () async {
      await repo.saveProfileRange(
        profileId: profileId,
        typeKey: 'blood_pressure',
        fieldKey: 'systolic',
        minValue: 90.0,
        maxValue: 130.0,
      );

      await repo.saveProfileRange(
        profileId: profileId,
        typeKey: 'blood_pressure',
        fieldKey: 'diastolic',
        minValue: 60.0,
        maxValue: 80.0,
      );

      await repo.removeProfileRange(
        profileId: profileId,
        typeKey: 'blood_pressure',
        fieldKey: 'systolic',
      );

      final ranges = await repo.getProfileRanges(profileId);
      expect(ranges.length, 1);
      expect(ranges.first.fieldKey, 'diastolic');
    });

    test('clearAllProfileRanges removes all rows for type', () async {
      await repo.saveProfileRange(
        profileId: profileId,
        typeKey: 'blood_pressure',
        fieldKey: 'systolic',
        minValue: 90.0,
        maxValue: 130.0,
      );

      await repo.saveProfileRange(
        profileId: profileId,
        typeKey: 'blood_pressure',
        fieldKey: 'diastolic',
        minValue: 60.0,
        maxValue: 80.0,
      );

      await repo.clearAllProfileRanges(
        profileId: profileId,
        typeKey: 'blood_pressure',
      );

      final ranges = await repo.getProfileRanges(profileId);
      expect(ranges.isEmpty, true);
    });

    test('getProfileRanges only returns rows for given profile', () async {
      final otherProfileId = await database.into(database.profiles).insert(
        db.ProfilesCompanion.insert(
          firstName: 'Other',
          lastName: 'User',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      );

      await repo.saveProfileRange(
        profileId: profileId,
        typeKey: 'pulse',
        fieldKey: 'pulse',
        minValue: 60.0,
        maxValue: 100.0,
      );

      await repo.saveProfileRange(
        profileId: otherProfileId,
        typeKey: 'pulse',
        fieldKey: 'pulse',
        minValue: 50.0,
        maxValue: 90.0,
      );

      final ranges = await repo.getProfileRanges(profileId);
      expect(ranges.length, 1);
      expect(ranges.first.minValue, 60.0);
    });

    group('getEffectiveRanges', () {
      test('returns defaults when no profile ranges exist', () async {
        final effective = await repo.getEffectiveRanges(profileId, 'pulse');
        final defaults = DefaultReferenceRanges.rangesForType('pulse');

        expect(effective, isNotNull);
        expect(defaults, isNotNull);
        expect(
          effective!.rangeForField('pulse')!.minValue,
          defaults!.rangeForField('pulse')!.minValue,
        );
      });

      test('profile range overrides default for same field', () async {
        await repo.saveProfileRange(
          profileId: profileId,
          typeKey: 'pulse',
          fieldKey: 'pulse',
          minValue: 55.0,
          maxValue: 95.0,
        );

        final effective = await repo.getEffectiveRanges(profileId, 'pulse');
        expect(effective, isNotNull);

        final pulseRange = effective!.rangeForField('pulse');
        expect(pulseRange, isNotNull);
        expect(pulseRange!.minValue, 55.0);
        expect(pulseRange.maxValue, 95.0);
      });

      test('profile range for new field is included alongside defaults',
          () async {
        await repo.saveProfileRange(
          profileId: profileId,
          typeKey: 'blood_pressure',
          fieldKey: 'pulse',
          minValue: 55.0,
          maxValue: 95.0,
        );

        final effective =
            await repo.getEffectiveRanges(profileId, 'blood_pressure');
        expect(effective, isNotNull);

        final sysRange = effective!.rangeForField('systolic');
        final diaRange = effective.rangeForField('diastolic');
        final pulseRange = effective.rangeForField('pulse');

        expect(sysRange, isNotNull);
        expect(diaRange, isNotNull);
        expect(pulseRange, isNotNull);

        // Profile overrides pulse
        expect(pulseRange!.minValue, 55.0);
        expect(pulseRange.maxValue, 95.0);

        // Defaults remain for systolic/diastolic
        final defaults =
            DefaultReferenceRanges.rangesForType('blood_pressure');
        expect(
          sysRange!.minValue,
          defaults!.rangeForField('systolic')!.minValue,
        );
      });

      test('returns null for unknown type with no profile ranges', () async {
        final effective =
            await repo.getEffectiveRanges(profileId, 'unknown_type');
        expect(effective, isNull);
      });
    });
  });

  group('ReadingStatusCalculator with custom ranges', () {
    test('aboveRange when value exceeds profile range', () {
      final ranges = MeasurementRanges(
        fieldRanges: {
          'pulse': ReferenceRange(minValue: 60.0, maxValue: 100.0),
        },
      );

      final status = ReadingStatusCalculator.calculate(
        typeKey: 'pulse',
        fieldValues: {'pulse': 110.0},
        ranges: ranges,
      );

      expect(status, ReadingStatus.aboveRange);
    });

    test('belowRange when value is below profile range', () {
      final ranges = MeasurementRanges(
        fieldRanges: {
          'pulse': ReferenceRange(minValue: 60.0, maxValue: 100.0),
        },
      );

      final status = ReadingStatusCalculator.calculate(
        typeKey: 'pulse',
        fieldValues: {'pulse': 50.0},
        ranges: ranges,
      );

      expect(status, ReadingStatus.belowRange);
    });

    test('inRange when value is within profile range', () {
      final ranges = MeasurementRanges(
        fieldRanges: {
          'pulse': ReferenceRange(minValue: 60.0, maxValue: 100.0),
        },
      );

      final status = ReadingStatusCalculator.calculate(
        typeKey: 'pulse',
        fieldValues: {'pulse': 75.0},
        ranges: ranges,
      );

      expect(status, ReadingStatus.inRange);
    });
  });
}
