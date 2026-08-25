import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/report_configuration.dart';
import 'package:rehab_track/domain/entities/report_date_range.dart';
import 'package:rehab_track/domain/entities/report_section.dart';

void main() {
  group('ReportDateRangeResolver', () {
    test('last7Days covers the previous 7 local days half-open', () {
      final now = DateTime(2026, 8, 24, 15, 30);
      final range = ReportDateRangeResolver.resolve(
        ReportDateRangeType.last7Days,
        now,
      );
      expect(range.startInclusive, DateTime(2026, 8, 18));
      expect(range.endExclusive, DateTime(2026, 8, 25));
      expect(range.unbounded, isFalse);
    });

    test('last90Days spans three calendar months back', () {
      final now = DateTime(2026, 8, 24, 1, 0);
      final range = ReportDateRangeResolver.resolve(
        ReportDateRangeType.last90Days,
        now,
      );
      expect(range.endExclusive!.isAfter(now), isTrue);
      expect(
        range.endExclusive!.difference(range.startInclusive!).inDays,
        inInclusiveRange(89, 91),
      );
    });

    test('last30Days starts at midnight 29 days before today', () {
      final now = DateTime(2026, 8, 24, 23, 59);
      final range = ReportDateRangeResolver.resolve(
        ReportDateRangeType.last30Days,
        now,
      );
      expect(range.startInclusive, DateTime(2026, 7, 26));
      expect(range.endExclusive, DateTime(2026, 8, 25));
    });

    test('allTime is unbounded', () {
      final range = ReportDateRangeResolver.resolve(
        ReportDateRangeType.allTime,
        DateTime(2026),
      );
      expect(range.startInclusive, isNull);
      expect(range.endExclusive, isNull);
      expect(range.unbounded, isTrue);
    });

    test('custom range is day-precise and inclusive of the end day', () {
      final range = ReportDateRangeResolver.resolve(
        ReportDateRangeType.custom,
        DateTime(2026, 8, 24),
        customStart: DateTime(2026, 8, 1),
        customEnd: DateTime(2026, 8, 10),
      );
      expect(range.startInclusive, DateTime(2026, 8, 1));
      expect(range.endExclusive, DateTime(2026, 8, 11));
    });

    test('inclusiveQueryEnd stays inside the half-open bound', () {
      final range = ResolvedReportDateRange(
        type: ReportDateRangeType.last30Days,
        startInclusive: DateTime(2026, 8, 1),
        endExclusive: DateTime(2026, 8, 11),
      );
      expect(
        range.inclusiveQueryEnd!.isBefore(range.endExclusive!),
        isTrue,
      );
      expect(
        range.endExclusive!.difference(range.inclusiveQueryEnd!) <
            const Duration(seconds: 2),
        isTrue,
      );
    });

    test('custom with missing bounds throws', () {
      expect(
        () => ReportDateRangeResolver.resolve(
          ReportDateRangeType.custom,
          DateTime(2026, 8, 24),
          customStart: null,
          customEnd: null,
        ),
        throwsArgumentError,
      );
    });
  });

  group('ReportConfiguration', () {
    test('defaults select every section and the default title', () {
      final config = ReportConfiguration(
        dateRangeType: ReportDateRangeType.last30Days,
        profileId: 1,
      );
      expect(config.selectedSections.length, ReportSection.values.length);
      expect(config.effectiveTitle, ReportConfiguration.defaultTitle);
      expect(config.isValid, isTrue);
      expect(config.orderedSections.first, ReportSection.profile);
      expect(config.orderedSections.last, ReportSection.activities);
    });

    test('empty title is invalid', () {
      final config = ReportConfiguration(
        title: '   ',
        dateRangeType: ReportDateRangeType.last30Days,
        profileId: 1,
      );
      expect(config.hasValidTitle, isFalse);
      expect(config.isValid, isFalse);
    });

    test('custom range requires both bounds in order', () {
      final base = (
        dateRangeType: ReportDateRangeType.custom,
        start: DateTime(2026, 8, 1),
        end: DateTime(2026, 8, 20),
      );
      expect(
        ReportConfiguration(
          dateRangeType: base.dateRangeType,
          customStartDate: base.start,
          customEndDate: base.end,
          profileId: 1,
        ).hasValidCustomRange,
        isTrue,
      );
      expect(
        ReportConfiguration(
          dateRangeType: base.dateRangeType,
          customStartDate: base.end,
          customEndDate: base.start,
          profileId: 1,
        ).hasValidCustomRange,
        isFalse,
      );
      expect(
        ReportConfiguration(
          dateRangeType: base.dateRangeType,
          profileId: 1,
        ).hasValidCustomRange,
        isFalse,
      );
    });

    test('no selected section is invalid', () {
      final config = ReportConfiguration(
        dateRangeType: ReportDateRangeType.last30Days,
        selectedSections: {},
        profileId: 1,
      );
      expect(config.hasSelectedSection, isFalse);
      expect(config.isValid, isFalse);
    });
  });
}
